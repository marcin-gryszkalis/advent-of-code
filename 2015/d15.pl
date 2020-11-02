#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
# @f = map { chomp; int $_ } @f;

my $cap = 100; # sum of parts
my $rightcalories = 500;

my $h;
my @ingredients;
for (@f)
{
    chomp;
    # Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
    if (m/(\S+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)/)
    {
        $h->{$1}->{capacity} = $2;
        $h->{$1}->{durability} = $3;
        $h->{$1}->{flavor} = $4;
        $h->{$1}->{texture} = $5;
        $h->{$1}->{calories} = $6;
        push(@ingredients, $1);
    }
}


my @splits; # in fact is right boundary of range
# eg. splits = (20,50) -> a = 0..20, b = 21..50, c = 51..99
my $maxlevel = scalar(@ingredients) - 1;
my $best = 0;
my $best2 = 0;
sub sss
{
    my $level = shift;
    my $spl = shift;
    for my $myspl ($spl..$cap-1)
    {
        $splits[$level] = $myspl;
        if ($level < $maxlevel - 1)
        {
            sss($level+1, $myspl+1);
        }
        elsif ($level < $maxlevel)
        {
            sss($level+1, $cap-1);
        }
        else # maxlevel
        {
            $splits[$level] = $spl; # it will be $cap-1 (99) anyway
            my $total = 1;
            for my $property (keys %{$h->{Butterscotch}})
            {
                next if $property eq 'calories';

                my $i = 0;
                my $prev = -1; # prev. range (nonexistent) ends at -1, first starts at 0
                my $s = 0;
                for my $ig (@ingredients)
                {
                    my $c = $splits[$i] - $prev;
                    $s += ($h->{$ig}->{$property} * $c);
                    $prev = $splits[$i];
                    $i++;
                }

                return if $s <= 0; # If any properties had produced a negative total, it would have instead become zero, causing the whole score to multiply to zero.

                $total *= $s;
            }

            # separate count for calories
            my $i = 0;
            my $prev = -1;
            my $sc = 0;
            for my $ig (@ingredients)
            {
                my $c = $splits[$i] - $prev;
                $sc += ($h->{$ig}->{calories} * $c);
                $prev = $splits[$i];
                $i++;
            }

            if ($total > $best || ($sc == $rightcalories && $total > $best2))
            {
                my $i = 0;
                my $prev = -1;
                my @desc = ();
                for my $ig (@ingredients)
                {
                    my $c = $splits[$i] - $prev;
                    $prev = $splits[$i];
                    $i++;
                    push(@desc,"$c ($ig)");
                }

                print join(" + ", @desc)." = $total ($sc kcal)\n";
                $best = $total if $total > $best;
                $best2 = $total if $sc == $rightcalories;
            }
        }
    }

}

sss(0, 0);
printf "stage 1: %d\n", $best;
printf "stage 2: %d\n", $best2;