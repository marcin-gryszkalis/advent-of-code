#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

# X loose -> +2
# Y draw -> 0
# Z win -> +1
my %repl = qw/
0 2
1 0
2 1
/;

my @t = qw/A B C/;

for (@f)
{
    my ($a,$b) = m/(.) (.)/;
    $a = ord($a) - ord('A');
    $b = ord($b) - ord('X');

    $stage1 += $b+1;
    $stage1 += 3 if $a == $b;
    $stage1 += 6 if ($a+1) % 3 == $b;

    print "stage1: $a $b = $stage1\n";

    my $r = ($a + $repl{$b}) % 3;

    $stage2 += $r+1;
    $stage2 += 3 if $a == $r;
    $stage2 += 6 if ($a+1) % 3 == $r;

    print "stage2: $a ($b) $r = $stage2\n";
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
