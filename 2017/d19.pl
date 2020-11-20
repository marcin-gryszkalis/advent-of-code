#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $map;
my $i = 0;
my $x = 0;
while (<>)
{
    chomp;
    $x = index($_, '|') if $i == 0;
    my @row = split//;
    $map->[$i++] = \@row;
}

my $y = 0;

my $dx = 0;
my $dy = 1;
my $dir = 'v'; # v or h

my $stage1 = '';
my $step = -1;
while (1)
{
    $step++;
    # print "$x,$y ($dx,$dy) $stage1\n";

    if ($map->[$y]->[$x] =~ ' ')
    {
        last;
    }
    if ($map->[$y]->[$x] =~ /([A-Z])/)
    {
        $stage1 .= $1;
    }
    elsif ($map->[$y]->[$x] eq '+')
    {
        if ($dir eq 'v')
        {
            $dir = 'h';
            if ($map->[$y]->[$x-1] eq '-') # turn W
            {
                $dx = -1; $dy = 0;
            }
            elsif ($map->[$y]->[$x+1] eq '-') # E
            {
                $dx = 1; $dy = 0;
            }
            else
            {
                last;
            }
        }
        else
        {
            $dir = 'v';
            if ($map->[$y-1]->[$x] eq '|') # turn N
            {
                $dx = 0; $dy = -1;
            }
            elsif ($map->[$y+1]->[$x] eq '|') # S
            {
                $dx = 0; $dy = 1;
            }
            else
            {
                last;
            }
        }
    }

    $x += $dx;
    $y += $dy;
}

printf "stage 1: %s\n", $stage1;
printf "stage 2: %s\n", $step;