#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

$_ = <>;
chomp;
my @b = split/\s+/;

my $visited = ();
my $cycle = 0;
my $stage1 = 0;
my $stage2 = 0;
while (1)
{
    my $id = join(":", @b);

    if (exists $visited->{$id})
    {
        # print "$visited->{$id} : $id\n";
        if ($visited->{$id} == 1 && $stage1 == 0)
        {
            $stage1 = $cycle;
        }
        elsif ($visited->{$id} == 2) # assume that it's the same id as in stage1, not proven
        {
            $stage2 = $cycle - $stage1;
            last;
        }
    }
    $visited->{$id}++;

    my $max = 0;
    my $maxi = -1;
    for my $i (0..$#b)
    {
        if ($b[$i] > $max) { $max = $b[$i]; $maxi = $i; }
    }

    $b[$maxi] = 0;
    my $i = ($maxi + 1) % scalar(@b);
    while (1)
    {
        $b[$i]++;
        $max--;
        last if $max == 0;
        $i = ($i + 1) % scalar(@b);
    }

    $cycle++;
}

printf "stage 1: %d\n", $stage1;
printf "stage 2: %d\n", $stage2;