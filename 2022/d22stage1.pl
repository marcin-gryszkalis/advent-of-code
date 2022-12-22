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

my @f =  read_file(\*STDIN, chomp => 1);
my $tx = pop @f;
pop @f; # empty line

my $maxy = scalar(@f) - 1;
my $maxx = max(map { length $_ } @f) - 1;

my ($sx,$sy) = (-1,0); # start
my $m;
for my $y (0..$maxy)
{
    my @r = split//,$f[$y];
    for my $x (0..$maxx)
    {
        next if !defined $r[$x] || $r[$x] eq ' ';
        $m->{$x,$y} = $r[$x];
        $sx = $x if $sx == -1 && $r[$x] eq '.';
    }
}

my @t = $tx =~ m/(\d+|[LR])/g;

my @mov = ([1,0], [0,1],[-1,0], [0,-1]);

my @g = qw/> V < ^/; # for drawing

my $x = $sx;
my $y = $sy;
my $dir = 0;

$m->{$x,$y} = $g[$dir];
for my $op (@t)
{
#    print "$x, $y [$dir]: $op\n";
    if ($op =~ /\d/)
    {
        my ($px, $py) = ($x, $y);

        while (1)
        {
            $x = ($x + $mov[$dir][0]) % ($maxx + 1);
            $y = ($y + $mov[$dir][1]) % ($maxy + 1);

            next unless exists $m->{$x,$y};

            if ($m->{$x,$y} eq '#')
            {
                $x = $px; # step back
                $y = $py;
                last;
            }

            $m->{$x,$y} = $g[$dir];

            ($px, $py) = ($x, $y);

            $op--;
            last if $op == 0;
        }
    }
    else
    {
        $dir = ($dir + ($op eq 'R' ? 1 : -1)) % 4;
    }
}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print $m->{$x,$y} // ' ';
    }
    print "\n";
}

printf "Stage 1: %s\n", ($x + 1) * 4 + ($y + 1) * 1000 + $dir;
