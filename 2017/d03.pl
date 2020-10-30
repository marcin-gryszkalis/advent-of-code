#!/usr/bin/perl
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my $x = 265149;

my $level = 2; # level 1 is sick case
while (1)
{
    my $side = $level * 2 - 1;

    # level starts at
    my $lstart = (2 * $level - 3)**2 + 1;
    #print "level $level starts at $lstart\n";

    last if $lstart > $x; # too far
    $level++;
}

$level--; # previous is the right one
my $side = $level * 2 - 1;
my $lstart = (2 * $level - 3)**2 + 1;

my $min_dn = $side;
for my $n (0..3) # 4 sides
{
    # middle digits are at
    my $mid = $lstart + (($side-1)/2)-1 + ($side-1)*$n;

    my $dn = abs($mid - $x);
#    print "dn ($mid,$x) = $dn\n";

    $min_dn = $dn if $dn < $min_dn;
}

my $dist = $level - 1 + $min_dn;
printf "stage 1: %d + %d = %d\n", $level-1, $min_dn, $dist;


# bok = level*2 - 1
# obwod = 4 * bok - 4 =
# 4 * (level*2 - 1) - 4 =
# 8*level - 8 =
# 8*(level - 1)

# level zaczyna się od s = (2*(level-1)+1)^2 + 1

# srodkowe cyfry to s + ((bok-1)/2)-1) + (bok-1)*n [n=0..3]