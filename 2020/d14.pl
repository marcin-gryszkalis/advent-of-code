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

# m               01X 01X
# a               000 111
# expected        010 011

# m1              011 011
# m0              010 010

# a & m1          000 011
# a & m1 | m0     010 011

my $mask0; # X=0
my $mask1; # X=1

for (@ff)
{
    if (/mask = ([01X]+)/)
    {
        $mask0 = $mask1 = $1;
        $mask0 =~ s/X/0/g; $mask0 = oct("0b$mask0");
        $mask1 =~ s/X/1/g; $mask1 = oct("0b$mask1");
    }
    elsif (/mem\[(\d+)\] = (\d+)/)
    {
        $m1{$1} = ($2 & $mask1) | $mask0;
    }
    else { die $_ }
}


sub g
{
    my $a = shift;
    my $v = shift;
    if ($a =~ /X/)
    {
        g($a =~ s/X/0/r, $v);
        g($a =~ s/X/1/r, $v);
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
