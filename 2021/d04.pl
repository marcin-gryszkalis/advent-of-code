#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = grep {/\d/} map { chomp; $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my @b = split/,/, shift @f;

my $t; # tables
my $h; # hits
my $bc = scalar(@f) / 5;
my %ts;
for my $tn (1..$bc)
{
    $ts{$tn} = 1;
    for my $x (0..4)
    {
        my @r = (shift(@f) =~ /\d+/g);
        for my $y (0..4)
        {
            $t->{$tn}->{$x,$y} = $r[$y];
        }
    }
}

for my $n (@b)
{
    for my $tn (keys %ts)
    {
        for my $x (0..4)
        {
            for my $y (0..4)
            {
                if (($t->{$tn}->{$x,$y} // -1) == $n)
                {
                    $h->{$tn}->{"x$x"}++;
                    $h->{$tn}->{"y$y"}++;
                    delete $t->{$tn}->{$x,$y};
                }
            }
        }
    }

    T: for my $tn (sort { $a <=> $b } keys %ts)
    {
        if (any { $_ == 5 } values %{$h->{$tn}})
        {
            my $r = sum(values(%{$t->{$tn}}));
            $stage1 = $r * $n if $stage1 == 0;
            $stage2 = $r * $n;
#            print "n($n) tn($tn) r($r)\n";
            delete $ts{$tn};
            next T;
        }
    }

}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;