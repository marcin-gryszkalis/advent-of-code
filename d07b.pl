#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;

open(my $f, "d07.txt") or die $!;
my @pzero = split(/,/, <$f>);

# threads
my @ti; # instruction pointer
my @tp; # memory [lists]
my @tinput; # input [lists]
my @toutput;
my @trunning; # state

sub intcode
{
	my $me = shift; # thread number

	my @p = @{$tp[$me]}; # copy, for sake of clarity
	my $i = $ti[$me];

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

		if ($op == 9 && $opb == 9)
		{
			say STDERR "[$i] 99 :: halt";
			$trunning[$me] = 0;
			return;
		}
		elsif ($op == 1) # add
		{
			$p[$p[$i+3]] = ($m1 ? $p[$i+1] : $p[$p[$i+1]]) + ($m2 ? $p[$i+2] : $p[$p[$i+2]]);
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: add ".($m1 ? "" : "@").$p[$i+1]." , ".($m2 ? "" : "@").$p[$i+2]." -> @".$p[$i+3]."\n";
			$i += 4
		}
		elsif ($op == 2) # mul
		{
			$p[$p[$i+3]] = ($m1 ? $p[$i+1] : $p[$p[$i+1]]) * ($m2 ? $p[$i+2] : $p[$p[$i+2]]);
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: mul ".($m1 ? "" : "@").$p[$i+1]." , ".($m2 ? "" : "@").$p[$i+2]." -> @".$p[$i+3]."\n";
			$i += 4
		}
		elsif ($op == 3) # in
		{
			my $x = shift @{$tinput[$me]};
			if (!defined $x)
			{
				print "no input available";
				exit 1;
			}
			print STDERR "### IN($x)\n";

			$p[$p[$i + 1]] = $x; # 1 for first part
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: inp -> @".$p[$i+1]."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: out @".$p[$i+1]."\n";
			print STDERR "### OUT(".($m1 ? $p[$i+1] :$p[$p[$i+1]]).")\n";
			my $output = ($m1 ? $p[$i+1] :$p[$p[$i+1]]);
			$i += 2;

			$toutput[$me] = $output;
			$ti[$me] = $i; # save ip
			$tp[$me] = \@p; # save memory
			return; # return control
		}
		elsif ($op == 5) # jnz
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+2])." :: jnz ".($m1?"@":"").$p[$i+1]." -> ".($m1?"@":"").$p[$i+2]."\n";
			if (($m1 ? $p[$i+1] : $p[$p[$i+1]]) != 0)
			{
				$i = ($m2 ? $p[$i+2] : $p[$p[$i+2]])
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 6) # jnz
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+2])." :: jz ".($m1?"@":"").$p[$i+1]." -> ".($m1?"@":"").$p[$i+2]."\n";
			if (($m1 ? $p[$i+1] : $p[$p[$i+1]]) == 0)
			{
				$i = ($m2 ? $p[$i+2] : $p[$p[$i+2]])
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 7) # lt
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: lt ".($m1?"@":"").$p[$i+1]." < ".($m1?"@":"").$p[$i+2]." -> ".($m1?"@":"").$p[$i+3]."\n";
			$p[$p[$i+3]] = (($m1 ? $p[$i+1] : $p[$p[$i+1]]) < ($m2 ? $p[$i+2] : $p[$p[$i+2]])) ? 1 : 0;
			$i += 4;
		}
		elsif ($op == 8) # eq
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: eq ".($m1?"@":"").$p[$i+1]." == ".($m1?"@":"").$p[$i+2]." -> ".($m1?"@":"").$p[$i+3]."\n";
			$p[$p[$i+3]] = (($m1 ? $p[$i+1] : $p[$p[$i+1]]) == ($m2 ? $p[$i+2] : $p[$p[$i+2]])) ? 1 : 0;
			$i += 4;
		}
		else
		{
			say "[$i] invalid opcode: $op";
			exit 1;
		}

		print STDERR "p[".join(",",@p)."]\n";
	}

}


my $max = 0;
permute {

	# init threads
	my $i = 0;
	for my $phase (@_)
	{
		$trunning[$i] = 1;
		$tp[$i] = [];
		push(@{$tp[$i]}, @pzero);
		$ti[$i] = 0;
		$tinput[$i] = [];
		push(@{$tinput[$i]}, $phase);
		$toutput[$i] = undef;
		$i++;
	}
	push(@{$tinput[0]}, 0); # first v

	my $current = 0;
	while (1)
	{
		my $next = ($current+1) % 5;
		intcode($current);
		push(@{$tinput[$next]}, $toutput[$current]); # feedback

		if ($trunning[$next] == 0) # next thread is already dead, finish
		{
			my $v = $toutput[$current];
			if ($v > $max)
			{
				print join("-",@_);
				print " $v\n";
				$max = $v;
			}

			return; # next permutation
		}

		$current = $next; # next thread
	}

} qw/5 6 7 8 9/;



