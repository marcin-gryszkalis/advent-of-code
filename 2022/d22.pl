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

my $stage1 = 0;
my $stage2 = 0;

my @f =  read_file(\*STDIN, chomp => 1);
my $tx = pop @f;
pop @f;
#@f = map { [split//] } @f;

my $wy = scalar(@f);
my $wx = max(map { length $_ } @f);
my $maxy = $wy - 1;
my $maxx = $wx - 1;

my ($sx,$sy) = (-1,0); #,$ex,$ey);
my $m;
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {
        next unless exists $r[$x];
        next if $r[$x] eq ' ';
        $m->{$x,$y} = $r[$x];
        $sx = $x if $r[$x] eq '.' && $sx == -1;
    }
}

$tx =~ s/(\d+)/ $1 /g;
$tx =~ s/^\s+//;
$tx =~ s/\s+$//;
my @t = split/ /,$tx;

my @mov = (
[1,0], # R
[0,1],
[-1,0],
[0,-1], # U
);

my @g = qw/> V < ^/;
my $x = $sx;
my $y = $sy;
my $dir = 0;

$m->{$x,$y} = $g[$dir];

for my $op (@t)
{
    print "$x, $y [$dir]: $op\n";
    if ($op =~ /\d/)
    {
        my $dx = $mov[$dir][0];
        my $dy = $mov[$dir][1];

        my $px = $x;
        my $py = $y;

        while (1)
        {
            #print "::: $x, $y [$dir]: $op\n";
            $x += $dx;
            $y += $dy;

            if ($x > $maxx) { $x = 0;  }
            if ($y > $maxy) { $y = 0;  }
            if ($x < 0) { $x = $maxx;  }
            if ($y < 0) { $y = $maxy;  }

            if (!exists $m->{$x,$y}) { next }
            if ($m->{$x,$y} eq '#') { $x = $px; $y = $py; last; }
            $m->{$x,$y} = $g[$dir];
            $px = $x;
            $py = $y;
            $op--;

            last if $op == 0;
        }
    }
    elsif ($op eq 'R')
    {
        $dir = ($dir + 1) % 4;
    }
    elsif ($op eq 'L')
    {
        $dir = ($dir - 1) % 4;
    }
    else
    {
        die $op;
    }

}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print exists $m->{$x,$y} ? $m->{$x,$y} : ' ';
    }
    print "\n";
}
$stage1 = ($x + 1) * 4 + ($y + 1) * 1000 + $dir;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;