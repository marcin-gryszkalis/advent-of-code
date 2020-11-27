#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $m;
my $miny = 10000;
my $maxy = 0;
my $minx = 10000;
my $maxx = 0;
while (<>)
{
    # y=638, x=502..504
    # x=561, y=1356..1360
    if (/([xy])=(\d+), ([xy])=(\d+)\.\.(\d+)/)
    {
        my $a = $2;
        my $b = $4;
        my $c = $5;
        my $p = $1;

        if ($p eq 'x')
        {
            my $x = $a;
            $maxx = $x if $x > $maxx;
            $minx = $x if $x < $minx;
            for my $y ($b..$c)
            {
                $maxy = $y if $y > $maxy;
                $miny = $y if $y < $miny;
                $m->[$y]->[$x] = '#';
            }
        }
        else
        {
            my $y = $a;
            $maxy = $y if $y > $maxy;
            $miny = $y if $y < $miny;
            for my $x ($b..$c)
            {
                $maxx = $x if $x > $maxx;
                $minx = $x if $x < $minx;
                $m->[$y]->[$x] = '#';
            }
        }
    }
    else { die $_ }
}

$minx -= 2;
$maxx += 2;

$m->[0]->[500] = "|"; # spring

for my $y (0..$maxy)
{
    for my $x ($minx..$maxx)
    {
        $m->[$y]->[$x]="." unless exists $m->[$y]->[$x];
    }
}

my @queue = ();
push(@queue, [500, 0]);

my $i = 0;
while (1)
{
    my $more = 0;

    # if ($i % 100 == 0)
    # {
    #     for my $y (0..$maxy)
    #     {
    #         for my $x ($minx..$maxx)
    #         {
    #             print $m->[$y]->[$x];
    #         }
    #         print "\n";
    #     }
    #     print "\n" x 5;
    # }

    my @newqueue = ();

    while (my $e = pop(@queue))
    {
        my $x = $e->[0];
        my $y = $e->[1];

        if ($m->[$y]->[$x] eq '|')
        {
            if ($y < $maxy && $m->[$y+1]->[$x] eq '.') # simple fall
            {
                $m->[$y+1]->[$x] = '|';
                push(@newqueue, [$x, $y+1]);
                $more++;
            }
            elsif ($y < $maxy && $m->[$y+1]->[$x] =~ /[#~]/) # there's water or block below
            {
                if ($x < $maxx && $m->[$y]->[$x+1] eq '.')
                {
                    $m->[$y]->[$x+1] = '|';
                    push(@newqueue, [$x+1, $y]);
                    push(@newqueue, [$x, $y]);
                    $more++;
                }
                elsif ($x > $minx && $m->[$y]->[$x-1] eq '.')
                {
                    $m->[$y]->[$x-1] = '|';
                    push(@newqueue, [$x-1, $y]);
                    push(@newqueue, [$x, $y]);
                    $more++;
                }
                else # check for blocks on both sides
                {
                    my $blocked = 1;
                    my $tx = $x;
                    while (1)
                    {
                        $tx++;
                        $blocked = 0 if $m->[$y]->[$tx] eq '.';
                        $blocked = 0 if $m->[$y]->[$tx] eq '|' && $m->[$y+1]->[$tx] !~ /[#~]/;
                        last if $tx >= $maxx || $blocked == 0 || $m->[$y]->[$tx] =~ /[#~]/;
                    }
                    $tx = $x;
                    while (1)
                    {
                        $tx--;
                        $blocked = 0 if $m->[$y]->[$tx] eq '.';
                        $blocked = 0 if $m->[$y]->[$tx] eq '|' && $m->[$y+1]->[$tx] !~ /[#~]/;
                        last if $tx <= $minx || $blocked == 0 || $m->[$y]->[$tx] =~ /[#~]/;
                    }

                    if ($blocked)
                    {
                        $m->[$y]->[$x] = '~';
                        if ($m->[$y-1]->[$x] eq '|')
                        {
                            push(@newqueue, [$x, $y-1]);
                        }
                        if ($m->[$y]->[$x-1] eq '|')
                        {
                            push(@newqueue, [$x-1, $y]);
                        }
                        if ($m->[$y]->[$x+1] eq '|')
                        {
                            push(@newqueue, [$x+1, $y]);
                        }

                        $more++;
                    }

                }
            }

        }
        elsif ($m->[$y]->[$x] eq '~')
        {

        }
    }

    @queue = @newqueue;
    last unless $more;
    $i++;
}

my $stage1 = 0;
my $stage2 = 0;
for my $y ($miny..$maxy)
{
    for my $x ($minx..$maxx)
    {
        $stage1++ if $m->[$y]->[$x] =~ /[|~]/;
        $stage2++ if $m->[$y]->[$x] eq '~';
        $m->[$y]->[$x] =~ s/\./ /g;
        print $m->[$y]->[$x];
    }
    print "\n";
}
print "\n";

printf "stage 1: %d\n", $stage1;
printf "stage 2: %d\n", $stage2;