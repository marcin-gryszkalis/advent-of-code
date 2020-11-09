#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $fwh;

my @f = read_file(\*STDIN);

my $total_depth = 0;
for (@f)
{
    chomp;
    my ($d,$r) = split/\D+/;
    $fwh->{$d} = $r;
    $total_depth = $d; # ordered
}

my $severity_stage1 = 0;
my $delay = 0;
while (1)
{
    my $severity = 0;
    my $caught = 0;
    my $layer = 0;
    my $t = $delay;
    while (1)
    {
        last if $layer > $total_depth;

        if (exists $fwh->{$layer} && $t % (($fwh->{$layer}-1) * 2) == 0)
        {
            $severity += ($t * $fwh->{$layer});
            $caught++;
            last if $delay > 0; # for stage 1 we need all caughts
            $severity_stage1 = $severity;
        }

        $t++; $layer++;
    }

    last unless $caught;
    $delay++;

}

printf "stage 1: %d\n", $severity_stage1;
printf "stage 2: %d\n", $delay;