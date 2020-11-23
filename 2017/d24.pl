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

my $used;
my $best = 0;
my $best2 = 0;
my $bestlen = 0;
my @bridge;

sub check
{
    my $level = shift;
    my $p = shift;

    my $gonedeeper = 0;
    for my $e (@f)
    {
        next if $used->{$e};

        $e =~ m{(\d+)/(\d+)};

        if ($1 eq $p || $2 eq $p) # it looks like 0--0 connection is valid
        {
            $used->{$e} = 1;
            push(@bridge, $e);

            check($level+1, $1 eq $p ? $2 : $1);

            pop(@bridge);
            $used->{$e} = 0;

            $gonedeeper = 1;
        }
    }

    unless ($gonedeeper)
    {
        my $sum = 0;
        for my $k (@bridge)
        {
            $k =~ m{(\d+)/(\d+)};
            $sum += ($1 + $2);
        }

        if ($sum > $best)
        {
            $best = $sum;
            printf "S1 %2d %s = %d\n", scalar(@bridge), join("--", @bridge), $sum;
        }

        if (scalar(@bridge) > $bestlen)
        {
            $bestlen = scalar(@bridge);
            $best2 = $sum; # reset best2 for better len
            printf "S2 %2d %s = %d\n", scalar(@bridge), join("--", @bridge), $sum;
        }

        if (scalar(@bridge) == $bestlen && $sum > $best2) # best of the best of...
        {
            $best2 = $sum;
            printf "S2 %2d %s = %d\n", scalar(@bridge), join("--", @bridge), $sum;
        }
    }
}

check(0, "0"); # anchor point

print "stage 1: $best\n";
print "stage 2: $best2\n";
