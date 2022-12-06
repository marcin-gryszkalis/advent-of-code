#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);
my $s = $f[0];

for my $stage (1..2)
{
    my $len = $stage == 1 ? 4 : 14;

    my $i = 0;
    while (1)
    {
        my @a = split//,substr($s,$i,$len);
        last if scalar(uniq @a) == $len;
        $i++;
    }

    printf "Stage %d: %d\n", $stage, $i+$len;
}
