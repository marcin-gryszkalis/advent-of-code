#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;
# pos=<86508574,12573428,20533848>, r=83193725

my @bots;

my $bestr = 0;
my @best;
for (@ff)
{
    m/([\d-]+),([\d-]+),([\d-]+).*?(\d+)/;
    if ($4 > $bestr)
    {
        $bestr = $4;
        @best = ($1,$2,$3);
    }

    my %h = ();
    $h{x} = $1;
    $h{y} = $2;
    $h{z} = $3;
    $h{r} = $4;
    push(@bots, \%h);

}

my $c = 0;
for my $h (@bots)
{
    $c++ if abs($best[0] - $h->{x}) + abs($best[1] - $h->{y}) + abs($best[2] - $h->{z}) <= $bestr;
}
print "stage 1: $c\n";

my $x = $best[0];
my $y = $best[1];
my $z = $best[2];

my $bestxd = 0;
my $bestc = 1;

my $nbx;
my $nby;
my $nbz;

my $i = 0;
while (1)
{
    my $scanrange = 20;
    my $scanstep = 2**20;

    $x = int rand(100_000_000);
    $y = int rand(100_000_000);
    $z = int rand(100_000_000);
    $x = -$x if rand(1) < 0.5;
    $y = -$y if rand(1) < 0.5;
    $z = -$z if rand(1) < 0.5;
    print "start($x,$y,$z)\n";
    while (1)
    {

        my $nx = $x - $scanrange*$scanstep;
        while ($nx < $x + $scanrange*$scanstep)
        {
            my $ny = $y - $scanrange*$scanstep;
            while ($ny < $y + $scanrange*$scanstep)
            {
                my $nz = $z - $scanrange*$scanstep;
                while ($nz < $z + $scanrange*$scanstep)
                {
                    my $c = 0;
                    for my $h (@bots)
                    {
                        $c++ if abs($nx - $h->{x}) + abs($ny - $h->{y}) + abs($nz - $h->{z}) <= $h->{r};
                    }

                    if ($c >= $bestc)
                    {
                        my $xd = abs($nx) + abs($ny) + abs($nz);
                        if ($c > $bestc || $xd > $bestxd)
                        {
                            $nbx = $nx;
                            $nby = $ny;
                            $nbz = $nz;
                            $bestc = $c;
                            $bestxd = $xd;
                            printf "FOUND at step $i: c=$c ($nx,$ny,$nz) xd=$xd\n";
                        }
                    }

                    $nz += $scanstep;
                }

            $ny += $scanstep;
            }

        $nx += $scanstep;
        }

        last unless defined $nbx;

        $x = $nbx;
        $y = $nby;
        $z = $nbz;

        last if $scanstep == 1;
        $scanstep = int($scanstep/2);
        print "$i move to ($nbx,$nby,$nbz), step=$scanstep\n";
        $i++;
    }
}
# 40 c=974 (27147759,23024627,33915430) xd=84087816
