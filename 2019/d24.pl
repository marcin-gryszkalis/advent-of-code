#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;


my $size = 5; # + offset around
my @zm = ( map { [('@') x ($size+2)] } (0..($size+2))  );
my $m = \@zm;


open(my $f, "d24.txt") or die $!;
my $sy = 0;
my $sx = 0;
for my $r (<$f>)
{
	chomp $r;
	my @rt = split//,$r;

	$sx = 0;
	for my $c (@rt)
	{
		$m->[$sx+1]->[$sy+1] = $c;
		$sx++;
	}
	$sy++;
}


sub draw()
{
	for my $y (0..$sy+1)
	{
		for my $x (0..$sx+1)
		{
			print $m->[$x]->[$y];
		}
		print "\n";
	}
	print "\n";
}

draw();

my $h;
while (1)
{
	my @nm = ( map { [('@') x ($size+2)] } (0..($size+2))  );
	my $n = \@nm;

	my $s = '';

	for my $y (1..$sy)
	{
		for my $x (1..$sx)
		{
			my $c = 0;
			$c++ if $m->[$x+1]->[$y] eq '#';
			$c++ if $m->[$x-1]->[$y] eq '#';
			$c++ if $m->[$x]->[$y+1] eq '#';
			$c++ if $m->[$x]->[$y-1] eq '#';

			if ($m->[$x]->[$y] eq '#' && $c != 1)
			{
				$n->[$x]->[$y] = '.'; # bug dies
			}
			elsif ($m->[$x]->[$y] eq '.' && ($c == 1 || $c == 2))
			{
				$n->[$x]->[$y] = '#'; # bug happens
			}
			else
			{
				$n->[$x]->[$y] = $m->[$x]->[$y];
			}

			$s .= $n->[$x]->[$y];
#			print "$x $y = $m->[$x]->[$y] (c=$c) -> $n->[$x]->[$y]\n";
		}
	}

	$m = \@nm;

	draw();

	if (exists $h->{$s})
	{
		my $c = 0;
		my $i = 0;
		for my $y (1..$sy)
		{
			for my $x (1..$sx)
			{
				if ($m->[$x]->[$y] eq '#')
				{
					$c += (2 ** $i);
				}
				$i++;
			}
		}

		say "BIODIVERSITY($c)";
		last;
	}

	$h->{$s} = 1;
}