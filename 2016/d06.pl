#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);


my @f = read_file(\*STDIN);

for my $stage (1..2)
{
    my $h;
    for (@f)
    {
        chomp;
        my $i = 0;
        for my $k (split//)
        {
            $h->{$i}->{$k}++;
    #        print "$i $k\n";
            $i++;
        }
    }

    my $p = '';
    for my $i (sort { $a <=> $b } keys %$h)
    {
        my @t = sort { $h->{$i}->{$b} <=> $h->{$i}->{$a} } keys %{$h->{$i}};
        @t = reverse @t if $stage == 2;
        $p .= $t[0];
    }
    printf "stage $stage: %s\n", $p;
}