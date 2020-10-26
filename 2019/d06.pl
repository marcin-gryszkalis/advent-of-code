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

sub deep
{
	my $a = shift;
	return 0 if $a eq 'COM';
	return 1 + deep($o{$a});
}

my %c;
$c{COM} = 0;

SCAN: while (1)
{
	for my $k (keys %o)
	{
		next if exists $c{$k};
		$c{$k} = deep($k);
		redo; # rescan
	}
	last;
}

my $s = 0;
for my $k (keys %c)
{
	$s += $c{$k}
}

say $s;