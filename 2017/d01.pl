#!/usr/bin/perl
use Data::Dumper;

$_ = <>;
chomp;
my @a = split//;

my $s = 0;
for my $i (0..scalar(@a))
{
    $s += $a[$i] if $a[$i] == $a[($i+1) % scalar(@a)];
}

printf "stage 1: %d\n", $s;


$s = 0;
for my $i (0..scalar(@a))
{
    $s += $a[$i] if $a[$i] == $a[($i+scalar(@a)/2) % scalar(@a)];
}

printf "stage 2: %d\n", $s;
