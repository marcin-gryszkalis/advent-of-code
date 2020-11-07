#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my %opmap = qw/dec - inc +/;
my $r;
my $s2max = 0;
while (<>)
{
    chomp;
    # wnh dec -346 if vke <= 331
    die unless /^(\S+)\s+(dec|inc)\s+(-?\d+)\s+if\s+(\S+)\s+(\S+)\s+(-?\d+)/;
    my ($reg, $mod, $val, $regx, $op, $opval) = @{^CAPTURE}; # ($1,..)

    $r->{$regx} //= 0;
    $r->{$reg} //= 0;
    eval("\$r->{\$reg} $opmap{$mod}= \$val if \$r->{\$regx} $op \$opval");
    $s2max = $r->{$reg} if $r->{$reg} > $s2max;
}

printf "stage 1: %d\n", max(values %$r);
printf "stage 2: %d\n", $s2max;