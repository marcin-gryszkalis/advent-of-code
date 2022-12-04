#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Set::Scalar;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

for (@f)
{
    my @a = split/\D/;
    my $x = Set::Scalar->new($a[0]..$a[1]);
    my $y = Set::Scalar->new($a[2]..$a[3]);

    # Set::Infinite is much faster
    # my $x = Set::Infinite->new($a[0],$a[1]);
    # my $y = Set::Infinite->new($a[2],$a[3]);

    $stage1++ if $x->is_subset($y) || $y->is_subset($x);
    $stage2++ unless $x->is_disjoint($y);
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;