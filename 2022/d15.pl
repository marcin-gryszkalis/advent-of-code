#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Set::IntSpan;

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

    $m->{$i}->{sx} = $t[0];
    $m->{$i}->{sy} = $t[1];

    $m->{$i}->{bx} = $t[2];
    $m->{$i}->{by} = $t[3];

    $m->{$i}->{dx} = abs($m->{$i}->{sx} - $m->{$i}->{bx});
    $m->{$i}->{dy} = abs($m->{$i}->{sy} - $m->{$i}->{by});

    $m->{$i}->{r} = $m->{$i}->{dx} + $m->{$i}->{dy};

    # real min/max, not used:
    $minx = min($minx, $m->{$i}->{sx} - $m->{$i}->{r}); 
    $maxx = max($maxx, $m->{$i}->{sx} - $m->{$i}->{r}); 
    $miny = min($miny, $m->{$i}->{sy} - $m->{$i}->{r}); 
    $maxy = max($maxy, $m->{$i}->{sy} - $m->{$i}->{r}); 

    $i++;
}

my $stage1y = 2000000;

$minx = 0;
$miny = 0;
$maxx = 4000000;
$maxy = 4000000;

if (scalar @f == 14) # test File
{
    $stage1y = 10;
    $minx = 0;
    $miny = 0;
    $maxx = 20;
    $maxy = 20;
}

my $s1s = new Set::IntSpan;

for my $s (keys %$m)
{
    my $p = $m->{$s};

    my $dy = abs($stage1y - $p->{sy});

    my $dx = $p->{r} - $dy;
    next if $dx < 0; # this diamond doesn't reach $stage1y

    my $lx = $p->{sx} - $dx;
    my $rx = $p->{sx} + $dx;
    $s1s += [[$lx,$rx]];

    $s1s -= $p->{bx} if $p->{by} == $stage1y;
    $s1s -= $p->{sx} if $p->{sy} == $stage1y;
}
printf "Stage 1: %s\n", $s1s->size();

my $sm;
for my $y ($miny..$maxy)
{
    $sm->{$y} = new Set::IntSpan;
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
        $sm->{$y} += [[$lx,$rx]];
#        print "$y($lx,$rx) $sm->{$y}\n";
    }

}

for my $y ($miny..$maxy)
{
    my $xset = $sm->{$y};
    next if $xset->size() == $maxx - $minx + 1;
        
    my $tset =  new Set::IntSpan([[$minx,$maxx]]);
    $tset -= $xset;
    my $x = $tset->min();
        
    printf "Stage 2: b($x,$y) = %s\n", 4000000 * $x + $y;
    last;
}

