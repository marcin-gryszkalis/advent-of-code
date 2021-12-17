#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

$_ = "target area: x=56..76, y=-162..-134";
# $_ = "target area: x=20..30, y=-10..-5"; # test case

my ($tx1,$tx2,$ty1,$ty2) = /x=(.*)\.\.(.*), y=(.*)\.\.(.*)/;
my $txs = ($tx2 - $tx1 + 1);
my $tys = ($ty2 - $ty1 + 1);

print "target: ($tx1,$tx2) - ($ty1,$ty2) [$txs,$tys]\n";

my $stage1 = 0;
my $stage2 = 0;

my $maxx = 0;
my $maxy = 0;
for my $xv (1..$tx2)
{
    my $ixv = $xv;
    for my $yv ($ty1..$tys*10)
    {
        my $iyv = $yv;
        $xv = $ixv;

        my $x = 0;
        my $y = 0;
        my $hiy = 0;

        while (1)
        {
            #print "$ixv,$iyv: $x,$y [$xv,$yv] $maxy\n";
            $x += $xv;
            $y += $yv;
            $xv-- if $xv > 0;
            $yv--;

            $hiy = max($y,$hiy);
            if ($x >= $tx1 && $x <= $tx2 && $y >= $ty1 && $y <= $ty2)
            {
                $stage2++;
                if ($hiy > $stage1)
                {
                    $stage1 = $hiy;
                    $maxy = $iyv ;
                    $maxx = $ixv ;
                    print "$maxx, $maxy -> $stage1\n";
                }

                last;
            }
            last if $x > $tx2 || $y < $ty1;
        }


    }
}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;