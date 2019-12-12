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
	$mp->[$mn++] = [ /<x=(.*), y=(.*), z=(.*)>/ ];
}

$mv = [ map { [qw/0 0 0/] } (0..($mn-1)) ];

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
			next if $m1 == $m2; # not required but saves time

			for my $a (0..2)
			{
				$mv->[$m1]->[$a] += ($mp->[$m2]->[$a] <=> $mp->[$m1]->[$a]);
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

	next unless $iterations < 20 || $it % ($iterations/10) == 1; # show only 10 steps for longer jobs
	print "After $it steps:\n";
	for my $i (0..$mn-1)
	{
		printf "pos=<%s>, vel=<%s>\n",
			join(", ", map { sprintf("%s=%3d", $axlab[$_], $mp->[$i]->[$_]) } (0..2)),
			join(", ", map { sprintf("%s=%3d", $axlab[$_], $mv->[$i]->[$_]) } (0..2));
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
			for my $i (0..$l-1)
			{
				# print "cmp $mc->[$m1]->[$a]->[$x] != $mc->[$m1]->[$a]->[$y]\n";
				next L if ($mc->[$m1]->[$a]->[$x] != $mc->[$m1]->[$a]->[$x+$l]); # not a cycle
				$x++;
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