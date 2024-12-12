#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

no warnings 'recursion';

my @f = read_file(\*STDIN, chomp => 1);

my $t;

my $x = 0;
my $y = 0;
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
my ($maxy, $maxx) = ($h - 1, $w - 1);

my $visited;
my $checked; # perimeters
my (@areas, @pers, @sides);

for $y (0..$maxy)
{
    for $x (0..$maxx)
    {
        next if exists $visited->{$x,$y};

        my ($a, $p, $s) = hike($x, $y, $t->{$x,$y});
        push(@areas, $a);
        push(@pers, $p);
        push(@sides, $s);
    }
}

sub hike($x, $y, $v)
{
    return (0,0,0) if exists $visited->{$x,$y};
    $visited->{$x,$y} = 1;
    my ($area, $per, $side) = (1, 0, 0);

    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            next if abs($dx + $dy) != 1;

            my ($nx, $ny) = ($x + $dx, $y + $dy);

            if ($nx < 0 || $nx > $maxx || $ny < 0 || $ny > $maxy) # outside border
            {
                unless (exists $checked->{$x,$y,$dx,$dy})
                {
                    $side++;
                    check($x, $y, $dx, $dy, $v);
                }
                $per++;
                next;
            }

            if ($t->{$nx,$ny} eq $v)
            {
                my ($a, $p, $s) = hike($nx, $ny, $v);
                $area += $a;
                $per += $p;
                $side += $s;
            }
            else
            {
                unless (exists $checked->{$x,$y,$dx,$dy})
                {
                    $side++;
                    check($x, $y, $dx, $dy, $v);
                }
                $per++;
            }
        }

    }

    return ($area, $per, $side);
}

sub check($px, $py, $pdx, $pdy, $v)
{
    $checked->{$px,$py,$pdx,$pdy} = 1;
    for my $dir (-1, 1)
    {
        my ($dx, $dy) = (0, 0);
        if (abs($pdx) == 1) # i.e. for left perimeter we move up & down
        {
            $dy = $dir;
        }
        else
        {
            $dx = $dir;
        }

        my ($x, $y) = ($px, $py);

        while (1)
        {
            $x += $dx;
            $y += $dy;
            last if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
            last if $t->{$x, $y} ne $v;
            my ($cx, $cy) = ($x + $pdx, $y + $pdy);
            if ($cx < 0 || $cx > $maxx || $cy < 0 || $cy > $maxy)
            {
                $checked->{$x,$y,$pdx,$pdy} = 1;
                next;
            }

            last if $t->{$cx,$cy} eq $v;

            $checked->{$x,$y,$pdx,$pdy} = 1;
        }
    }
}

say "Stage 1: ", sum pairwise { $a * $b } @areas, @pers;
say "Stage 2: ", sum pairwise { $a * $b } @areas, @sides;
