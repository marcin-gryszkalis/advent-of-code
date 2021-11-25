#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Number::AnyBase;

my @alphabet = (0..9, 'A'..'Z', 'a'..'z'); # 2-chars 62-base =~ 3800
my $b62 = Number::AnyBase->new(\@alphabet);

my $df;
my $maxx = 0;
my $maxy = 0;

# root@ebhq-gridcenter# df -h
# Filesystem              Size  Used  Avail  Use%
# /dev/grid/node-x0-y0     93T   71T    22T   76%
my @ff = read_file(\*STDIN);
my $i = 0;
for (@ff)
{
    next unless m{/dev/grid/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T};
    my $x = $1;
    my $y = $2;
    $maxx = $x if $x > $maxx;
    $maxy = $y if $y > $maxy;

    my $id = sprintf("%02s", $b62->to_base($i++));
    $df->{$x}->{$y}->{id} = $id;
    $df->{$x}->{$y}->{used} = $4;
    $df->{$x}->{$y}->{avail} = $5;
    die $_ unless $3 == $4 + $5; # just sanity check if df uses no rounding
}

my $goal = $df->{$maxx}->{0}->{id};
print "We want to move data from ($maxx,0) = $goal to (0,0)\n";

my $c = 0;
my $adj = 0;
# my $it = variations([keys %$df], 2); - when "x:y" was used as $df key
for my $ax (0..$maxx)
{
    for my $ay (0..$maxy)
    {
        for my $bx (0..$maxx)
        {
            for my $by (0..$maxy)
            {
                if ($df->{$ax}->{$ay}->{used} == 0) # remember empty node for stage2, assume there's only 1 such node
                {
                    $df->{emptyx} = $ax;
                    $df->{emptyy} = $ay;
                }

                # Node A is not empty (its Used is not zero).
                next if $df->{$ax}->{$ay}->{used} == 0;

                # Nodes A and B are not the same node.
                next if $ax == $bx && $ay == $by;

                # The data on node A (its Used) would fit on node B (its Avail).
                next if $df->{$ax}->{$ay}->{used} > $df->{$bx}->{$by}->{avail};


                $c++;

                next if abs($ax-$bx) + abs($ay-$by) != 1; # check adjacency

                $adj++;

            }
        }
    }
}
print "Stage 1: $c\n";
print "Adj: $adj\n";

# print Dumper $df;

# calc initial hash
sub xhash($)
{
    my $xdf = shift;
    my $h = '';
    for my $ax (0..$maxx)
    {
        for my $ay (0..$maxy)
        {
            $h .= $xdf->{$ax}->{$ay}->{id};
        }
    }
    return $h;
}

my $h = xhash($df);
print "$h\n";

# alternatively:
my $h2 = '';
for my $i (0..(($maxx+1)*($maxy+1)-1))
{
    $h2 .= sprintf("%02s", $b62->to_base($i++));
}
print "$h2\n";

$df->{hash} = $h;
$df->{level} = 0;

my $visited;
$visited->{$h} = 1;

my @stateq = (); # bfs queue
push(@stateq, clone($df));

while (1)
{
    my $xdf = shift(@stateq);
    die unless defined $xdf;

    # find possible moves
    my $dx = $xdf->{emptyx}; # destination
    my $dy = $xdf->{emptyy};

    for my $zx (-1..1)
    {
        for my $zy (-1..1)
        {
            next if abs($zx) + abs($zy) != 1;

            my $sx = $dx + $zx; # source
            next if $sx < 0 || $sx > $maxx;
            my $sy = $dy + $zy;
            next if $sy < 0 || $sy > $maxy;

            my $ndf = clone($xdf);

            # swap source and destination
            my $e = $ndf->{$sx}->{$sy}->{id};
            $ndf->{$sx}->{$sy}->{id} = $ndf->{$dx}->{$dy}->{id};
            $ndf->{$dx}->{$dy}->{id} = $e;

            my $newhash = xhash($ndf);
            print "$ndf->{level}: ($sx,$sy) <-> ($dx,$dy):\n$newhash\n";

            # swap directly in hash
            my $oh = $ndf->{hash};
            my $spos = ($sx * ($maxy+1) + $sy) * 2;
            my $dpos = ($dx * ($maxy+1) + $dy) * 2;
print "spos($spos), dpos($dpos)\n";
            my $s = substr($oh, $dpos, 2);
            substr($oh, $dpos, 2) = substr($oh, $spos, 2);
            substr($oh, $spos, 2) = $s;

            die "wrong: $newhash NE $oh\n" unless $newhash eq $oh;

#             print Dumper $ndf;

            if (substr($newhash, 0, 2) eq $goal)
            {
                my $finallevel = $ndf->{level} + 1;
                print "moved!\nlevel=finallevel\n$newhash\n";
                exit;
            }

            next if $visited->{$newhash};
            $visited->{$newhash} = 1;
            $ndf->{hash} = $newhash;
            $ndf->{level}++;
            $ndf->{emptyx} = $sx;
            $ndf->{emptyy} = $sy;
            push(@stateq, $ndf);

            #exit;
        }
    }
}
# my $init = clone($a);
