#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my $stage1 = 0;
my $stage2 = 0;

my @f =  read_file(\*STDIN, chomp => 1);
my $tx = pop @f;
pop @f;
#@f = map { [split//] } @f;

my $wy = scalar(@f);
my $wx = max(map { length $_ } @f);
my $maxy = $wy - 1;
my $maxx = $wx - 1;

my ($sx,$sy) = (-1,0); #,$ex,$ey);
my $m;
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {
        next unless exists $r[$x];
        next if $r[$x] eq ' ';
        $m->{$x,$y} = $r[$x];
        $sx = $x if $r[$x] eq '.' && $sx == -1;
    }
}

$tx =~ s/(\d+)/ $1 /g;
$tx =~ s/^\s+//;
$tx =~ s/\s+$//;
my @t = split/ /,$tx;

my @mov = (
[1,0], # R
[0,1],
[-1,0],
[0,-1], # U
);

my @g = qw/> V < ^/;
my $x = $sx;
my $y = $sy;
my $dir = 0;

$m->{$x,$y} = $g[$dir];

my $w = 4;
$w = 50;

my $maxf = $w - 1;

my %facemulx =
(
    1 => 1,
    2 => 2,
    3 => 1,
    4 => 0,
    5 => 1,
    6 => 0
);

my %facemuly =
(
    1 => 0,
    2 => 0,
    3 => 1,
    4 => 2,
    5 => 2,
    6 => 3
);


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

# 1-2
# my $rules = {
# x'1R' => { n => 6, x => '$w', y => '$w - $y', d => 2 }
# '1D' => { n => 4, x => '$x', y => 0, d => 1 }
# '4D' => { n => 5, x => '$x', y => 0, d => 1 }
# '5D' => { n => 2, # x => '$x', y => 0, d => 1 }
# '2R' => { n => 3, x => '$x', y => 0, d => 1 }
# };

my $face = 1;
for my $op (@t)
{
    print "OP($op) $x, $y [$dir]: $op\n";
    if ($op =~ /\d/)
    {
        while (1)
        {
    print STDERR "$x $y $dir\n";
#    print "$x $y $dir\n";
            my $dx = $mov[$dir][0];
            my $dy = $mov[$dir][1];

        my $px = $x;
        my $py = $y;
        my $pdir = $dir;
        my $pface = $face;

            print "::: $face -- $x, $y [$dir]: op $op\n";

            # my $nx = $x + $dx;
            # my $ny = $y + $dy;
            my $fx = $x % $w;
            my $fy = $y % $w;

            my $b = undef;
            if ($fx == $maxf && $dx == 1)
            {
                $b = 'r';
            }
            if ($fy == $maxf && $dy == 1)
            {
                $b = 'd';
            }
            if ($fx == 0 && $dx == -1)
            {
                $b = 'l';
            }
            if ($fy == 0 && $dy == -1)
            {
                $b = 'u';
            }

            if (defined $b)
            {
                my $rule = $rules{"${face}$b"};
                my ($newface, $nb) = split//,$rule;

                print "rule(${face}$b => $rule)\n";

                print "FX ($fx,$fy) -> ";

                my $bnb = "$b$nb";
                if ($bnb =~ /(uu|dd)/)
                {
                    print "ROT-180-UD ";
                    ($fx,$fy) = ($maxf - $fx,$fy);
                    $dir = ($dir + 2) % 4;
                }
                elsif ($bnb =~ /(ll|rr)/)
                {
                    print "ROT-180-RL ";
                    ($fx,$fy) = ($fx,$maxf - $fy);
                    $dir = ($dir + 2) % 4;
                }
                elsif ($bnb eq 'lr' || $bnb eq 'rl')
                {
                    # nothing
                    $fx += $dx;
                    $fy += $dy;
            if ($fx > $maxf) { $fx = 0;  }
            if ($fy > $maxf) { $fy = 0;  }
            if ($fx < 0) { $fx = $maxf;  }
            if ($fy < 0) { $fy = $maxf;  }
                }
                elsif ($bnb eq 'ud' || $bnb eq 'du')
                {
                    # nothing
                    $fx += $dx;
                    $fy += $dy;
            if ($fx > $maxf) { $fx = 0;  }
            if ($fy > $maxf) { $fy = 0;  }
            if ($fx < 0) { $fx = $maxf;  }
            if ($fy < 0) { $fy = $maxf;  }
                }
                elsif ($bnb =~ /(ru|ld)/)
                {
                    print "ROT-CW-AC ";
                    ($fx,$fy) = ($maxf - $fy, $maxf - $fx);
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
                    ($fx,$fy) = ($maxf - $fy, $maxf - $fx);
                    $dir = ($dir + 1) % 4;
                }
                elsif ($bnb =~ /(dr|ul)/)
                {
                    print "ROT-CCW-BD ";
                    ($fx,$fy) = ($fy, $fx);
                    $dir = ($dir + 1) % 4;
                }
                else
                {
                    die $bnb;
                }

                print "($fx,$fy) dir: $dir\n";
                $x = $fx + $w*$facemulx{$newface};
                $y = $fy + $w*$facemuly{$newface};
                $face = $newface;
            }
            else # standard movement
            {
                $x += $dx;
                $y += $dy;
            }

            if (!exists $m->{$x,$y}) { die "$x,$y" }

            if ($m->{$x,$y} eq '#') 
            { 
                $x = $px; $y = $py; 
                $dir = $pdir;#  if defined $b;
                $face = $pface;
                last; 
            }

            $m->{$x,$y} = $g[$dir];
            $op--;

            last if $op == 0;
        }
    }
    elsif ($op eq 'R')
    {
        $dir = ($dir + 1) % 4;
    }
    elsif ($op eq 'L')
    {
        $dir = ($dir - 1) % 4;
    }
    else
    {
        die $op;
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
$stage1 = ($x + 1) * 4 + ($y + 1) * 1000 + $dir;
printf "Stage 1: $x $y $dir = %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

