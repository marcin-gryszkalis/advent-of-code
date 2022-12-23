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

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $maxys = scalar(@f) - 1;
my $maxxs = max(map { length $_ } @f) - 1;

my $maxx = 0;
my $maxy = 0;
my $minx = 1000;
my $miny = 1000;

my ($sx,$sy) = (-1,0); # start
my $m;
my $i = 0;
my $e;
for my $y (0..$maxys)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxxs)
    {
        $m->{$x,$y} = '.';
        next if !defined $r[$x] || $r[$x] eq '.';
        $e->{$i}->{x} = $x;
        $e->{$i}->{y} = $y;

        $m->{$x,$y} = '#';

        $maxx = max($maxx, $x);
        $maxy = max($maxy, $y);
        $minx = min($minx, $x);
        $miny = min($miny, $y);


        $i++;
    }
}


my $maxi = $i-1;

my @dir = qw/N S W E/;

my $moved = 0;
my $round = 0;
for my $r (1..1000000)
{
    $round = $r;
    my $p = undef;

    for my $i (0..$maxi)
    {
        $e->{$i}->{s} = 0; # stopped by conflict
        $e->{$i}->{p} = 0; # stopped by conflict
    }

    I: for my $i (0..$maxi)
    {
        my $x = $e->{$i};


        if (

($m->{$x->{x}-1,$x->{y}-1} // '.') eq '.' &&
($m->{$x->{x}-1,$x->{y}  } // '.') eq '.' &&
($m->{$x->{x}-1,$x->{y}+1} // '.') eq '.' &&
($m->{$x->{x}  ,$x->{y}-1} // '.') eq '.' &&
($m->{$x->{x}  ,$x->{y}+1} // '.') eq '.' &&
($m->{$x->{x}+1,$x->{y}-1} // '.') eq '.' &&
($m->{$x->{x}+1,$x->{y}  } // '.') eq '.' &&
($m->{$x->{x}+1,$x->{y}+1} // '.') eq '.'
            )
        {
            $x->{p} = 'X';
            next I;
        }

        for my $d (@dir)
        {
            if ($d eq 'N')
            {
                if (
                    ($m->{$x->{x}-1,$x->{y}-1} // '.') eq '.' &&
                    ($m->{$x->{x},  $x->{y}-1} // '.') eq '.' &&
                    ($m->{$x->{x}+1,$x->{y}-1} // '.') eq '.'
                    )
                {
                    $x->{p} = 'N';
                    if (exists $p->{$x->{x},$x->{y}-1}) # there's already a proposal for this x,y
                    {
                        $e->{$p->{$x->{x},$x->{y}-1}}->{s} = 1;
                    }
                    else
                    {
                        $p->{$x->{x},$x->{y}-1} = $i;
                    }
                        next I;
                }
            }


            if ($d eq 'S')
            {
                if (
                    ($m->{$x->{x}-1,$x->{y}+1} // '.') eq '.' &&
                    ($m->{$x->{x},  $x->{y}+1} // '.') eq '.' &&
                    ($m->{$x->{x}+1,$x->{y}+1} // '.') eq '.'
                    )
                {
                    $x->{p} = 'S';
                    if (exists $p->{$x->{x},$x->{y}+1}) # there's already a proposal for this x,y
                    {
                        $e->{$p->{$x->{x},$x->{y}+1}}->{s} = 1;
                    }
                    else
                    {
                        $p->{$x->{x},$x->{y}+1} = $i;
                    }
                        next I;
                }
            }

            if ($d eq 'W')
            {
                if (
                    ($m->{$x->{x}-1,$x->{y}-1} // '.') eq '.' &&
                    ($m->{$x->{x}-1,$x->{y}} // '.') eq '.' &&
                    ($m->{$x->{x}-1,$x->{y}+1} // '.') eq '.'
                    )
                {
                    $x->{p} = 'W';

                    if (exists $p->{$x->{x}-1,$x->{y}}) # there's already a proposal for this x,y
                    {
                        $e->{$p->{$x->{x}-1,$x->{y}}}->{s} = 1;
                    }
                    else
                    {
                        $p->{$x->{x}-1,$x->{y}} = $i;
                    }
                        next I;
                }
            }

            if ($d eq 'E')
            {
                if (
                    ($m->{$x->{x}+1,$x->{y}-1} // '.') eq '.' &&
                    ($m->{$x->{x}+1,$x->{y}} // '.') eq '.' &&
                    ($m->{$x->{x}+1,$x->{y}+1} // '.') eq '.'
                    )
                {
                                        $x->{p} = 'E';

                    if (exists $p->{$x->{x}+1,$x->{y}}) # there's already a proposal for this x,y
                    {
                        $e->{$p->{$x->{x}+1,$x->{y}}}->{s} = 1;
                    }
                    else
                    {
                        $p->{$x->{x}+1,$x->{y}} = $i;
                    }
                        next I;
                }
            }

        }
    }



#print Dumper $p;
#print Dumper $e;
$moved = 0;
    for my $pp (keys %$p)
    {
        my $i = $p->{$pp};
        next if $e->{$i}->{s}; #

        my ($dx,$dy) = split/,/,$pp;

        $m->{$e->{$i}->{x},$e->{$i}->{y}} = '.';
        $m->{$pp} = '#';
        $e->{$i}->{x} = $dx;
        $e->{$i}->{y} = $dy;

        $moved++;

        $maxx = max($maxx, $dx);
        $maxy = max($maxy, $dy);
        $minx = min($minx, $dx);
        $miny = min($miny, $dy);
    }

if ($r == 10)
{
while (0) ###  stage1
{
    my $shrink = 1;
    my $y = $miny;
    for my $x ($minx..$maxx)
    {
        if (($m->{$x,$y} // ".") eq '#')
        {
            $shrink = 0;
            last;
        }
    }
    $miny++ if $shrink;
    next if $shrink;

    $shrink = 1;
    $y = $maxy;
    for my $x ($minx..$maxx)
    {
        if (($m->{$x,$y} // ".") eq '#')
        {
            $shrink = 0;
            last;
        }
    }
    $maxy-- if $shrink;
    next if $shrink;

    $shrink = 1;
    my $x = $minx;
    for my $y ($miny..$maxy)
    {
        if (($m->{$x,$y} // ".") eq '#')
        {
            $shrink = 0;
            last;
        }
    }
    $minx++ if $shrink;
    next if $shrink;

    $shrink = 1;
    $x = $maxx;
    for my $y ($miny..$maxy)
    {
        if (($m->{$x,$y} // ".") eq '#')
        {
            $shrink = 0;
            last;
        }
    }
    $maxx-- if $shrink;
    next if $shrink;

    last;
}

$stage1 = ($maxx - $minx + 1) * ($maxy - $miny + 1) - scalar(keys %$e);
}

printf "$minx,$miny - $maxx,$maxy :: maxi($maxi) round $r : %s -- moved: %d\n", join("",@dir), $moved;
push(@dir, shift(@dir)); # rotate directions


last if $moved == 0;
# $stage2 = 0;
# for my $y ($miny..$maxy)
# {
#     for my $x ($minx..$maxx)
#     {
#         print ($m->{$x,$y} // ".");
#         $stage2 += ($m->{$x,$y} // ".") eq '.';
#     }
#     print "\n";
# }


}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $round;
