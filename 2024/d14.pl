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

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @robots;
for (@f)
{
    /p=(.+),(.+) v=(.+),(.+)/;
    push(@robots, { x => $1, y => $2, vx => $3, vy => $4 });
}

# test input
# my ($w, $h) = (11,7);
my ($w, $h) = (101,103);

my $nsmax = 0;
for my $step (1..10000)
{
    my $img = undef;

    my $neighbourscore = 0;
    for my $r (@robots)
    {
        $r->{x} = ($r->{x} + $r->{vx}) % $w;
        $r->{y} = ($r->{y} + $r->{vy}) % $h;
        $img->{$r->{x},$r->{y}} = 1;
    }

    if ($step == 100)
    {
        for my $r (@robots)
        {
            if ($r->{x} == int($w/2) || $r->{y} == int($h/2))
            {
                $r->{q} = '-';
                next;
            }

            $r->{q} = ($r->{x} < int($w/2) ? 0 : 1).($r->{y} < int($h/2) ? 0 : 1);
        }

        my %fq = frequency map { $_->{q} } grep { $_->{q} ne '-' } @robots;
        say "Stage 1: ", product values %fq;
    }


    for my $y (1..$h-2)
    {
        for my $x (1..$w-2)
        {
            next unless exists $img->{$x,$y};
            $neighbourscore++ if exists $img->{$x-1,$y};
            $neighbourscore++ if exists $img->{$x+1,$y};
            $neighbourscore++ if exists $img->{$x,$y-1};
            $neighbourscore++ if exists $img->{$x,$y+1};
        }
    }

    if ($neighbourscore > $nsmax)
    {
        $nsmax = $neighbourscore;
        $stage2 = $step;

        say "$step $neighbourscore";
        for my $y (0..$h-1)
        {
            for my $x (0..$w-1)
            {
                print exists $img->{$x,$y} ? "#" : ".";
            }
            print "\n";
        }
    }
}

say "Stage 2: ", $stage2;
