#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $ga_start = 679;
my $gb_start = 771;

# sample
# $ga_start = 65;
# $gb_start = 8921;


my $ga_factor = 16807;
my $gb_factor = 48271;

my $x_factor = 2147483647;

my $ga_match = 4;
my $gb_match = 8;

# To create its next value, a generator will
# take the previous value it produced,
# multiply it by a factor
# keep the remainder of dividing that resulting product by 2147483647

my $a = $ga_start;
my $b = $gb_start;
my $matches = 0;
for my $i (0..40_000_000)
{
    use integer;
    $a = $a * $ga_factor % $x_factor;
    $b = $b * $gb_factor % $x_factor;
    $matches++ if ($a&0xffff) == ($b&0xffff);
    printf("%15d %15d %15d   matches: %d\n", $i, $a, $b, $matches) if $i%1000000 == 0;
}

printf "stage 1: %d\n", $matches;


$a = $ga_start;
$b = $gb_start;
$matches = 0;
for my $i (0..5_000_000)
{
    use integer;
    do {
        $a = $a * $ga_factor % $x_factor;
    } while ($a % $ga_match != 0);

    do {
        $b = $b * $gb_factor % $x_factor;
    } while ($b % $gb_match != 0);

    $matches++ if ($a&0xffff) == ($b&0xffff);
    printf("%15d %15d %15d   matches: %d\n", $i, $a, $b, $matches) if $i%1000000 == 0;
}

printf "stage 2: %d\n", $matches;
