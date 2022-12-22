#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Math::Prime::Util qw/gcd/;
$; = ',';

my @f =  read_file(\*STDIN, chomp => 1);
my $tx = pop @f;
pop @f; # empty line

my $maxy = scalar(@f) - 1;
my $maxx = max(map { length $_ } @f) - 1;
my $w = gcd($maxx+1,$maxy+1); # one face width
my $fmaxxy = $w - 1; # one face maxy/maxy (it's a square)

my ($sx,$sy) = (-1,0); # start
my $m;
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {
        next if !defined $r[$x] || $r[$x] eq ' ';
        $m->{$x,$y} = $r[$x];
        $sx = $x if $sx == -1 && $r[$x] eq '.';
    }
}

my @t = $tx =~ m/(\d+|[LR])/g;

my @mov = ([1,0], [0,1],[-1,0], [0,-1]);

my @g = qw/> V < ^/; # for drawing

my $x = $sx;
my $y = $sy;
my $dir = 0;

$m->{$x,$y} = $g[$dir];

# map face number to map position
my %facemulx;
my %facemuly;
my $i = 1;
for my $y (0..$maxy/$w)
{
    for my $x (0..$maxx/$w)
    {
        if (exists $m->{$x*$w,$y*$w})
        {
            $facemulx{$i} = $x;
            $facemuly{$i} = $y;
            $i++;
        }
    }
}

my %border = qw/
r 0
d 1
l 2
u 3
/;

my %rules = (
'1r' => '2l',
'1d' => '3u',
'1l' => '4l',
'1u' => '6l',

'2r' => '5r',
'2d' => '3r',
'2l' => '1r',
'2u' => '6d',

'3r' => '2d',
'3d' => '5u',
'3l' => '4u',
'3u' => '1d',

'4r' => '5l',
'4d' => '6u',
'4l' => '1l',
'4u' => '3l',

'5r' => '2r',
'5d' => '6r',
'5l' => '4r',
'5u' => '3d',

'6r' => '5d',
'6d' => '2u',
'6l' => '1u',
'6u' => '4d',
);

my $face = 1;
for my $op (@t)
{
    print "OP($op) $x, $y [$dir]: $op\n";
    if ($op =~ /\d/)
    {
        while (1)
        {
            my $dx = $mov[$dir][0];
            my $dy = $mov[$dir][1];

            my ($px, $py, $pdir, $pface) = ($x, $y, $dir, $face);

            print "::: $face -- $x, $y [$dir]: op $op\n";

            my $fx = $x % $w;
            my $fy = $y % $w;

            my $b = undef; # are we crossing the border? which one?
            $b = 'r' if $fx == $fmaxxy && $dx == 1;
            $b = 'd' if $fy == $fmaxxy && $dy == 1;
            $b = 'l' if $fx == 0 && $dx == -1;
            $b = 'u' if $fy == 0 && $dy == -1;

            if (defined $b)
            {
                my ($newface, $nb) = split//,$rules{"${face}$b"};
                my $bnb = "$b$nb";

                print "rule($face$b => $newface$nb)\n";

                print "FX ($fx,$fy) -> ";

                if ($bnb =~ /(lr|rl|ud|du)/)
                {
                    ($fx,$fy) = (($fx + $dx) % $w, ($fy + $dy) % $w)
                }
                elsif ($bnb =~ /(uu|dd)/)
                {
                    print "ROT-180-UD ";
                    ($fx,$fy) = ($fmaxxy - $fx,$fy);
                    $dir = ($dir + 2) % 4;
                }
                elsif ($bnb =~ /(ll|rr)/)
                {
                    print "ROT-180-RL ";
                    ($fx,$fy) = ($fx,$fmaxxy - $fy);
                    $dir = ($dir + 2) % 4;
                }
                elsif ($bnb =~ /(ru|ld)/)
                {
                    print "ROT-CW-AC ";
                    ($fx,$fy) = ($fmaxxy - $fy, $fmaxxy - $fx);
                    $dir = ($dir - 1) % 4;
                }
                elsif ($bnb =~ /(rd|lu)/)
                {
                    print "ROT-CW-BD ";
                    ($fx,$fy) = ($fy, $fx);
                    $dir = ($dir - 1) % 4;
                }
                elsif ($bnb =~ /(ur|dl)/)
                {
                    print "ROT-CCW-AC ";
                    ($fx,$fy) = ($fmaxxy - $fy, $fmaxxy - $fx);
                    $dir = ($dir + 1) % 4;
                }
                elsif ($bnb =~ /(dr|ul)/)
                {
                    print "ROT-CCW-BD ";
                    ($fx,$fy) = ($fy, $fx);
                    $dir = ($dir + 1) % 4;
                }

                print "($fx,$fy) dir: $dir\n";

                $x = $fx + $w * $facemulx{$newface};
                $y = $fy + $w * $facemuly{$newface};
                $face = $newface;
            }
            else # standard movement
            {
                $x += $dx;
                $y += $dy;
            }

            die "OOB $x,$y" unless exists $m->{$x,$y}; # assert

            if ($m->{$x,$y} eq '#') # step back
            {
                ($x, $y, $dir, $face) = ($px, $py, $pdir, $pface);
                last;
            }

            $m->{$x,$y} = $g[$dir];

            $op--;
            last if $op == 0;
        }
    }
    else
    {
        $dir = ($dir + ($op eq 'R' ? 1 : -1)) % 4;
    }

}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print exists $m->{$x,$y} ? $m->{$x,$y} : ' ';
    }
    print "\n";
}

printf "Stage 2: %s\n", ($x + 1) * 4 + ($y + 1) * 1000 + $dir;
