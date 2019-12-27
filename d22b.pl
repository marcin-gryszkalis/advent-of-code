#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::BigInt;


my @commands = ();
open(my $f, "d22.txt") or die $!;
while (<$f>)
{
	chomp;
	push(@commands, $_);
}

# my $size = 10007;
my $size = 119315717514047;
my $rep = 101741582076661;
my $p = 2020;
# $p = 4485;

my @f = ();
my $i = 1;
my $x = $p;
for my $i (1..10)
{
	for my $c (reverse @commands)
	{
#		say $c;
		if ($c =~ /deal with increment (\d+)/)
		{
			my $incr = Math::BigInt->new($1);
			$p = ($p * $incr->copy()->bmodinv($size)) % $size;
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


# a*x+b = f1
# a*f1+b = f2
#    V
# a*x - a*f1 = f1 - f2
# a * (x - f1) = f1 - f2
# a = (f1 - f2) / (x - f1) # / -- div % size -> modular inverse
# b = f1 - (a * x)

my $a = (($f[1] - $f[2]) * Math::BigInt->new($x - $f[1])->bmodinv($size)) % $size;
my $b = ($f[1] - $a * $x) % $size;
say "a=$a";
say "b=$b";

# f_n(x) = ... a * ( a * (a*x + b) + b) + b ...
# f_n(x) = ... a * ( a*a*x + a*b) + b) + b ...
# f_n(x) = ... a*a*a*x + a*a*b + a*b + b ...
# f_n(x) = ... a^3*x + a^2*b + a^1*b + a^0*b ...

# f_n(x) = a^n*x + a^(n-1)*b + a^(n-2)*b + ... + a^(n-n)*b
# f_n(x) = a^n*x + a^(n-1)*b + a^(n-2)*b + ... + b

# geometric seq, sum of elements s_1..s_k:
# s_k = a_1 * (1 - q^n) / (1 - q)

# f_n(x) = a^n*x + b * (1 - a^n) / (1 - a)

# my $result = (((($a ** $x) % $size) + ($b * (1 - $a ** $rep) % $size)) / (1 - $a)) % $size;

my $result = ((($a->copy()->bmodpow($rep,$size) * $x) % $size) + ($b * (1 - $a->copy()->bmodpow($rep,$size)) * Math::BigInt->new(1-$a)->bmodinv($size))) % $size;

say "result at $rep repetitions = $result";
