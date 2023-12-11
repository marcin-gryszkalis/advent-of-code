#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my %expand = qw/
1 2
2 1000000
/;

my @f = read_file(\*STDIN, chomp => 1);

my $x = 0;
my $y = 0;
my $t;

my %occx;
my %occy;
my @galaxies;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        if ($t->{$x,$y} eq '#')
        {
            $occx{$x} = 1;
            $occy{$y} = 1;
            push(@galaxies, [$x,$y]);
        }

        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

for my $stage (1..2)
{
    my $sum = 0;
    for my $v (combinations([0..$#galaxies], 2))
    {
        my ($gai, $gbi) = @$v;

        my ($gax,$gay) = @{$galaxies[$gai]};
        my ($gbx,$gby) = @{$galaxies[$gbi]};

        ($gax,$gbx) = ($gbx,$gax) if $gax > $gbx;
        ($gay,$gby) = ($gby,$gay) if $gay > $gby;

        my $i = 0;

        for my $x ($gax+1..$gbx)
        {
            $i += exists $occx{$x} ? 1 : $expand{$stage};
        }

        for my $y ($gay+1..$gby)
        {
            $i += exists $occy{$y} ? 1 : $expand{$stage};
        }

        $sum += $i;

        # print "$gai -> $gbi = $i ($sum)\n";
    }

    printf "Stage %d: %s\n", $stage, $sum;
}