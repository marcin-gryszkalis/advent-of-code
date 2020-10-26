#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use POSIX qw/ceil floor/;
use Math::Utils qw/lcm/;

my $e;
my $stor; # storage
open(my $f, "d14.txt") or die $!;
while (<$f>)
{
	# 7 A, 1 B => 1 C
	my @a = split /\s=>\s/;
	my @b = split(/\s/, $a[1]);
	my @c = split(/,\s/, $a[0]);
	$e->{$b[1]}->{cnt} = $b[0];
	my @i = 0;
	for my $n (@c)
	{
		my @d = split(/\s/, $n);
		$e->{$b[1]}->{req}->{$d[1]} = $d[0];
		$stor->{$d[1]} = 0; # init empty storage
	}
}
$stor->{FUEL} = 0;

my $lvl = 0;
sub dbg
{
	my $m = shift;
	print STDERR ("  " x ($lvl-1))."$m\n";
}

my $ore = 0; # global harvested ORE
sub produce
{
	$lvl++;
	my $w = shift;
	my $a = shift;

	dbg "start - produce $a pieces of $w";
	if ($w eq 'ORE')
	{
		dbg "harvested $a ORE";
		$ore += $a;
		$stor->{ORE} += $a;
		$lvl--;
		return;
	}

	my $c = $e->{$w}->{cnt};
	# my $m = ceil($a/$c);
	dbg "we need $a pieces of $w, produced in $c/bag";

	if ($stor->{$w} >= $a)
	{
		dbg "we have enough $w in storage: $stor->{$w}";
		return;
	}

	my $old = $stor->{$w};
	dbg "we'll use $old of $w from storage (all)";

	my $new = $a - $old;
	my $newbags = ceil($new / $c);
	dbg "still need $new of $w, so we'll produce $newbags bags";

	for my $r (sort keys %{$e->{$w}->{req}})
	{
		# for reaction we need $r,
		my $rc = $e->{$w}->{req}->{$r};
		dbg "so for reaction to create $newbags bags of $w we need $newbags*$rc of $r";
		produce($r, $newbags * $rc); # produce $newbags * $rc or more!

		# the reaction:
		my $forreac = $newbags * $rc;
		$stor->{$r} -= $forreac;
		dbg "we used $forreac of $r for reaction, $stor->{$r} left in storage";
	}

	# the reaction effect
	my $save = $c*$newbags;
	$stor->{$w} += $save;
	dbg "created $save of $w, total: $stor->{$w}";

	$lvl--;
	return;
}


# part 1
$ore = 0;
produce('FUEL', 1);
say "1 FUEL requires $ore ORE";
sleep(3);

# part 2
my $nmin = 1;
my $nmax = 10000000;

my $goal = 1000000000000;

$ore = 0;
produce('FUEL', $nmin);
my $oremin = $ore;
for my $k (keys %$stor) { $stor->{$k} = 0 }

$ore = 0;
produce('FUEL', $nmax);
my $oremax = $ore;
for my $k (keys %$stor) { $stor->{$k} = 0 }

die $oremin if $oremin >= $goal;
die $oremax if $oremax <= $goal;

my $fu = 0;
while (1)
{
	$fu++;

	my $n = $nmin + floor(($nmax - $nmin) / 2);
	last if ($n == $nmin);

	$ore = 0;
	produce('FUEL', $n);
	say "$fu: [$nmin,$nmax] - $n FUEL requires $ore ORE";

	$nmax = $n if $ore > $goal;
	$nmin = $n if $ore < $goal;

	$ore = 0;
	for my $k (keys %$stor) { $stor->{$k} = 0 }
}

