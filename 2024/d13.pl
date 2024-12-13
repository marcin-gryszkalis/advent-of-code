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
use Math::Matrix;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my %price = qw/
A 3
B 1
/;

my @offset = (0, 10000000000000);

my $n;
my ($prizex, $prizey) = (0, 0);
my @stage = (0, 0);

for (@f)
{
    if (/Button ([AB]): X\+(\d+), Y\+(\d+)/)
    {
        $n->{$1}->{x} = $2;
        $n->{$1}->{y} = $3;
    }
    elsif (/Prize: X=(\d+), Y=(\d+)/)
    {
        $prizex = $1;
        $prizey = $2;

        for my $st (0,1)
        {
            my $M = Math::Matrix -> new(
                [$n->{A}->{x}, $n->{B}->{x}, $prizex + $offset[$st]],
                [$n->{A}->{y}, $n->{B}->{y}, $prizey + $offset[$st]]
                );

            my $s = $M->solve;

            my $a = sprintf("%.0f", $s->[0][0]);
            my $b = sprintf("%.0f", $s->[1][0]);

            next if
                $a < 0 || $b < 0 ||
                $n->{A}->{x} * $a + $n->{B}->{x} * $b != $prizex + $offset[$st] ||
                $n->{A}->{y} * $a + $n->{B}->{y} * $b != $prizey + $offset[$st];

            $stage[$st] += ($a * $price{A} + $b * $price{B});
        }

    }
}

say "Stage $_: ", $stage[$_-1] for (1..2)

