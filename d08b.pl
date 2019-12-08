#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

 # 0 is black, 1 is white, and 2 is transparent.

open(my $f, "d08.txt") or die $!;
my $r = <$f>;

my $w = 25;
my $h = 6;
my $ls = $w * $h; # layer size

my @a = $r =~ m/.{1,$ls}/g;

my @t;
my $lc = 0; # layer count
for my $l (@a)
{
	my @b = split//,$l;
	push(@t,\@b);
	$lc++;
}

my $map = {
	0 => ".",
	1 => "#"
};

my @res = ();
my $i = 0;
EXT: for my $c (0..$ls-1)
{
	for my $i (0..$lc-1)
	{
		my $p = $t[$i][$c];
		if ($p < 2)
		{
			push(@res, $map->{$p});
			next EXT;
		}

	}
}

my $c = 0;
for my $c (0..$ls-1)
{
	print shift(@res);
	$c++;
	print "\n" unless $c % $w;
}
