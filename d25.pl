#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Algorithm::Combinatorics qw(combinations);
use IO::Handle;

use threads;
use Thread::Queue;

### intcode ######################################
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

open(my $dbgf,">intcode-debug.txt") or die $!;
$dbgf->autoflush;

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

open(my $f, "d25.txt") or die $!;
my @pzero = split(/,/, <$f>);

my $i = 0; # 1 robot
my $thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

sub enq
{
	my ($q,$s) = @_;
	for my $a (split/[\r\n]+/, $s)
	{
		$a =~ s/\s*#.*//; # trailing space + comments
		next if $a eq '';

		for my $b (split//,$a)
		{
			$q->enqueue(ord($b));
		}
		$q->enqueue(ord("\n"));
	}
}

my $mt = <<'EOF';
west
north
take dark matter
south
east
north
west
take planetoid
west
take spool of cat6
east
east
south
east
north
take sand
west
take coin
north
take jam
south
west
south
take wreath
west
take fuel cell
east
north
north
west
south
inv
EOF

my $invt = <<'EOF';
jam
fuel cell
planetoid
sand
spool of cat6
coin
dark matter
wreath
EOF



my @manual = split/\n/,$mt;
my @inv = split/\n/,$invt;

my @checklist = ();
my @combscenario = ();

for my $e (@inv) # drop everything
{
	push(@combscenario, "drop $e");
}

for my $i (1..scalar(@inv))
{
	my $it = combinations(\@inv, $i);
	C: while (my $es = $it->next)
	{
		for my $e (@$es)
		{
			push(@combscenario, "take $e");
		}

		push(@combscenario, "south");

		for my $e (@$es)
		{
			push(@combscenario, "drop $e");
		}
	}
}

my $heavy = -1;
my $s = '';
while (1)
{
	my $e = $tqout[$i]->dequeue_nb();
	if (defined $e)
	{
		if ($e > 128)
		{
			say "HULL($e)";
			next;
		}

		if ($e == 10)
		{
			say $s;

			if ($s =~ /Droids on this ship are (\S+) than the detected/)
			{
				$heavy = $1 eq 'lighter' ? 0 : 1;
				say "HEAVY? $heavy";
			}

			if ($s =~ /Command\?/)
			{
				my $in = shift(@manual);
				if (defined $in)
				{
					print $in;
				}
				else
				{
					$in = shift(@combscenario);
					say "### auto: $in";

					# $in = <STDIN>;

				}
				chomp $in;
				enq($tqin[$i], $in);
			}


			$s = '';
		}
		else
		{
			$s .= chr($e);
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

