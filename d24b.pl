#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;


my $size = 5;
my $levels = 250; # it grows 2 levels (1 up, 1 down) every 2 cycles (approx)
my @zm = (map { [ map { [('.') x ($size)] } (0..($size))  ] } (0..$levels));

my $m = \@zm;

my $maxminutes = 200;

my $lzero = int($levels/2); # level zero

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
		$m->[$lzero]->[$sx]->[$sy] = $c;
		$sx++;
	}
	$sy++;
}

sub draw()
{
	for my $y (0..$sy-1)
	{
		for my $l (-10+$lzero..10+$lzero)
		{
			for my $x (0..$sx-1)
			{
				print $m->[$l]->[$x]->[$y];
			}

			print " ";
		}
			print "\n";
	}
}

draw();


my $mapx = <<'EOF';
	0 u7 1 5 u11
	1 u7 2 6 0
	2 u7 3 7 1
	3 u7 4 8 2
	4 u7 u13 9 3

	5 0 6 10 u11
	6 1 7 11 5
	7 6 2 8 d0 d1 d2 d3 d4
	8 3 9 13 7
	9 4 u13 14 8

	10 5 11 15 u11
	11 6 d0 d5 d10 d15 d20 16 10
	12 x
	13 8 14 18 d4 d9 d14 d19 d24
	14 9 u13 19 13

	15 10 16 20 u11
	16 11 17 21 15
	17 d20 d21 d22 d23 d24 18 22 16
	18 13 19 23 17
	19 14 u13 24 18

	20 15 21 u17 u11
	21 16 22 u17 20
	22 17 23 u17 21
	23 18 24 u17 22
	24 19 u13 u17 23
EOF

my @mapxx = grep { /\d/ } split /\n/, $mapx;

my $map;
for my $mx (@mapxx)
{
	$mx =~ s/^\s+//;
	$mx =~ s/\s+$//;
	my @mm = split/\s+/, $mx;
	my $i = shift @mm;
	$map->[$i] = \@mm;
}

my $h;
my $minutes = 0;
while ($minutes < $maxminutes)
{
	$minutes++;

	say "\nminutes($minutes)";
#	print STDERR "minutes($minutes)\n";
	my @nm = (map { [ map { [('.') x ($size)] } (0..($size))  ] } (0..$levels));
	my $n = \@nm;

	my $bugs = 0;
	for my $l ((-int($minutes/2)-1+$lzero)..(int($minutes/2)+1+$lzero))
	{
#		print STDERR "LEVEL($l)\n";
		for my $y (0..$sy-1)
		{
			for my $x (0..$sx-1)
			{
				my $c = 0;

				next if $x == int($size/2) && $y == int($size/2); # middle block

#				print STDERR "$x $y at $l\n";

				my $mi = $y * $size + $x;
				for my $nbr (@{$map->[$mi]})
				{
					my $xl = $l;
					$nbr =~ m/(u|d)?(\d+)/;
					my $xfer = $1 // '';
					$xl-- if $xfer eq 'd';
					$xl++ if $xfer eq 'u';
					my $ni = $2;

					my $nx = $ni % $size;
					my $ny = int($ni / $size);

					$c++ if $m->[$xl]->[$nx]->[$ny] eq '#';
#					print STDERR "   $nx $ny at $xl ($nbr) --- $m->[$xl]->[$nx]->[$ny] (c=$c)\n";

				}

				if ($m->[$l]->[$x]->[$y] eq '#' && $c != 1)
				{
					$n->[$l]->[$x]->[$y] = '.'; # bug dies
				}
				elsif ($m->[$l]->[$x]->[$y] eq '.' && ($c == 1 || $c == 2))
				{
					$n->[$l]->[$x]->[$y] = '#'; # bug happens
					$bugs++;
				}
				else
				{
					$n->[$l]->[$x]->[$y] = $m->[$l]->[$x]->[$y];
					$bugs++ if $m->[$l]->[$x]->[$y] eq '#';
				}

#				print STDERR "   RESULT: $x $y at $l = $m->[$l]->[$x]->[$y] (c=$c) -> $n->[$l]->[$x]->[$y]\n";
			}
		}
	}

	$m = \@nm;

	draw();
	say "BUGS($bugs)";
}