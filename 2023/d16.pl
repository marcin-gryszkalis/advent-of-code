#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax indexes/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;
my $maxe = 0;

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

my @sq;
for my $sy (0..$maxy)
{
    push(@sq, [0,$sy,1,0]);
    push(@sq, [$maxx,$sy,-1,0]);
}

for my $sx (0..$maxx)
{
    push(@sq, [$sx,0,0,1]);
    push(@sq, [$sx,$maxy,0,-1]);
}

for my $ss (@sq)
{
    my @q;
    push(@q, $ss);

    my $e = undef;
    my $v = undef;

    while (my $start = pop(@q))
    {
        my ($x,$y,$dx,$dy) = @$start;

        next if $x < 0 || $x > $maxx;
        next if $y < 0 || $y > $maxy;

        next if exists $v->{$x,$y,$dx,$dy};
        $v->{$x,$y,$dx,$dy} = 1;
        $e->{$x,$y} = 1;

        if ($t->{$x,$y} eq '|' && $dy == 0)
        {
            push(@q, [$x,$y-1,0,-1]);
            push(@q, [$x,$y+1,0,1]);
            next;
        }

        if ($t->{$x,$y} eq '-' && $dx == 0)
        {
            push(@q, [$x-1,$y,-1,0]);
            push(@q, [$x+1,$y,1,0]);
            next;
        }

        if ($t->{$x,$y} eq '/')
        {
            my $ndx = -$dy;
            my $ndy = -$dx;
            push(@q, [$x+$ndx,$y+$ndy,$ndx,$ndy]);
            next;
        }

        if ($t->{$x,$y} eq '\\')
        {
            my $ndx = $dy;
            my $ndy = $dx;
            push(@q, [$x+$ndx,$y+$ndy,$ndx,$ndy]);
            next;
        }

        # just go
        push(@q, [$x+$dx,$y+$dy,$dx,$dy]);
    }

    my $enrg = sum values %$e;
    $stage1 = $enrg if $stage1 == 0;

    $maxe = max($maxe, $enrg);
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $maxe;
