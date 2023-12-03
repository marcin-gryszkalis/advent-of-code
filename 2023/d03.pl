#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x++,$y} = $v;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

my $pn;
my $hm;

for my $y (0..$maxy)
{
    my $x = 0;
    while (1)
    {
        my $v = $t->{$x,$y};

        if ($v =~ /\d/)
        {
            my $pn = 0;
            my $havestar = 0;
            my $hsx = 0;
            my $hsy = 0;

            my $num = '';

            while (1) # stepping through digits
            {
                for my $dy (-1..1)
                {
                    for my $dx (-1..1)
                    {
                        next if $dx == 0 && $dy == 0;
                        if (exists $t->{$x+$dx,$y+$dy} )
                        {
                            my $sym = $t->{$x+$dx,$y+$dy};

                            if ($sym ne '.' && $sym !~ /\d/)
                            {
                                $pn = 1;

                                if ($sym eq '*') # assumed that number is never adjacent to 2 stars
                                {
                                    $havestar = 1;
                                    $hsx = $x+$dx;
                                    $hsy = $y+$dy;
                                }
                            }
                        }
                    }
                }

                $num .= $v;

                $x++;
                last if $x > $maxx;

                $v = $t->{$x,$y};
                last if $v !~ /\d/;
            }

            $stage1 += $num if $pn;

            if ($havestar)
            {
                push(@{$hm->{$hsx,$hsy}}, $num); # array of numbers adjacent to star at $hsx,$hsy
            }
        }

        $x++;
        last if $x > $maxx;
    }
}

$stage2 = sum(map { product(@$_) } grep { scalar @$_ == 2 } values %$hm);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
