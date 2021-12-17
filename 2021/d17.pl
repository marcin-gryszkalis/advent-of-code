#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

$_ = "target area: x=20..30, y=-10..-5"; # test case
$_ = "target area: x=56..76, y=-162..-134";

my ($tx1,$tx2,$ty1,$ty2) = m/[\d-]+/g;

my $stage1 = 0;
my $stage2 = 0;

# for lower bound:
# https://www.wolframalpha.com/input/?i=solve+for+n%3A+%28n%5E2+-+n%29%2F2+%3E%3D+x
for my $xv (int((sqrt(8*$tx1)+1)/2)..$tx2)
{
    my $ixv = $xv;
    
    # Originally guessed yv upper bound like this:
    # for my $yv ($ty1..$ty_size*10)

    # Proper explanation from DFreiberg@reddit

    # https://www.reddit.com/r/adventofcode/comments/ri9kdq/2021_day_17_solutions/hovwa0a/?utm_source=reddit&utm_medium=web2x&context=3
    # It took a while to understand why there was a definite upper y_0 bound
    # for this problem. Y has no drag, just gravity, so its arc is going to be symmetric.
    # Thus, as the shot comes back down, it will always pass through y = 0 with a velocity of -y_0,
    # since it started at y=0 with a velocity of +y_0.
    # So, if -y_0 is smaller than the lower bound of the target,
    # you'll always overshoot if you go any higher.

    # It also means (as a lot of people have noticed) that there's an O(1) solution to part 1:
    # y_max = y_targ * (y_targ + 1) / 2.

    for my $yv ($ty1..-$ty1)
    {
        my $iyv = $yv;
        $xv = $ixv;

        my $x = 0;
        my $y = 0;
        my $hiy = 0;

        while (1)
        {
            $x += $xv;
            $y += $yv;
            $xv-- if $xv > 0;
            $yv--;

            $hiy = max($y, $hiy);
            if ($x >= $tx1 && $x <= $tx2 && $y >= $ty1 && $y <= $ty2)
            {
                $stage2++;
                if ($hiy > $stage1)
                {
                    $stage1 = $hiy;
                    print "$ixv, $iyv -> $stage1\n";
                }

                last;
            }
            last if $x > $tx2 || $y < $ty1;
        }
    }
}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
