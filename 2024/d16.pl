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
use Array::Heap::PriorityQueue::Numeric;
$; = ',';

my @op = (
    [1,0],  # >
    [0,1],  # v
    [-1,0], # <
    [0,-1], # ^
);

my @f = read_file(\*STDIN, chomp => 1);

my $t;

my ($startx, $starty) = (0, 0);
my ($endx, $endy) = (0, 0);
my $startdir = 0;

my $y = 0;
for (@f)
{
    last if /^$/;
    my $x = 0;
    for my $v (split//)
    {
        ($startx, $starty) = ($x, $y) if $v eq 'S';
        ($endx, $endy) = ($x, $y) if $v eq 'E';
        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my $bestcost = 1_000_000_000;
my $bestdir = -1;

my $q = Array::Heap::PriorityQueue::Numeric->new();

my $dist;
$dist->{$startx,$starty,$startdir} = 0;
$q->add([$startx, $starty, $startdir, 0], 0);
while (my $e = $q->get())
{
    my ($x, $y, $dir, $cost) = @$e;
    my $ndir = $dir;
    for my $i (1..4)
    {
        my $d = $op[$ndir];
        my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);
        my $v = $t->{$nx,$ny};

        if ($v eq 'E')
        {
            if ($cost + 1 < $bestcost)
            {
                $bestcost = $cost + 1;
                $bestdir = $ndir;
            }
        }

        if ($v eq '.')
        {
            my $ncost = $cost + ($dir == $ndir ? 1 : 1001);
            $dist->{$nx,$ny,$ndir} = 1_000_000_000 unless exists $dist->{$nx,$ny,$ndir};

            if ($ncost <= $dist->{$nx,$ny,$ndir})
            {
                $dist->{$nx,$ny,$ndir} = $ncost;
                $q->add([$nx, $ny, $ndir, $ncost], $ncost);
            }
        }

        $ndir = ($ndir + 1) % 4;
    }
}

my %good;
my @bt = ();

push(@bt, [$endx, $endy, $bestdir, $bestcost]);
Q: while (my $e = shift(@bt))
{
    my ($x, $y, $dir, $cost) = @$e;
    $good{$x,$y} = 1;

    my $ndir = 0;
    for my $i (1..4)
    {
        my $d = $op[$ndir];
        my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);
        my $v = $t->{$nx,$ny};

        if ($v eq 'S')
        {
            $good{$nx,$ny} = 1;
            next;
        }

        if ($v eq '.')
        {
            for my $fdir (0..3)
            {
                my $ncost = $dist->{$nx,$ny,$fdir};
                next unless defined $ncost;

                my $diff = $cost - $ncost;
                next if $dir == $fdir && $diff != 1;
                next if $dir != $fdir && $diff != 1001;

                push(@bt, [$nx, $ny, $fdir, $ncost]);
            }
        }

        $ndir = ($ndir + 1) % 4;
    }

}

for my $py (0..$maxy)
{
    for my $px (0..$maxx)
    {
        print exists $good{$px,$py} ? 'O' : $t->{$px,$py};
    }
    print "\n";
}

say "Stage 1: ", $bestcost;
say "Stage 2: ", scalar keys %good;
