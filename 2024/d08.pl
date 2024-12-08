#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my %locations;

my $x = 0;
my $y = 0;
for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        push(@{$locations{$v}}, { 'x' => $x, 'y' => $y }) if $v ne '.';
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my $antinodes1;
my $antinodes2;
for my $frq (keys %locations)
{
        my $i = combinations($locations{$frq}, 2);
        C: while (my $c = $i->next)
        {
            my $dx = $c->[0]->{x} - $c->[1]->{x};
            my $dy = $c->[0]->{y} - $c->[1]->{y};

            $x = $c->[0]->{x} + $dx;
            $y = $c->[0]->{y} + $dy;
            $antinodes1->{$x,$y} = 1 unless $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;

            $x = $c->[1]->{x} - $dx;
            $y = $c->[1]->{y} - $dy;
            $antinodes1->{$x,$y} = 1 unless $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;


            $x = $c->[0]->{x};
            $y = $c->[0]->{y};
            while (1)
            {
                $antinodes2->{$x,$y} = 1;
                $x += $dx;
                $y += $dy;
                last if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
            }

            $x = $c->[1]->{x};
            $y = $c->[1]->{y};
            while (1)
            {
                $antinodes2->{$x,$y} = 1;
                $x -= $dx;
                $y -= $dy;
                last if $x < 0 || $x > $maxx || $y < 0 || $y > $maxy;
            }

        }

}

say "Stage 1: ", scalar keys %$antinodes1;
say "Stage 2: ", scalar keys %$antinodes2;