#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my %machine = qw/
children 3
cats 7
samoyeds 2
pomeranians 3
akitas 0
vizslas 0
goldfish 5
trees 3
cars 2
perfumes 1
/;

my @f = read_file(\*STDIN);
# @f = map { chomp; int $_ } @f;
my $h;
for (@f)
{
    chomp;
    # Sue 462: pomeranians: 6, cats: 2, perfumes: 6
    m/Sue (\d+):\s+(.*)/;

    my $sue = $1;
    my $stuff = $2;
    for my $i (split/,\s+/, $stuff)
    {
        $i =~ m/(\S+):\s+(\d+)/;
        $h->{$sue}->{$1} = $2;
    }
}

# stage 1
for my $sue (keys %$h)
{
    my $ok = 1;
    for my $i (keys %{$h->{$sue}})
    {
        $ok = 0 unless $h->{$sue}->{$i} == $machine{$i};
        last unless $ok;
    }

    if ($ok)
    {
        printf "stage 1: %d\n", $sue;
        last;
    }
}

# stage 2
# the cats and trees readings indicates that there are greater than that many
# the pomeranians and goldfish readings indicate that there are fewer than that many
for my $sue (keys %$h)
{
    my $ok = 1;
    for my $i (keys %{$h->{$sue}})
    {
        if (
            $i =~ /(cats|trees)/ && $h->{$sue}->{$i} < $machine{$i}  ||
            $i =~ /(pomeranians|goldfish)/ && $h->{$sue}->{$i} > $machine{$i}  ||
            $i !~ /(cats|trees|pomeranians|goldfish)/ && $h->{$sue}->{$i} != $machine{$i}
            )
        {
            $ok = 0;
            last;
        }
    }

    if ($ok)
    {
        printf "stage 2: %d\n", $sue;
        last;
    }
}
