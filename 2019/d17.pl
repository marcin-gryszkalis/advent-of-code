#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Algorithm::Combinatorics qw(combinations);

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

open(my $f, "d17.txt") or die $!;
my @pzero = split(/,/, <$f>);

my $d = 0; # 0=top, 1=right, 2=down, 3=left
my @dx = qw/ 0 1 0 -1/;
my @dy = qw/-1 0 1  0/;
my @dmap = qw/^ > v </;

my $basesize = 70; # map background size
my @zm = ( map { [(0) x ($basesize)] } (0..($basesize))  );
my $m = \@zm; # map
my @zv = ( map { [(0) x ($basesize)] } (0..($basesize))  );
my $v = \@zv; # visited


$pzero[0] = 2; # part 2 (does part 1 too)

my $i = 0; # 1 robot
my $thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

sub enq
{
	my ($q,$s) = @_;
	for my $a (split//, $s)
	{
		$q->enqueue(ord($a));
	}
}

my $offset = 1; # becuase I don't want to worry walking out of board
my $x = 0;
my $y = 0;
my $sx = 0; # board size
my $sy = 0;
my $rx = 0; # robot
my $ry = 0;
while (1)
{
	my $e = $tqout[$i]->dequeue_nb();
	if (defined $e)
	{
		print chr($e);
		last unless chr($e) =~ /[.#^\n]/; # something else than map

		if ($e == 10)
		{
			$y++;
			$sy++;
			$x = 0;
			next;
		}

		if ($e == ord('^'))
		{
			$rx = $x + $offset;
			$ry = $y + $offset;
		}

		$m->[$x+$offset]->[$y+$offset] = chr($e);
		$x++;
		$sx = $x if $x > $sx;
	}
	else # queue is empty, maybe we'll check for dead threads?
	{
		if ($thread[$i]->is_joinable())
		{
			$thread[$i]->join();
			$thalive--;
		}

		if ($thalive == 0) # all dead
		{
			last;
		}
	}
}

say "MAPSIZE($sx,$sy)";
say "ROBOT($rx,$ry)";

# part 1
my $sum = 0;
for my $y (1..$sy-1)
{
	for my $x (1..$sx-1)
	{
		next unless $m->[$x]->[$y] eq '#';
		$sum += ($x * $y) if
			$m->[$x-1]->[$y] eq '#' &&
			$m->[$x+1]->[$y] eq '#' &&
			$m->[$x]->[$y-1] eq '#' &&
			$m->[$x]->[$y+1] eq '#';
	}
}
say "SUM($sum)";


# part 2

# map the path
sub front
{
	my $nx = $x+$dx[$d];
	my $ny = $y+$dy[$d];
	my $c = $m->[$nx]->[$ny];
#	say "front($x,$y) $d ($nx,$ny) = $c";
	return $c;
}

sub right
{
	my $nd = ($d+1) % 4;
	my $nx = $x+$dx[$nd];
	my $ny = $y+$dy[$nd];
	my $c = $m->[$nx]->[$ny];
#	say "right($x,$y) $nd ($nx,$ny) = $c";
	return $c;
}

sub left
{
	my $nd = ($d+3) % 4;
	my $nx = $x+$dx[$nd];
	my $ny = $y+$dy[$nd];
	my $c = $m->[$nx]->[$ny];
#	say "left($x,$y) $nd ($nx,$ny) = $c";
	return $c;
}

$x = $rx;
$y = $ry;

my @q;
T: while (1)
{
	my $l = 0;
	if (front() eq '#')
	{
		while (front() eq '#')
		{
			$l++;
			$x += $dx[$d];
			$y += $dy[$d];
		}

		push(@q, $l);
	}
	elsif (right() eq '#')
	{
		push(@q, 'R');
		$d = ($d+1) % 4;
	}
	elsif (left() eq '#')
	{
		push(@q, 'L');
		$d = ($d+3) % 4;
	}
	else
	{
		last;
	}
}

my $path = join(",", @q);
say "PATH: $path";

# find best split of ABC procedures

my $minl = 2; # min length of proc
my $qparts;
my $parts;
my $n = $#q-1;
while (1)
{
	for my $i (0..($#q-$n))
	{
		my $s = join(",",@q[$i..$i+$n]);
		$qparts->{$n}->{$s}++;
	}


	for my $k (keys %{$qparts->{$n}})
	{
		$parts->{$k} = $qparts->{$n}->{$k} if $qparts->{$n}->{$k} > 1;
	}

	$n--;
	last if $n <= $minl-2;
}

# for my $k (sort { $parts->{$b} <=> $parts->{$a} || length($b) <=> length($a) } keys %$parts)
# {
# 	print STDERR "$k $parts->{$k}\n";
# }

my $it = combinations([ sort { $parts->{$b} <=> $parts->{$a} || length($b) <=> length($a) } keys %$parts], 3);

my @finalc = undef;
my $finals = '';
W: while (my $c = $it->next)
{
	my $t = join("|", @$c);
	my $re = qr/^(($t),?)+$/;
	# print "$t\n";
	if ($path =~ m/$re/) # found right combination
	{
		@finalc = @$c;
		while (1)
		{
			my $j = 0;
			for my $e (@finalc)
			{
				if ($path =~ /^$e,?/)
				{
					$finals .= $j;
					$path =~ s/$e,?//;
					last W if length($path) == 0;
				}
				$j++;
			}
		}
		last W;
	}
}

$finals = join(",", map { chr(ord('A') + $_) } split//,$finals);
say "MAIN: $finals";

enq($tqin[$i], "$finals\n");

my $j = 0;
for my $e (@finalc)
{
	printf "PROC %s: %s\n", chr(ord('A')+$j), $e;
	enq($tqin[$i], "$e\n");
	$j++;
}

enq($tqin[$i], "n\n");

while (1)
{
	my $e = $tqout[$i]->dequeue_nb();
	if (defined $e)
	{
		if ($e > 128)
		{
			say "DUST($e)";
		}
		else
		{
			print chr($e);
		}
	}
	else # queue is empty, maybe we'll check for dead threads?
	{
		if ($thread[$i]->is_joinable())
		{
			$thread[$i]->join();
			$thalive--;
		}

		if ($thalive == 0) # all dead
		{
			last;
		}
	}
}

