#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);

my $ok = 0;
for (@f)
{
    chomp;

    next if /\[[a-z]*([a-z])(?!\1)(.)\2\1/; # abba inside []
    next unless /([a-z])(?!\1)(.)\2\1/; # abba
    $ok++;
}

printf "stage 1: %d\n", $ok;


$ok = 0;
for (@f)
{
    chomp;

    # a[b]c[d]e -> e c a X d b
    my @a = split/[\[\]]/;
    my $i = 0;
    my $t = ' X ';
    for my $s (@a)
    {
        $t = $i % 2 == 0 ? "$s $t" : "$t $s"; # even even odd odd
        $i++;
    }

    $ok++ if $t =~ /([a-z])(?!\1)([a-z])\1.*X.*\2\1\2/;

}

printf "stage 2: %d\n", $ok;