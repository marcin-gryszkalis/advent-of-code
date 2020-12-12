#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $stage1 = 0;
my $stage2 = 0;

my %dx = qw/N  0  S 0  E 1  W -1/;
my %dy = qw/N -1  S 1  E 0  W  0/;

my %dm = qw/0 E 90 S 180 W 270 N/;

#########
# stage 1

my $x = 0; # ship
my $y = 0;
my $d = 0; # east

for (@ff)
{
    m/(.)(\d+)/;
    my $a = $1;
    my $b = $2;

    if ($a =~ /[NSEW]/)
    {
        $x += $dx{$a} * $b;
        $y += $dy{$a} * $b;
    }
    elsif ($a eq 'F')
    {
        $x += $dx{$dm{$d}} * $b;
        $y += $dy{$dm{$d}} * $b;
    }
    elsif ($a eq 'R')
    {
        $d = ($d + $b) % 360;
    }
    elsif ($a eq 'L')
    {
        $d = ($d - $b + 360) % 360;
    }
    else { die $_ }

    # print "$a=$b x=$x y=$y d=$d ($dm{$d})\n";
}

$stage1 = abs($x) + abs($y);
print "stage 1: $stage1\n";

#########
# stage 2

$x = 10; # waypoint relative pos
$y = -1;

my $sx = 0; # ship
my $sy = 0;

for (@ff)
{
    m/(.)(\d+)/;
    my $a = $1;
    my $b = $2;

    if ($a =~ /[NSEW]/)
    {
        $x += $dx{$a} * $b;
        $y += $dy{$a} * $b;
    }
    elsif ($a eq 'F')
    {
        $sx += $x * $b;
        $sy += $y * $b;
    }
    elsif ($a eq 'R')
    {
        ($x,$y) = (-$y,$x) for (1..$b/90)
    }
    elsif ($a eq 'L')
    {
        ($x,$y) = ($y,-$x) for (1..$b/90)
    }
    else { die $_ }

    # print "$a=$b x=$x y=$y sx=$sx sy=$sy\n";
}

$stage2 = abs($sx) + abs($sy);
print "stage 2: $stage2\n";
