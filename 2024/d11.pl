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
my %h;

$h{$_}++ for @f;

for my $step (1..75)
{
    my $g = clone \%h;
    for (keys %$g)
    {
        my $l = length($_);
        my $c = $g->{$_};

        $h{$_} -= $c;

        if ($_ == 0)
        {
            $h{1} += $c;
        }
        elsif ($l % 2 == 0)
        {
            $h{substr($_, 0, $l/2)} += $c;
            $h{int substr($_, $l/2)} += $c;
        }
        else
        {
            $h{$_ * 2024} += $c;
        }
    }

    $stage1 = sum values %h if $step == 25;
}


say "Stage 1: ", $stage1;
say "Stage 2: ", sum values %h;