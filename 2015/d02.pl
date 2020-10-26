#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

my $total = 0;
my $total_ribbon = 0;
while (<>)
{
    chomp;
    my @a = sort { $a <=> $b } split/x/;
    my @b = sort { $a <=> $b } ($a[0] * $a[1], $a[1] * $a[2], $a[2] * $a[0]);
    $total += 2*$b[0] + 2*$b[1] + 2*$b[2] + $b[0];
    $total_ribbon += 2*$a[0] + 2*$a[1] + $a[0]*$a[1]*$a[2];
}

print "stage 1: $total\n";
print "stage 2: $total_ribbon\n";