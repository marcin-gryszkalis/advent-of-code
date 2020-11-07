#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $startch = 'A';

$_ = <>;
chomp;

my $garbage = 0;
sub count_garbage
{
    $garbage += length($_[0]);
    return '';
}

s/!!//g;
s/!.//g;
s/\<([^>]+)\>/count_garbage($1)/ge;
s/[^{}]//g;

sub f
{
    my $s = shift;
    my $t = '';
    for my $x (split(//,$s))
    {
        $t .= chr(ord($x)+1);
    }
    return $startch.$t;
}

s/{}/$startch/g;
my $i = 0;
while (1)
{
    s/{([^{}]+)}/f($1)/ge;
#    print "$_\n\n";
    last unless /{/;
    $i++;
}

my $sum = 0;
for my $s (split//)
{
    $sum += (ord($s)-ord($startch)+1);
}
printf "stage 1: %d\n", $sum;
printf "stage 2: %d\n", $garbage;
# print "$_\n";
