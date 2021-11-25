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

my $startx;
my $starty;

my $maxx;
my $maxy;
my $maxv = 0;

my $map0;

my $y = 0;
while (<>)
{
    my @a = split//;
    my $x = 0;
    for my $e (@a)
    {
        $map0->{$x,$y} = $e;

        if ($e eq '0')
        {
            $startx = $x;
            $starty = $y;
        }

        if ($e =~ /\d/ && $e > $maxv)
        {
            $maxv = $e;
        }

        $x++;
    }
    $maxx = $x - 1;
    $y++;
}
$maxy = $y - 1;

print "start ($startx,$starty)\n";
print "maxv = $maxv\n";

my $best = $maxx * $maxy * $maxv;
my @nodes = (1..$maxv);

my $it = permutations(\@nodes);
my $c = 0;
PERM: while (my $nd = $it->next)
{
    print "perm: ".join("", @$nd)."\n";
    my $x = $startx;
    my $y = $starty;
    my $map = clone($map0);

    $map->{$x,$y} = '.';

    my $state0;
    $state0->{level} = 0;
    $state0->{x} = $x;
    $state0->{y} = $y;
    $state0->{path} = "$x,$y ";

    my @sq = ();
    push(@sq, $state0);

    my $dst = shift(@$nd);
    my $visited = undef;

    $visited->{$dst,$x,$y} = 1;

    my $found = 0;

    while (1)
    {
        my $st = shift(@sq);
        if (!defined $st) # empty queue
        {
            next PERM;
        }

        my $sqs = scalar(@sq);
##        print "$st->{level}: $st->{x} $st->{y} (dst=$dst found=$found, sqsize=$sqs) path=$st->{path}\n";

        if ($map->{$st->{x},$st->{y}} eq $dst)
        {
            $map->{$st->{x},$st->{y}} = '.';
            $found++;
##            print "Found $dst: $st->{level} $st->{path}\n";
            @sq = (); # remove stuff from queue, it won't be better
            if ($found == $maxv) # found last point
            {
                if ($st->{level} < $best)
                {
                    $best = $st->{level};
                    print "Best: $st->{level} $st->{path}\n";
                }
                next PERM;
            }
            $dst = shift(@$nd);
        }
        elsif ($map->{$st->{x},$st->{y}} =~ /\d/) # other number, this path is not what we look for
        {
            next;
        }

        next if $st->{level} == $best; # optimize, this path is already long

        for my $dx (-1..1)
        {
            for my $dy (-1..1)
            {
                next if abs($dx) + abs($dy) != 1;

                my $nx = $st->{x} + $dx;
                my $ny = $st->{y} + $dy;

                next if $nx < 0 || $nx > $maxx;
                next if $ny < 0 || $ny > $maxy;

                next if $map->{$nx,$ny} eq '#';
                next if $visited->{$dst,$nx,$ny};

                my $nstate = undef;
                $nstate->{x} = $nx;
                $nstate->{y} = $ny;
                $nstate->{level} = $st->{level} + 1;
                $nstate->{path} = $st->{path} . "$nx,$ny ";
                push(@sq, $nstate);
                $visited->{$dst,$nx,$ny} = 1;
            }
        }
    }

}

print "Stage 1: $best\n";
# for my $y (0..$maxy)
# {
#     for my $x (0..$maxx)
#     {
#         my $k = $x*$x + 3*$x + 2*$x*$y + $y + $y*$y;
#         $k += $designer;

# #        printf "$x $y $k %b %s\n", $k, bits($k);

#         my $c = bits($k) % 2 == 0 ? "." : "#";

#         $map->{$x,$y} = $c;

#         $c = "${RED}X$RST" if $x == $destx && $y == $desty;
#         print "$c";
#     }

#     print "\n";
# }
