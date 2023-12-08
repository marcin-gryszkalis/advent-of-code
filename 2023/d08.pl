#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
use ntheory qw/lcm/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);
my @instr = split//,shift @f;
shift @f;

my $stage1 = 0;
my $stage2 = 0;

my $m;
for (@f)
{
    my ($f,$l,$r) = m/[A-Z0-9]+/g;
    $m->{$f}->{L} = $l;
    $m->{$f}->{R} = $r;
}

my $p = 'AAA';
my $i = 0;
while ($p ne 'ZZZ')
{
    $p = $m->{$p}->{$instr[$i++ % scalar(@instr)]};
}
$stage1 = $i;

my @pi;
for $p (grep { /A$/ } keys %$m)
{
    $i = 0;
    while ($p !~ /Z$/)
    {
        $p = $m->{$p}->{$instr[$i++ % scalar(@instr)]};
    }
    push(@pi, $i);

}
$stage2 = lcm(@pi);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;