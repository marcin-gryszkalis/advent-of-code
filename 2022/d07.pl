#!/usr/bin/perl
use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);
shift @f; # skip cd /

my $stage1 = 0;
my $stage2 = 0;

my $tt;
$tt->{ROOT}->{SIZE} = 0;
$tt->{ROOT}->{FP} = 'ROOT'; # full path

my $ft; # flat tree

my $xt = $tt->{ROOT};
my @xstack;

for (@f)
{
    if (/\$ cd (\S+)/)
    {
        my $n = $1;
        if ($n eq '..')
        {
            $xt = pop(@xstack);
        }
        else
        {
            unless (defined $xt->{$n})
            {
                $xt->{$n}->{SIZE} = 0;
                $xt->{$n}->{FP} = $xt->{FP}."/".$n;
                $ft->{$xt->{$n}->{FP}} = 0;
            }

            push(@xstack, $xt);
            $xt = $xt->{$n};
        }
    }
    elsif (/\$ ls/)
    {
        next;
    }
    elsif (/dir (\S+)/)
    {
        next;
    }
    elsif (/(\d+) (\S+)/)
    {
        my $xs = $1;

        $xt->{SIZE} += $xs;
        $ft->{$xt->{FP}} += $xs;
        for my $xxt (@xstack)
        {
            $xxt->{SIZE} += $xs;
            $ft->{$xxt->{FP}} += $xs;
        }
    }
    else
    {
        die $_;
    }
}

# say Dumper $tt;

my $tofree = 30000000 - (70000000 - $tt->{ROOT}->{SIZE});

for my $k (sort { $ft->{$a} <=> $ft->{$b} } keys %$ft)
{
    $stage1 += $ft->{$k} if $ft->{$k} < 100000;
    $stage2 = $ft->{$k} if $stage2 == 0 && $ft->{$k} > $tofree;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;