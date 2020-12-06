#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $ff = read_file(\*STDIN);

my $stage1 = 0;
my $stage2 = 0;
for (split/\n\n/,$ff)
{
    my %h = ();
    my @u = split/\s+/;
    $h{$_}++ for (split//, join("", @u));

    $stage1 += keys(%h);
    $stage2 += grep { $h{$_} == @u } keys(%h);
}

printf "stage 1: $stage1\n";
printf "stage 2: $stage2\n";
