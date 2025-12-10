#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %xs;
my %ys;

for (@l)
{
    my ($x,$y) = split/,/;
    $xs{$x} = 1;
    $ys{$y} = 1;
}

my (%mx,%my);
my $xi = 0;
my $yi = 0;

for my $x (sort { $a <=> $b } keys %xs)
{
    $mx{$x} = $xi;
    $xi++;
}

for my $y (sort { $a <=> $b } keys %ys)
{
    $my{$y} = $yi;
    $yi++;
}

my $maxx = $xi;
my $maxy = $yi;

my $space;

my $px = -1;
my $py = -1;
for ((@l,$l[0]))
{
    my ($x,$y) = split/,/;
    $x = $mx{$x};
    $y = $my{$y};

    if ($x == $px) # vertical
    {
        for my $dy (min($py,$y)..max($py,$y))
        {
            $space->{$x,$dy} = '#';
        }
    }
    elsif ($y == $py) # horizontal
    {
        for my $dx (min($px,$x)..max($px,$x))
        {
            $space->{$dx,$y} = '#';
        }
    }
    else
    {
        # first point
    }

    $px = $x;
    $py = $y;
}

# flood fill
my @qx;
my @qy;

my ($xx,$yy) = split/,/,$l[0];
$xx = $mx{$xx};
$yy = $mx{$yy};
$xx++; # could be better automation for finding point "inside" to start fill ;)
$yy++;
push(@qx, $xx);
push(@qy, $yy);

while (1)
{
    my $x = pop(@qx);
    last unless defined $x;
    my $y = pop(@qy);

    die if $x < 0 || $y < 0 || $x > $maxx || $y > $maxy; # broken fill

    $space->{$x,$y} = '#';
    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            next if $dx == 0 && $dy == 0;
            if (!exists $space->{$x+$dx,$y+$dy})
            {
                push(@qx, $x+$dx);
                push(@qy, $y+$dy);
            }
        }
    }
}

# for my $y (0..$maxy)
# {
#     for my $x (0..$maxx)
#     {
#         print exists $space->{$x,$y} ? '#' : '.';
#     }
#     print "\n";
# }

my $t;
my $r;
for (@l)
{
    my ($x1,$y1) = split/,/;

    for (keys %$t)
    {
        my ($x2,$y2) = split/,/;
        my $m = (abs($x2-$x1)+1) * (abs($y2-$y1)+1);
        $stage1 = max($stage1, $m);
#        say "($x1,$y1) ($x2,$y2) = $m ($stage1)";

        next if $x1 == $x2 || $y1 == $y2; # skip flat rectangles, not generic but ok ;)

        $r->{$mx{$x1},$my{$y1},$mx{$x2},$my{$y2}} = $m; # save rectangle (real size) in reduced space
    }
    $t->{$x1,$y1} = 1;
}


my $i = 0;
R: for my $rk (sort { $r->{$b} <=> $r->{$a} } keys %$r)
{
#    say "$i: $rk = $r->{$rk}";
    $i++;
    my ($x1,$y1,$x2,$y2) = split/,/, $rk;

    for my $x (min($x1,$x2)..max($x1,$x2))
    {
        next R unless exists $space->{$x,$y1};
        next R unless exists $space->{$x,$y2};
    }

    for my $y (min($y1,$y2)..max($y1,$y2))
    {
        next R unless exists $space->{$x1,$y};
        next R unless exists $space->{$x2,$y};
    }

    $stage2 = $r->{$rk};
    last;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;

