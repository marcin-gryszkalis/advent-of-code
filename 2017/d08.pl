#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);

my $r;
my $s2max = 0;
for (@f)
{
    chomp;
    # wnh dec -346 if vke <= 331
    die unless /^(\S+)\s+(dec|inc)\s+(-?\d+)\s+if\s+(\S+)\s+(\S+)\s+(-?\d+)/;
    my ($reg, $mod, $val, $regx, $op, $opval) = @{^CAPTURE}; # ($1,..)

    $r->{$regx} //= 0;
    my $expr = "$r->{$regx} $op $opval";
    if (eval($expr))
    {
        $val = -$val if $mod eq "dec";
        $r->{$reg} += $val;
        $s2max = $r->{$reg} if $r->{$reg} > $s2max;
    }
}


printf "stage 1: %d\n", max(values %$r);
printf "stage 1: %d\n", $s2max;

# stage 1: 4448
# stage 1: 6582
