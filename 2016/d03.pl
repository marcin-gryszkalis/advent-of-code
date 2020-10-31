#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my @f = read_file(\*STDIN);

my $ok = 0;
for (@f)
{
    chomp;
    my @t = m/(\d+)\s+(\d+)\s+(\d+)/;
    @t = sort { $a <=> $b } @t;
    $ok++ if $t[0]+$t[1] > $t[2];
}

printf "stage 1: %d\n", $ok;



$ok = 0;
my $i = 0;
my (@x0,@x1,@x2);
for (@f)
{
    chomp;
    my @t = m/(\d+)\s+(\d+)\s+(\d+)/;

    push(@x0, $t[0]);
    push(@x1, $t[1]);
    push(@x2, $t[2]);

    if ($i % 3 == 2)
    {
        @t = sort { $a <=> $b } @x0;
        $ok++ if $t[0]+$t[1] > $t[2];
        @t = sort { $a <=> $b } @x1;
        $ok++ if $t[0]+$t[1] > $t[2];
        @t = sort { $a <=> $b } @x2;
        $ok++ if $t[0]+$t[1] > $t[2];

        @x0 = (); @x1 = (); @x2 = ();
    }

    $i++;
}

printf "stage 2: %d\n", $ok;

