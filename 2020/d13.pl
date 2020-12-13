#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $t = $ff[0];
my @b = grep { /\d/ } split(/,/, $ff[1]);

my $stage1 = 0;
my $stage2 = 0;

L: for my $i ($t..$t+1000)
{
    for my $a (@b)
    {
        if ($i % $a == 0)
        {
            $stage1 = ($i - $t) * $a;
            last L;
        }
    }
}

print "stage 1: $stage1\n";

my @b2 =  split(/,/, $ff[1]);
my @c;
my $i = 0;
for my $a (@b2)
{
    if ($a ne 'x')
    {
        print "(t + $i) % $a == 0 -> (t % $a + $i % $a ) == 0 -> (t % $a) == ( -$i % $a ) ->   t mod $a = ".(-$i % $a)."\n";
        push(@c, [-$i % $a, $a]);
    }
    $i++;
}

use ntheory qw/chinese/;
printf "stage 2: %d\n", chinese(@c);
