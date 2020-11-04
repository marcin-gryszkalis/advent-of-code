#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# directions
my @x = qw/n ne se s sw nw/;
         # 0  1  2 3  4  5

# rules:
# opposite: x and x+3 - null
# reduction: x and x+2 - x+1

sub dist
{
    $_ = shift;
    $_ = ",$_,";

    while (1)
    {
        my $l = length($_);

        for my $i (0..5) # opposite
        {
            my $d1 = $x[$i];
            my $d2 = $x[($i+3) % 6];
            my $r = '';

            s/,$d1(,.*?,)$d2,/,$r,$1,/g;
            s/,$d2(,.*?,)$d1,/,$r,$1,/g;
        }

        for my $i (0..5) # reduction
        {
            my $d1 = $x[$i];
            my $d2 = $x[($i+2) % 6];
            my $r = $x[($i+1) % 6];

            s/,$d1(,.*?,)$d2,/,$r,$1,/g;
            s/,$d2(,.*?,)$d1,/,$r,$1,/g;
        }

        s/,+/,/g; # cleanup

        last if length($_) == $l;
    }

    s/^,//; s/,$//;
    return (() = m/,/g) + 1;
}

my $p = <>;
chomp $p;

my $s1dist = dist($p);
printf("stage 1: %d\n", $s1dist);

my $best = 0;
my @a = split(/,/,$p);
my @b = @a[0..$s1dist];
@a = @a[$s1dist+1..$#a];
while (1) # 0.5h but easiest to implement :)
{
    last if scalar(@a) == 0;
    push(@b, shift(@a));
    my $d = dist(join(",", @b));
    $best = $d if $d > $best;
    printf "%4d -> %4d | d: %4d | best: %4d\n", scalar(@a), scalar(@b), $d, $best;
    last if $best - $d > scalar(@a); # n steps left to check, but we are more than n under best
}

printf("stage 2: %d\n", $best);
