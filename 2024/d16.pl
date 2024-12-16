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

my $stage1 = 0;
my $stage2 = 0;

my $t;

my ($x, $y) = (0, 0);
my ($startx, $starty) = (0, 0);
my $startdir = 0;

for (@f)
{
    last if /^$/;
    $x = 0;
    for my $v (split//)
    {
        if ($v eq 'S')
        {
            $startx = $x;
            $starty = $y;
        }

        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my @path = map { split // } grep { /[<>v^]/ } @f;

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my @pathcosts = ();

my $q = Array::Heap::PriorityQueue::Numeric->new();

my $dist;
$dist->{$startx,$starty,$startdir} = 0;
$q->add([$startx, $starty, $startdir, 0], 0);
Q: while (my $e = $q->get())
{
    my ($x, $y, $dir, $cost) = @$e;
    # say "$x, $y ($dir) -- $cost";
    my $ndir = $dir;
    for my $i (1..4)
    {
        my $d = $op[$ndir];
        my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);
        my $v = $t->{$nx,$ny};

        if ($v eq 'E')
        {
            say "E: ", $cost + 1;
            push(@pathcosts, $cost + 1);
        }

        if ($v eq '.')
        {
            my $ncost = $cost + ($dir == $ndir ? 1 : 1001);
            $dist->{$nx,$ny,$ndir} = 1_000_000_000 unless exists $dist->{$nx,$ny,$ndir};

            if ($ncost < $dist->{$nx,$ny,$ndir})
            {
                $dist->{$nx,$ny,$ndir} = $ncost;
                $q->add([$nx, $ny, $ndir, $ncost], $ncost);
            }
        }
        else # wall or visited or S
        {

        }

        $ndir = ($ndir + 1) % 4;
    }

}

for my $py (0..$maxy)
{
    for my $px (0..$maxx)
    {
        print $t->{$px,$py};
    }
    print "\n";
}


say "Stage 1: ", min(@pathcosts);
say "Stage 2: ", $stage2;

# too high 111488
# 111480 ?