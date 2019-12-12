#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Utils qw/lcm/;

my $iterations = 1000000;

my $mp; # moon position
my $mv; # moon velocity
my $mc; # moon position list (for cycles)

my @axlab = qw/x y z/;

my $mn = 0; # number of moons
open(my $f, "d12.txt") or die $!;
while (<$f>)
{
	die unless /<x=(.*), y=(.*), z=(.*)>/;
	$mp->[$mn]->[0] = $1;
	$mp->[$mn]->[1] = $2;
	$mp->[$mn]->[2] = $3;
	$mn++;
}

for my $i (0..$mn-1)
{
	for my $j (0..2)
	{
		$mv->[$i]->[$j] = 0;
	}
}

for my $it (1..$iterations)
{
	for my $m1 (0..$mn-1) # save position in $mc list
	{
		for my $a (0..2)
		{
			$mc->[$m1]->[$a]->[$it-1] = $mp->[$m1]->[$a];
		}
	}

	for my $m1 (0..$mn-1) # calc velocities
	{
		for my $m2 (0..$mn-1)
		{
			next if $m1 == $m2;

			for my $a (0..2)
			{
				next if $mp->[$m1]->[$a] == $mp->[$m2]->[$a];
				$mv->[$m1]->[$a] += ($mp->[$m1]->[$a] < $mp->[$m2]->[$a] ? 1 : -1);
			}
		}
	}

	for my $m1 (0..$mn-1) # apply velocities
	{
		for my $a (0..2)
		{
			$mp->[$m1]->[$a] += $mv->[$m1]->[$a];
		}
	}

	next unless $iterations <20 || $it%($iterations/10) == 1; # show only 10 steps for longer jobs
	print "After $it steps:\n";
	for my $i (0..$mn-1)
	{
		print "pos=<";
		for my $j (0..2)
		{
			printf("%s=%3d%s", $axlab[$j], $mp->[$i]->[$j], $j<2?",":"");
		}
		print ", vel=<";
		for my $j (0..2)
		{
			printf("%s=%3d%s", $axlab[$j], $mv->[$i]->[$j], $j<2?",":"");
		}
		print ">\n";
	}


}

# part 1
my $e = 0;
for my $m1 (0..$mn-1)
{
	my $pot = 0;
	my $kin = 0;
	my $tot = 0;
	for my $a (0..2)
	{
		$pot += abs($mp->[$m1]->[$a]);
		$kin += abs($mv->[$m1]->[$a]);
	}

	$tot = $pot * $kin;
	$e += $tot;
	say "$m1 pot: $pot, kin: $kin, tot: $tot";
}

say "TOTAL: $e";

# part 2
my @cycles;
for my $m1 (0..$mn-1)
{
	A: for my $a (0..2)
	{
		L: for my $l (1..int($iterations/2)-1)
		{
			my $x = 0;
			my $y = 0+$l;
			for my $i (0..$l-1)
			{
				# print "cmp $mc->[$m1]->[$a]->[$x] != $mc->[$m1]->[$a]->[$y]\n";
				next L if ($mc->[$m1]->[$a]->[$x] != $mc->[$m1]->[$a]->[$y]); # not a cycle
				$x++;
				$y++;
			}

			print "$m1 $axlab[$a]: cycle $l\n";
			push(@cycles, $l);
			next A;
		}

	}
}

die "not enough iterations" if scalar @cycles < $mn * 3;
my $lcm = lcm(@cycles);
say "CYCLE LENGTH: $lcm";