#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

for (@f)
{
    my @a = split/\D/;
    $stage1++ if $a[0] <= $a[2] && $a[1] >= $a[3] || $a[2] <= $a[0] && $a[3] >= $a[1];
    $stage2++ if $a[0] <= $a[2] && $a[1] >= $a[2] || $a[2] <= $a[0] && $a[0] <= $a[3];
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;