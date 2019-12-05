#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

open(my $f, "d02.txt") or die $!;
my @p = split(/,/, <$f>);


$p[1] = 12;
$p[2] = 2;

my $i = 0;

while (1)
{
	die unless defined $p[$i];
	if ($p[$i] == 99)
	{
		say $p[0];
		exit;
	}
	elsif ($p[$i] == 1)
	{
		$p[$p[$i+3]] = $p[$p[$i+1]] + $p[$p[$i+2]];
		$i += 4
	}
	elsif ($p[$i] == 2)
	{
		$p[$p[$i+3]] = $p[$p[$i+1]] * $p[$p[$i+2]];
		$i += 4
	}
	else { die; }
}
