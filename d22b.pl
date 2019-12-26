#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

my @commands = ();
open(my $f, "d22.txt") or die $!;
while (<$f>)
{
	chomp;
	push(@commands, $_);
}

my $size = 10007;
# $size = 119315717514047;
my $rep = 101741582076661;

my @deck = (0..$size-1);
# printf("deck: %s\n", join(" ", @deck));

# https://rosettacode.org/wiki/Modular_inverse#Perl
sub invmod
{
	my($a,$n) = @_;
	my($t,$nt,$r,$nr) = (0, 1, $n, $a % $n);
	while ($nr != 0)
	{
		# Use this instead of int($r/$nr) to get exact unsigned integer answers
		my $quot = int( ($r - ($r % $nr)) / $nr );
		($nt,$t) = ($t-$quot*$nt,$nt);
		($nr,$r) = ($r-$quot*$nr,$nr);
	}

	return if $r > 1; # can't find
	$t += $n if $t < 0;
	return $t;
}

my $p = 4485;
for my $c (reverse @commands)
{
	say $c;
	if ($c =~ /deal with increment (\d+)/)
	{
		my $incr = $1;
		$p = ($p * invmod($incr, $size)) % $size;
	}
	elsif ($c =~ /cut (-?\d+)/)
	{
		my $cut = $1;
		$p = ($p + $cut + $size) % $size;
	}
	elsif ($c =~ /deal into new stack/)
	{
		$p = $size - $p - 1;
	}
	else
	{
		die;
	}
}
say $p;

