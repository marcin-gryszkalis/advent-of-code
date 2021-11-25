#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Socket;

my $ranges;
while (<>)
{
    chomp;
    my @a = split/-/;
    $ranges->{$a[0]} = $a[1];
}

my $stage1 = 0;

my $r = 0;
for my $l (sort { $a <=> $b } keys %$ranges)
{
    print "$l - $ranges->{$l}\n";
    if ($l > $r+1)
    {
        $stage1 = $r+1;
        printf "Stage 1: %d = %s\n", $stage1, inet_ntoa(inet_aton($stage1));
        last;
    }
    $r = max($ranges->{$l}, $r);
}

