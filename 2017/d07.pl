#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $parent;
my $kids;
my @nodes;
my $baseweight;
while (<>)
{
    chomp;

    next unless m/(\S+).*?(\d+)(.*->\s*(.*))?/;
    my $p = $1;
    push(@nodes, $p);
    $baseweight->{$p} = $2;

    if (defined $4)
    {
        my @cs = split/,\s*/, $4;
        $kids->{$p} = \@cs;
        for my $c (@cs)
        {
            $parent->{$c} = $p;
        }
    }
}

my $top = first { !exists($parent->{$_}) } @nodes;
print "stage 1: $top\n";

sub wup
{
    my $n = shift;
    my $level = shift;

    my $w;
    my $wsum = 0;
    if (exists $kids->{$n}) # not a leaf node
    {
        for my $k (@{$kids->{$n}})
        {
            $w->{$k} = wup($k, $level+1);
            $wsum += $w->{$k};
        }

        my $maxv = max(values %$w);
        my $minv = min(values %$w);
        if ($maxv != $minv)
        {
            printf "stage 2: node=%s diff=%d\n", $n, $maxv - $minv;
            for my $m (keys %$w)
            {
                my $bw = $baseweight->{$m};
                my $nw = 0;
                if ($w->{$m} < $maxv)
                {
                    $nw = $bw + ($maxv - $minv);
                }
                else
                {
                    $nw = $bw - ($maxv - $minv);
                }
                printf "%10s weight=%-10d kids-weight=%-10d new-weight=%-10d\n", $m, $baseweight->{$m}, $w->{$m}, $nw;
            }
            exit;
        }

    }
    return $baseweight->{$n} + $wsum;
}

wup($top, 0)