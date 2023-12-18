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

my $x = 0;
my $y = 0;

my $m = {
'0' => [1,0],
'1' => [0,1],
'2' => [-1,0],
'3' => [0,-1],
};

my %mm = qw/R 0 D 1 L 2 U 3/;


for my $stage (1..2)
{
    my $total = 0;

    my $t = {};

    my ($minx,$maxx) = (0,0);
    my ($miny,$maxy) = (0,0);

    # I or E: internal (3 sides inside) / external (3 sides outside) vertex
    my $intext = {};

    $f[-1] =~ m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;
    my $pd = $stage == 1 ? $mm{$1} : $4;

    for (@f)
    {
        my ($d1,$l1,$h5,$d2) = m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;

        my $d = $stage == 1 ? $mm{$d1} : $d2;
        my $l = $stage == 1 ? $l1 : hex($h5);

        # assume we have internal on the right (below we verify)
        # turn right - external, turn left - internal
        $intext->{$x,$y} = $d - ($pd+4) %4 == 1 ? 'E' : 'I';

        $x += $m->{$d}->[0] * $l;
        $y += $m->{$d}->[1] * $l;

        $minx = min($minx,$x);
        $maxx = max($maxx,$x);
        $miny = min($miny,$y);
        $maxy = max($maxy,$y);

        push(@{$t->{$y}}, $x);

        $pd = $d;
    }

    $y = first { $a <=> $b } keys %$t;
    $x = first { $a <=> $b } @{$t->{$y}};
    die "assumption that interior is on the right side was wrong :)" if $intext->{$x,$y} eq 'E';

    my %state = ();

    my $py = 0;
    for my $y (sort { $a <=> $b } keys %$t)
    {
        if (%state)
        {
            my $v = 0;
            my $px = 0;
            my $i = 0;
            for my $x (sort { $a <=> $b } keys %state)
            {
                if ($i%2 == 0) # Left
                {

                }
                else # Right
                {
                    $v += ($x - $px + 1);

                    print "$y: $px - $x = $v\n";
                }
                $i++;
                $px = $x;
            }

            printf "multiply by %d\n", ($y - $py - 1);
            $total += $v * ($y - $py - 1); # lines between
        }
        $py = $y;

    #    print Dumper \%state;
        my %nstate = %state;

        if (exists $t->{$y})
        {
            for my $x (sort { $a <=> $b } @{$t->{$y}})
            {
                if (exists $state{$x}) # to be removed
                {
                    if ($intext->{$x,$y} eq 'I') # internal
                    {
                        delete $nstate{$x};
                    }
                    else # external
                    {
                    }
                }
                else # new
                {
                    if ($intext->{$x,$y} eq 'I') # internal
                    {
                    }
                    else # external
                    {
                        $nstate{$x} = 1;

                    }
                }
            }
        }

        my $v = 0;
        my $px = 0;
        my $i = 0;
        for my $x (sort { $a <=> $b } keys %nstate)
        {
            if ($i%2 == 0) # Left
            {

            }
            else # Right
            {
                $v += ($x - $px + 1);

                print "$y: $px - $x = $v\n";# if ($y % 100000 == 0);
            }
            $i++;
            $px = $x;
        }
        $total += $v;

        if (exists $t->{$y})
        {
            for my $x (sort { $a <=> $b } @{$t->{$y}})
            {
                if (exists $state{$x}) # to be removed
                {
                    if ($intext->{$x,$y} eq 'I') # internal
                    {
                    }
                    else # external
                    {
                        delete $nstate{$x};
                    }
                }
                else # new
                {
                    if ($intext->{$x,$y} eq 'I') # internal
                    {
                        $nstate{$x} = 1;
                    }
                    else # external
                    {
                    }
                }
            }
        }

        %state = %nstate;
    }

    printf "Stage $stage: %s\n", $total;
}
