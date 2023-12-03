#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Math::Prime::Util qw/lcm/;
use Storable;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my ($minx,$miny) = (0,0);
my $maxy = scalar(@f) - 1;
my $maxx = length($f[0]) - 1;

my $i = 0;
my $e; # blizzards
my $bm; # base map
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {

        if ($r[$x] =~ /[.#]/)
        {
            $bm->{$x,$y} = $r[$x];
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

my $moves =
{
    '>' => [1,0],
    'v' => [0,1],
    '<' => [-1,0],
    '^' => [0,-1],
    '.' => [0,0],
};

# number of rounds in cycle before blizzards reach initial state
my $rrr = lcm($maxx-1, $maxy-1);

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
        for my $i (keys %$e)
        {
            my $x = $e->{$i};
            my $d = $x->{d};
            if ($xm->{$x->{x},$x->{y}} eq '.')
            {
                $xm->{$x->{x},$x->{y}} = $d;
            }
            else
            {
                $xm->{$x->{x},$x->{y}} = 'X'; # multiple
            }
        }

        $mstate->[$r] = $xm;

        for my $i (keys %$e)
        {
            my $b = $e->{$i};
            $b->{x} += $moves->{$b->{d}}->[0];
            $b->{y} += $moves->{$b->{d}}->[1];
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
    # swap start and end
    ($startx,$starty,$endx,$endy) = ($endx,$endy,$startx,$starty) if $pass > 1;

    print "pass $pass start at round $startr: ($startx,$starty) => ($endx,$endy)\n";

    my $visited = undef;

    my @q = ();
    push(@q, { x => $startx, y => $starty, m => 0, r => $startr, d => 'S', t => '' });

    my $ii = 0;
    while (1)
    {
        my $p = shift(@q);
        die "end of queue" unless defined $p;

        next if $visited->{$p->{x},$p->{y},$p->{m}};
        $visited->{$p->{x},$p->{y},$p->{m}} = 1;

        my $xb = $bstate->[$p->{r}];
        my $xm = $mstate->[$p->{r}];

        print "$pass.$ii: round: $p->{r} $p->{d} ($p->{m}) :: $p->{t}\n"; $ii++;

        if (0) # draw the map
        {
            for my $y ($miny..$maxy)
            {
                for my $x ($minx..$maxx)
                {
                    if ($x == $p->{x} && $y == $p->{y})
                    {
                        print 'E';
                        die unless $xm->{$x,$y} =~ /[.S]/; # assert
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
            print "$pass.$ii: best $p->{m} -- $p->{t}\n";
            $stage1 = $p->{m} if $pass == 1;
            $stage2 += $p->{m};
            $startr = $p->{r}; # start for next pass
            next PASS;
        }

        my $nextr = ($p->{r} + 1) % $rrr;
        my $nb = $bstate->[$nextr];
        my $nm = $mstate->[$nextr];

        for my $d (keys %$moves)
        {
            my $nx = $p->{x} + $moves->{$d}->[0];
            my $ny = $p->{y} + $moves->{$d}->[1];

            next if $nx < $minx || $nx > $maxx;
            next if $ny < $miny || $ny > $maxy;
            next if $nm->{$nx,$ny} ne '.';

            push(@q, { x => $nx, y => $ny, m => $p->{m} + 1, r => $nextr, d => $d, t => $p->{t}.$d });
        }
    }
}


printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

