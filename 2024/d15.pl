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

my $op = {
    '<' => { 'x' => -1, 'y' => 0 },
    '>' => { 'x' => 1, 'y' => 0 },
    '^' => { 'x' => 0, 'y' => -1 },
    'v' => { 'x' => 0, 'y' => 1 }
};

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $t;

my ($x, $y) = (0, 0);
my ($startx, $starty) = (0, 0);
for (@f)
{
    last if /^$/;
    $x = 0;
    for my $v (split//)
    {
        if ($v eq '@')
        {
            $startx = $x;
            $starty = $y;
            $v = '.';
        }

        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my @path = map { split // } grep { /[<>v^]/ } @f;

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

($x, $y) = ($startx, $starty);
M: for my $m (@path)
{
    my $dx = $op->{$m}->{x};
    my $dy = $op->{$m}->{y};

    my ($cx, $cy) = ($x, $y);
    while (1)
    {
        $cx += $dx;
        $cy += $dy;
#        say "? $t->{$cx,$cy}";
        next M if $t->{$cx,$cy} eq '#';
        last if $t->{$cx,$cy} eq '.';
    }

#    say "$x,$y -- $dx,$dy -- $cx,$cy";
    while ($cx != $x || $cy != $y)
    {
#        say "move ",$t->{$cx - $dx, $cy - $dy}," from (",$cx-$dx,",",$cy-$dy,") to ($cx,$cy)";
        $t->{$cx,$cy} = $t->{$cx - $dx, $cy - $dy};
        $cx -= $dx;
        $cy -= $dy;
    }

    $x += $dx;
    $y += $dy;

}

for my $py (0..$maxy)
{
    for my $px (0..$maxx)
    {
        $stage1 += (100 * $py + $px) if $t->{$px,$py} eq 'O';
        if ($px == $x && $py == $y) { print "@"; next }
        print $t->{$px,$py};
    }

    print "\n";
}


say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;