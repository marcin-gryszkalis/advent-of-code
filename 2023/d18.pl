#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $m = {
'0' => [1,0],
'1' => [0,1],
'2' => [-1,0],
'3' => [0,-1],
};

my %mm = qw/R 0 D 1 L 2 U 3/;


for my $stage (1..2)
{
    my $total = 0;

    my $t = {};

    my ($x,$y) = (0,0);

    # I or E: internal (3 sides inside) / external (3 sides outside) vertex
    my $intext = {};

    $f[-1] =~ m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;
    my $pd = $stage == 1 ? $mm{$1} : $4;

    for (@f)
    {
        my ($d1,$l1,$h5,$d2) = m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;

        my $d = $stage == 1 ? $mm{$d1} : $d2;
        my $l = $stage == 1 ? $l1 : hex($h5);

        # assume we have internal on the right (i.e. vertices are clockwise):
        # turn right - external, turn left - internal
        $intext->{$x,$y} = "$pd$d" =~ /(01|12|23|30)/ ? 'E' : 'I'; #($d - ($pd+4) %4 == 1) ? 'E' : 'I';

        $x += $m->{$d}->[0] * $l;
        $y += $m->{$d}->[1] * $l;

        push(@{$t->{$y}}, $x);

        $pd = $d;
    }

    # check left-most vertex from set of top-most vertices
    $y = min keys %$t;
    $x = min @{$t->{$y}};
    die "assumption that interior is on the right side was wrong :)" unless $intext->{$x,$y} eq 'E';

    my %state = ();

    my $py = 0;
    for my $y (sort { $a <=> $b } keys %$t)
    {
        if (%state)
        {
            my $v = reduce { $a + $b->[1] - $b->[0] + 1 } (0, pairs sort { $a <=> $b } keys %state);
            $total += $v * ($y - $py - 1); # lines between changes
        }
        $py = $y;

        my %nstate = %state;

        if (exists $t->{$y}) 
        {
            for my $x (sort { $a <=> $b } @{$t->{$y}})
            {
                delete $nstate{$x} if exists $state{$x} && $intext->{$x,$y} eq 'I';
                $nstate{$x} = 1 if !exists$state{$x} && $intext->{$x,$y} eq 'E';
            }
        }

        my $v = reduce { $a + $b->[1] - $b->[0] + 1 } (0, pairs sort { $a <=> $b } keys %nstate);
        $total += $v;

        if (exists $t->{$y})
        {
            for my $x (sort { $a <=> $b } @{$t->{$y}})
            {
                delete $nstate{$x} if exists $state{$x} && $intext->{$x,$y} eq 'E';
                $nstate{$x} = 1 if !exists$state{$x} && $intext->{$x,$y} eq 'I';
            }
        }

        %state = %nstate;
    }

    printf "Stage $stage: %s\n", $total;
}
