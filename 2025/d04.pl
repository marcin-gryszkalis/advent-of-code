#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $tab;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $tab->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

for my $stage (1..2)
{
    my $t = clone $tab;

    my $removed = 0;
    my @q = ();

    for my $sx (0..$maxx)
    {
        for my $sy (0..$maxy)
        {
            next unless $t->{$sx,$sy} eq '@';
            push(@q, "$sx,$sy");
        }
    }

    while (my $e = pop(@q))
    {
        my ($sx,$sy) = split/,/, $e;
        next unless $t->{$sx,$sy} eq '@';
        my $s = 0;

        my @n = ();
        for my $dx (-1..1)
        {
            for my $dy (-1..1)
            {
                my $x = $sx + $dx;
                my $y = $sy + $dy;
                next if $dx == 0 && $dy == 0;
                next if $x < 0 || $x > $maxx ||
                        $y < 0 || $y > $maxy;

                next unless $t->{$x, $y} eq '@';
                $s++;
                push(@n, "$x,$y");
            }
        }

        if ($s < 4)
        {
            $removed++;

            if ($stage == 2)
            {
                push(@q, @n);
                $t->{$sx,$sy} = '.';
            }
        }
    }

    say "Stage $stage: $removed";

}