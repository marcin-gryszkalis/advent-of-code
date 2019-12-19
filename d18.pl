#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations);

my $d = 0; # 0=top, 1=right, 2=down, 3=left
my @dx = qw/ 0 1 0 -1/;
my @dy = qw/-1 0 1  0/;
my @dmap = qw/^ > v </;

my $sx = 0; # board size -1 (max x,y)
my $sy = 0;

my $startx;
my $starty;

my $nok = 0; # number of keys
my $nod = 0; # number of doors

# my @zm = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
# my $m = \@zm; # map
my $m;

my $x = 0;
my $y = 0;
open(my $f, "d18.txt") or die $!;
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
			$startx = $x;
			$starty = $y;
		}

		if ($e =~ /[a-z]/)
		{
			$nok++;
		}

		if ($e =~ /[A-Z]/)
		{
			$nod++;
		}

		$x++;
	}
	$y++;
}
$sy = $y-1;

my @zv = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $v = \@zv; # visited

sub draw
{
	for my $ay (0..$sy)
	{
		for my $ax (0..$sx)
		{
			if ($ax == $x && $ay == $y) { print $dmap[$d] }
			# elsif ($ax == $startx && $ay == $starty) { print "@" }
			# elsif ($v->[$ax]->[$ay] == 1) { print "+" }
			else { print $m->[$ax]->[$ay]; }
		}
		print "\n";
	}
	print "\n";
}

draw();
say "KEYS($nok)";
say "DOORS($nod)";

# create graph

$x = $startx;
$y = $starty;


my $mv = 0;
my $step = 0;
my $shortest = 0;

my $ii = 0; # intersection index
my $fh; # hash of stuff to be found (doors and keys)

my $prev = '@'; # previously visited node

# my $g = Graph::Simple->new ( is_directed => 0, is_weighted => 1);
my $g = Graph::Undirected->new;

while (1)
{
		my $e = $m->[$x]->[$y];

		# door or key
		if ($e =~ /[a-z]/i)
		{
			$fh->{$e} = 1;

			$g->add_weighted_edge($prev, $e, $step) unless $g->has_edge($prev, $e);
			$prev = $e;
			$step = 0;

			if (scalar keys %$fh == $nok+$nod) # found everything
			{
				last;
			}
		}
		elsif ($e eq '@') # or maybe start
		{
			if ($prev ne '@')
			{
				$g->add_weighted_edge($prev, $e, $step) unless $g->has_edge($prev, $e);
				$prev = '@';
				$step = 0;
			}
		}
		else # no door/key but maybe an intersection
		{
			# intersection
			my $ways = 0;
			$ways++ if $m->[$x-1]->[$y] ne '#';
			$ways++ if $m->[$x+1]->[$y] ne '#';
			$ways++ if $m->[$x]->[$y-1] ne '#';
			$ways++ if $m->[$x]->[$y+1] ne '#';
			if ($ways > 2)
			{
				my $name = "($x:$y)";
				$g->add_weighted_edge($prev, $name, $step) unless $g->has_edge($prev, $name);
				$ii++;
				$prev = $name;
				$step = 0;
			}
		}


		my $right = ($d + 1) % 4;
		my $left = ($d + 3) % 4;
		my $back = ($d + 2) % 4;

#		print "POS($x,$y) C(r=$cr,f=$cf,l=$cl,b=$cb) D($dmap[$d])\n";
		if ($m->[$x + $dx[$right]]->[$y + $dy[$right]] ne '#') # maybe turn right
		{
			$d = $right;
		}
		elsif ($m->[$x + $dx[$d]]->[$y + $dy[$d]] ne '#') # go straight
		{

		}
		elsif ($m->[$x + $dx[$left]]->[$y + $dy[$left]] ne '#') # turn left
		{
			$d = $left;
		}
		else # go back
		{
			$d = $back;
		}


		# move
		if ($v->[$x + $dx[$d]]->[$y + $dy[$d]] == 0) # not visited
		{
			$v->[$x + $dx[$d]]->[$y + $dy[$d]] = 1;
			$step++;
		}
		else # visited, backtracking
		{
			$v->[$x]->[$y] = 0;
			$step--;
		}

		$x += $dx[$d];
		$y += $dy[$d];

#		draw();
#		print "The graph is $g\n";

		$mv++;
}


my $ap_len;
my $ap_required_keys;
my $ap_doors_between;

my @edges = $g->edges;
for my $e (@edges)
{
	my $a = shift @$e;
	my $b = shift @$e;
	my $w = $g->get_edge_weight($a,$b);
	printf "%7s - %7s = %3d\n",$a,$b,$w;

}


my $modified = 1;
while ($modified)
{
	$modified = 0;

	for my $v ($g->vertices())
	{
		next if $v eq '@' or $v =~ m/[a-z]/i;

		my @nbs = $g->neighbours($v);
		if (scalar @nbs == 1) # leaf node
		{
			$g->delete_vertex($v); # with edges I guess
			say "OPTIMIZE-LEAF($v)";
			$modified = 1;
			next;
		}

		say "OPTIMIZE-CROSSING($v)";
		my $it = combinations(\@nbs, 2);
		while (my $es = $it->next)
		{
			my $sumw =  $g->get_edge_weight($es->[0], $v) + $g->get_edge_weight($v, $es->[1]);
			say "   $es->[0] --($sumw)-- $es->[1]";
			$g->add_weighted_edge($es->[0], $es->[1], $sumw);
		}
		$g->delete_vertex($v);
		$modified = 1;
	}
}

my @edges = $g->edges;
for my $e (@edges)
{
	my $a = shift @$e;
	my $b = shift @$e;
	my $w = $g->get_edge_weight($a,$b);
	printf "%7s - %7s = %3d\n",$a,$b,$w;

}



my @kvs = grep { $_ eq '@' || /[a-z]/ } $g->vertices;
my $it = combinations(\@kvs, 2);
while (my $es = $it->next)
{
	my @path = $g->SP_Dijkstra($es->[0], $es->[1]);
	my $l = 0;
	my $ip = 0;
	while ($ip < $#path)
	{
		$l += $g->get_edge_weight($path[$ip], $path[$ip+1]);
		$ip++;
	}

	$ap_len->{$es->[0]}->{$es->[1]} =
	$ap_len->{$es->[1]}->{$es->[0]} = $l;

	$ap_len->{$es->[0]}->{$es->[0]} = 0; # we need that for sort later
	$ap_len->{$es->[1]}->{$es->[1]} = 0; # we need that for sort later

	my @pathx = grep { /[A-Z]/ } @path;
	$ap_required_keys->{$es->[0]}->{$es->[1]} =
	$ap_required_keys->{$es->[1]}->{$es->[0]} = \@pathx;

	my @pathy = grep { /[a-z]/ } @path;
	@pathy = @pathy[1..$#pathy-1]; # skip first and last
	$ap_doors_between->{$es->[0]}->{$es->[1]} =
	$ap_doors_between->{$es->[1]}->{$es->[0]} = \@pathy;
}

my $it = combinations(\@kvs, 2);
while (my $es = $it->next)
{
	say "$es->[0] --(".($ap_len->{$es->[0]}->{$es->[1]}).")-- $es->[1], ".
	"required: ".join(",", @{$ap_required_keys->{$es->[0]}->{$es->[1]}}).
	", between: ".join(",", @{$ap_doors_between->{$es->[0]}->{$es->[1]}});
}

# DFS
$mv = 0;
my @shortestp;
my $shortest = 100000;
sub visit
{
	$mv++;

	my $c = shift; # current
	my $pa = shift; # path list ref
#	my $fkh = shift; # found keys ref

	# say "visit($c)";
	my @path = @$pa;


#	my %found_keys = %$fkh;

	my %vp1 = map { $_ => 1 } @path; # visited by path
#	my $v1 = join("/", sort grep { /[a-z]/ } keys %vp1);

	push(@path, $c);
#	die if scalar(@path) > 1000; # justin case

	print "$mv CHECK: ".join(" ", @path)."\n"; # if $mv % 10000 == 0;
	return if (scalar @path > $nok+1); # dupes in path, too long

	my $xxp = join("",@path);

	# check length
	my $ip = 0;
	my $l = 0;
	while ($ip < $#path)
	{
		# $l += $g->get_edge_weight($path[$ip], $path[$ip+1]);
		$l += $ap_len->{$path[$ip]}->{$path[$ip+1]};
		$ip++;
	}
	return if $l > $shortest; # too long

	# check for success - count keys

	if (scalar @path == $nok+1)
	{
		# success!
		print "$mv GOOD: ".join(" ", @path)." = $l\n";

		# print "LEN: $l\n";
		if ($l < $shortest)
		{
			# my %seen;
			# @shortestp = grep { /[a-z]/ && !$seen{$_}++} @path;
			@shortestp = @path;
			$shortest = $l;
			print "\nSHORTEST: ".join(" ", @shortestp)." = $shortest\n";
		}

		return;
	}

	NN: for my $next (sort { $ap_len->{$c}->{$a} <=> $ap_len->{$c}->{$b} } @kvs)
	{
	#	exit;
		next if $c eq $next; # or check vp2
		next if $vp1{$next}; # visited
		for my $k (@{$ap_required_keys->{$c}->{$next}})
		{
#			print "goto $c -> $next, required key: $k\n";# if $xxp =~ /^afb/;
			next NN unless $vp1{lc $k};
#			print "OK\n";
		}

		for my $vb (@{$ap_doors_between->{$c}->{$next}})
		{
			# next NN if $vp1{$vb}; # ?
			push(@path, $vb) unless $vp1{$vb};
		}

		visit($next, \@path);
	}
}


my @path = ();
my %visited = ();
visit('@', \@path);

print "SHORTEST: ".join(" ", @shortestp)." = $shortest\n";







exit;

$mv = 0;
my @shortestp;
my $shortest = 100000;
sub visit_
{
	$mv++;

	my $c = shift; # current
	my $vh = shift; # visited hash ref
	my $pa = shift; # path list ref

	# say "visit($c)";
	my %visited = %$vh;
	my @path = @$pa;

#	print "(".join(" ", @path).") + $c\n";

	my %vp1 = map { $_ => 1 } @path; # visited by path
	my $v1 = join("/", sort grep { /[a-z]/ } keys %vp1);

	push(@path, $c);
	die if scalar(@path) > 1000; # justin case

	my $ip = 0;
	my $l = 0;
	while ($ip < $#path)
	{
		$l += $g->get_edge_weight($path[$ip], $path[$ip+1]);
		$ip++;
	}
	return if $l > $shortest;
# say "LEM($l)";

	print "$mv CHECK: ".substr(join(" ", @path),0,100)."... = $l\r" if $mv % 10000 == 0;

	my %vp2 = map { $_ => 1 } @path; # visited by path
	my $v2 = join("/", sort grep { /[a-z]/ } keys %vp2);

	# check for loop
	if (exists $visited{$c} && $visited{$c} eq $v2)
	{
		return; # we've been here with the same set of visited keys (not places)
	}
	$visited{$c} = $v2;

	# check for success - count keys
	my %fkeys = map { $_ => 1 } grep { /[a-z]/ } @path;
	if (scalar keys %fkeys == $nok)
	{
		# success!

		# print "LEN: $l\n";
		if ($l < $shortest)
		{
			my %seen;
			@shortestp = grep { /[a-z]/ && !$seen{$_}++} @path;
			$shortest = $l;
			print "\nSHORTEST: ".join(" ", @shortestp)." = $shortest\n";
			return;
		}
	}

	# found key
	if ($c =~ /[a-z]/)
	{
		# already added to path
	}

	if ($c =~ /[A-Z]/)
	{
		my $k = lc $c;
		return unless exists $fkeys{$k}; # no key, go back
	}

	my @nbs = $g->neighbours($c);
	for my $n (sort { $g->get_edge_weight($a,$c) <=> $g->get_edge_weight($b,$c) } @nbs)
	{
		# say "goto $c -> $n";
		visit($n, \%visited, \@path);
	}
}

my @path = ();
my %visited = ();
#push(@path, '@');
#$visited{'@'} = '';

visit('@', \%visited, \@path);

print "SHORTEST: ".join(" ", @shortestp)." = $shortest\n";
