#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $elvescnt = 3014603;
#$elvescnt = 5;

# part 1 approach was O(n^2) in this case but noticed, that we don't need to count presents stolen - just postiions
my @left = (1..$elvescnt/2);
my @right = ($elvescnt/2+1..$elvescnt); # right half >= left half
while (scalar(@left) > 0)
{
    shift @right; # remove victim at the beginning of @right
    if (scalar(@right) == scalar(@left)) # halves are even
    {
        push @left, shift @right; # so rebalance
    }
    push @right, shift @left; # move killer to the end of queue
}
printf "stage 2: %d\n", $right[0];
