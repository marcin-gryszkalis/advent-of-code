 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my $h;
my $maxx = 0;
my $maxy = 0;
my $y = 0;
for (@f)
{
    my $x = 0;
    for my $a (split//)
    {
        $h->{$x++,$y} = $a;
    }
    $maxx = $x - 1;
    $y++;
}
$maxy = $y - 1;


for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
         $stage1 += $h->{$x,$y} + 1 if
            $h->{$x,$y} < ($h->{$x-1,$y} // 10) &&
            $h->{$x,$y} < ($h->{$x+1,$y} // 10) &&
            $h->{$x,$y} < ($h->{$x,$y-1} // 10) &&
            $h->{$x,$y} < ($h->{$x,$y+1} // 10);
    }
}

my $p;
for my $k (keys %$h)
{
    $p->{$k} = 0 if $h->{$k} == 9;
}

my %cnt;
my $pi = 0;
for my $sx (0..$maxx)
{
    for my $sy (0..$maxy)
    {
        next if exists $p->{$sx,$sy};

        $pi++;
        my @sq = ();

        my $e;
        $e->{x} = $sx;
        $e->{y} = $sy;
        push(@sq, $e);
        $p->{$sx,$sy} = $pi;
        $cnt{$pi}++;

        while (1)
        {
            $e = shift(@sq);
            last unless defined $e;

            for my $dy (-1..1)
            {
                for my $dx (-1..1)
                {
                    next if abs($dx) + abs($dy) != 1;
                    my $xdx = $e->{x} + $dx;
                    my $ydy = $e->{y} + $dy;
                    next if $xdx < 0 || $xdx > $maxx;
                    next if $ydy < 0 || $ydy > $maxy;
                    next if exists $p->{$xdx,$ydy};

                    my $ee;
                    $ee->{x} = $xdx;
                    $ee->{y} = $ydy;
                    push(@sq, $ee);
                    $p->{$xdx,$ydy} = $pi;
                    $cnt{$pi}++;
                }
            }
        }
    }
}

my @d = sort { $b <=> $a } values %cnt;
$stage2 = $d[0] * $d[1] * $d[2];

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
