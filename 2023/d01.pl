#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my @nums = qw/one two three four five six seven eight nine/;

my %m = map { $_ => $_ } (1..9);

for my $stage (1..2)
{
    my $sum = 0;
    if ($stage == 2)
    {
        my $i = 1;
        %m = (%m, map { $_ => $i++ } @nums);
    }

    my $re = join("|", keys %m);

    for (@f)
    {
        my @h = map { $m{$_} } /(?=($re))/g; # positive look-ahead doesn't move position -> handle overlapping matches
        $sum += $h[0].$h[-1];
    }

    print "Stage $stage: $sum\n";
}
