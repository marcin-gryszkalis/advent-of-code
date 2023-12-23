#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

my $startx  = 1;
my $starty  = 0;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

my $endx = $maxx-1;
my $endy = $maxy;

for my $stage(1..2)
{
    my $edge = undef;
    my $succ = undef;

    my $exits; # exits from node

    for my $x (0..$maxx)
    {
        Y: for my $y (0..$maxy)
        {
            next if $t->{$x,$y} eq '#';
            my @nexits = ();
            my $allexits = 0;
            for my $dy (-1..1)
            {
                for my $dx (-1..1)
                {
                    next unless abs($dx) + abs($dy) == 1;

                    my ($nx, $ny) = ($x + $dx, $y + $dy);
                    next unless exists $t->{$nx,$ny};
                    next if $t->{$nx,$ny} eq '#';

                    $allexits++;

                    if ($stage == 1)
                    {
                        next if $dx == 1 && $t->{$nx,$ny} eq '<';
                        next if $dx == -1 && $t->{$nx,$ny} eq '>';
                        next if $dy == 1 && $t->{$nx,$ny} eq '^';
                        next if $dy == -1 && $t->{$nx,$ny} eq 'v';
                    }

                    push(@nexits, [$nx,$ny]);
                }
            }

            if ($allexits > 2)
            {
                $exits->{$x,$y} = \@nexits;
            }
        }
    }

    $exits->{$startx,$starty} = [[$startx,$starty+1]];
    $exits->{$endx,$endy} = [[$endx,$endy-1]];

    # build a graph
    # every edge is found twice (a-b, b-a)
    for my $sxsy (keys %$exits)
    {
        for my $e (@{$exits->{$sxsy}})
        {
            my ($x,$y) = @$e;

            my $visited = undef;
            $visited->{$sxsy} = 1;


            my $i = 0;
            while (1)
            {
                $visited->{$x,$y} = 1;
                $i++;

                if (exists $exits->{$x,$y})
                {
                    die "more that one edge between nodes $sxsy and $x,$y" if exists $edge->{$sxsy,"$x,$y"};
                    print "path $sxsy ---[$i]--> $x,$y\n";
                    $edge->{$sxsy,"$x,$y"} = $i;
                    push(@{$succ->{$sxsy}}, "$x,$y");
                    last;
                }

                my $moved = 0;
                Y: for my $dy (-1..1)
                {
                    for my $dx (-1..1)
                    {
                        next unless abs($dx) + abs($dy) == 1;
                        my $nx = $x + $dx;
                        my $ny = $y + $dy;
                        next unless exists $t->{$nx,$ny};
                        next if $t->{$nx,$ny} eq '#';

                        if ($stage == 1)
                        {
                            next if $dx == 1 && $t->{$nx,$ny} eq '<';
                            next if $dx == -1 && $t->{$nx,$ny} eq '>';
                            next if $dy == 1 && $t->{$nx,$ny} eq '^';
                            next if $dy == -1 && $t->{$nx,$ny} eq 'v';
                        }

                        next if exists $visited->{$nx,$ny};
                        $x = $nx;
                        $y = $ny;
                        $moved = 1;
                        last Y; # only 1 way from non-node
                    }
                }

                last unless $moved;
            }
        }

    }

    my @q = ();
    my $end = "$endx,$endy";
    my $visited = undef;

    push(@q, ["$startx,$starty",$visited,0,0]); ## ,["$startx,$starty"]]);
    my $mmm = 0;
    my $i = 0;
    while (@q)
    {
        my $ee = pop(@q);

        my ($vx,$v,$lvl,$fwd,$p) = @$ee;

        $v->{$vx} = 1;

        if ($vx eq $end)
        {
            printf("%20d: (max=%d)\n", $i, max($fwd,$mmm)) if $fwd > $mmm || $i % 10_000 == 0;
            $mmm = max($fwd,$mmm);
            $i++;
            #printf "!!!!!! (max=$mmm) $fwd (%s)\n", join(" ",@$p);
        }

        for my $s (@{$succ->{$vx}})
        {
            next if exists $v->{$s};

    ##        $p = clone $p;
    ##        push(@$p, $s);

            push(@q, [$s, clone($v), $lvl+1,$fwd + $edge->{$vx,$s}]); ## , $p]);
        }
    }


    printf "Stage $stage: %s\n", $mmm;
}
# 6874
