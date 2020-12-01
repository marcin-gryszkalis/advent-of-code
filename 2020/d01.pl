#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

for my $stage (1..2)
{
    my $it = combinations(\@f, $stage+1);
    while (my $p = $it->next)
    {
        printf "stage %d: %d\n", $stage, product(@$p) if sum(@$p) == 2020;
    }
}