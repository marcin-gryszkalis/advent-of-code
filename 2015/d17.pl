#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $M = 150;

my @f = read_file(\*STDIN);
@f = map {int} @f;

my $count = 0;
my $cpl;
for my $l (1..scalar(@f))
{
    my $i = 0;
    my $it = combinations(\@f, $l);
    while (my $p = $it->next)
    {
        my $s = sum(@$p);
        if ($s == $M)
        {
            $count++;
            $cpl->{$l}++;
            printf "%4d %2d %8d %s\n", $count, $l, $i, join(",", @$p);

        }
        $i++;
    }

}

printf "stage 1: %d\n", $count;
printf "stage 2: %d\n", $cpl->{min(keys(%$cpl))};