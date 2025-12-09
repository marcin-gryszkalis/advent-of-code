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

my @l = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;
my $t;
my $d;
my $circ;

for (@l)
{
    for my $o (keys %$t)
    {
        my ($x1,$y1,$z1) = split/,/;
        my ($x2,$y2,$z2) = split/,/, $o;
        my $dist = sqrt((($x1-$x2) ** 2) + (($y1-$y2) ** 2) + (($z1-$z2) ** 2));
        $d->{$_,$o} = $dist;
    }

    $t->{$_} = 0;
    $circ->{0}->{$_} = 1;
}

my @sd = sort { $d->{$a} <=> $d->{$b} } keys %$d;

my $L = scalar(keys %$t) < 100 ? 10 : 1000; # 10 for test case
my $C = 0;
my $l = 0;
for my $dk (@sd)
{
    if ($l++ == $L)
    {
        $stage1 = product((sort { $b <=> $a } map { scalar(keys %{$circ->{$_}}) } grep { $_ != 0 } keys %{$circ})[0..2]);
    }

    $dk =~ m/^(\d+,\d+,\d+),(.*)/;
    my ($xyz1,$xyz2) = ($1,$2);

    if ($t->{$xyz1} == $t->{$xyz2}) # same circuit number
    {
        if ($t->{$xyz1} > 0)
        {
            say "$l: skip $xyz1 to $xyz2 (already conn)"; # same big circuit, skip
            next;
        }

        # both are single, make new circuit and connect them
        $C++;
        say "$l: connect $xyz1 to $xyz2 (single = $C)";
        $t->{$xyz1} = $t->{$xyz2} = $C;
        $circ->{$C}->{$xyz1} = $circ->{$C}->{$xyz2} = 1;
        delete $circ->{0}->{$xyz1};
        delete $circ->{0}->{$xyz2};
    }
    else
    {
        # connect
        ($xyz1,$xyz2) = ($xyz2,$xyz1) if $t->{$xyz1} == 0; # swap
        my $c = $t->{$xyz1};
        my $kc = $t->{$xyz2};
        if ($kc == 0)
        {
            say "$l: connect $xyz2 ($t->{$xyz2}) to $xyz1 ($t->{$xyz1})";
            $circ->{$c}->{$xyz2} = 1;
            $t->{$xyz2} = $c;
            delete $circ->{0}->{$xyz2};
        }
        else
        {
            say "$l: connect $xyz2 (all in $t->{$xyz2}) to $xyz1 ($t->{$xyz1})";
            for my $k (keys %{$circ->{$kc}})
            {
                $circ->{$c}->{$k} = 1;
                $t->{$k} = $c;
            }
            delete $circ->{$kc};
        }
    }

    if (scalar(keys %{$circ->{0}}) == 0 && scalar(keys %$circ) == 2) # 0 and other
    {
        my ($x1,$y1,$z1) = split/,/, $xyz1;
        my ($x2,$y2,$z2) = split/,/, $xyz2;
        $stage2 = $x1 * $x2;
        last;
    }
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
