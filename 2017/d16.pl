#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

$_ = <>;
chomp;
my @dance = split/,/;

#my @s = ();
my $i = 0;
my $s0 = join("", ('a'..'p'));
my $s = $s0;

sub swap($$$)
{
    my ($x, $m, $n) = @_;

    my $a = substr($x, $m, 1);
    my $b = substr($x, $n, 1, $a);
    substr($x, $m, 1) = $b;
    return $x;
}

my $rem = -1;
my $try = 1;
while (1)
{
    for my $d (@dance)
    {
        # Exchange, written xA/B, makes the programs at positions A and B swap places.
        if ($d =~ m{^x(\d+)/(\d+)})
        {
            $s = swap($s, $1, $2);

        }
        # Partner, written pA/B, makes the programs named A and B swap places.
        elsif ($d =~ m{^p(.)/(.)})
        {
            $s = swap($s, index($s, $1), index($s, $2));
        }
        # Spin, written sX, makes X programs move from the end to the front, but maintain their order otherwise. (For example, s3 on abcde produces cdeab).
        elsif ($d =~ m{^s(\d+)})
        {
            $s = substr($s, -$1).substr($s, 0, length($s)-$1);
        }
        else
        {
            die $d;
        }
    }

    printf "stage 1: %s\n", $s if $try == 1 && $rem == -1;
#    printf "$try: %s\n", $s;

    if ($rem == -1 && $s eq $s0)
    {
        $rem = 1_000_000_000 % $try;
        print "cycle: $try (reminder: $rem)\n";
        $try = 1;
        next;
    }

    if ($rem > -1 && $try == $rem)
    {
        printf "stage 2: %s\n", $s;
        last;
    }

    $try++;
}
