#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @xp1;
my @zdiv1;
my @yp1;

my $i = 0;
while (<>)
{
    if (/add x (\S+)/ && $1 ne 'z')
    {
        push(@xp1, $1);
    }
    elsif (/div z (\S+)/)
    {
        push(@zdiv1, $1);
    }
    elsif (/add y (\S+)/ && $i++ % 4 == 3)
    {
        push(@yp1, $1);
    }
}

for my $stage (1..2)
{
    my @input;
    my @stack;
    my @stackv;
    for my $i (0..13)
    {
        if ($zdiv1[$i] == 1)
        {
            push(@stack, $i);
            push(@stackv, $yp1[$i]);
        }
        else
        {
            my $k = pop(@stack);
            my $v = pop(@stackv);

            $v += $xp1[$i];
#            print "input[$k] + $v == input[$i] \n";

            if ($stage == 1)
            {
                if ($v > 0)
                {
                    $input[$k] = 9 - $v;
                    $input[$i] = 9;
                }
                else
                {
                    $input[$k] = 9;
                    $input[$i] = 9 + $v;
                }
            }
            else
            {
                if ($v > 0)
                {
                    $input[$k] = 1;
                    $input[$i] = $v + 1;
                }
                else
                {
                    $input[$k] = -$v + 1;
                    $input[$i] = 1;
                }

            }
        }
    }

    printf("Stage %d: %s\n", $stage, join("", @input));

    # validation
    my $w = 0;
    my $x = 0;
    my $y = 0;
    my $z = 0;

    for my $k (0..13)
    {
        # re code
        $w = $input[$k];

        $x = (($z % 26 + $xp1[$k]) != $w) ? 1 : 0; # depends on z from prev round!

        $z = int($z/$zdiv1[$k]) * (25 * $x + 1); # (z / (1 OR 26)) * (25 or 1)

        $y = $w + $yp1[$k]; # always > 0 (1..25)

        $y *= $x; # x = 0 or 1
        $z += $y; # this has to be avoided :)
    }

    die "not valid" if $z != 0;
}
