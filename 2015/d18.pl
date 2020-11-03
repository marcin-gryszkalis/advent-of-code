#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $M = 100; # 6 for d18a.txt

my @f = read_file(\*STDIN);

my @cnts;
for my $stage (1..2)
{
    my $a;
    my $r = 0;
    my @b = split(//,'.' x $M+2);
    $a->[$r++] = \@b;
    for (@f)
    {
        chomp;
        my @b = split//;
        push(@b,'.'); unshift(@b, '.');
        $a->[$r++] = \@b;
    }
    @b = split(//,'.' x $M+2);
    $a->[$r++] = \@b;

    if ($stage == 2)
    {
        $a->[1]->[1] = '#';
        $a->[1]->[$M] = '#';
        $a->[$M]->[1] = '#';
        $a->[$M]->[$M] = '#';
    }

    my $b;
    my $c;
    for my $step (1..100)
    {
        for my $x (1..$M)
        {
            for my $y (1..$M)
            {
                print $a->[$x]->[$y];
            }
            print "\n";
        }
        print "\n";


        for my $x (1..$M)
        {
            for my $y (1..$M)
            {
                my $ns =
                    ($a->[$x-1]->[$y-1] // '@') .
                    ($a->[$x-1]->[$y] // '@') .
                    ($a->[$x-1]->[$y+1] // '@') .
                    ($a->[$x]->[$y-1] // '@') .
                    ($a->[$x]->[$y+1] // '@') .
                    ($a->[$x+1]->[$y-1] // '@') .
                    ($a->[$x+1]->[$y] // '@') .
                    ($a->[$x+1]->[$y+1] // '@');
                 my $n = () = $ns =~ /#/g;

    #A light which is on stays on when 2 or 3 neighbors are on, and turns off otherwise.
    #A light which is off turns on if exactly 3 neighbors are on, and stays off otherwise.

                if ($a->[$x]->[$y] eq '#')
                {
                    $b->[$x]->[$y] = ($n >= 2 && $n <= 3) ? '#' : '.';
                }
                else
                {
                    $b->[$x]->[$y] = $n == 3 ? '#' : '.';

                }
            }
        }

        if ($stage == 2)
        {
            $b->[1]->[1] = '#';
            $b->[1]->[$M] = '#';
            $b->[$M]->[1] = '#';
            $b->[$M]->[$M] = '#';
        }

        $c = $a; # swap a/b
        $a = $b;
        $b = $c;
    }

    my $cnt = 0;
    for my $x (1..$M)
    {
        for my $y (1..$M)
        {
            print $a->[$x]->[$y];
            $cnt++ if $a->[$x]->[$y] eq '#';
        }
        print "\n";
    }
    push(@cnts, $cnt);
}

printf "stage 1: %d\n", $cnts[0];
printf "stage 2: %d\n", $cnts[1];