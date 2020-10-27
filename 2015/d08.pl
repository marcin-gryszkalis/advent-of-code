#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

use File::Slurp;
my @f = read_file(\*STDIN);

sub xdec($)
{
    $_ = shift;
    return $_ if s/\\x(..)/chr(hex($1))/e;
    return $_ if s/\\"/"/;
    return $_ if s/\\\\/\\/;
}

my $a = 0;
my $b = 0;
my $c = 0;

for my $line (@f)
{
    chomp $line;

    $_ = $line;
    $a += length $_;

    s/(^"|"$)//g;

    # can't do this in 3 steps, no order would process these right:
    # \\\x41 -> \A
    # \\x41 -> \x41
    s/(\\x(..)|\\"|\\\\)/xdec($1)/eg;
    $b += length $_;

#    print "[$line] -decode-> [$_]\n";

    $_ = $line;
    s/("|\\)/\\$1/g;
    $_ = qq{"$_"};
    $c += length $_;

#    print "[$line] -encode-> [$_]\n";
}

printf "stage 1: %d\n", $a-$b;
printf "stage 2: %d\n", $c-$a;
