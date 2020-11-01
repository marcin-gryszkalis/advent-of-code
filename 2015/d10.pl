#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;

my $inp = "1113122113";
#$inp = "3";
my $s = $inp;
# my $cc = 1.303577296; # * length($s);
my $cc = 1.30357726903429639125709911215255189073070250465940487575486139062855088785246155712681576686442522555;
my $l2 = 1;
my $l1 = 0;
for my $i (1..57)
{
    $s =~ s/((.)\2*)/length($1).$2/eg;
    $l2 = $l1 * $cc;
    $l1 = length($s);
    my $df = abs($l2-$l1);
    printf "%d %d %d %d %s\n", $i, $l1, $l2, $df, $s eq '1113122113' ? "!" : "";
}

# 40 (-5?) 360154
# 40  95798
