#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

open(my $f, "d02.txt") or die $!;
my @pzero = split(/,/, <$f>);


for my $n (0..99)
{
VLOOP: for my $v (0..99)
{

my @p = @pzero;

$p[1] = $n;
$p[2] = $v;

my $i = 0;

while (1)
{
	die unless defined $p[$i];
	if ($p[$i] == 99)
	{
		say(100*$n + $v) if $p[0] == 19690720;
		next VLOOP;
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
	else { next VLOOP; }
}


}
}
