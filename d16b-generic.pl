#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use POSIX qw/ceil floor/;

# note: this is generic optimized version, but still working on whole input/output (ignoring skip)
# it's able to solve 32-byte input in 30 minutes (100 phases)
my @px = qw/0 1 0 -1/;

my $skip;

my @a;
open(my $f, "d16.txt") or die $!;
while (<$f>)
{
	$skip = int substr($_,0,7);
	@a = split //;
	last;
}

@a = (@a) x 10000;
my $l = scalar @a;

say STDERR "LEN($l)";
say STDERR "SKIP($skip)";

my @s = (); # temporary sums

for my $phase (1..100)
{
	print STDERR "phase: $phase\n";
	my @o = ();

	# first row
	my $x = 0;
	my $j = 0; # src xj
	my $b = 0; # block number
	my $bt = 1; # block type
	while (1)
	{
		my $e = $bt * $a[$j];
		$x += $e;
		$s[$j] = $e;

		$j += 2;
		last if $j >= $l;

		$b++;
		$bt = -$bt;
	}
	push(@o, abs($x) % 10);

	# rows 1..$l-1
	for my $i (1..$l-1) # dest Xi
	{
		$x = 0;

		$j = 0; # src xj
		$b = 0; # block number
		$bt = 1; # block type
		while (1) # loop over blocks
		{
			my $bs1 = $i; # previous block size
			my $s1 = 2 * $b * $i + $i - 1; # start of previous block
			my $e1 = $s1 + $bs1 - 1; # end of previous block
			$e1 = $l-1 if $e1 > $l-1;

			my $bs2 = $i + 1; # block size
			my $s2 = 2 * $b * ($i + 1) + $i; # start of block
			my $e2 = $s2 + $bs2 - 1; # end of block
			$e2 = $l-1 if $e2 > $l-1;

			last if $s2 >= $l;  # ?

			# note:
			#	s1 < s2
			#	e1 <= e2 (= at the right edge)

			my $overlap = 0;
			my $left = 0;
			my $right = 0;
			my $opt = 0; # use optimization
			if ($e1 >= $s2) # at least 1 common index
			{
				$overlap = $e1 - $s2 + 1;
				$left = $s2 - $s1;
				$right = $e2 - $e1;

				$opt = 1 if $overlap > $left + $right;
			}

			my $xx = 0; # sum for current block
			if ($opt == 1)
			{
				$xx = $s[$s1]; # get common part
				for my $k ($s1..$s2-1) # subtract left part
				{
					my $e = $bt * $a[$k];
					$xx -= $e;
				}
				for my $k ($e1+1..$e2) # add right part, won't happen if $e1 == $e2 (right edge)
				{
					my $e = $bt * $a[$k];
					$xx += $e;
				}

			}
			else # standard recalc
			{
				for my $k ($s2..$e2)
				{
					my $e = $bt * $a[$k];
					$xx += $e;
				}
			}

			$s[$s2] = $xx; # save for next round
			$x += $xx;
			$b++;
			$bt = -$bt;

		}
		push(@o, abs($x) % 10);
	}

	my $r = join("", @o[$skip..$skip+7]);
	printf "%4d %s\n", $phase, $r;
	@a = @o;
}

