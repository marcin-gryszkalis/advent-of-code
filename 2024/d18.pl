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

my $stage1 = 0;
my $stage2 = 0;

my @op = (
    [1,0],  # >
    [0,1],  # v
    [-1,0], # <
    [0,-1], # ^
);

my @f = read_file(\*STDIN, chomp => 1);

my $t;

my ($startx, $starty) = (0, 0);
my $startdir = 0;

my ($maxy, $maxx) = (0,0);
for (@f)
{
    my ($x,$y) = /(\d+)/g;
    $maxx = max($maxx, $x);
    $maxy = max($maxy, $y);
}

my ($endx, $endy) = ($maxy, $maxx);
my $limit = $maxx == 6 ? 12 : 1024;

my $i = 0;
while (1)
{
    $_ = shift @f;
    my ($x,$y) = /(\d+)/g;
    $t->{$x,$y} = "#";
    last if $i++ == $limit;
}


for my $py (0..$maxy)
{
    for my $px (0..$maxx)
    {
        $t->{$px,$py} = "." unless defined $t->{$px,$py};
#         print $t->{$px,$py};
    }
#    print "\n";
}

my $fall = -1;
while (1)
{
    my $bestcost = 1_000_000_000;

    my $dist;
    $dist->{$startx,$starty} = 0;

    my @q = ();
    my $vis = undef;
    push(@q, [$startx, $starty, 0]);

    Q: while (my $e = shift @q)
    {
        my ($x, $y, $cost) = @$e;

        next if $vis->{$x,$y};
        $vis->{$x,$y} = 1;

        for my $i (0..3)
        {
            my $d = $op[$i];
            my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);
            next if $nx > $maxx || $nx < 0 || $ny > $maxy || $ny < 0;

            my $v = $t->{$nx,$ny};

            if ($nx == $endx && $ny == $endy)
            {
                if ($cost + 1 < $bestcost)
                {
                    $bestcost = $cost + 1;
                    $stage1 = $bestcost unless $stage1;
                    last Q;
                }
            }

            if ($v eq '.')
            {
                my $ncost = $cost + 1;
                $dist->{$nx,$ny} = 1_000_000_000 unless exists $dist->{$nx,$ny};

                if ($ncost <= $dist->{$nx,$ny})
                {
                    $dist->{$nx,$ny} = $ncost;
                    push(@q, [$nx, $ny, $ncost]);
                }
            }

        }
    }

    if ($bestcost == 1_000_000_000)
    {
        $stage2 = $fall;
        last;
    }

    $fall = shift @f;
    last unless defined $fall;
    my ($x,$y) = $fall =~/(\d+)/g;
    $t->{$x,$y} = "#";

}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;

