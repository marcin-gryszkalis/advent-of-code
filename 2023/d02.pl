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

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

G: for (@f)
{
    m/^Game (\d+): (.*)/;
    my $id =  $1;
    my $r = $2;
    my @a = split/; /,$r;
    my $bad = 0;

    my $maxr = 0;
    my $maxb = 0;
    my $maxg = 0;

    for my $x (@a)
    {
        my @p = ($x =~ m/(\d+ \D+)/g);
        for my $k (@p)
        {
#            print "$id ::: $x ::: $k\n";
            $k =~ m/(\d+) (\S+)/;
            my $col = $2;
            my $v = $1;
            print "($2 $1)\n";
            $bad = 1 if $col =~ /red/ && $v > 12;
            $bad = 1 if $col =~ /green/ && $v > 13;
            $bad = 1 if $col =~ /blue/ && $v > 14;

            $maxr = max($maxr, $v) if $col =~ /red/;
            $maxg = max($maxg, $v) if $col =~ /green/;
            $maxb = max($maxb, $v) if $col =~ /blue/;
        }
    }

    my $power = $maxr * $maxg * $maxb;

    $stage2 += $power;
print "!!!$id!!! $power\n";
    $stage1 += $id unless $bad;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;