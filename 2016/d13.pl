#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Digest::MD5 qw(md5_hex);

my $RED="\e[31m"; 
my $RST="\e[0m";

my $designer = 1352;
# $designer = 10;

my $destx = 31;
my $desty = 39;
# $destx = 7;
# $desty = 4;

my $maxx = $destx + 20;
my $maxy = $desty + 20;

my $reachable = 0;

sub bits($)
{
    my $n = shift;
    my $c = 0;
    while ($n) 
    {
        $c += $n & 1;
        $n >>= 1;
    }
    return $c;
}

my $map;

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        my $k = $x*$x + 3*$x + 2*$x*$y + $y + $y*$y;
        $k += $designer;

#        printf "$x $y $k %b %s\n", $k, bits($k);

        my $c = bits($k) % 2 == 0 ? "." : "#";

        $map->{$x,$y} = $c;

        $c = "${RED}X$RST" if $x == $destx && $y == $desty;
        print "$c";
    }

    print "\n";
}

my $visited;

my $state;
$state->{x} = 1;
$state->{y} = 1;
$state->{level} = 0;
$state->{path} = "1,1 ";
my @sq;
push(@sq, $state);
$visited->{1,1} = 1;

while (1)
{
    my $state = shift(@sq);
    die unless defined $state;

    print "$state->{level}: $state->{x} $state->{y}\n";

    $reachable++ if $state->{level} <= 50; # assume stage1 result is larger!

    if ($state->{x} == $destx && $state->{y} == $desty)
    {
        print "Stage 1: $state->{level} $state->{path}\n";
        print "Stage 2: $reachable\n";
        exit;        
    }

    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            next if abs($dx) + abs($dy) != 1;

            my $nx = $state->{x} + $dx;
            my $ny = $state->{y} + $dy;

            next if $nx < 0 || $nx > $maxx;
            next if $ny < 0 || $ny > $maxy;

            next if $map->{$nx,$ny} eq '#';
            next if $visited->{$nx,$ny};

            my $nstate = undef;
            $nstate->{x} = $nx;
            $nstate->{y} = $ny;
            $nstate->{level} = $state->{level} + 1;
            $nstate->{path} = $state->{path} . "$nx,$ny ";
            push(@sq, $nstate);
            $visited->{$nx,$ny} = 1;
        }
    }
}
