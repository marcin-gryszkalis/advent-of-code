#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;

my $x = 1;
my $i = 1;

my @s = map { '.' } (0..239);
my %cycles = qw/noop 1 addx 2/;
my $p = 0;
my $y = 1;
for (@f)
{
    my ($op,$v) = /(....)\s?(-?\d+)?/;
    for my $r (1..$cycles{$op})
    {
        $p = $i - 1;
        $y = $p % 40;
        $s[$p] = ($y >= $x-1 && $y <= $x+1) ? '#' : '.';
        $stage1 += $i * $x if ($i - 20) % 40 == 0;
        $i++;
    }

    $x += $v if $op eq 'addx';
#    print "$i $p $x $y\n";
}


printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage1;

for my $k (0..239)
{
    print $s[$k];
    print "\n" if $k % 40 == 39;
}
