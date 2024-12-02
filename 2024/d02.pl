#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

sub issafe($r)
{
    my $n = 1;
    my $ord = 0;

    my $p = $r->[0];
    while (my $i = $r->[$n])
    {
        return 0 if abs($p - $i) < 1 || abs($p - $i) > 3;

        $ord += $i <=> $p;
        return 0 if abs($ord) != $n;

        $p = $i;
        $n++;
    }

    return 1;
}

F: for (@f)
{
    my @r = split/\s+/;

    if (issafe(\@r))
    {
        $stage1++;
        $stage2++;
        next;
    }

    for my $i (0..$#r)
    {
        my @rr = @r;
        splice(@rr, $i, 1);
        if (issafe(\@rr))
        {
            $stage2++;
            next F;
        }
    }
}
say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
