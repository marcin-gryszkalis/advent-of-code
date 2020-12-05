#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my %h;
for (@f)
{
    s/[FL]/0/g;
    s/[BR]/1/g;
    m/(.......)(...)/;

    my $a = oct("0b".$1);
    my $b = oct("0b".$2);

    my $id = 8*$a + $b;
    $h{$id} = 1;
}

printf "stage 1: %d\n", max(keys(%h));

my $start = 0;
for my $id (0..1023)
{
    if (exists $h{$id} && !$start)
    {
        $start = 1;
        next;
    }

    if (!exists $h{$id} && $start)
    {
        print "stage 2: $id\n";
        last;
    }
}