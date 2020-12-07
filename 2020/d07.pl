#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @ff = read_file(\*STDIN);

my %h;

my $stage1 = 0;
my $stage2 = 0;

for (@ff)
{
    chomp;
# dark violet bags contain no other bags.
    next if /no other bag/;
# vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    die $_ unless m/(\S+\s\S+) bags contain (.*)/;
    my $b = $1;
    my @rest = split/, /, $2;
    $h{$b} = \@rest;
}

sub sr1
{
    my $b = shift;
    return 1 if $b =~ /shiny gold/;
    return 0 unless exists $h{$b};
    my $r = 0;
    for my $n (@{$h{$b}})
    {
        $n =~ m/(\d+) (\S+\s+\S+)/;
        $r += sr1($2);
    }

    return $r;
}

for my $b (keys %h)
{
    next if $b =~ /shiny gold/;
    $stage1++ if sr1($b) > 0;
}

printf "stage 1: $stage1\n";

sub sr2
{
    my $b = shift;
    return 1 unless exists $h{$b};

    my $r = 0;
    for my $n (@{$h{$b}})
    {
        $n =~ m/(\d+) (\S+\s+\S+)/;
        my $m = $1;
        $r += $m * sr2($2);
    }

    return $r + 1;
}

$stage2 = sr2("shiny gold") - 1;

printf "stage 2: $stage2\n";
