#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

my $max = 1_000_000_000 - 1;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;


        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxx, $maxy) = ($w - 1, $h - 1);
my %v;
my %loads;
for my $c (0..$max)
{
    # north
    my $moved = 0;
    while (1)
    {
        for my $y (1..$maxy)
        {
            for my $x (0..$maxx)
            {
                if ($t->{$x,$y} eq 'O' && $t->{$x,$y-1} eq '.')
                {
                    $t->{$x,$y} = '.';
                    $t->{$x,$y-1} = 'O';
                    $moved = 1;
                }
            }
        }

        last unless $moved;
        $moved = 0;
    }

    if ($stage1 == 0)
    {
        $stage1 = sum(map { $maxy - (split/$;/)[1] + 1 } grep { $t->{$_} eq 'O' } keys %$t);
    }

    # west
    $moved = 0;
    while (1)
    {
        for my $y (0..$maxy)
        {
            for my $x (1..$maxx)
            {
                if ($t->{$x,$y} eq 'O' && $t->{$x-1,$y} eq '.')
                {
                    $t->{$x,$y} = '.';
                    $t->{$x-1,$y} = 'O';
                    $moved = 1;
                }
            }
        }

        last unless $moved;
        $moved = 0;
    }

    # south
    $moved = 0;
    while (1)
    {
        for my $y (0..$maxy-1)
        {
            for my $x (0..$maxx)
            {
                if ($t->{$x,$y} eq 'O' && $t->{$x,$y+1} eq '.')
                {
                    $t->{$x,$y} = '.';
                    $t->{$x,$y+1} = 'O';
                    $moved = 1;
                }
            }
        }

        last unless $moved;
        $moved = 0;
    }

    # east
    $moved = 0;
    while (1)
    {
        for my $y (0..$maxy)
        {
            for my $x (0..$maxx-1)
            {
                if ($t->{$x,$y} eq 'O' && $t->{$x+1,$y} eq '.')
                {
                    $t->{$x,$y} = '.';
                    $t->{$x+1,$y} = 'O';
                    $moved = 1;
                }
            }
        }

        last unless $moved;
        $moved = 0;
    }

    my $h = '';
    my $load = 0;
    for my $y (0..$maxy)
    {
        for my $x (0..$maxx)
        {
            $load += $maxy - $y + 1 if $t->{$x,$y} eq 'O';
            $h .= $t->{$x,$y};
        }
    }

#    print "$c $load $h \n";
    if (exists $v{$h} )
    {
        my $off = $v{$h};
        my $len = $c - $v{$h};

        my $target = ($max - $off) % $len + $off;
        $stage2 = $loads{$target};
        last;
    }

    $v{$h} = $c;
    $loads{$c} = $load;

}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;