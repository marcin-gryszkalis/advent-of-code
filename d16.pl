#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use POSIX qw/ceil floor/;

my @a;
open(my $f, "d16.txt") or die $!;
while (<$f>)
{
	@a = split //;
	last;
}

my $l = scalar @a;
say "LEN($l)";

for my $phase (1..100)
{
	my @o = ();
	for my $i (0..$l-1) # i/o digits
	{
		my @p = ((0) x ($i+1), (1) x ($i+1), (0) x ($i+1), (-1) x ($i+1));
		my $pl = scalar @p;

		@p = (@p) x ($l / $pl + 1);
		shift @p;

#		say "P: ".join(",", @p);

		my $x = 0;
		my $pi = 0;
		for my $e (@a)
		{
			$x += ($e * shift(@p));
		}
		push(@o, abs($x) % 10);
	}

	my $r = join("", @o);
#	$r = substr($r,0,8);
	printf "%4d %s\n", $phase, $r;
	@a = @o;
}

