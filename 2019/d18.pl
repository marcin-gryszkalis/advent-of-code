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
my @dmap = qw/^ > v </;

my $sx = 0; # board size -1 (max x,y)
my $sy = 0;

my @startx;
my @starty;

my $nok = 0; # number of keys
my $nod = 0; # number of doors
my $nor = 0; # number of robots

my %cache;

my $m;

my $x = 0;
my $y = 0;
my %elements = ();
open(my $f, "d18b.txt") or die $!;
while (<$f>)
{
	chomp;
	$x = 0;
	for my $e (split//)
	{
		$sx = $x if $x > $sx;
		$m->[$x]->[$y] = $e;

		if ($e eq '@')
		{
			$startx[$nor] = $x;
			$starty[$nor] = $y;
			$elements{"${e}$nor"} = [$x,$y];
			$nor++;
		}

		if ($e =~ /[a-z]/)
		{
			$nok++;
			$elements{$e} = [$x,$y];
		}

		if ($e =~ /[A-Z]/)
		{
			$nod++;
			$elements{$e} = [$x,$y];
		}

		$x++;
	}
	$y++;
}
$sy = $y-1;

sub draw
{
	for my $ay (0..$sy)
	{
		for my $ax (0..$sx)
		{
			if ($ax == $x && $ay == $y) { print $dmap[$d] }
			else { print $m->[$ax]->[$ay]; }
		}
		print "\n";
	}
	print "\n";
}

draw();
say "ROBOTS($nor)";
say "KEYS($nok)";
say "DOORS($nod)";

# create graph
my $mv = 0;
my $step = 0;

my $ii = 0; # intersection index
my $fh; # hash of stuff to be found (doors and keys)

my $g = Graph::Undirected->new;

# BFS for every pair of elements
my @elks = sort keys %elements;
my $it = combinations(\@elks, 2);
PAIR: while (my $es = $it->next)
{
	say "search for $es->[0] -> $es->[1]";

	my @bfsq = ();

	my @zv = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
	my $v = \@zv;

	my ($x, $y) = @{$elements{$es->[0]}};
	push(@bfsq, [$x,$y,0]); # x, y, step
	$v->[$x]->[$y] = 1;

	while (scalar(@bfsq) > 0)
	{
		($x, $y, $step) = @{shift(@bfsq)};
		my $e = $m->[$x]->[$y];

#		say("$e -- ($x,$y) at $step");

		# goal is to find $es->[1]
		if ($e eq $es->[1])
		{
			$g->add_weighted_edge($es->[0], $es->[1], $step);
			say("from $es->[0] to $e at ($x,$y) = $step");
			next PAIR;
		}

		for my $d (0..3) # we search only for direct roads
		{
			next if $v->[$x + $dx[$d]]->[$y + $dy[$d]] == 1; # visited
			next if $m->[$x + $dx[$d]]->[$y + $dy[$d]] eq '#'; # wall
			next if $m->[$x + $dx[$d]]->[$y + $dy[$d]] =~ /[a-z]/i && $m->[$x + $dx[$d]]->[$y + $dy[$d]] ne $es->[1]; # it's not the element you're looking for

			$v->[$x + $dx[$d]]->[$y + $dy[$d]] = 1;
			push(@bfsq, [$x + $dx[$d], $y + $dy[$d], $step+1]);
		}
	}
}

my $ap_len;
my $ap_required_keys = {};
my $ap_doors_between;

my @edges = $g->edges;
for my $e (@edges)
{
	my $a = shift @$e;
	my $b = shift @$e;
	my $w = $g->get_edge_weight($a,$b);
	printf "%7s - %7s = %3d\n",$a,$b,$w;

	$ap_required_keys->{$a}->{$b} = [];
	$ap_required_keys->{$b}->{$a} = [];
}

# optimize graph (remove doors)
my $modified = 1;
while ($modified)
{
	$modified = 0;

	for my $v ($g->vertices())
	{
		next if $v =~ m/[a-z@]/;

		my @nbs = $g->neighbours($v);
		if (scalar @nbs == 1) # leaf node
		{
			$g->delete_vertex($v); # with edges I guess
			say "OPTIMIZE-LEAF($v)";
			$modified = 1;
			next;
		}

		say "OPTIMIZE($v)";
		my $it = combinations(\@nbs, 2);
		while (my $es = $it->next)
		{
			next if $g->has_edge($es->[0], $es->[1]); # already connected

			my $sumw =  $g->get_edge_weight($es->[0], $v) + $g->get_edge_weight($v, $es->[1]);
			say "   $es->[0] --$v($sumw)-- $es->[1]";
			$g->add_weighted_edge($es->[0], $es->[1], $sumw);

			my @pathy1 = ();

			if ($v =~ m/[A-Z]/) # door
			{
				push(@pathy1, $v);
			}
			push(@pathy1, @{$ap_required_keys->{$es->[0]}->{$v}});
			push(@pathy1, @{$ap_required_keys->{$v}->{$es->[1]}});

			my @pathy2 = @pathy1;
			$ap_required_keys->{$es->[0]}->{$es->[1]} = \@pathy1;
			$ap_required_keys->{$es->[1]}->{$es->[0]} = \@pathy2;
		}

		$g->delete_vertex($v);
		$modified = 1;
	}
}

@edges = $g->edges;
for my $e (@edges)
{
	my $a = shift @$e;
	my $b = shift @$e;
	my $w = $g->get_edge_weight($a,$b);

	printf "%7s - %7s = %3d, req: %s\n",$a,$b,$w, join("", @{$ap_required_keys->{$a}->{$b}});
}

my @kvs = $g->vertices;


# all pairs
$it = combinations(\@kvs, 2);
while (my $es = $it->next)
{
	my @path = $g->SP_Dijkstra($es->[0], $es->[1]);
	if (scalar @path > 0)
	{
		my $l = 0;
		my $ip = 0;
		my @reqks = ();
		while ($ip < $#path)
		{
			$l += $g->get_edge_weight($path[$ip], $path[$ip+1]);
			push(@reqks, @{$ap_required_keys->{$path[$ip]}->{$path[$ip+1]}});
			$ip++;
		}

		$ap_required_keys->{$es->[0]}->{$es->[1]} = \@reqks;
		my @reqks2 = @reqks;
		$ap_required_keys->{$es->[1]}->{$es->[0]} = \@reqks;

		$ap_len->{$es->[0]}->{$es->[1]} =
		$ap_len->{$es->[1]}->{$es->[0]} = $l;

	}
	else # not reachable
	{
		$ap_len->{$es->[0]}->{$es->[1]} = -1;
		$ap_len->{$es->[1]}->{$es->[0]} = -1;
	}

	$ap_len->{$es->[0]}->{$es->[0]} = 0; # we need that for sort later
	$ap_len->{$es->[1]}->{$es->[1]} = 0;
}

$it = combinations(\@kvs, 2);
while (my $es = $it->next)
{
	next unless $ap_len->{$es->[0]}->{$es->[1]}>0;
	printf
		" $es->[0] --(%s)-- $es->[1], required: %s\n",
		$ap_len->{$es->[0]}->{$es->[1]},
		join(",", @{$ap_required_keys->{$es->[0]}->{$es->[1]}});
}

# say Dumper $ap_len;

# $g is not used anymore

# DFS with cache
$mv = 0;
sub visit
{
	$mv++;

	my $csa = shift; # current(s)
	my @cs = @$csa;

	my $pa = shift; # path list ref
	my @path = @$pa; # path copy

	my @tnext = ();

	my %vp1 = map { $_ => 1 } @path; # visited by path
	my $v1 = join("", sort keys %vp1); # as sorted string
	my $c1 = join("+", @cs); # all currents

	printf "$mv: visit %s with path=%s\n", $c1, $v1;

	my $v3 = "$v1:$c1"; # cache key
	if (exists $cache{$v3})
	{
		say STDERR "FOUND-IN-CACHE($v3) = $cache{$v3}";
		return $cache{$v3};
	}

	if (scalar(@path) == $nok + $nor) # check for success - length of path + last $c == $nok + $nor
	{
		# success!
		printf(STDERR "$mv GOOD: %s\n", join(" ", @path));
		return 0;
	}

 	for my $ci (0..$nor-1)
 	{
 		my $c = $cs[$ci];


		# printf("$mv CHECK[$ci]: at $c with path=%s (vp1=%s vp2=%s)\n", join("", @path), $v1, $v2);# if $mv % 1000 == 0;
		# return if (scalar @path > $nok+1); # dupes in path, too long


	 	my $vi = 0;

		# NN: for my $n (sort { say "$a $b $c"; $ap_len->{$a}->{$c} <=> $ap_len->{$b}->{$c} } @kvs)
		NN: for my $n (@kvs) # try paths from $c[0..3] to $n
	 	{
	 		$vi++;

	 		next if $c eq $n;

	 		next unless exists $ap_len->{$c}->{$n}; # only reachable
	 		next unless $ap_len->{$c}->{$n} > 0;

	 		next if exists $vp1{$n}; # already in path

			my @path = @$pa; # path copy
			push(@path, $n);

		#	die if scalar(@path) > 1000; # justin case

			my %vp2 = map { $_ => 1 } @path; # visited by path
			my $v2 = join("", sort keys %vp2);

	  		printf STDERR "$mv:$vi [$v2] try($c -> $n) req: %s (have: %s)\n", join("", @{$ap_required_keys->{$c}->{$n}}), $v2;
	 		for my $k (@{$ap_required_keys->{$c}->{$n}}) # do we have required keys?
	 		{
	 			next NN unless $vp2{lc $k};
	 		}

	 		my @next = ();
	 		for my $cj (0..$nor-1)
	 		{
	 			push(@next, $ci == $cj ? $n : $cs[$cj]); # update only one of nexts
	 		}
			my $vl = $ap_len->{$c}->{$n} + visit(\@next, \@path); # path with c
			push(@tnext, $vl);
		}

	}

	die "empty tnext?" unless scalar(@tnext) > 0;
	my $res = min(@tnext);
	say STDERR "TNEXT: $res = min: ".join(" ", @tnext);

	say STDERR "CACHE-UPDATE: $v3 = $res";
	$cache{$v3} = $res;

	return $res;
}


my @path = (); # ([] x $nor); # arxar
my @current = ();
for my $i (0..$nor-1)
{
	push(@current, '@'.$i);
	push(@path, '@'.$i);
}

# visit('@', \@path, \%visited);
my $ret = visit(\@current, \@path);
print "RET: $ret\n";
