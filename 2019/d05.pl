#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;

open(my $f, "d05.txt") or die $!;
my @pzero = split(/,/, <$f>);
my @p = @pzero;

my $i = 0;

while (1)
{
	die unless defined $p[$i];

	my $r = reverse $p[$i];
	$r =~ m/^(\d)(\d)?(\d)?(\d)?(\d)?/;
	my $op = $1;
	my $opb = $2;
	my $m1 = $3 // 0; # 0 - ptr, 1 - immed
	my $m2 = $4 // 0;
	my $m3 = $5 // 0;
	# die if $m3 == 1; # never 1

	if ($op == 9 && $opb == 9)
	{
		say "[$i] 99 :: halt";
		exit;
	}
	elsif ($op == 1) # add
	{
		$p[$p[$i+3]] = ($m1 ? $p[$i+1] : $p[$p[$i+1]]) + ($m2 ? $p[$i+2] : $p[$p[$i+2]]);
		print "[$i] ".join(",",@p[$i..$i+3])." :: add ".($m1 ? "" : "@").$p[$i+1]." , ".($m2 ? "" : "@").$p[$i+2]." -> @".$p[$i+3]."\n";
		$i += 4
	}
	elsif ($op == 2) # mul
	{
		$p[$p[$i+3]] = ($m1 ? $p[$i+1] : $p[$p[$i+1]]) * ($m2 ? $p[$i+2] : $p[$p[$i+2]]);
		print "[$i] ".join(",",@p[$i..$i+3])." :: mul ".($m1 ? "" : "@").$p[$i+1]." , ".($m2 ? "" : "@").$p[$i+2]." -> @".$p[$i+3]."\n";
		$i += 4
	}
	elsif ($op == 3) # in
	{
		$p[$p[$i + 1]] = 5; # 1 for first part
		print "[$i] ".join(",",@p[$i..$i+1])." :: inp -> @".$p[$i+1]."\n";
		$i += 2
	}
	elsif ($op == 4) # out
	{
		print "[$i] ".join(",",@p[$i..$i+1])." :: out @".$p[$i+1]."\n";
		print "### OUT(".($m1 ? $p[$i+1] :$p[$p[$i+1]]).")\n";
		$i += 2
	}
	elsif ($op == 5) # jnz
	{
		print "[$i] ".join(",",@p[$i..$i+2])." :: jnz ".($m1?"@":"").$p[$i+1]." -> ".($m1?"@":"").$p[$i+2]."\n";
		if (($m1 ? $p[$i+1] : $p[$p[$i+1]]) != 0)
		{
			$i = ($m2 ? $p[$i+2] : $p[$p[$i+2]])
		}
		else
		{ $i += 3 }
	}
	elsif ($op == 6) # jnz
	{
		print "[$i] ".join(",",@p[$i..$i+2])." :: jz ".($m1?"@":"").$p[$i+1]." -> ".($m1?"@":"").$p[$i+2]."\n";
		if (($m1 ? $p[$i+1] : $p[$p[$i+1]]) == 0)
		{
			$i = ($m2 ? $p[$i+2] : $p[$p[$i+2]])
		}
		else
		{ $i += 3 }
	}
	elsif ($op == 7) # lt
	{
		print "[$i] ".join(",",@p[$i..$i+3])." :: lt ".($m1?"@":"").$p[$i+1]." < ".($m1?"@":"").$p[$i+2]." -> ".($m1?"@":"").$p[$i+3]."\n";
		$p[$p[$i+3]] = (($m1 ? $p[$i+1] : $p[$p[$i+1]]) < ($m2 ? $p[$i+2] : $p[$p[$i+2]])) ? 1 : 0;
		$i += 4;
	}
	elsif ($op == 8) # eq
	{
		print "[$i] ".join(",",@p[$i..$i+3])." :: eq ".($m1?"@":"").$p[$i+1]." == ".($m1?"@":"").$p[$i+2]." -> ".($m1?"@":"").$p[$i+3]."\n";
		$p[$p[$i+3]] = (($m1 ? $p[$i+1] : $p[$p[$i+1]]) == ($m2 ? $p[$i+2] : $p[$p[$i+2]])) ? 1 : 0;
		$i += 4;
	}
	else
	{
		say "[$i] invalid opcode: $op";
		exit 1;
	}
}

