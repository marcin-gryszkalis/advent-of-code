#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

my $m; # skymap

my $sy = 0;
my $sx = 0;

open(my $f, "d10.txt") or die $!;
for my $r (<$f>) 
{
	chomp $r;
	my @rt = split//,$r;

	$sx = 0;
	for my $c (@rt)
	{
		$m->[$sx]->[$sy] = $c eq '#' ? 1 : 0;
		$sx++;
	}
	$sy++;
}

$sx--;
$sy--;

my $bestx = 0;
my $besty = 0;
my $max = 0;

for my $x (0..$sx)
{
	for my $y (0..$sy)
	{
		next unless $m->[$x]->[$y]; # start at asteroid
		print STDERR "ASTEROID ($x,$y)\n";

        my @zzz = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
		my $o = \@zzz; # visited map

		my $cnt = 0;
		my @srx = ((reverse -$sx..-1),(0..$sx)); # -1, -2, ..., 0, 1, 2...
		my @sry = ((reverse -$sy..-1),(0..$sy));
		for my $dx (@srx)
		{
			DY: for my $dy (@sry)
			{
				next if $dx == 0 && $dy == 0;

				my $found = 0;
                
                my $farx = $dx != 0 ? int($sx / abs($dx)) + 1 : 0;
                my $fary = $dy != 0 ? int($sy / abs($dy)) + 1 : 0;
                my $far = $farx > $fary ? $farx : $fary;
				for my $dd (1..$far) # step with given $dx,$dy
				{
					my $ddx = $dx * $dd;
					my $ddy = $dy * $dd;
					next if $x+$ddx > $sx || $x+$ddx < 0; # out of board
					next if $y+$ddy > $sy || $y+$ddy < 0;

					print STDERR "   [$x + $ddx,$y + $ddy] = [".($x+$ddx).",".($y+$ddy)."] -- ".($o->[$x+$ddx]->[$y+$ddy])."\n";
					next if $o->[$x+$ddx]->[$y+$ddy] == 1; # visited

					print STDERR "   new at ".($x+$ddx).",".($y+$ddy)." -- ".($m->[$x+$ddx]->[$y+$ddy])."\n";
					$o->[$x+$ddx]->[$y+$ddy] = 1; # mark visited
					if ($found == 0 && $m->[$x+$ddx]->[$y+$ddy] == 1) # first asteroid
					{
						print STDERR "   FOUND at ".($x+$ddx).",".($y+$ddy)."\n";
						$found=1;
						$cnt++;
					}
				}

			}
		}

		say "$x,$y -> $cnt";
		if ($cnt > $max)
		{
			$max = $cnt;
			$bestx = $x;
			$besty = $y;
			say "MAX $x,$y -> $cnt";
		}
		exit if $cnt == 0;
	}
}

