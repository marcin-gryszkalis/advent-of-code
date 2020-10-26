#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

use File::Slurp;
my @f = read_file(\*STDIN);

my $i = 0;
for (@f)
{
    # It contains at least three vowels (aeiou only), like aei, xazegov, or aeiouaeiouaeiou.
    next unless /([aeiou].*){3}/;

    # It contains at least one letter that appears twice in a row, like xx, abcdde (dd), or aabbccdd (aa, bb, cc, or dd).
    next unless /(.)\1/;

    # It does not contain the strings ab, cd, pq, or xy, even if they are part of one of the other requirements.
    next if /(ab|cd|pq|xy)/;

    $i++;
}
print "stage 1: $i\n";

$i = 0;
for (@f)
{
    # It contains a pair of any two letters that appears at least twice in the string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
    next unless /(..).*\1/;

    # It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
    next unless /(.).\1/;

    $i++;
}
print "stage 2: $i\n";
