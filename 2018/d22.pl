#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @types = qw/. = |/;
my $DEPTH = 5913;
my $TX = 8;
my $TY = 701;

# example
# $DEPTH = 510;
# $TX = 10;
# $TY = 10;

my $margin = 50;
my $MX = $TX + $margin;
my $MY = $TY + $margin;

my $geoidx;
my $erolvl;
my $regtype;

for my $y (0..$MY)
{
    for my $x (0..$MX)
    {
        if ($x == $TX && $y == $TY)
        {
            $geoidx->[$y]->[$x] = 0;
        }
        elsif ($y == 0) # includes 0,0
        {
            $geoidx->[$y]->[$x] = $x * 16807;
        }
        elsif ($x == 0)
        {
            $geoidx->[$y]->[$x] = $y * 48271;
        }
        else
        {
            $geoidx->[$y]->[$x] = $erolvl->[$y-1]->[$x] * $erolvl->[$y]->[$x-1];
        }

        $erolvl->[$y]->[$x] = ($geoidx->[$y]->[$x] + $DEPTH) % 20183;

        $regtype->[$y]->[$x] = $erolvl->[$y]->[$x] % 3;
    }
}

my $stage1 = 0;
for my $y (0..$TY)
{
    for my $x (0..$TX)
    {
        print $types[$regtype->[$y]->[$x]];
        $stage1 += $regtype->[$y]->[$x];
    }
    print "\n";
}
print "\n";

print "stage 1: $stage1\n";

my %dx = qw/N 0 E 1 S 0 W -1/;
my %dy = qw/N -1 E 0 S 1 W 0/;

# BFS, A*?
my @bfs;
my %visited;

my %state = qw/x 0 y 0 equip t tt 0/;
$state{dist} = $TX+$TY;

my $i = 0;
push(@bfs, \%state);
my $best = 999; # educated guess ;)
while (1)
{

    # this would make sense IFF I used sorted heap re-sorting queue is way too slow
    # best:
    # @bfs = sort { ($a->{dist} + $a->{tt} + ($a->{equip} eq 't'?0:7) ) <=> ($b->{dist} + $b->{tt} + ($b->{equip} eq 't'?0:7)) } @bfs;
    # @bfs = sort { $a->{dist} + $a->{tt} <=> $b->{dist} + $b->{tt} } @bfs;
    # @bfs = sort { $a->{dist} <=> $b->{dist} || $a->{tt} <=> $b->{tt} } @bfs;
    # @bfs = sort { $a->{tt} <=> $b->{tt} || $a->{dist} <=> $b->{dist}} @bfs;
    # @bfs = sort { $a->{tt} + ($a->{equip} eq 't'?0:7) <=> $b->{tt} + ($b->{equip} eq 't'?0:7)} @bfs;

    my $s = shift(@bfs);
    exit unless defined $s;

    next if exists $visited{"$s->{x}:$s->{y}:$s->{equip}"} && $visited{"$s->{x}:$s->{y}:$s->{equip}"} <= $s->{tt};

    $visited{"$s->{x}:$s->{y}:$s->{equip}"} = $s->{tt};

    printf("%10d %3d,%3d [%s] -- dist=%d time=%d\n", $i, $s->{x}, $s->{y}, $s->{equip}, $s->{dist}, $s->{tt}) if $i % 1000 == 0;
    if ($s->{x} == $TX && $s->{y} == $TY)
    {
        if ($s->{equip} ne 't') # switch to torch (it's already handled while adding to queue)
        {
            $s->{tt} += 7;
        }

        if ($s->{tt} < $best)
        {
            printf("FOUND! %10d %3d,%3d [%s] -- dist=%d time=%d\n", $i, $s->{x}, $s->{y}, $s->{equip}, $s->{dist}, $s->{tt});
            $best = $s->{tt};
        }
        next;
    }

    for my $eq (qw/t c n/)
    {
        my $dt = $s->{equip} eq $eq ? 1 : 8; # 7+1

        for my $dir (qw/N E S W/)
        {
            my $nx = $s->{x} + $dx{$dir};
            my $ny = $s->{y} + $dy{$dir};
            my $nt = $s->{tt} + $dt;
            my $nd = abs($TX-$nx) + abs($TY-$ny);

            next if $nx < 0 || $nx > $MX; # bounds
            next if $ny < 0 || $ny > $MY;

            next if exists $visited{"$nx:$ny:$eq"} && $visited{"$nx:$ny:$eq"} <= $nt;
#            printf "$nx:$ny:$eq  %s > $nt ?\n", $visited{"$nx:$ny:$eq"} if exists $visited{"$nx:$ny:$eq"};
            next if $nt > $best;
            next if $nd + $s->{tt} > $best; # too far

            next if $regtype->[$ny]->[$nx] == 0 && $eq eq 'n'; # valid for next place
            next if $regtype->[$ny]->[$nx] == 1 && $eq eq 't';
            next if $regtype->[$ny]->[$nx] == 2 && $eq eq 'c';

            next if $regtype->[$s->{y}]->[$s->{x}] == 0 && $eq eq 'n'; # valid for current place
            next if $regtype->[$s->{y}]->[$s->{x}] == 1 && $eq eq 't';
            next if $regtype->[$s->{y}]->[$s->{x}] == 2 && $eq eq 'c';

            next if $nx == $TX && $ny == $TY && $eq ne 't'; # require torch at target

            my %next;
            $next{x} = $nx;
            $next{y} = $ny;
            $next{equip} = $eq;
            $next{tt} = $nt;
            $next{dist} = $nd;

            push(@bfs, \%next);
        }

    }

    $i++;
}
