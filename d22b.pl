#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use bignum;

# https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
# # https://rosettacode.org/wiki/Modular_inverse#Perl
use ntheory 'invmod';

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
my $p = 2020;

my @deck = (0..$size-1);
# printf("deck: %s\n", join(" ", @deck));

my @f = ();
my $i = 0;
my $x = $p;
for my $i (0..10)
{
	for my $c (reverse @commands)
	{
#		say $c;
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
			$p = ($size - $p - 1) % $size;
		}
		else
		{
			die;
		}
	}

	$f[$i] = $p;
	say "f_${i}($x)=$f[$i]";
}


# a*x+b = f0
# a*f0+b = f1
#    V
# a*x - a*f0 = f0 - f1
# a * (x - f0) = f0 - f1
# a = (f0 - f1) / (x - f0) # / -- div % size -> modular inverse
# b = f0 - (a * x)

my $a = (($f[0] - $f[1]) * invmod($x - $f[0], $size)) % $size;
my $b = ($f[0] - $a * $x) % $size;
say "a=$a";
say "b=$b";

# https://www.nayuki.io/page/fast-skipping-in-a-linear-congruential-generator
# x_k = [(a^n * x_0  % m)+((((a^n−1) % ((a−1)* m) ) / (a−1) ) * b)] % m.
# $rep = 5;

my $result = ((( ($a ** $rep) * $x) % $size) + (((($a ** $rep - 1) % (($a - 1) * $size)) / ($a-1)) * $b)) % $size;

say "result at $rep repetitions = $result";