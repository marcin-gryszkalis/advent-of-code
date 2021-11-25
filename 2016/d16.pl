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
# stage 1: my $disksize = 272;
my $disksize = 35651584;

# demo
# my $a = "10000";
# my $disksize = 20;

my $step = 0;
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
}

$a = substr($a, 0, $disksize);

my $checksum = $a;
while (1)
{
    last if length($checksum) % 2 == 1;
    $checksum =~ s/(.)(.)/($1==$2?1:0)/eg;
}

print "Checksum: $checksum\n";