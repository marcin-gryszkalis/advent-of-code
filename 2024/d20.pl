#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @op = (
    [1,0],  # >
    [0,1],  # v
    [-1,0], # <
    [0,-1], # ^
);

my $stage1 = 0;
my $stage2 = 0;

my @f = read_file(\*STDIN, chomp => 1);

my $t;

my ($startx, $starty) = (0, 0);
my ($endx, $endy) = (0, 0);
my $startdir = 0;

my $y = 0;
for (@f)
{
    last if /^$/;
    my $x = 0;
    for my $v (split//)
    {
        ($startx, $starty) = ($x, $y) if $v eq 'S';
        ($endx, $endy) = ($x, $y) if $v eq 'E';
        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my @q = ();
my $dist;
push(@q, [$startx,$starty,0]);
#$dist->{$startx,$starty} = 0;
$t->{$startx,$starty} = 'X';

while (my $e = shift(@q))
{
    my ($x,$y,$c) = @$e;
    $dist->{$x,$y} = $c;

    for my $o (@op)
    {
        my ($dx,$dy) = @$o;
        my ($nx,$ny) = ($x + $dx, $y + $dy);
        next if $t->{$nx,$ny} eq '#';
        next if $t->{$nx,$ny} eq 'X';

        push(@q, [$nx, $ny, $c+1]);
        $t->{$nx,$ny} = 'X';
    }
}

my %cheats;
for my $y (1..$maxy-1)
{
    for my $x (1..$maxx-1)
    {
        next unless $t->{$x,$y} eq '#';
        if ($t->{$x-1,$y} eq 'X' && $t->{$x+1,$y} eq 'X')
        {
            $cheats{abs($dist->{$x-1,$y} - $dist->{$x+1,$y}) - 2}++;
            #say "- $x,$y : ", abs($dist->{$x-1,$y} - $dist->{$x+1,$y});
        }
        if ($t->{$x,$y-1} eq 'X' && $t->{$x,$y+1} eq 'X')
        {
            $cheats{abs($dist->{$x,$y-1} - $dist->{$x,$y+1}) - 2}++;
            #say "| $x,$y : ", abs($dist->{$x,$y-1} - $dist->{$x,$y+1});
        }
    }
}

#print Dumper \%cheats;

$stage1 = sum map { $cheats{$_} } grep { $_ >= 100 } keys %cheats;

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
