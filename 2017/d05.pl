#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my @ff = read_file(\*STDIN);

@ff = map { chomp; int $_ } @ff;

for my $stage (1..2)
{
    my @f = @ff;
    my $step = 0;
    my $i = 0;
    while (1)
    {
        $step++;

        my $n = $i + $f[$i];
        last if $n < 0 || $n >= scalar @f;

        if ($stage == 2 && $f[$i] >= 3) { $f[$i]-- } else { $f[$i]++ }

        $i = $n;
    }

    printf "stage $stage: %d\n", $step;
}

