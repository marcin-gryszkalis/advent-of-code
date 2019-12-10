#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;

# starting asteroid

my $x = 26;
my $y = 29;

my $m;

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


my $p;

my @zzz = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $o = \@zzz; # visited map


my $cnt = 0;
my @srx = ((reverse -$sx..-1),(0..$sx));
my @sry = ((reverse -$sy..-1),(0..$sy));

# sort destinations by angle and distance to base
my $pi = 3.14159265358979;
my $at;
for my $dx (@srx)
{
	for my $dy (@sry)
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

		print STDERR "   [$ddx,$ddy] -- ".($o->[$x+$ddx]->[$y+$ddy])."\n";
		next if $o->[$x+$ddx]->[$y+$ddy] == 1; # visited

		print STDERR "   new at ".($x+$ddx).",".($y+$ddy)." -- ".($m->[$x+$ddx]->[$y+$ddy])."\n";
		$o->[$x+$ddx]->[$y+$ddy] = 1; # mark visited
		if ($found==0 && $m->[$x+$ddx]->[$y+$ddy] == 1) # first asteroid
		{
			$found=1;
			$cnt++;
			print "FOUND $cnt victim at ".($x+$ddx).",".($y+$ddy)."\n";
			exit if $cnt == 200;
		}
	}
}

