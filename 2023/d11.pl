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

my ($h, $w) = ($y, length($f[0]));
my ($maxx, $maxy) = ($w - 1, $h - 1);

for my $stage (1..2)
{
    my $sum = 0;
    for my $v (combinations(\@galaxies, 2))
    {
        my ($ga, $gb) = @$v;
        my ($gax, $gay) = @$ga;
        my ($gbx, $gby) = @$gb;

        ($gax, $gbx) = minmax($gax, $gbx);
        ($gay, $gby) = minmax($gay, $gby);

        $sum +=
            sum0(map { exists $occx{$_} ? 1 : $expand{$stage} } ($gax+1..$gbx)) +
            sum0(map { exists $occy{$_} ? 1 : $expand{$stage} } ($gay+1..$gby));
    }

    printf "Stage %d: %s\n", $stage, $sum;
}