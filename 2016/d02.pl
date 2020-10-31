#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my @f = read_file(\*STDIN);

my @pad1 = ([1,2,3], [4,5,6], [7,8,9]);
my @pad2 = ([0,0,1,0,0], [0,2,3,4,0], [5,6,7,8,9],[0,10,11,12,0],[0,0,13,0,0]);
my @pads = (\@pad1, \@pad2);

my @startx = (1, 0);
my @starty = (1, 2);
my @maxx = (2,4);
my @maxy = (2,4);

my $dx = { L => -1, R => 1, U => 0, D => 0 };
my $dy = { L => 0, R => 0, U => -1, D => 1 };

for my $stage (0..1)
{

    my $pad = $pads[$stage];
    my $code = '';

    my $mx = $maxx[$stage];
    my $my = $maxy[$stage];

    my $x = $startx[$stage];
    my $y = $starty[$stage];

    my $i = 0;
    for (@f)
    {
        chomp;
        my @a = split//;

        for my $m (@a)
        {
            my $nx = $x + $dx->{$m};
            my $ny = $y + $dy->{$m};
#            print "$i ($x,$y) - $m -> ($nx,$ny)\n";

            if (
                $nx >= 0 && $nx <= $mx &&
                $ny >= 0 && $ny <= $my &&
                $pad->[$ny][$nx] != 0 # always true in 1st stage
                )
            {
                $x = $nx;
                $y = $ny;
            }
        }

        $code .= sprintf("%X", $pad->[$y][$x]); # reverse y-x!
        $i++;
    }

    printf "stage %d: %s\n", $stage+1, $code;
}

