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

        $i++;
    }
}

my $maxx = max(map { $e->{$_}->{x} } keys %$e);
my $minx = min(map { $e->{$_}->{x} } keys %$e);
my $maxy = max(map { $e->{$_}->{y} } keys %$e);
my $miny = min(map { $e->{$_}->{y} } keys %$e);

my $maxi = $i-1;

my @dir = qw/N S W E/;

my %check;
$check{N} = [ { x => -1, y => -1}, { x => 0, y => -1}, { x => +1, y => -1} ];
$check{S} = [ { x => -1, y => +1}, { x => 0, y => +1}, { x => +1, y => +1} ];
$check{W} = [ { x => -1, y => -1}, { x => -1, y => 0}, { x => -1, y => +1} ];
$check{E} = [ { x => +1, y => -1}, { x => +1, y => 0}, { x => +1, y => +1} ];

my %move;
$move{N} = { x => 0, y => -1};
$move{S} = { x => 0, y => +1};
$move{W} = { x => -1, y => 0};
$move{E} = { x => +1, y => 0};

my $moved = 0;
my $round = 0;
while (1)
{
    $round++;
    my $p = undef;

    for my $i (0..$maxi)
    {
        $e->{$i}->{s} = 0; # stopped by conflict
        $e->{$i}->{p} = 0; # save proposal (for debugging)
    }

    I: for my $i (0..$maxi)
    {
        my $x = $e->{$i};

        my %possible = ();
        for my $d (@dir)
        {
            $possible{$d} = (
                ($m->{$x->{x} + $check{$d}->[0]->{x},$x->{y} + $check{$d}->[0]->{y}} // '.') eq '.' &&
                ($m->{$x->{x} + $check{$d}->[1]->{x},$x->{y} + $check{$d}->[1]->{y}} // '.') eq '.' &&
                ($m->{$x->{x} + $check{$d}->[2]->{x},$x->{y} + $check{$d}->[2]->{y}} // '.') eq '.'
                );
        }

        if (all { $possible{$_} } @dir)
        {
            $x->{p} = 'X';
            next I;
        }

        for my $d (@dir)
        {
            next unless $possible{$d};
            $x->{p} = $d;

            my $k = ($x->{x} + $move{$d}->{x}).$;.($x->{y} + $move{$d}->{y});
            if (exists $p->{$k}) # there's already a proposal for this x,y
            {
                $e->{$p->{$k}}->{s} = 1; # we stop one who was there (don't delete the proposal as the conflict may apply to 2, 3 or 4 elves)
            }
            else
            {
                $p->{$k} = $i; # add new proposal
            }

            next I;
        }
    }

    $moved = 0;
    for my $pp (keys %$p)
    {
        my $x = $e->{$p->{$pp}};
        next if $x->{s};

        my ($dx,$dy) = split/$;/,$pp;

        $m->{$x->{x},$x->{y}} = '.';
        $m->{$pp} = '#';
        $x->{x} = $dx;
        $x->{y} = $dy;

        $moved++;
    }

    $maxx = max(map { $e->{$_}->{x} } keys %$e);
    $minx = min(map { $e->{$_}->{x} } keys %$e);
    $maxy = max(map { $e->{$_}->{y} } keys %$e);
    $miny = min(map { $e->{$_}->{y} } keys %$e);

    printf "$round %s: $minx,$miny - $maxx,$maxy :: moved: %d\n", join("",@dir), $moved;

    if ($round == 10)
    {
        $stage1 = ($maxx - $minx + 1) * ($maxy - $miny + 1) - scalar(keys %$e);
    }

    last if $moved == 0;

    push(@dir, shift(@dir)); # rotate directions

    # draw the map
    for my $y ($miny..$maxy)
    {
        for my $x ($minx..$maxx)
        {
            print ($m->{$x,$y} // ".");
        }
        print "\n";
    }


}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $round;
