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
    my @g = split//;
    my $x = 0;
    for my $a (@g)
    {
        $h->{$x++,$y} = $a;
    }
    $maxx = $x;
    $y++;
}
$maxy= $y;


for my $y (0..$maxy-1)
{
    for my $x (0..$maxx-1)
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

my $pi = 0;
while (1)
{
    my $sx = -1;
    my $sy = -1;
    SL: for my $ssx (0..$maxx-1)
    {
        for my $ssy (0..$maxy-1)
        {
            unless (exists $p->{$ssx,$ssy})
            {
                $sx = $ssx;
                $sy = $ssy;
                last SL;
            }
        }
    }
    last if $sx == -1 && $sy == -1;

    $pi++;
    my @sq = ();

    my $e = undef;
    $e->{x} = $sx;
    $e->{y} = $sy;
    push(@sq, $e);

    while (1)
    {
        $e = pop(@sq);
        last unless defined $e;

        $p->{$e->{x},$e->{y}} = $pi;

        for my $dy (-1..1)
        {
            for my $dx (-1..1)
            {
                next if abs($dx) + abs($dy) != 1;
                next if $e->{x}+$dx < 0 || $e->{x}+$dx >= $maxx;
                next if $e->{y}+$dy < 0 || $e->{y}+$dy >= $maxy;
                next if exists $p->{$e->{x}+$dx,$e->{y}+$dy};

                my $ee = undef;
                $ee->{x} = $e->{x}+$dx;
                $ee->{y} = $e->{y}+$dy;
                push(@sq, $ee);
            }
        }
    }
}

my %cnt;
for my $v (values %$p)
{
    $cnt{$v}++;
}

my @d = sort { $b <=> $a } values %cnt;
$stage2 = $d[1] * $d[2] * $d[3];

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
