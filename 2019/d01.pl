#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

sub fr
{
	my $x = shift;

	my $a = int($x/3) - 2;
	return 0 if $a <= 0;
	return $a + fr($a);
}

open(my $f, "d01.txt") or die $!;
my $s  = 0;
while (<$f>)
{
	chomp;
	my $f = fr($_);
	print "$_ = $f\n";
	$s += $f

}

say $s;