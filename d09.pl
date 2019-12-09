#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;

open(my $f, "d09.txt") or die $!;
my @pzero = split(/,/, <$f>);

sub mem
{
	my $p = shift;
	my $rb = shift;
	my $i = shift;
	my $m = shift;

	if ($m == 0) { return $p->[$p->[$i]] // 0 }
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return $p->[$p->[$i] + $rb] // 0 }
	else { die "invalid mode ($m)"; }
}

sub memx
{
	my $p = shift;
	my $rb = shift;
	my $i = shift;
	my $m = shift;
	my $v = shift;

	if ($m == 0) { $p->[$p->[$i]] = $v }
	elsif ($m == 1) { $p->[$i] = $v } # no
	elsif ($m == 2) { $p->[$p->[$i] + $rb] = $v; }
	else { die "invalid mode ($m)"; }
}

sub dbg
{
	my $p = shift;
	my $rb = shift;
	my $i = shift;
	my $m = shift;

	if ($m == 0) { return "@".($p->[$i] // 0)}
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return "%".($p->[$i] // 0)." [".$p->[$i]." + rb:$rb = ".($p->[$p->[$i] + $rb]//0)."]" }
	else { die "invalid mode ($m)"; }
}

sub intcode
{
	my $progsrc = shift;
	my @p = @$progsrc;
	my $p = \@p;

	my $inpsrc = shift;
	my @input = @$inpsrc;

	my $output = undef;
	my $i = 0;
	my $rb = 0;

	while (1)
	{
		die unless defined $p[$i];

		my $r = reverse $p[$i];
		$r =~ m/^(\d)(\d)?(\d)?(\d)?(\d)?/;
		my $op = $1;
		my $opb = $2;
		my $m1 = $3 // 0; # 0 - ptr, 1 - immed. 2 - rel-base
		my $m2 = $4 // 0;
		my $m3 = $5 // 0;

		if ($op == 9 && defined $opb && $opb == 9)
		{
			say STDERR "[$i] 99 :: halt";
			return $output;
		}
		elsif ($op == 1) # add
		{
			memx($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) + mem($p,$rb,$i+2,$m2));
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: add ".dbg($p,$rb,$i+1,$m1)." + ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 2) # mul
		{
			memx($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) * mem($p,$rb,$i+2,$m2));
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: mul ".dbg($p,$rb,$i+1,$m1)." * ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 3) # in
		{
			my $x = shift @input;
			if (!defined $x)
			{
				print "no input available";
				exit 1;
			}
			print STDERR "### IN($x)\n";

			memx($p,$rb,$i+3,$m3,$x);
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: inp -> ".dbg($p,$rb,$i+1,$m1)."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: out ".dbg($p,$rb,$i+1,$m1)."\n";
			$output = mem($p,$rb,$i+1,$m1);
			print STDERR "### OUT($output)\n";

			$i += 2
		}
		elsif ($op == 5) # jnz
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+2])." :: jnz ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) != 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 6) # jz
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+2])." :: jz ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) == 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 7) # lt
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: lt ".dbg($p,$rb,$i+1,$m1)." < ".dbg($p,$rb,$i+2,$m2)." -> ".dbg($p,$rb,$i+3,$m3)."\n";
			memx($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) < mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 8) # eq
		{
			print STDERR "[$i] ".join(",",@p[$i..$i+3])." :: eq ".dbg($p,$rb,$i+1,$m1)." == ".dbg($p,$rb,$i+2,$m2)." -> ".dbg($p,$rb,$i+3,$m3)."\n";
			memx($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) == mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 9) # arb
		{
			$rb += mem($p,$rb,$i+1,$m1);
			print STDERR "[$i] ".join(",",@p[$i..$i+1])." :: arb by ".dbg($p,$rb,$i+1,$m1)." rb:$rb\n";
			$i += 2;
		}
		else
		{
			say "[$i] invalid opcode: $op";
			exit 1;
		}

	}

}

my @p = @pzero;
my @in = (2);
my $v = intcode(\@p,\@in);

