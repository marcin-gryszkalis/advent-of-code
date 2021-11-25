#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

# input
my $a = "11101000110010100";
my $disksize = 272;

# demo
# my $a = "10000";
# my $disksize = 20;

while (1)
{
    # Call the data you have at this point "a".
    # Make a copy of "a"; call this copy "b".
    my $b = $a;

    # Reverse the order of the characters in "b".
    $b = reverse $b;

    # In "b", replace all instances of 0 with 1 and all 1s with 0.
    $b =~ tr/01/10/;

    # The resulting data is "a", then a single 0, then "b".
    $a = "${a}0$b";

    last if length $a >= $disksize;

    print "a: $a\n";
}

$a = substr($a, 0, $disksize);

my $checksum = $a;
while (1)
{
    print "checksum: $checksum\n";
    last if length($checksum) % 2 == 1;
    $checksum =~ s/(.)(.)/($1==$2?1:0)/eg;
}

print "Stage 1: $checksum\n";