#!/usr/bin/perl
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my $search = 265149;

my $level = 2; # level 1 is sick case
while (1)
{
    my $side = $level * 2 - 1;

    # level starts at
    my $lstart = (2 * $level - 3)**2 + 1;

    last if $lstart > $search; # too far
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
    my $dn = abs($mid - $search);
    $min_dn = $dn if $dn < $min_dn;
}

my $dist = $level - 1 + $min_dn;
printf "stage 1: %d + %d = %d\n", $level-1, $min_dn, $dist;


# stage 2, a sim
my $h;
$h->{0}->{0} = 1; # x,y
my $x = 0;
my $y = 0;

my $d = 0; # direction
my @dx = qw/1 0 -1 0/;
my @dy = qw/0 1 0 -1/;

my $v = 0;
my $i = 0;
while (1)
{
    # step forward
    $x = $x + $dx[$d];
    $y = $y + $dy[$d];
    # print "$i: x($x) y($y) d($d)\n";

    # sum neighbours
    $v = 0;
    for my $ax (-1..1)
    {
        for my $ay (-1..1)
        {
            next unless exists $h->{$x + $ax}->{$y + $ay};
            $v += $h->{$x + $ax}->{$y + $ay};
        }
    }
    $h->{$x}->{$y} = $v;

    last if $v > $search;

    # check if there's empty box on my left
    my $nd = ($d + 1) % 4;
    if (!exists $h->{$x + $dx[$nd]}->{$y + $dy[$nd]}) # make a turn
    {
        $d = $nd;
    }

    $i++;
}

printf "stage 2: %d at step %d\n", $v, $i;
