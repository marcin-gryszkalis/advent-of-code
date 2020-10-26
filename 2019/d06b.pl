#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
no warnings 'recursion';

my %o;

open(my $f, "d06.txt") or die $!;
while (<$f>)
{
	chomp;
	m/(.+)[)](.+)/;
	$o{$2} = $1; # 2 directly orbits 1
}

my %youpath;
my $i = 'YOU';
my $d = 0;
while ($i ne 'COM')
{
	$i = $o{$i};
	$youpath{$i} = $d;
	$d++;
}

$i = 'SAN';
$d = 0;
while (1)
{
	$i = $o{$i};
	last if exists $youpath{$i};
	$d++;
}

say $youpath{$i} + $d;

