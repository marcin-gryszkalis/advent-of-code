#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use POSIX qw/ceil floor/;

use threads;
use Thread::Queue;

### intcode ######################################
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

open(my $dbgf,">intcode-debug.txt") or die $!;
sub mem
{
	my ($p,$rb,$i,$m,$v) = @_;

	if (defined $v)
	{
		if ($m == 0) { $p->[$p->[$i]] = $v }
		elsif ($m == 1) { $p->[$i] = $v } # makes no sense
		elsif ($m == 2) { $p->[$p->[$i] + $rb] = $v; }
		else { die "invalid mode ($m)"; }
	}

	if ($m == 0) { return $p->[$p->[$i]] // 0 }
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return $p->[$p->[$i] + $rb] // 0 }
	else { die "invalid mode ($m)"; }
}

sub dbg
{
	my ($p,$rb,$i,$m) = @_;

	if ($m == 0) { return "@".($p->[$i] // 0)." [=".($p->[$p->[$i]] // 0)."]"}
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return "@".($p->[$i] // 0).($rb<0?$rb:"+$rb")." [=".($p->[$p->[$i] + $rb]//0)."]" }
	else { die "invalid mode ($m)"; }
}

sub dbghdr
{
	my ($me,$p,$i,$l) = @_;
	my @pp = @$p[$i..$i+$l];
	return sprintf "[$me:$i] %-20s |", join(",",@pp);
}

sub intcode
{
	my $me = shift;

	my $qin = shift;
	my $qout = shift;

	my $progsrc = shift;
	my @p = @$progsrc;
	my $p = \@p;

	my $i = 0;

	my $rb = 0;

	print $dbgf "[$me:0] START\n";
	while (1)
	{
		die unless defined $p[$i];

		my $r = reverse $p[$i];
		$r =~ m/^(\d)(\d)?(\d)?(\d)?(\d)?/;
		my $op = $1;
		my $opb = $2;
		my $m1 = $3 // 0; # 0 - ptr, 1 - immed. 2 - rel-base
		my $m2 = $4 // 0;
		my $m3 = $5 // 0;

		if ($op == 9 && defined $opb && $opb == 9)
		{
			print $dbgf dbghdr($me,$p,$i,0)." halt\n";
			return; # end of thread!
		}
		elsif ($op == 1) # add
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) + mem($p,$rb,$i+2,$m2));
			print $dbgf dbghdr($me,$p,$i,3)." add ".dbg($p,$rb,$i+1,$m1)." + ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 2) # mul
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) * mem($p,$rb,$i+2,$m2));
			print $dbgf dbghdr($me,$p,$i,3)." mul ".dbg($p,$rb,$i+1,$m1)." * ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 3) # in
		{
			my $x = $qin->dequeue(); # blocking
			if (!defined $x)
			{
				print "no input available";
				exit 1;
			}
			print $dbgf "### IN($x)\n";

			mem($p,$rb,$i+1,$m1,$x);
			print $dbgf dbghdr($me,$p,$i,1)." inp -> ".dbg($p,$rb,$i+1,$m1)."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print $dbgf dbghdr($me,$p,$i,1)." out ".dbg($p,$rb,$i+1,$m1)."\n";
			my $output = mem($p,$rb,$i+1,$m1);
			print $dbgf "### OUT($output)\n";

			$qout->enqueue($output);
			$i += 2
		}
		elsif ($op == 5) # jnz
		{
			print $dbgf dbghdr($me,$p,$i,2)." jnz ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) != 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 6) # jz
		{
			print $dbgf dbghdr($me,$p,$i,2)." jz  ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) == 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 7) # lt
		{
			print $dbgf dbghdr($me,$p,$i,3)." lt  ".dbg($p,$rb,$i+1,$m1)." < ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) < mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 8) # eq
		{
			print $dbgf dbghdr($me,$p,$i,3)." eq  ".dbg($p,$rb,$i+1,$m1)." == ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) == mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 9) # arb
		{
			$rb += mem($p,$rb,$i+1,$m1);
			print $dbgf dbghdr($me,$p,$i,2)." arb by ".dbg($p,$rb,$i+1,$m1)." rb:$rb\n";
			$i += 2;
		}
		else
		{
			print $dbgf dbghdr($me,$p,$i,1)." err invalid opcode: $op\n";
			exit 1;
		}

	}

}

### main #######################################

open(my $f, "d19.txt") or die $!;
my @pzero = split(/,/, <$f>);

my %mmap =
(
	0 => '.',
	1 => '#',
);

my $basesize = 50;
my $sx = $basesize; # size
my $sy = $basesize;

my @zm = ( map { [(0) x ($basesize)] } (0..($basesize))  );
my $m = \@zm; # map
# my @zv = ( map { [(0) x ($basesize)] } (0..($basesize))  );
# my $v = \@zv; # visited

my $i = 0; # 1 robot

my $x = 0;
my $y = 0;

my $c = 0;

sub check
{
	my ($x,$y) = @_;

	my @p = @pzero;
	my $thalive = 1;
	$tqin[$i] = Thread::Queue->new();
	$tqout[$i] = Thread::Queue->new();
	$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@p));

	$tqin[$i]->enqueue($x);
	$tqin[$i]->enqueue($y);
	my $e = $tqout[$i]->dequeue();
	# while (!$thread[$i]->is_joinable())
	# {
		$thread[$i]->join();
		$thalive--;
	# }
	return $e;
}


# part 1
for my $x (0..$sx-1)
{
	# estimated by close look ;)
	my $l = 0.44 * $x; # low
	my $h = 0.62 * $x; # high

	my $rh = -1; # real
	my $rl = -1;

	for my $y ($l..$h)
	{
		my $e = check($x, $y);
		$c++ if $e;

		$rl = $y if $e && $rl == -1;
		$rh = $y if $e;

		$m->[$x]->[$y] = $e;
	}
}

say "COUNT: $c";

# for my $y (reverse(0..$sx-1))
for my $y (0..$sx-1)
{
	# for my $y (int(0.45*$x)..int(0.65*$x))
	for my $x (0..$sx-1)
	{
		print $mmap{$m->[$x]->[$y]};
	}
	print "\n";
}

# part 2

# recalc real high and low and factors
$x = 100000;
# estimated by close look ;)
my $l = 0.449 * $x; # low
my $h = 0.600 * $x; # high

my $rh = -1; # real
my $rl = -1;

for my $y ($l..$h)
{
	print "rl for $x,$y\r";
	my $e = check($x, $y);
	$c++ if $e;

	if ($e)
	{
		$rl = $y;
		last;
	}
}

for my $y (reverse($l..$h))
{
	print "rh for $x,$y\r";
	my $e = check($x, $y);
	$c++ if $e;

	if ($e)
	{
		$rh = $y;
		last;
	}
}

say "approx limits: $rl:$rh";
say "real limits: $rl:$rh";

my $ml = $rl / $x;
my $mh = $rh / $x;

say "yl = $ml * x";
say "yh = $mh * x";

my $sqsize = 100; # ship size

my $n1 = 1;
my $n2 = 8000;

my $stepping = 0;
my $x;
my $goodcode = 0;
while (1)
{
	$x = $stepping ? $x - 1 : int($n1 + ($n2 - $n1) / 2);

	my $l = floor($ml * $x);
	my $h = ceil($mh * $x);

	my $y = -1;
	for my $yy ($l..$h)
	{
		$y = $yy;
		print STDERR "check at $x,$y\n";
		my $e = check($x, $y);
		# $m->[$x]->[$y] = $e;

		last if $e;
	}

	print STDERR "diagonal starts at $x,$y\n";

	# check diagonal
	my $k = 0;
	my $ormore = 1;
	for my $kk (1..$sqsize+1)
	{
		$k = $kk;
		my $dx = $x - $k;
		my $dy = $y + $k;
		my $dh = ceil($mh * $dx);
		print STDERR "check diagonal at $dx,$dy (dh = $dh)\n";
		unless (check($dx, $dy))
		{
			$ormore = 0;
			last;
		}
	}
#	$k--;

	my $code = 10000 * ($x - $sqsize + 1) + $y;
	$goodcode = $code if $k == $sqsize;
	printf "CHECKED %s [$n1 - $n2]: at $x,$y ----- diagonal $k%s, code=%s\n", $stepping ? "STEP" : "BIN", ($ormore ? " or more" : ""), $code;

	if (!$stepping) # binary search
	{
		if ($k >= $sqsize)
		{
			$n2 = $x;
		}
		else
		{
			$n1 = $x;
		}
	}
	else
	{
		last if $k < $sqsize-3; # anything, we're too low
	}
	$stepping = 1 if $n1 == $n2 || $n1 + 1 == $n2;
}

say "CODE: $goodcode";