#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;

my $p = "vzbxkghb";

my $found = 0;
while (1)
{
    # increase
    my @a = split(//, reverse $p);
    my $i = 0;
    while (1)
    {
        $a[$i] = chr(ord($a[$i])+1);
        last unless $a[$i] eq '{'; # z+1 = {
        $a[$i] = 'a';
        $i++;
    }
    $p = join("", reverse @a);

    # Passwords may not contain the letters i, o, or l, as these letters can be mistaken for other characters and are therefore confusing.
    next if $p =~ /[iol]/;

    # Passwords must contain at least two different, non-overlapping pairs of letters, like aa, bb, or zz.
    next unless $p =~ /(.)\1.*((?!\1).)\2/;

    # Passwords must include one increasing straight of at least three letters, like abc, bcd, cde, and so on, up to xyz. They cannot skip letters; abd doesn't count.
    @a = split(//, $p);
    $i = 1;
    my $d = 0;
    while ($i < scalar @a)
    {
        if (ord($a[$i]) - 1 == ord($a[$i-1]))
        {
            $d++;
            last if $d == 2;
        }
        else
        {
            $d = 0;
        }
        $i++;
    }
    next if $d < 2;


    print "$found $p\n";
    $found++;
    last if $found > 10;
}