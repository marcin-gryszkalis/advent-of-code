#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;

use threads;
use Thread::Queue;

# 0 for first part, 1 for second part
my $start = 1;

# threads
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

open(my $f, "d11.txt") or die $!;
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

my @mmap = qw/. #/;
my @dmap = qw/^ > v </;

my $sx = 200; # board size
my $sy = 200;

my @zm = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $m = \@zm; # map

my $oo; # visited pieces

# start in the middle
my $x = int($sx/2);
my $y = int($sy/2);

my $direction = 0; # 0=top, 1=right, 2=down, 3=left
my @dx = qw/0 1 0 -1/;
my @dy = qw/-1 0 1 0/;

my $i = 0; # 1 robot
my $thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

$tqin[$i]->enqueue($start);

my $mv = 0;
while (1)
{
	my $paint = $tqout[$i]->dequeue_nb();
	if (defined $paint)
	{
		my $turn = $tqout[$i]->dequeue();  # assume we'll have 2 pieces of output
		print "$mv DO($paint:$turn)\n";

		$m->[$x]->[$y] = $paint;
		$oo->{"$x:$y"}++;

		$direction = ($direction + ($turn ? 1 : 3)) % 4;
		print "$mv NDIR($direction)\n";

		$x += $dx[$direction];
		$y += $dy[$direction];
		print "$mv POS($x,$y)\n";

		if ($x > $sx || $x < 0 || $y > $sy || $y < 0) { die "out of board"; }

		my $piece = $m->[$x]->[$y];
		$tqin[$i]->enqueue($piece);
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
			say "***** PAINTED COUNT: ".scalar keys %$oo;

			for my $ay (0..$sy)
			{
				for my $ax (0..$sx)
				{
					print(($ax == $x && $ay == $y) ? $dmap[$direction] : $mmap[$m->[$ax]->[$ay]]);
				}
				print "\n";
			}

			last;
		}
	}
}
