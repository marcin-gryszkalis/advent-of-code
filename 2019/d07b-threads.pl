#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;
use Time::HiRes qw(usleep nanosleep);

use threads;
use Thread::Queue;

$| = 1;

open(my $f, "d07.txt") or die $!;
my @pzero = split(/,/, <$f>);

# threads
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

sub intcode
{
	my $qin = shift;
	my $qout = shift;

	my $progsrc = shift;
	my @p = @$progsrc;

	my $me = shift;
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

		if ($op == 9 && $opb == 9)
		{
			say STDERR "[$me:$i] 99 :: halt";
			return; # end of thread!
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
			my $x = $qin->dequeue(); # blocking
			if (!defined $x)
			{
				print "no input available";
				exit 1;
			}
			print STDERR "### $me IN($x)\n";

			$p[$p[$i + 1]] = $x;
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: inp -> @".$p[$i+1]."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: out @".$p[$i+1]."\n";
			print STDERR "### $me OUT(".($m1 ? $p[$i+1] :$p[$p[$i+1]]).")\n";
			my $output = ($m1 ? $p[$i+1] :$p[$p[$i+1]]);
			$i += 2;

			$qout->enqueue($output);
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

#		print STDERR "p[".join(",",@p)."]\n";
	}

}

my $max = 0;
permute {

	print "START PERMUTATION: ".join(",", @_)."\n";

	# init threads
	my $i = 0;
	for my $phase (@_)
	{
		$tqin[$i] = Thread::Queue->new();
		$tqout[$i] = Thread::Queue->new();

		$tqin[$i]->enqueue($phase);
		$thread[$i] = threads->create(\&intcode, ($tqin[$i], $tqout[$i], \@pzero, $i));
		$i++;
	}

	$tqin[0]->enqueue(0); # first v

	my $thcount = $i;
	my $thalive = $i;
	my $lastoutput = undef;
	my $current = 0;
	while (1)
	{
		my $next = ($current+1) % 5;

		print STDERR "DEQ($current)\n";
		my $v = $tqout[$current]->dequeue_nb(); # feedback

		if (defined $v)
		{
			if ($current == $thcount-1) # last output from last thread
			{
				$lastoutput = $v;
				print STDERR "*** lastoutput = $lastoutput\n";
			}
			print STDERR "ENQ($next -- $v)\n";
			$tqin[$next]->enqueue($v);
		}
		else # queue is empty, maybe we'll check for dead threads? but not so frequently
		{
			$i = 0;
			for my $phase (@_)
			{
				if ($thread[$i]->is_joinable())
				{
					$thread[$i]->join();
					$thalive--;
				}
				$i++;
			}

			if ($thalive == 0) # all dead
			{
				if ($lastoutput > $max)
				{
					print "MAX: ";
					print join("-",@_);
					print " $lastoutput\n";
					$max = $lastoutput;
				}
				return; # finish permutation
			}
		}
		$current = $next; # next thread
	}

} qw/5 6 7 8 9/;
