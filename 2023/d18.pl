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

my $x = 0;
my $y = 0;
my $t;

my $m = {
'0' => [1,0],
'1' => [0,1],
'2' => [-1,0],
'3' => [0,-1],
};

my %mm = qw/R 0 D 1 L 2 U 3/;


my ($minx,$maxx) = ($x,$x);
my ($miny,$maxy) = ($y,$y);

my $intext;

$f[-1] =~ m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;
my $pd = $mm{$1};

for (@f)
{
    my ($d,$l,$h5,$dd) = m/(.)\s+(\d+)\s+\(#(.*)(.)\)/;

    my $l2 = hex($h5);

    # stage1
    $dd = $mm{$d};
    $l2 = $l;

    # assume we have internal on the right
    if ("$pd$dd" =~ /(01|12|23|30)/) # turn right
    {
        $intext->{$x,$y} = 'E'
    }
    else
    {
        $intext->{$x,$y} = 'I'
    }

    #print "$x,$y $pd$dd $intext->{$x,$y}\n";

    $x += $m->{$dd}->[0] * $l2;
    $y += $m->{$dd}->[1] * $l2;

    $minx = min($minx,$x);
    $maxx = max($maxx,$x);
    $miny = min($miny,$y);
    $maxy = max($maxy,$y);

    push(@{$t->{$y}}, $x);


    $pd = $dd;
}

my $vv;
my %state;

for my $y ($miny..$maxy)#sort { $a <=> $b } keys %$t)
{
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

            print "$y: $px - $x\n" if ($y % 100000 == 0);
        }
        $i++;
        $px = $x;
    }
    $stage1 += $v;

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

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;