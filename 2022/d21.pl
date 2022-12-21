#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %v;
my %op;
for (@f)
{
    # root: pppw + sjmn
    # dbpl: 5

    if (/(....):\s+(\d+)/)
    {
        $v{$1} = $2;
    }
    elsif (/(....):\s+(....) (.) (....)/)
    {
        $op{$1}->{a} = $2;
        $op{$1}->{b} = $4;
        $op{$1}->{op} = $3;
    }
    else
    {
        die $_;
    }
}

sub calc($m)
{
    return $v{$m} if exists $v{$m};

    my $a = calc($op{$m}->{a});
    my $b = calc($op{$m}->{b});
    return eval "$a $op{$m}->{op} $b";
}

$stage1 = calc('root');

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;