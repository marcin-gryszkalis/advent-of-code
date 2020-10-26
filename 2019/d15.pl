#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use Math::Permute::List;

use threads;
use Thread::Queue;

# threads
my @thread;
my @tqin; # input msg queue
my @tqout; # output msg queue

open(my $f, "d15.txt") or die $!;
my @pzero = split(/,/, <$f>);

sub mem
{
	my ($p,$rb,$i,$m,$v) = @_;

	if (defined $v)
	{
		if ($m == 0) { $p->[$p->[$i]] = $v }
		elsif ($m == 1) { $p->[$i] = $v } # makes no sense
		elsif ($m == 2) { $p->[$p->[$i] + $rb] = $v; }
		else { die "invalid mode ($m)"; }
	}

	if ($m == 0) { return $p->[$p->[$i]] // 0 }
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return $p->[$p->[$i] + $rb] // 0 }
	else { die "invalid mode ($m)"; }
}

sub dbg
{
	my ($p,$rb,$i,$m) = @_;

	if ($m == 0) { return "@".($p->[$i] // 0)." [=".($p->[$p->[$i]] // 0)."]"}
	elsif ($m == 1) { return $p->[$i] // 0}
	elsif ($m == 2) { return "@".($p->[$i] // 0).($rb<0?$rb:"+$rb")." [=".($p->[$p->[$i] + $rb]//0)."]" }
	else { die "invalid mode ($m)"; }
}

sub dbghdr
{
	my ($me,$p,$i,$l) = @_;
	my @pp = @$p[$i..$i+$l];
	return sprintf "[$me:$i] %-20s |", join(",",@pp);
}

sub intcode
{
	my $me = shift;

	my $qin = shift;
	my $qout = shift;

	my $progsrc = shift;
	my @p = @$progsrc;
	my $p = \@p;

	my $i = 0;

	my $rb = 0;

	print STDERR "[$me:0] START\n";
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
			print STDERR dbghdr($me,$p,$i,0)." halt\n";
			return; # end of thread!
		}
		elsif ($op == 1) # add
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) + mem($p,$rb,$i+2,$m2));
			print STDERR dbghdr($me,$p,$i,3)." add ".dbg($p,$rb,$i+1,$m1)." + ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			$i += 4
		}
		elsif ($op == 2) # mul
		{
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) * mem($p,$rb,$i+2,$m2));
			print STDERR dbghdr($me,$p,$i,3)." mul ".dbg($p,$rb,$i+1,$m1)." * ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
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
			print STDERR "### IN($x)\n";

			mem($p,$rb,$i+1,$m1,$x);
			print STDERR dbghdr($me,$p,$i,1)." inp -> ".dbg($p,$rb,$i+1,$m1)."\n";
			$i += 2
		}
		elsif ($op == 4) # out
		{
			print STDERR dbghdr($me,$p,$i,1)." out ".dbg($p,$rb,$i+1,$m1)."\n";
			my $output = mem($p,$rb,$i+1,$m1);
			print STDERR "### OUT($output)\n";

			$qout->enqueue($output);
			$i += 2
		}
		elsif ($op == 5) # jnz
		{
			print STDERR dbghdr($me,$p,$i,2)." jnz ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) != 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 6) # jz
		{
			print STDERR dbghdr($me,$p,$i,2)." jz  ".dbg($p,$rb,$i+1,$m1)." -> ".dbg($p,$rb,$i+2,$m2)."\n";
			if (mem($p,$rb,$i+1,$m1) == 0)
			{
				$i = mem($p,$rb,$i+2,$m2)
			}
			else
			{ $i += 3 }
		}
		elsif ($op == 7) # lt
		{
			print STDERR dbghdr($me,$p,$i,3)." lt  ".dbg($p,$rb,$i+1,$m1)." < ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) < mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 8) # eq
		{
			print STDERR dbghdr($me,$p,$i,3)." eq  ".dbg($p,$rb,$i+1,$m1)." == ".dbg($p,$rb,$i+2,$m2)." => ".dbg($p,$rb,$i+3,$m3)."\n";
			mem($p,$rb,$i+3,$m3,mem($p,$rb,$i+1,$m1) == mem($p,$rb,$i+2,$m2) ? 1 : 0);
			$i += 4;
		}
		elsif ($op == 9) # arb
		{
			$rb += mem($p,$rb,$i+1,$m1);
			print STDERR dbghdr($me,$p,$i,2)." arb by ".dbg($p,$rb,$i+1,$m1)." rb:$rb\n";
			$i += 2;
		}
		else
		{
			print STDERR dbghdr($me,$p,$i,1)." err invalid opcode: $op\n";
			exit 1;
		}

	}

}

my @mmap = (' ','.','#','O');  # ?, nothing, wall, oxygen
my @maptostatus = (-1, 1, 0 ,2);

my $d = 0; # 0=top, 1=right, 2=down, 3=left
my @dx = qw/ 0 1 0 -1/;
my @dy = qw/-1 0 1  0/;
my @dmap = qw/^ > v </;

my @dirtocmd = (1,4,2,3); # north (1), south (2), west (3), and east (4),

my $sx = 44; # board size
my $sy = 44;

my @zm = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $m = \@zm; # map
my @zv = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
my $v = \@zv; # visited

my $i = 0; # 1 robot
my $thalive = 1;
$tqin[$i] = Thread::Queue->new();
$tqout[$i] = Thread::Queue->new();
$thread[$i] = threads->create(\&intcode, ($i, $tqin[$i], $tqout[$i], \@pzero));

my $startx = int($sx/2);
my $starty = int($sy/2);

my $x = $startx;
my $y = $starty;

my $ox = undef; # oxygen tank
my $oy = undef;

sub move
{
	my $d = shift;
	$tqin[$i]->enqueue($dirtocmd[$d]);
	my $status = $tqout[$i]->dequeue();

	if ($status > 0)
	{
		$x += $dx[$d];
		$y += $dy[$d];
		if ($x > $sx || $x < 0 || $y > $sy || $y < 0) { die "out of board"; }

		if ($status == 2) # oxygen
		{
			$m->[$x]->[$y] = 3;
		}
		else
		{
			$m->[$x]->[$y] = 1;
		}
	}
	else # wall
	{
		$m->[$x + $dx[$d]]->[$y + $dy[$d]] = 2;
	}

	return $status;
}

sub check
{
	my $d = shift;

	return $maptostatus[$m->[$x + $dx[$d]]->[$y + $dy[$d]]] if $m->[$x + $dx[$d]]->[$y + $dy[$d]] > 0; # already known

	my $st = move($d);
	if ($st > 0)
	{
		move(($d + 2) % 4); # move back
	}
	return $st;
}

sub draw
{
	for my $ay (0..$sy-1)
	{
		for my $ax (0..$sx-1)
		{
			if ($ax == $x && $ay == $y) { print "%" }
			elsif ($ax == $startx && $ay == $starty) { print "@" }
			elsif ($v->[$ax]->[$ay] == 1) { print "+" }
			else { print $mmap[$m->[$ax]->[$ay]] };
		}
		print "\n";
	}
}

my $mv = 0;
my $step = 0;
my $shortest = 0;
while (1)
{
		my $right = ($d + 1) % 4;
		my $left = ($d + 3) % 4;
		my $back = ($d + 2) % 4;

		my $cr = check($right); # look around, not required but getting full picture quicker
		my $cf = check($d);
		my $cl = check($left);
		my $cb = check($back);

#		print "POS($x,$y) C(r=$cr,f=$cf,l=$cl,b=$cb) D($dmap[$d])\n";
		if ($cr > 0) # maybe turn right
		{
			$d = $right;
		}
		elsif ($cf > 0) # go straight
		{

		}
		elsif ($cl > 0) # turn left
		{
			$d = $left;
		}
		else # go back
		{
			$d = $back;
		}

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

		my $st = move($d);

		draw();

		if ($st == 2) # found oxygen tank!
		{
			$shortest = $step;
			$ox = $x;
			$oy = $y;
			last;
		}

		$mv++;
}



#part 2
# reset visited map
@zv = ( map { [(0) x ($sy+1)] } (0..($sx+1))  );
$v = \@zv; # visited

# it's already there:
# my $x = $ox;
# my $y = $oy;

my $mv = 0;
my $step = 0;
my $maxstep = 0;
while (1)
{
		my $right = ($d + 1) % 4;
		my $left = ($d + 3) % 4;
		my $back = ($d + 2) % 4;
		my $cr = check($right); # look around
		my $cf = check($d);
		my $cl = check($left);
		my $cb = check($back);

#		print "POS($x,$y) C(r=$cr,f=$cf,l=$cl,b=$cb) D($dmap[$d])\n";
		if ($cr > 0) # maybe turn right
		{
			$d = $right;
		}
		elsif ($cf > 0) # go straight
		{

		}
		elsif ($cl > 0) # go straight
		{
			$d = $left;
		}
		else # go back
		{
			$d = $back;
		}

		if ($v->[$x + $dx[$d]]->[$y + $dy[$d]] == 0)
		{
			$v->[$x + $dx[$d]]->[$y + $dy[$d]] = 1;
			$step++;
		}
		else # backtracking
		{
			$v->[$x]->[$y] = 0;
			$step--;
		}

		my $st = move($d);

		if ($step > $maxstep)
		{
			$maxstep = $step;
			draw();
		}

		last if $x == $ox && $y == $oy; # back to start, checked everything
		$mv++;
}

print "SHORTEST-PATH($shortest)\n";
printf "OXYGEN-TIME($maxstep)\n";
