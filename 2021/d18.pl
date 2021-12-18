#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use POSIX qw/ceil floor/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

sub xadd
{
    my $s = "[".join(",",@_)."]";
    while (1)
    {
        my $prev = $s;

        $s = xplode($s);
        next if $prev ne $s;

        $s = xplit($s);
        next if $prev ne $s;

        return $s;
    }
}

sub xplode
{
    my $s = shift;
    my @t = $s =~ m/(\[|\]|,|\d+)/g;
    my $l = 0; # level
    my $lpos = -1; # number on left
    my $rpos = -1; # number on right
    my $xpos = -1; # pos of [ for exploding

    for my $i (0..scalar(@t)-1)
    {
        $l++ if $t[$i] eq '[';
        $l-- if $t[$i] eq ']';
        if ($t[$i] =~ /\d/)
        {
            if ($xpos == -1)
            {
                $lpos = $i;
            }
            elsif ($rpos < $xpos+4) # xpos found, rpos not found (-1) or inside xploded pair
            {
                $rpos = $i;
            }
        }

        if ($l == 5 && $xpos == -1)
        {
            $xpos = $i; # we can't stop here becuase we need to find $rpos
        }
    }

    if ($xpos > -1)
    {
        $t[$rpos] += $t[$xpos+3] if $rpos > -1;
        $t[$lpos] += $t[$xpos+1] if $lpos > -1;
        splice(@t, $xpos, 5, 0);
    }

    return join("",@t);
}

sub xplit
{
    $_ = shift;
    return s{(\d\d+)}{"[".floor($1/2).",".ceil($1/2)."]"}er;
}

sub mag
{
    $_ = shift;
    1 while s/\[(\d+),(\d+)\]/3*$1+2*$2/eg;
    return $_;
}

$stage1 = mag(reduce { xadd($a,$b) } @f);

for my $a (@f)
{
    for my $b (@f)
    {
        $stage2 = max($stage2, mag(xadd($a,$b)), mag(xadd($b,$a)));
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;