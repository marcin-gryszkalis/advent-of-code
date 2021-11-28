#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Digest::MD5 qw(md5_hex);

my $safe = 0;

my $input = ".^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^....";
# $input = ".^^.^.^^^^"; # test
my $rows2check = 400000;
# $rows2check = 10; # test

my $N = length $input;

my $p = $input;
my $c = 0;
for my $y (1..$rows2check)
{
    $c++;

#    print "$c: $p\n";

    my $pp = $p;
    $pp =~ s/\^//g;
    $safe += length($pp);

    print "Stage 1: $safe\n" if $c == 40;
    print "Stage 2: $safe\n" if $c == $rows2check;

    my $s = '';
    for my $i (0..$N-1)
    {
        my $l = $i == 0 ? '.' : substr($p, $i-1, 1);
        my $c = substr($p, $i  , 1);
        my $r = $i == $N-1 ? '.' : substr($p, $i+1, 1) || '.';

        my $n = (
        # Then, a new tile is a trap only in one of the following situations:
        # Its left and center tiles are traps, but its right tile is not.
            ($l eq '^' && $c eq '^' && $r eq '.') ||
        # Its center and right tiles are traps, but its left tile is not.
            ($l eq '.' && $c eq '^' && $r eq '^') ||
        # Only its left tile is a trap.
            ($l eq '^' && $c eq '.' && $r eq '.') ||
        # Only its right tile is a trap.
            ($l eq '.' && $c eq '.' && $r eq '^')
        ) ? '^' : '.';

        $s .= $n;
    }
    $p = $s;
}

