#!/usr/bin/perl
use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);
shift @f; # skip cd /

my $stage1 = 0;
my $stage2 = 0;

my $t;
$t->{ROOT}->{SIZE} = 0;
$t->{ROOT}->{FP} = 'ROOT'; # full path

my $ft; # flat tree

my $x = $t->{ROOT};
my @xstack;

for (@f)
{
    if (/\$ cd (\S+)/)
    {
        my $n = $1;
        if ($n eq '..')
        {
            $x = pop(@xstack);
        }
        else
        {
            unless (defined $x->{$n})
            {
                $x->{$n}->{SIZE} = 0;
                $x->{$n}->{FP} = $x->{FP}."/".$n;
                $ft->{$x->{$n}->{FP}} = 0;
            }

            push(@xstack, $x);
            $x = $x->{$n};
        }
    }
    elsif (/(\d+) (\S+)/)
    {
        my $xs = $1;

        $x->{SIZE} += $xs;
        $ft->{$x->{FP}} += $xs;
        for my $xx (@xstack)
        {
            $xx->{SIZE} += $xs;
            $ft->{$xx->{FP}} += $xs;
        }
    }
    # ls and dir are no-op
}

my $tofree = 30000000 - (70000000 - $t->{ROOT}->{SIZE});

for my $k (sort { $ft->{$a} <=> $ft->{$b} } keys %$ft)
{
    $stage1 += $ft->{$k} if $ft->{$k} < 100000;
    $stage2 = $ft->{$k} if $stage2 == 0 && $ft->{$k} > $tofree;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;