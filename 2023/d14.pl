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

# N W S E
my @ddx = qw/0 -1 0 1/;
my @ddy = qw/-1 0 1 0/;

my ($h, $w) = ($y, length($f[0]));
my ($maxx, $maxy) = ($w - 1, $h - 1);
my %v;
my %loads;
for my $c (0..$max)
{
    # north

    for my $dir (0..3)
    {
        my $dx = $ddx[$dir];
        my $dy = $ddy[$dir];

        my $sx = $dx == -1 ? 1 : 0;
        my $sy = $dy == -1 ? 1 : 0;

        my $ex = $dx == 1 ? $maxx - 1 : $maxx;
        my $ey = $dy == 1 ? $maxy - 1 : $maxy;

        my $moved = 0;
        while (1)
        {
            for my $y ($sy..$ey)
            {
                for my $x ($sx..$ex)
                {
                    if ($t->{$x,$y} eq 'O' && $t->{$x+$dx,$y+$dy} eq '.')
                    {
                        $t->{$x,$y} = '.';
                        $t->{$x+$dx,$y+$dy} = 'O';
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