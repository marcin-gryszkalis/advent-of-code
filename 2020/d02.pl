#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $c = 0;
my $d = 0;
for (@f)
{
    # 3-5 q: scqrdqq
    m/(\d+)-(\d+)\s+(\S):\s+(\S+)/;
    my ($a,$b,$l,$p) = @{^CAPTURE};

    $d++ if (substr($p,$a-1,1) eq $l) xor (substr($p,$b-1,1) eq $l);

    $p =~ s/[^$l]//g;
    $c++ if length($p) >= $a && length($p) <= $b;
}
print "stage 1: $c\n";
print "stage 2: $d\n";

