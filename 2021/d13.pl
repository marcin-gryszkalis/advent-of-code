 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $p;
my @foldd;
my @foldv;
for (@f)
{
    if (/(\d+),(\d+)/)
    {
        $p->{$1,$2} = 1;
    }
    elsif (/fold along ([xy])=(\d+)/)
    {
        push(@foldd, $1);
        push(@foldv, $2);
    }
}

my $i = 0;
while (1)
{
    my $fd = shift(@foldd);
    my $fv = shift(@foldv);
    last unless defined $fd;

    my $q;
    for my $k (keys %$p)
    {
        my ($x,$y) = split/\D/,$k;
        my $nx = $fd eq 'x' && $x >= $fv ? 2*$fv - $x : $x;
        my $ny = $fd eq 'y' && $y >= $fv ? 2*$fv - $y : $y;
        $q->{$nx,$ny} = 1;
    }

    $p = $q;
    $stage1 = scalar(keys %$p) if $i++ == 0;
}

$stage1 = scalar(keys %$p);
printf "Stage 1: %s\n", $stage1;

my $maxx = 0;
my $maxy = 0;
for my $k (keys %$p)
{
    my ($x,$y) = split/\D/,$k;
    $maxx = max($maxx,$x);
    $maxy = max($maxy,$y);
}

printf "Stage 2:\n";
for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print (exists $p->{$x,$y} ? "#" : ".");
    }
    print "\n";
}

