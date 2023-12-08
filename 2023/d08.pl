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

my $stage1 = 0;
my $stage2 = 0;

my @instr = split//,shift @f;
shift @f;

my $p1 = 'AAA';
my @p2 = ();

my $m;
for (@f)
{
    my ($f,$l,$r) = m/[A-Z0-9]+/g;
    $m->{$f}->{L} = $l;
    $m->{$f}->{R} = $r;

    push @p2, $f if $f =~ /A$/;
}

my %found;
my $i = 0;

while (1)
{
    last if $p1 eq 'ZZZ';
    $p1 = $m->{$p1}->{$instr[$i % scalar(@instr)]};
    $i++;
}
$stage1 = $i;

$i = 0;
L: while (1)
{
    for my $q (@p2)
    {
        if ($q =~ /Z$/)
        {
            $found{$q} = $i;
            last L if scalar keys %found == scalar @p2;
        }

        $q = $m->{$q}->{$instr[$i % scalar(@instr)]};
    }

    $i++;
}
$stage2 = lcm(values %found);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;