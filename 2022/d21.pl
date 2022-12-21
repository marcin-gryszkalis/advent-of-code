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
}

sub calc($m)
{
    return $v{$m} if exists $v{$m};

    my $a = calc($op{$m}->{a});
    my $b = calc($op{$m}->{b});
    return eval "$a $op{$m}->{op} $b";
}

printf "Stage 1: %s\n", calc('root');

sub calc2($m, $humn)
{
    $v{humn} = $humn;
    return calc($m);
}

# binary search, assumes that the input function is monotonic (it is true for example and actual inputs)
my $increasing = (calc2('root', 1000) > calc2('root', 0));

$op{root}->{op} = '-';

my $l = 0;
my $r = 999_999_999_999_999;

while (1)
{
    my $i = $l + int(($r-$l)/2);
    my $x = calc2('root', $i);

    print "$l < $i < $r :: $x\n";

    if ($x == 0)
    {
        $stage2 = $i;
        last;
    }
    elsif ($increasing && $x < 0 || !$increasing && $x > 0)
    {
        $l = $i;
    }
    else
    {
        $r = $i;
    }
}

printf "Stage 2: %s\n", $stage2;
