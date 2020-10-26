#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

# stage 2 limit, 32 for d06a.txt
my $good = 10000;

# area limits
my $ax1 = 0;
my $ax2 = 0;
my $ay1 = 0;
my $ay2 = 0;

my %area = ();
my %owners = ();

while (<>)
{
    chomp;
    my ($x,$y) = split/,\s+/;
    $area{"$x:$y"} = 0;

    $ax1 = $x if $x < $ax1;
    $ax2 = $x if $x > $ax2;
    $ay1 = $y if $y < $ay1;
    $ay2 = $y if $y > $ay2;
}

$ax1--; $ay1--;
$ax2++; $ay2++;

for my $x ($ax1..$ax2)
{
    for my $y ($ay1..$ay2)
    {
        my $mind = $ax2-$ax1 + $ay2-$ay1; # safe starting minimum
        my $owner = -1;

        for my $p (keys %area)
        {
            my ($px,$py) = split/:/, $p;

            my $d = abs($x-$px) + abs($y-$py);
            if ($d < $mind)
            {
                $mind = $d;
                $owner = $p;
            }
            elsif ($d == $mind)
            {
                $owner = ".";
            }
        }

        $owners{"$x:$y"} = $owner;
        $area{$owner}++ if $owner ne '.';
    }
}

# edges -> infinite areas
for my $y ($ay1..$ay2)
{
    $area{$owners{"$ax1:$y"}} = -1;
    $area{$owners{"$ax2:$y"}} = -1;
}
for my $x ($ax1..$ax2)
{
    $area{$owners{"$x:$ay1"}} = -1;
    $area{$owners{"$x:$ay2"}} = -1;
}
delete $area{"."};

# largest non-infinite area
my $max = 0;
my $maxowner = -1;
for my $p (keys %area)
{
    if ($area{$p} > $max)
    {
        $max = $area{$p};
        $maxowner = $p;
    }
}
print "stage 1: $maxowner with area of $max\n";

my $goodcount = 0;
for my $x ($ax1..$ax2)
{
    for my $y ($ay1..$ay2)
    {
        my $d = 0;
        for my $p (keys %area)
        {
            my ($px,$py) = split/:/, $p;
            my $d =
            $d += abs($x-$px) + abs($y-$py);
            last if $d >= $good;
        }

        $goodcount++ if $d < $good;
    }
}

print "stage 2: $goodcount\n";
