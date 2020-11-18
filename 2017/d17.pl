#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Digest::MD5 qw(md5 md5_hex md5_base64);

# input:
my $STEP = 363;

my $LASTM1 = 2017;
my $LASTM2 = 50_000_000;

my $cm = { v => 0, prv => undef, nxt => undef };
$cm->{prv} = $cm;
$cm->{nxt} = $cm;

my $i = 1;
while ($i <= $LASTM1)
{
    $cm = $cm->{nxt} for (0..$STEP-1);

    $cm = { v => $i, prv => $cm, nxt => $cm->{nxt} };
    $cm->{prv}{nxt} = $cm;
    $cm->{nxt}{prv} = $cm;

    $i++;
}
printf "stage 1: %d\n", $cm->{nxt}{v};

$i = 1;
my $pos = 0;
my $stage2 = -1;
while ($i <= $LASTM2)
{
    $pos = ($pos + $STEP) % $i;
    $pos++;
    $stage2 = $i if $pos == 1;
    $i++;
}
printf "stage 2: %d\n", $stage2;
