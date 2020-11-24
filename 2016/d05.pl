#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

use Digest::MD5 qw(md5 md5_hex md5_base64);

my $input = "ugkcyxxp";

my $p = '';
my $i = 0;
L: for my $l (1..8)
{
    while (1)
    {
        my $dh = md5_hex($input.$i);
        $i++;
        next unless $dh =~ /^00000(.)/;
        $p .= $1;
        printf "%10d %s %s\n", $i, $dh, $p;
        next L;
    }
}
printf "stage 1: %s\n", $p;

my @pa = ('_') x 8;
$p = join("", @pa);
$i = 0;
M: while (1)
{
    last unless $p =~ /_/;
    while (1)
    {
        my $dh = md5_hex($input.$i);
        $i++;
        next unless $dh =~ /^00000(.)(.)/;
        my $pos = hex($1);
        my $c = $2;
        next if $pos >= 8;
        next if $pa[$pos] ne '_';
        @pa[$pos] = $c;
        $p = join("", @pa);
        printf "%10d %s %s\n", $i, $dh, $p;
        next M;
    }
}
printf "stage 2: %s\n", $p;