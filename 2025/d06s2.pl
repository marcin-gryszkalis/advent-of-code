#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my $stage2 = 0;

my @l = read_file(\*STDIN, chomp => 1);
my @ops;
my @e;
for (@l)
{
    my @a = split//;
    my $i = 0;
    $e[$i++] .= $_ for @a;
    $e[$i] .= " ";
}

my $exp = '';
my $op;
for (@e)
{
    if (/([+*])/)
    {
        $op = $1;
        $exp .= $_;
    }
    elsif (/\d/)
    {
        $exp .= "$_$op";
    }
    else
    {
        $exp =~ s/[+*]$//;
        $stage2 += eval($exp);
        $exp = '';
    }
}

say "Stage 2: ", $stage2;
