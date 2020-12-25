#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;


my $cpub = 11349501;
my $dpub = 5107328;

# test case:
# $cpub = 5764801;
# $dpub = 17807724;

my $dvd = 20201227;

my $cloopsize = 0;
my $dloopsize = 0;

my $subj = 7;
my $v = 1;
while ($v != $cpub)
{
    $cloopsize++;

    $v *= $subj;
    $v %= $dvd;
}

$subj = 7;
$v = 1;
while ($v != $dpub)
{
    $dloopsize++;

    $v *= $subj;
    $v %= $dvd;
}

print "card loop size: $cloopsize\n";
print "door loop size: $dloopsize\n";

my $stage1 = 1;
for (1..$dloopsize)
{
    $stage1 *= $cpub;
    $stage1 %= $dvd;
}

my $stage2 = 1;
for (1..$cloopsize)
{
    $stage2 *= $dpub;
    $stage2 %= $dvd;
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";