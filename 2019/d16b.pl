#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

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
@a = @a[$skip..$#a];
my $l = scalar @a;

say STDERR "LEN($l)";
say STDERR "SKIP($skip)";

for my $phase (1..100)
{
	my $i = $l - 1;
	while ($i--)
	{
		$a[$i] = ($a[$i] + $a[$i+1]) % 10;
	}

	my $r = join("", @a[0..7]);
	printf "%4d %s\n", $phase, $r;
}

