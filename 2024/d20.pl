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

my $GAIN_THRESHOLD = 100;

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

my $y = 0;
for (@f)
{
    my $x = 0;
    for my $v (split//)
    {
        ($startx, $starty) = ($x, $y) if $v eq 'S';
        ($endx, $endy) = ($x, $y) if $v eq 'E';
        $t->{$x++,$y} = $v;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my $dist;

my @q = ();
push(@q, [$startx,$starty,0]);

while (my $e = shift(@q))
{
    my ($x,$y,$c) = @$e;
    $dist->{$x,$y} = $c;
    $t->{$x,$y} = 'X';

    for my $o (@op)
    {
        my ($dx,$dy) = @$o;
        my ($nx,$ny) = ($x + $dx, $y + $dy);
        next if $t->{$nx,$ny} eq '#';
        next if $t->{$nx,$ny} eq 'X';

        push(@q, [$nx, $ny, $c+1]);
    }
}

for my $stage (1..2)
{
    my $cl = $stage == 1 ? 2 : 20;

    my %cheats = ();
    my %tested = ();
    for my $y (1..$maxy-1)
    {
        for my $x (1..$maxx-1)
        {
            next unless $t->{$x,$y} eq 'X';

            for my $oy ($y-$cl..$y+$cl)
            {
                next if $oy <= 0 || $oy >= $maxy;

                my $dy = abs($oy-$y);
                for my $ox ($x-($cl-$dy)..$x+($cl-$dy))
                {
                    next if $ox <= 0 || $ox >= $maxx;
                    next if $x == $ox && $y == $oy;

                    next if $t->{$ox,$oy} ne 'X';
                    next if exists $tested{$ox,$oy,$x,$y};

                    my $dist = abs($dist->{$x,$y} - $dist->{$ox,$oy});
                    my $distcheat = abs($x-$ox) + abs($y-$oy);

                    $cheats{$dist - $distcheat}++;
                    $tested{$x,$y,$ox,$oy} = 1;
                }
            }
        }
    }

    say "Stage $stage: ", sum map { $cheats{$_} } grep { $_ >= $GAIN_THRESHOLD } keys %cheats;
}
