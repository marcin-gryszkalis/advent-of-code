#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;

use threads;
use Thread::Queue;

# threads
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

open(my $f, "d13.txt") or die $!;
my @pzero = split(/,/, <$f>);

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

	print STDERR "[$me:0] START\n";
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
			print STDERR dbghdr($me,$p,$i,0)." halt\n";
			return; # end of thread!
		}
		elsif ($op == 1) # add
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) + mem($p,$rb,$i+2,$m2));
			print STDERR dbghdr($me,$p,$i,3)." add ".dbg($p,$rb,$i+1,$m1)." + ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 2) # mul
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) * mem($p,$rb,$i+2,$m2));
			print STDERR dbghdr($me,$p,$i,3)." mul ".dbg($p,$rb,$i+1,$m1)." * ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
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
			print STDERR "### IN($x)\n";

			mem($p,$rb,$i+1,$m1,$x);
			print STDERR dbghdr($me,$p,$i,1)." inp -> ".dbg($p,$rb,$i+1,$m1)."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print STDERR dbghdr($me,$p,$i,1)." out ".dbg($p,$rb,$i+1,$m1)."\n";
			my $output = mem($p,$rb,$i+1,$m1);
			print STDERR "### OUT($output)\n";

			$qout->enqueue($output);
			$i += 2
		}
		elsif ($op == 5) # jnz
		{
			print STDERR dbghdr($me,$p,$i,2)." jnz ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) != 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 6) # jz
		{
			print STDERR dbghdr($me,$p,$i,2)." jz  ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) == 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 7) # lt
		{
			print STDERR dbghdr($me,$p,$i,3)." lt  ".dbg($p,$rb,$i+1,$m1)." < ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) < mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 8) # eq
		{
			print STDERR dbghdr($me,$p,$i,3)." eq  ".dbg($p,$rb,$i+1,$m1)." == ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) == mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 9) # arb
		{
			$rb += mem($p,$rb,$i+1,$m1);
			print STDERR dbghdr($me,$p,$i,2)." arb by ".dbg($p,$rb,$i+1,$m1)." rb:$rb\n";
			$i += 2;
		}
		else
		{
			print STDERR dbghdr($me,$p,$i,1)." err invalid opcode: $op\n";
			exit 1;
		}

	}

}

my @mmap = qw/. + x = o/;

my $sx = 40; # board size
my $sy = 24;

my @zm = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $m = \@zm; # map

my $px = 20; # paddle x

# part 1
my $i = 0; # 1 robot
my $thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

my $mv = 0;
while (1)
{
	my $x = $tqout[$i]->dequeue_nb();
	if (defined $x)
	{
		my $y = $tqout[$i]->dequeue(); # assume we'll have 3 pieces of output
		my $o = $tqout[$i]->dequeue();

		if ($x == -1 && $y == 0)
		{
			print "$mv %%%%%% SCORE($o)\n";
		}
		else
		{
			# print "$mv ****** DO($x,$y = $o)\n";

			$m->[$x]->[$y] = $o;
			if ($x > $sx || $x < 0 || $y > $sy || $y < 0) { die "out of board"; }

			if ($o == 3) # padd
			{
				$px = $x;
			}
		}
		$mv++;
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
			my $bc = 0;

			for my $ay (0..$sy-1)
			{
				for my $ax (0..$sx-1)
				{
					print $mmap[$m->[$ax]->[$ay]];
					$bc++ if $m->[$ax]->[$ay] == 2;
				}
				print "\n";
			}

			say "BLOCK-COUNT($bc)";
			last;
		}
	}
}

sleep(3);

# part 2
@pzero[0] = 2; # insert coin
my $score = 0;

$i = 0; # 1 robot
$thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

$mv = 0;
while (1)
{
	my $x = $tqout[$i]->dequeue_nb();
	if (defined $x)
	{
		my $y = $tqout[$i]->dequeue();  # assume we'll have 3 pieces of output
		my $o = $tqout[$i]->dequeue();  # assume we'll have 3 pieces of output

		if ($x == -1 && $y == 0)
		{
			$score = $o;
		}
		else
		{
			# print "$mv ****** DO($x,$y = $o)\n";

			$m->[$x]->[$y] = $o;
			if ($x > $sx || $x < 0 || $y > $sy || $y < 0) { die "out of board"; }

			if ($o == 3) # padd
			{
				$px = $x;
			}
			if ($o == 4) # ball
			{
				for my $ay (0..$sy-1)
				{
					for my $ax (0..$sx-1)
					{
						print $mmap[$m->[$ax]->[$ay]];
					}
					print "\n";
				}

				my $move = ($x <=> $px); # joystick
				$tqin[$i]->enqueue($move);
			}
		}
		$mv++;
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
			say "SCORE($score)\n";
			last;
		}
	}
}

