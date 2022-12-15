#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $m;

my ($minx,$maxx) = (100000000,-100000000);
my ($miny,$maxy) = (100000000,-100000000);
my $i = 0;
for (@f)
{
    my @t = m/([\d-]+)/g; # Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    # $m->{$t[0],$t[1]}->{bx} = $t[2];
    # $m->{$t[0],$t[1]}->{by} = $t[3];

    $m->{$i}->{sx} = $t[0];
    $m->{$i}->{sy} = $t[1];
    $m->{$i}->{bx} = $t[2];
    $m->{$i}->{by} = $t[3];

    $m->{$i}->{dx} = abs($t[0] - $t[2]);
    $m->{$i}->{dy} = abs($t[1] - $t[3]);
    $minx = min($t[0],$minx); $maxx = max($t[0],$maxx);
    $miny = min($t[1],$miny); $maxy = max($t[1],$maxy);

    $minx = min($t[2],$minx); $maxx = max($t[2],$maxx);
    $miny = min($t[3],$miny); $maxy = max($t[3],$maxy);
    $i++;
}

print "$minx,$miny - $maxx,$maxy\n";

#my $y = 10;
my $y = 2000000;

# remove unsuable
# for my $s (keys %$m)
# {
#     my $p = $m->{$s};
#     if (($p->{dy}+$p->{dx}) < abs($y - $p->{sy}))
#     {
#         delete $m->{$s};
#         print "deleted $s\n";
#     }
# }

$minx -= 100000;
$maxx += 100000;

$minx = 0;
$miny = 0;
$maxx = 4000000;
$maxy = 4000000;

if (scalar @f == 14) # test File
{
    $minx = 0;
    $miny = 0;
    $maxx = 20;
    $maxy = 20;
}

use Set::Infinite;

my $sm;
for my $y ($miny..$maxy)
{
    $sm->[$y] = Set::Infinite->new();
    $sm->[$y] = $sm->[$y]->tolerance(1)
}

for my $s (keys %$m)
{
    print "sensor: $s\n";
    my $p = $m->{$s};

    my $d = $p->{dx} + $p->{dy};

    my $ly = max($p->{sy} - $d, $miny);
    my $ry = min($p->{sy} + $d, $maxy);

    for my $y ($ly..$ry)
    {
        my $dy = abs($y - $p->{sy});
        my $dx = ($p->{dx} + $p->{dy}) - $dy;
#        next if $dx < 0;

        my $lx = max($p->{sx} - $dx, $minx);
        my $rx = min($p->{sx} + $dx, $maxx);
        $sm->[$y] = $sm->[$y]->union($lx,$rx);
#        print "$y($lx,$rx) $sm->[$y]\n";
    }

}

for my $y ($miny..$maxy)
{
    my $xset = $sm->[$y];
    my $cc = $xset->size() + $xset->count();
#    printf "$xset %d %d\n", $xset->size(), $xset->count();
    if ($xset->size() < ($maxx - $minx + 1))
    {
        print "$y $xset ";
        print "\n";
        #exit;

        my $tset = Set::Infinite->new($minx,$maxx);
        $tset = $tset->minus($xset);
        print "t = $tset\n";
        print 4000000 * ($tset->min() + 1) + $y;
        print "\n";
        exit;
    }
}

exit;

Y: for my $y ($miny..$maxy)
{
    my $xset = Set::Infinite->new();
    print "y($y)\n" if $y % 5000 == 0;
    for my $s (keys %$m)
    {
        my $p = $m->{$s};

        #next if (($p->{dy}+$p->{dx}) < abs($y - $p->{sy}));


        my $dy = abs($y - $p->{sy});
        my $dx = ($p->{dx} + $p->{dy}) - $dy;
        next if $dx < 0;

        my $lx = max($p->{sx} - $dx, $minx);
        my $rx = min($p->{sx} + $dx, $maxx);
#        print "$y - $s($p->{sx},$p->{sy}) d($dx,$dy) lx=$lx rx=$rx\n";
#        my $set = Set::Infinite->new($lx,$rx);
        #     {
        # a => $lx, open_begin => 0,
        # b => $rx, open_end => 0,
        # });
        $xset = $xset->union($lx,$rx);
    }

#    if ($xset->size() < ($maxx - $minx + 10000))
#    if (!$xset->is_span())

    my $cc = $xset->size() + $xset->count();
    if ($cc < ($maxx - $minx + 1))
    {
        print "$y $xset ";
        print "\n";
        #exit;
    }

}

# print $xset;
# print $xset->size();
exit;

# X: for my $x ($minx..$maxx)
# {
#     Y: for my $y ($miny..$maxy)
#     {
#         for my $s (keys %$m)
#         {
#             my $p = $m->{$s};
#             next Y if ($p->{bx} == $x && $p->{by} == $y);
#             next Y if ($p->{sx} == $x && $p->{sy} == $y);
#         }

#         for my $s (keys %$m)
#         {
#             my $p = $m->{$s};
#             my $dx = $p->{dx};#abs($p->{sx} - $p->{bx});
#             my $dy = $p->{dy};#abs($p->{sy} - $p->{by});

#             if (abs($y - $p->{sy}) + abs($x - $p->{sx}) <= $dx + $dy)
#             {
#                 print "$x,$y - $s($p->{sx},$p->{sy}) d($dx,$dy) = $stage1\n" if $x % 10000 == 0;
#                 $stage1++;
#                 next Y;
#             }
#         }

#         print "$x,$y\n";
#         $stage2 = $x * 4000000 + $y;
#     }
# }

# # distress beacon must have x and y coordinates each no lower than 0 and no larger than 4000000.

# printf "Stage 1: %s\n", $stage1;
# printf "Stage 2: %s\n", $stage2;
# # 5114987