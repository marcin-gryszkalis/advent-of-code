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
my @deck = (0..$size-1);
# printf("deck: %s\n", join(" ", @deck));

for my $c (@commands)
{
	say $c;
	if ($c =~ /deal with increment (\d+)/)
	{
		my $incr = $1;
		my @d = ();
		my $i = 0;
		for my $i (0..$size-1)
		{
			$d[($i*$incr) % $size] = $deck[$i];
		}
		@deck = @d;
	}
	elsif ($c =~ /cut (-?\d+)/)
	{
		my $cut = $1;
		$cut = $size + $cut if $cut < 0;
		@deck = (@deck[$cut..$size-1], @deck[0..$cut-1]);
	}
	elsif ($c =~ /deal into new stack/)
	{
		@deck = reverse @deck;
	}
	else
	{
		die;
	}

	printf("deck: %s...\n", substr(join(" ", @deck),0,100));
}

for my $i (0..$size-1)
{
	say "2019($i)" if $deck[$i] == 2019;
}