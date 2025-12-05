#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = read_file(\*STDIN, chomp => 1);

for my $stage (1..2)
{
    my $sum = 0;

    for (@l)
    {
        my @b = split//;

        my $L = $stage == 1 ? 2 : 12;

        my $s = 0;
        my $e = $#b;
        my $x = '';

        S: while (1)
        {
            last if $L == 0;
            for my $d (reverse(1..9))
            {
                for my $p ($s..$e)
                {
                    if ($b[$p] == $d && $p <= $e - $L + 1)
                    {
                        $x .= $d;
                        $L--;
                        $s = $p + 1;
                        next S;
                    }
                }
            }

            die;
        }

        $sum += $x;
    }

    say "Stage $stage: $sum";
}
