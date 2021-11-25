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

my $maxx;
my $maxy;
my $maxv = 0;

my $map0;

my $nodex;
my $nodey;

my $y = 0;
while (<>)
{
    my @a = split//;
    my $x = 0;
    for my $e (@a)
    {
        $map0->{$x,$y} = $e;

        if ($e =~ /\d/)
        {
            $maxv = $e if $e > $maxv;
            $nodex->{$e} = $x;
            $nodey->{$e} = $y;
        }

        $x++;
    }
    $maxx = $x - 1;
    $y++;
}
$maxy = $y - 1;

print "maxv = $maxv\n";

my $distance;

my $best = $maxx * $maxy * $maxv;
my @nodes = (0..$maxv);

my $it = combinations(\@nodes, 2);
my $c = 0;
COMB: while (my $nd = $it->next)
{
    my $src = $nd->[0];
    my $dst = $nd->[1];

    my $x = $nodex->{$src};
    my $y = $nodey->{$src};

    my $map = clone($map0);

    $map->{$x,$y} = '.';

    my $state0;
    $state0->{level} = 0;
    $state0->{x} = $x;
    $state0->{y} = $y;
    $state0->{path} = "$x,$y ";

    my @sq = ();
    push(@sq, $state0);

    my $visited = undef;
    $visited->{$x,$y} = 1;

    my $found = 0;

    while (1)
    {
        my $st = shift(@sq);
        if (!defined $st) # empty queue
        {
            next COMB; # strange
        }

##        my $sqs = scalar(@sq);
##        print "$st->{level}: $st->{x} $st->{y} (dst=$dst found=$found, sqsize=$sqs) path=$st->{path}\n";

        if ($map->{$st->{x},$st->{y}} eq $dst)
        {
            $distance->{$src,$dst} = $st->{level};
            $distance->{$dst,$src} = $st->{level};
            print "distance($src -> $dst) = $st->{level}\n";
            next COMB;
        }
        elsif ($map->{$st->{x},$st->{y}} =~ /\d/) # other number, nothing special :)
        {
            # next;
        }

#        next if $st->{level} == $best; # optimize, this path is already long

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


@nodes = (1..$maxv);
$it = permutations(\@nodes);
PERM: while (my $nd = $it->next)
{
    unshift(@$nd, 0);

    my $d = 0;
    for my $i (0..$maxv-1)
    {
        $d += $distance->{$nd->[$i],$nd->[$i+1]};
    }

    if ($d < $best)
    {
        $best = $d;
        print "Best ($d): ".join("",@$nd)."\n";
    }
}


print "Stage 1: $best\n";
