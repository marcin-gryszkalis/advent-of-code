#!/usr/bin/perl
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my @f = read_file(\*STDIN);

my $c = 0;
for (@f)
{
    chomp;
    my @a = split/\s+/;
    $c += (max(@a) - min(@a));
}

printf "stage 1: %d\n", $c;

my $c = 0;
L: for (@f)
{
    chomp;
    my @a = split/\s+/;
    for my $i (@a)
    {
        for my $j (@a)
        {
            next if $i == $j;

            if ($i % $j == 0)
            {
                $c += $i/$j;
                next L;
            }
        }
    }
}

printf "stage 2: %d\n", $c;

