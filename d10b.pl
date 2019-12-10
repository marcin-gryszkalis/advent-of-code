#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

# starting asteroid
my $x = 26;
my $y = 29;

my $victim = 2000;

my $m; # skymap

my $sy = 0;
my $sx = 0;

my $anum = 0; # number of asteroids on map
open(my $f, "d10.txt") or die $!;
for my $r (<$f>)
{
	chomp $r;
	my @rt = split//,$r;

	$sx = 0;
	for my $c (@rt)
	{
		$m->[$sx]->[$sy] = $c eq '#' ? 1 : 0;
		$anum += $m->[$sx]->[$sy];
		$sx++;
	}

	$sy++;
}

$sx--;
$sy--;


my $p;

my $cnt = 0;

# sort destinations by angle and distance to base
my $pi = 3.14159265358979;
my $at;
for my $dx (-$sx..$sx)
{
	for my $dy (-$sy..$sy)
	{
		next if $dx == 0 && $dy == 0;
		my $angle = $pi - atan2($dx,$dy);
		$at->{"$dx:$dy"} = $angle;
	}
}

my @pt = sort {
	my ($ax,$ay) = split/:/,$a;
	my ($bx,$by) = split/:/,$b;
	return $at->{$a} <=> $at->{$b} || (abs($ax)+abs($ay) <=> abs($bx)+abs($by))
	} keys %$at;

# for my $p (@pt) { print "$p - $at->{$p}\n"; } exit;

while (1)
{
	say "Start a round!";

	my @zzz = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
	my $o = \@zzz; # visited map

	for my $p (@pt)
	{
		my ($dx,$dy) = split/:/,$p;
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
				$found=1;
				$cnt++;
				$m->[$x+$ddx]->[$y+$ddy] = 0; # remove from map
				$anum--;
				
				print "FOUND $cnt victim at ".($x+$ddx).",".($y+$ddy).", $anum left\n";
				exit if $cnt == $victim;

				die "all asteroids killed" if $anum == 1; # 1 = base
			}
		}
	}
}
