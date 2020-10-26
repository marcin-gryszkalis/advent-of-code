#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

open(my $f, "d03.txt") or die $!;
my @p1 = split(/,/, <$f>);
my @p2 = split(/,/, <$f>);

my %vx = qw/
L -1
R 1
U 0
D 0
/;

my %vy = qw/
L 0
R 0
U +1
D -1
/;

my %visited;

# assume start = (0,0)
my $cx = 0;
my $cy = 0;
for my $s (@p1)
{
	$s =~ m/(.)(\d+)/;
	my $dir = $1;
	my $len = $2;

	for (1..$len)
	{
		$cx += $vx{$dir};
		$cy += $vy{$dir};
		$visited{"$cx:$cy"} = 1;
	}

}

my $mindist = 10000000;

$cx = 0;
$cy = 0;
for my $s (@p2)
{
	$s =~ m/(.)(\d+)/;
	my $dir = $1;
	my $len = $2;

	for (1..$len)
	{
		$cx += $vx{$dir};
		$cy += $vy{$dir};

		if (exists $visited{"$cx:$cy"})
		{
			my $dist = abs($cx) + abs($cy);
			if ($dist < $mindist)
			{
				print "$cx:$cy at $dist\n";
				$mindist = $dist;
			}

		}
	}

}

