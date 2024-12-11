#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = split/\s+/, read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;
my @n;

for my $step (1..75)
{
    @n = ();
    for (@f)
    {
        my $l = length($_);
        if ($_ == 0)
        {
            push(@n, 1)
        }
        elsif ($l % 2 == 0)
        {
            push(@n, substr($_, 0, $l/2));
            push(@n, int substr($_, $l/2));
        }
        else
        {
            push(@n, $_ * 2024);
        }
    }

    say "$step ", scalar @n;
    @f = @n;
}

say "Stage 1: ", scalar @n;
say "Stage 2: ", $stage2;