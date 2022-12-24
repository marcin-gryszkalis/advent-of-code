#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use List::PriorityQueue;
use Storable;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my ($minx,$miny) = (0,0);
my $maxy = scalar(@f) - 1;
my $maxx = length($f[0]) - 1; # max(map { length $_ } @f) - 1;

my ($sx,$sy) = (-1,0); # start
my $i = 0;
my $e;
my $bm;
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {

        if ($r[$x] eq '.')
        {
            $bm->{$x,$y} = '.';
        }
        elsif ($r[$x] eq '#')
        {
            $bm->{$x,$y} = '#';
        }
        else
        {
            $e->{$i}->{x} = $x;
            $e->{$i}->{y} = $y;
            $e->{$i}->{d} = $r[$x];
            $i++;

            $bm->{$x,$y} = '.';
        }

    }
}
#print Dumper $e; exit;

my $maxi = $i - 1;

my $move = {

    '>' => [1,0],
    'v' => [0,1],
    '<' => [-1,0],
    '^' => [0,-1],
};

my $rrr = ($maxx-1) * ($maxy-1);
my $bstate;
my $mstate;

if ($maxx > 10)
{
    eval
    {
        $bstate = retrieve('bstate.dat');
        $mstate = retrieve('mstate.dat');
    }
}

if (!defined $bstate)
{

my $r = 0;
for my $r (0..$rrr-1)
{
    print "precalc round: $r of $rrr\n";

    $bstate->[$r] = clone $e;

    my $xm = clone $bm;
    for my $i (0..$maxi)
    {
        my $x = $e->{$i};
        my $d = $x->{d};
#        print "$i: $x->{x} $x->{y} = $d\n";
        if ($xm->{$x->{x},$x->{y}} eq '.')
        {
            $xm->{$x->{x},$x->{y}} = $d;
        }
        else
        {
            $xm->{$x->{x},$x->{y}} = 'X';
        }
    }

    $mstate->[$r] = $xm;

    for my $i (0..$maxi)
    {
        my $b = $e->{$i};
        $b->{x} += $move->{$b->{d}}->[0];
        $b->{y} += $move->{$b->{d}}->[1];
        $b->{x} = $minx+1 if $b->{x} == $maxx;
        $b->{y} = $miny+1 if $b->{y} == $maxy;
        $b->{x} = $maxx-1 if $b->{x} == $minx;
        $b->{y} = $maxy-1 if $b->{y} == $miny;
    }

}

if ($maxx > 10)
{
    store($bstate, 'bstate.dat');
    store($mstate, 'mstate.dat');
}

}

my $startx = 1;
my $starty = 0;
my $endx = $maxx-1;
my $endy = $maxy;

my $startr = 0;
PASS: for my $pass (1..3)
{
    ($startx,$starty,$endx,$endy) = ($endx,$endy,$startx,$starty) if $pass > 1;

# my $r = $startr;
# my $wr = 0;
# while (1)
# {
#     $wr++;
#     if ($mstate->[$r]->{$startx,$starty} eq '.')
#     {
#         $startr = $r;
#         last;
#     }
#     $r = ($r + 1) % $rrr;
# }
print "pass $pass start at round $startr: ($startx,$starty) => ($endx,$endy)\n";
my $visited = undef;

#print Dumper \@mstate; exit;
my $q = new List::PriorityQueue;
#$q->insert({ x => $startx, y => $starty, m => 0, r => $startr, d => 'S', t => '' }, (abs($endx - $startx) + abs($endy - $starty)) );
$q->insert({ x => $startx, y => $starty, m => 0, r => $startr, d => 'S', t => '' }, 0);# (abs($endx - $startx) + abs($endy - $starty)) );

my $ii = 0;
my $best = 1000;
my $besti = 0;
while (1)
{
    my $p = $q->pop();
    die "end of queue" unless defined $p;

#    next if $p->{m} > 30;

    next if $visited->{$p->{x},$p->{y},$p->{m}};
    $visited->{$p->{x},$p->{y},$p->{m}} = 1;

    my $xb = $bstate->[$p->{r}];
    my $xm = $mstate->[$p->{r}];
    $xm->{$startx,$starty} = 'S';
    $xm->{$endx,$endy} = '.';

    # draw the map
    print "$pass.$ii: round: $p->{r} $p->{d} ($p->{m}) :: $p->{t}\n"; $ii++;
    if (0)
    {
        for my $y ($miny..$maxy)
        {
            for my $x ($minx..$maxx)
            {
                if ($x == $p->{x} && $y == $p->{y})
                {
                    print 'E';
                    die unless $xm->{$x,$y} =~ /[.S]/;
                }
                else
                {
                    print ($xm->{$x,$y});
                }
            }
            print "\n";
        }
    }

    if ($p->{x} == $endx && $p->{y} == $endy)
    {
        $best = $p->{m} if $p->{m} < $best;
        print "$pass.$ii: best $best: $p->{m} -- $p->{t}\n";
        $startr = $p->{r}; # ($p->{r} + 1) % $rrr;
        $stage1 = $best if $pass == 1;
        $stage2 += $best;
        next PASS;
        # $besti++;
        # exit if $besti > 3;
    }


    my $nextr = ($p->{r} + 1) % $rrr;
    my $nb = $bstate->[$nextr];
    my $nm = $mstate->[$nextr];
    $nm->{$startx,$starty} = 'S';
    $nm->{$endx,$endy} = '.';


        # for my $y ($miny..$maxy)
        # {
        #     for my $x ($minx..$maxx)
        #     {
        #         if ($x == $p->{x} && $y == $p->{y})
        #         {
        #             print 'E';
        #         }
        #         else
        #         {
        #             print ($nm->{$x,$y});
        #         }
        #     }
        #     print "\n";
        # }

    for my $d (qw/> v < ^/)
    {
        my $nx = $p->{x} + $move->{$d}->[0];
        my $ny = $p->{y} + $move->{$d}->[1];

        next if $nx < $minx || $nx > $maxx;
        next if $ny < $miny || $ny > $maxy;
        next if ($nm->{$nx,$ny} ne '.');

        $q->insert({ x => $nx, y => $ny, m => $p->{m} + 1, r => $nextr, d => $d, t => $p->{t}.$d }, 0);# (abs($endx - $nx) + abs($endy - $ny)));
#        $q->insert({ x => $nx, y => $ny, m => $p->{m} + 1, r => $nextr, d => $d, t => $p->{t}.$d }, (abs($endx - $nx) + abs($endy - $ny)));
    }

    if ($nm->{$p->{x},$p->{y}} =~ m/[.S]/) # stay
    {
        $q->insert({ x => $p->{x}, y => $p->{y}, m => $p->{m} + 1, r => $nextr, d => 'X', t => $p->{t}.'X' }, 0);# (abs($endx - $p->{x}) + abs($endy - $p->{y})));
#        $q->insert({ x => $p->{x}, y => $p->{y}, m => $p->{m} + 1, r => $nextr, d => 'X', t => $p->{t}.'X' }, (abs($endx - $p->{x}) + abs($endy - $p->{y})));
    }

}

}


printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

# 281 = too high
# 280 = too high
# 279 = too high
# 278 = bad
# 259 = bad :(
# 225 = ok

# 117483: best 226: 226 -- >>>X>v>>>>Xv>>>><^>><>>>>v>v<>>>>>^>>v>X<<>Xvvv^>>X^X^>>>v>v<>>X>>>vv>>v^^^>>>>>>v<v^><>vvv>v>>Xvv<<<>^>>>>>v^><^>>vv>>>vv>>>>v>>X>>>>v^>><<>>>^>vvv>v^<v>>>>v^>>^>>vX>vv>X>><vv>vv^>X>>vvvvXv>>>>>^^X>vv>>v>>vv>>vX>^>^>>>vv>vXv

# Part one: 225
# Part two: 711
