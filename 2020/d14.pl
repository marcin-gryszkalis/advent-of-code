#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

no warnings 'portable'; # Binary number > 0b11111111111111111111111111111111 non-portable

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $stage1 = 0;
my $stage2 = 0;

my %m1;
my %m2;
my $mask;


for (@ff)
{
    if (/mask = ([01X]+)/)
    {
        $mask = $1;
    }
    elsif (/mem\[(\d+)\] = (\d+)/)
    {
        my $addr = $1;
        my $v = $2;

        my @va = split//, sprintf("%036b", $v);
        my @ma = split//, $mask;
        my $r = '';
        for my $i (0..35)
        {
            $r .= ($ma[$i] eq 'X' ? $va[$i] : $ma[$i]);
        }

        $m1{$addr} = oct("0b$r");
    }
    else { die $_ }
}



sub g
{
    my $a = shift;
    my $v = shift;
    if ($a =~ /X/)
    {
        my $b = $a;
        $a =~ s/X/0/;
        $b =~ s/X/1/;
        g($a, $v);
        g($b, $v);
    }
    else
    {
        $m2{oct("0b$a")} = $v;
    }
}


for (@ff)
{
    if (/mask = ([01X]+)/)
    {
        $mask = $1;
    }
    elsif (/mem\[(\d+)\] = (\d+)/)
    {
        my $addr = $1;
        my $v = $2;

        my @aa = split//, sprintf("%036b", $addr);
        my @ma = split//, $mask;

        my $r = '';
        for my $i (0..35)
        {
            $r .= ($ma[$i] eq '0' ? $aa[$i] : $ma[$i]);
        }

        g($r, $v);
    }
    else { die $_ }
}


printf "stage 1: %d\n", sum(values %m1);
printf "stage 2: %d\n", sum(values %m2);
