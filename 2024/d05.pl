#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $rules;
my @updates;
for (@f)
{
    $rules->{$1}->{$2} = 1 if /(\d+)\|(\d+)/;
    push(@updates, $_) if /,/;
}

U: for my $u (@updates)
{
    my @pages = split/,/, $u;
    for my $i (0..$#pages-1)
    {
        for my $j ($i+1..$#pages)
        {
            my $p = $pages[$i];
            my $q = $pages[$j];
            next U if exists $rules->{$q}->{$p};
        }
    }

    $stage1 += $pages[$#pages/2];
}

for my $u (@updates)
{
    my @pages = split/,/, $u;
    my $broken = 0;
    while (1)
    {
        my $swapped = 0;
        for my $i (0..$#pages-1)
        {
            for my $j ($i+1..$#pages)
            {
                my $p = $pages[$i];
                my $q = $pages[$j];
                if (exists $rules->{$q}->{$p})
                {
                    $broken = 1;
                    splice(@pages, $j, 0, splice(@pages, $i, 1));
                    $swapped = 1;
                }

            }
        }

        last unless $swapped;
    }

    $stage2 += $pages[$#pages/2] if $broken;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
