#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

open(my $f, "d08.txt") or die $!;
my $r = <$f>;

my $w = 25;
my $h = 6;
my $ls = $w * $h;

my @a = $r =~ m/.{1,$ls}/g;

my $min = $ls;
my $mind = 0;

for my $l (@a)
{
	my $x0 = $l =~ tr/0//;
	my $x1 = $l =~ tr/1//;
	my $x2 = $l =~ tr/2//;

	if ($x0 < $min)
	{
		$mind = $x1 * $x2;
		say $mind;
		$min = $x0;
	}
}