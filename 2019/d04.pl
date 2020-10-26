#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

my $a = 134564;
my $b = 585159;

my $i = 0;
L: for ($a..$b)
{
	my @t = split//;
	for my $j (0..4)
	{
		next L if $t[$j+1] < $t[$j];
	}

	next unless m/(.)(\1)/;

	$i++;
}
say $i;