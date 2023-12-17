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

no warnings 'recursion';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

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

my ($h, $w) = ($y, length($f[0]));
my ($maxx, $maxy) = ($w - 1, $h - 1);

$x = 0;
$y = 0;
my ($dx,$dy) = (0,0);


use Graph::Directed;
my $g = Graph::Directed->new;   # A directed graph.

my @vstart;
my @vend;
my @vs;
for my $x (0..$maxx)
{
    for my $y (0..$maxy)
    {

        for my $dx3 (-3..3)
        {
            for my $dy3 (-3..3)
            {
                next if (abs($dx3) + abs($dy3)) != 3;

                for my $dx2 (-2..2)
                {
                    for my $dy2 (-2..2)
                    {
                        next if (abs($dx2) + abs($dy2)) != 2;

                        for my $dx1 (-1..1)
                        {
                            for my $dy1 (-1..1)
                            {
                                next if (abs($dx1) + abs($dy1)) != 1;

                                my ($x3,$y3) = ($x + $dx3, $y + $dy3);
                                my ($x2,$y2) = ($x + $dx2, $y + $dy2);
                                my ($x1,$y1) = ($x + $dx1, $y + $dy1);

                                next if (abs($x3-$x2) + abs($y3-$y2)) != 1;
                                next if (abs($x2-$x1) + abs($y2-$y1)) != 1;

                                next if $x1 > $maxx;
                                next if $x2 > $maxx;
                                next if $x3 > $maxx;
                                next if $y1 > $maxy;
                                next if $y2 > $maxy;
                                next if $y3 > $maxy;

                                $x1 = 'x' if $x1 < 0;
                                $x2 = 'x' if $x2 < 0;
                                $x3 = 'x' if $x3 < 0;
                                $y1 = 'x' if $y1 < 0;
                                $y2 = 'x' if $y2 < 0;
                                $y3 = 'x' if $y3 < 0;


                                my $v = "$x3,$y3:$x2,$y2:$x1,$y1:$x,$y";
                                push(@vs, $v);
                                push(@vstart, $v) if $x == 0 && $y == 0;
                                push(@vend, $v) if $x == $maxx && $y == $maxy;
        #                        print "$x2,$y2|$x1,$y1|$x,$y ($dx2,$dy2)($dx1,$dy1)\n";
                            }
                        }

                    }
                }
            }
        }
    }
}

printf "vertices: %d\n", scalar(@vs);

for my $u (@vs)
{
#    print "$u\n";
    my ($x3,$y3,$x2,$y2,$x1,$y1,$x,$y) = ($u =~ m/[^:,]+/g);
    for my $dx (-1..1)
    {
        for my $dy (-1..1)
        {
            next if abs($dx) + abs($dy) != 1;
            my ($nx, $ny) = ($x + $dx, $y + $dy);
            next if $nx < 0 || $nx > $maxx;
            next if $ny < 0 || $ny > $maxy;

            next if $nx eq $x1 && $ny eq $y1; # in path of $u

            next if $nx eq $x && $x eq $x1 && $x1 eq $x2 && $x2 eq $x3; # in line
            next if $ny eq $y && $y eq $y1 && $y1 eq $y2 && $y2 eq $y3; # in line

            my $v = "$x2,$y2:$x1,$y1:$x,$y:$nx,$ny";

 #           print "$u ---( $t->{$nx,$ny} )---> $v\n";
            $g->add_weighted_edge($u, $v, $t->{$nx,$ny});
        }

    }
}

my $bv = "0,x:0,x:0,x:0,0";
my $ev = "11,10:11,11:11,12:12,12";

my @res;
for my $bv (@vstart)
{
    for my $ev (@vend)
    {
        die unless $g->has_vertex($bv);
        die unless $g->has_vertex($ev);
        my @path = $g->SP_Dijkstra($bv, $ev);
        next if scalar(@path) == 0;
        my $r = 0;
        for my $v (@path)
        {
            my ($x3,$y3,$x2,$y2,$x1,$y1,$x,$y) = ($v =~ m/[^:,]+/g);
#            print "$x,$y $t->{$x,$y}\n";
            $r += $t->{$x,$y};
        }
        $r -= $t->{0,0};

        print "$bv -> $ev = $r\n";
        push(@res, $r);
    }
}

say(min @res);
exit;

my @q;
my $cache;

sub go($x,$y,$dx,$dy,$path)
{
    return 1_000_000_000 if scalar(@$path) > 34;
    push(@$path,[$x,$y,$dx,$dy]);

my $pm;
for my $k (@$path)
{
    $pm->{$k->[0],$k->[1]} = 1;
}



    if ($x == $maxx && $y == $maxy)
    {


        return $t->{$x,$y};
    }

    my $p3 = $path->[-3] // ['x','x'];
    my $p2 = $path->[-2] // ['x','x'];
    my $p1 = $path->[-1] // ['x','x'];
    my $lm =
        join(",",$p3->[0],$p3->[1])."|".
        join(",",$p2->[0],$p2->[1])."|".
        join(",",$p1->[0],$p1->[1]);


# for my $y (0..$maxy)
# {
#     for my $x (0..$maxx)
#     {
#         if (exists $pm->{$x,$y})
#         {
#             print ".";
#         }
#         else
#         {
#             print $t->{$x,$y};
#         }
#     }
#     print "\n";
# }
# print "\n";
# die if ($x ==0 && $y == 1);


    #print "$x,$y\n";
    if (exists $cache->{$lm})
    {
        return $cache->{$lm};
    }


    my @p = @$path;
    my $mustchange = 0;
    if (scalar(@$path) >= 4)
    {
        $mustchange = 'x' if ($path->[-1]->[0] == $path->[-2]->[0] && $path->[-2]->[0] == $path->[-3]->[0] && $path->[-3]->[0] == $path->[-4]->[0]);
        $mustchange = 'y' if ($path->[-1]->[1] == $path->[-2]->[1] && $path->[-2]->[1] == $path->[-3]->[1] && $path->[-3]->[1] == $path->[-4]->[1]);
    }
#print "mustchange($mustchange)\n";
    my @res = ();
    for my $dx (reverse (-1..1))
    {
        for my $dy (reverse(-1..1))
        {
            next unless abs($dx) + abs($dy) == 1;
            next if $mustchange eq 'x' && $dx == 0;
            next if $mustchange eq 'y' && $dy == 0;

            my $nx = $x + $dx;
            my $ny = $y + $dy;
            next if $nx < 0 || $nx > $maxx;
            next if $ny < 0 || $ny > $maxy;
            #next if exists $pm->{$nx,$ny};

            my $v = go($nx,$ny,$dx,$dy,clone $path);
            push(@res, $v);
        }
    }

    my $r = scalar(@res) == 0 ? 1_000_000_000 : $t->{$x,$y} + min(@res);
    return $cache->{$lm} = $r;
}

$stage1 = go(0, 0, 0, 0, []);
print Dumper $cache;

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

# 944 too hi