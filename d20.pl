#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations);

my $d = 0; # 0=top, 1=right, 2=down, 3=left
my @dx = qw/ 0 1 0 -1/;
my @dy = qw/-1 0 1  0/;

my $sx = 0; # board size -1 (max x,y)
my $sy = 0;

my @startx;
my @starty;

my $m;

my $x = 0;
my $y = 0;
open(my $f, "d20.txt") or die $!;
while (<$f>)
{
	chomp;
	$x = 0;
	for my $e (split//)
	{
		$sx = $x if $x > $sx;
		$m->[$x]->[$y] = $e;

		$x++;
	}
	$y++;
}
$sy = $y-1;

my %portalscnt = ();
my $portals;
# parse rows
for my $y (0..$sy-1)
{
	for my $x (0..$sx-1)
	{
		next unless exists $m->[$x]->[$y];
		if ($m->[$x]->[$y] =~ /[A-Z]/ && exists $m->[$x+1]->[$y] && $m->[$x+1]->[$y] =~ /[A-Z]/)
		{
			my $n = $m->[$x]->[$y].$m->[$x+1]->[$y];
			$portalscnt{$n} = defined $portalscnt{$n} ? $portalscnt{$n}+1 : 0;
			my $c = $portalscnt{$n};
			my $n = "$n$c";

			if (exists $m->[$x+2]->[$y] && $m->[$x+2]->[$y] eq '.')
			{
				$portals->{$n}->{x} = $x+2;
				$portals->{$n}->{y} = $y;
			}
			else
			{
				$portals->{$n}->{x} = $x-1;
				$portals->{$n}->{y} = $y;
			}
		}

	}
}

# parse cols
for my $x (0..$sx-1)
{
	for my $y (0..$sy-1)
	{
		next unless exists $m->[$x]->[$y];
		if ($m->[$x]->[$y] =~ /[A-Z]/ && exists $m->[$x]->[$y+1] && $m->[$x]->[$y+1] =~ /[A-Z]/)
		{
			my $n = $m->[$x]->[$y].$m->[$x]->[$y+1];
			$portalscnt{$n} = defined $portalscnt{$n} ? $portalscnt{$n}+1 : 0;
			my $c = $portalscnt{$n};
			my $n = "$n$c";

			if (exists $m->[$x]->[$y+2] && $m->[$x]->[$y+2] eq '.')
			{
				$portals->{$n}->{x} = $x;
				$portals->{$n}->{y} = $y+2;
			}
			else
			{
				$portals->{$n}->{x} = $x;
				$portals->{$n}->{y} = $y-1;
			}
		}

	}
}

# create graph
my $mv = 0;
my $step = 0;

my $g = Graph::Undirected->new;

# teleports
for my $e (keys %portalscnt)
{
	next if $e =~ /(AA|ZZ)/;
	$g->add_weighted_edge("${e}0", "${e}1", 1);
}

# reverse map
my $revmap;
for my $p (sort keys %$portals)
{
	my $x = $portals->{$p}->{x};
	my $y = $portals->{$p}->{y};
	$revmap->{"$x:$y"} = $p;
}

# BFS for every pair of elements
P: for my $p (sort keys %$portals)
{
	say "search from $p";

	my @bfsq = ();

	my @zv = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
	my $v = \@zv;

	my $x = $portals->{$p}->{x};
	my $y = $portals->{$p}->{y};
	push(@bfsq, [$x,$y,0]); # x, y, step
	$v->[$x]->[$y] = 1;

	while (scalar(@bfsq) > 0)
	{
		($x, $y, $step) = @{shift(@bfsq)};
		my $e = $m->[$x]->[$y];

		if ($step > 0 && exists $revmap->{"$x:$y"})
		{
			my $f = $revmap->{"$x:$y"};
			unless ($g->has_edge($p, $f))
			{
				$g->add_weighted_edge($p, $f, $step);
				say("from $p to $f = $step");
			}
		}

		for my $d (0..3) # we search only for direct roads
		{
			next if $v->[$x + $dx[$d]]->[$y + $dy[$d]] == 1; # visited
			next if $m->[$x + $dx[$d]]->[$y + $dy[$d]] ne '.'; # path

			$v->[$x + $dx[$d]]->[$y + $dy[$d]] = 1;
			push(@bfsq, [$x + $dx[$d], $y + $dy[$d], $step+1]);
		}
	}
}

say $g;

my @path = $g->SP_Dijkstra('AA0','ZZ0');
my $c = 0;
for my $i (0..$#path-1)
{
	my $l = $g->get_edge_weight($path[$i], $path[$i+1]);
	$c += $l;
	say "$path[$i] +$l";

}

say "LENGTH: $c";
