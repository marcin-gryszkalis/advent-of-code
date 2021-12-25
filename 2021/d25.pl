#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;


my @f = read_file(\*STDIN, chomp => 1);

my $o;

my $y = 0;
for (@f)
{
    my $x = 0;
    for my $e (split//)
    {
        $o->{$x,$y} = $e;
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);

my $maxy = $h - 1;
my $maxx = $w - 1;

my @q;

my $step = 0;
while (1)
{
    $step++;

    my $moved = 0;

    my $t = '>';
    for my $y (0..$maxy)
    {
        for my $x (0..$maxx)
        {
            if ($o->{$x,$y} eq $t && $o->{($x+1) % $w,$y} eq '.')
            {
                push(@q, [$x,$y]);
            }
        }
    }

    while (my $e = pop(@q))
    {
        $o->{($e->[0]+1) % $w,$e->[1]} = $t;
        $o->{$e->[0],$e->[1]} = '.';
        $moved++;
    }


    $t = 'v';
    for my $y (0..$maxy)
    {
        for my $x (0..$maxx)
        {
            if ($o->{$x,$y} eq $t && $o->{$x,($y+1) % $h} eq '.')
            {
                push(@q, [$x,$y]);
            }
        }
    }

    while (my $e = pop(@q))
    {
        $o->{$e->[0],($e->[1]+1) % $h} = $t;
        $o->{$e->[0],$e->[1]} = '.';
        $moved++;
    }

    # print "step: $step -- moved: $moved\n";
    # for my $y (0..$maxy)
    # {
    #     for my $x (0..$maxx)
    #     {
    #         print $o->{$x,$y};
    #     }
    #     print "\n";
    # }
    # print "\n";

    last if $moved == 0;
}

printf "Stage 1: %s\n", $step;
