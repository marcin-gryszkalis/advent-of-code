#!/usr/bin/perl
use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);
my @a = split//,$f[0];

sub beg($len)
{
    my $i = 0;
    while (1)
    {
        last if scalar(uniq @a[$i..$i+$len-1]) == $len;
        $i++;
    }
    return $i + $len;
}

printf "Stage 1: %d\n", beg(4);
printf "Stage 2: %d\n", beg(14);
