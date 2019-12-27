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
my $p = 4485;

my @deck = (0..$size-1);
# printf("deck: %s\n", join(" ", @deck));

# https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
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

	return if $r > 1; # can't find (normal div is not defined for 0, invmod is not defined when a ≡_n 0 [a congruent mod n with 0])
	$t += $n if $t < 0;
	return $t;
}

my @f = ();
my $i = 0;
my $x = $p;
for my $i (0..1)
{
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

	$f[$i] = $p;
}

say "f($x)=$f[0]";
say "f(f($x))=$f[1]";

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
say "a=$b";

