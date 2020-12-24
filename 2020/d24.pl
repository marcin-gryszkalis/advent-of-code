#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

$; = ',';

# directions
my @x = qw/e se sw w nw ne/;
         # 0  1  2 3  4  5

# cube coords for hex grid
my %t = (
    'e'  => [1,-1,0],
    'se' => [0,-1,1],
    'sw' => [-1,0,1],
    'w'  => [-1,1,0],
    'nw' => [0,1,-1],
    'ne' => [1,0,-1],
);

my $stage1 = 0;
my $stage2 = 0;

my @t;
for (@ff)
{
    s/(nw|ne|sw|se)/,${1},/g;
    s/([ew])([ew])/,${1},${2},/g;

    s/,+/,/g;
    s/(^,|,$)//g;

    push(@t, $_);
}

my $space;

my ($minx, $maxx) = (0,0);
my ($miny, $maxy) = (0,0);
my ($minz, $maxz) = (0,0);

for my $k (@t)
{
    my ($x,$y,$z) = (0,0,0);

    for my $s (split/,/, $k)
    {
        my $d = $t{$s};
        $x += $d->[0];
        $y += $d->[1];
        $z += $d->[2];
    }

    $space->{$x,$y,$z} = (($space->{$x,$y,$z} // 0) + 1) % 2;

#    print "$k --> $x,$y,$z\n";
    $minx = $x if $x < $minx; $maxx = $x if $x > $maxx;
    $miny = $y if $y < $miny; $maxy = $y if $y > $maxy;
    $minz = $z if $z < $minz; $maxz = $z if $z > $maxz;
}

$stage1 = sum(values %$space);

for my $day (1..100)
{
    my $spacer = clone($space);

    for my $x ($minx-1..$maxx+1)
    {
        for my $y ($miny-1..$maxy+1)
        {
            for my $z ($minz-1..$maxz+1)
            {
                next unless $x + $y + $z == 0;

                my $bn = 0;
                for my $nt (values %t)
                {
                    my $no = ($x + $nt->[0]).",".($y+$nt->[1]).",".($z+$nt->[2]);
                    $bn++ if (($spacer->{$no} // 0) == 1);
                }

                #Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white.
                if (($spacer->{$x,$y,$z} // 0) == 1 && ($bn == 0 || $bn > 2))
                {
                    $space->{$x,$y,$z} = 0;
                }
                #Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black.
                elsif (($spacer->{$x,$y,$z} // 0) == 0 && $bn == 2)
                {
                    $space->{$x,$y,$z} = 1;
                }

                if (exists $space->{$x,$y,$z})
                {
                    $minx = $x if $x < $minx; $maxx = $x if $x > $maxx;
                    $miny = $y if $y < $miny; $maxy = $y if $y > $maxy;
                    $minz = $z if $z < $minz; $maxz = $z if $z > $maxz;
                }

            }
        }
    }

    printf "day $day %d\n", sum(values %$space);
}

$stage2 = sum(values %$space);

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";
