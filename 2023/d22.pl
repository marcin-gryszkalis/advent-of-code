#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @bricks;
my $t;
my $i = 0;
for (@f)
{
    my @a = m/(\d+)/g;
    push @bricks, \@a;

    for my $x ($a[0]..$a[3])
    {
        for my $y ($a[1]..$a[4])
        {
            for my $z ($a[2]..$a[5])
            {
                $t->{$x,$y,$z} = $i;
            }
        }
    }
    $i++;
}

my %under = ();
my %supports = ();

B: for my $i (sort { $bricks[$a]->[2] <=> $bricks[$b]->[2] } (0..$#bricks)) # sort by z from the bottom
{
    my @a = @{$bricks[$i]};

    next B if $a[2] == 1; # bottom

    my $canfall = 1;
    for my $x ($a[0]..$a[3])
    {
        for my $y ($a[1]..$a[4])
        {
            for my $z ($a[2]..$a[5])
            {
                next unless exists $t->{$x,$y,$z-1};
                next if $t->{$x,$y,$z-1} eq $i; # vertical

                $canfall = 0;

                $under{$i}->{$t->{$x,$y,$z-1}} = 1;
                $supports{$t->{$x,$y,$z-1}}->{$i} = 1;
            }
        }
    }

    if ($canfall)
    {
        for my $x ($a[0]..$a[3])
        {
            for my $y ($a[1]..$a[4])
            {
                for my $z ($a[2]..$a[5])
                {
                    delete $t->{$x,$y,$z};
                    $t->{$x,$y,$z-1} = $i;
                }
            }

        }

        $a[2]--;
        $a[5]--;

        $bricks[$i] = \@a;
        redo B;
    }
}

my %savesupports = %{ clone \%supports};
my %saveunder = %{ clone \%under };
for my $ti (0..$#bricks)
{
    my %supports = %{ clone \%savesupports};
    my %under = %{ clone \%saveunder};

    my @q = ();
    push(@q, $ti);

    my $c = 0;
    while (@q)
    {
        my $i = pop(@q);

        for my $bi (keys %{$supports{$i}})
        {
            # print "$ti: $bi was supported by $i\n";
            delete $under{$bi}->{$i};
            delete $supports{$i}->{$bi};
            unless (%{$under{$bi}})
            {
                # print "$ti: all supports removed for $bi\n";
                push(@q, $bi);
                $c++;
            }
        }
    }

    $stage1++ if $c == 0;
    $stage2 += $c;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;