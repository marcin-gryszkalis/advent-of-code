#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;
my $inpside = length($f[0]);

my $OFF = 2000;

my $side = 2*$OFF + $inpside;

my $m;
push @$m, [('.')x$side] for (0..$side-1);

for my $r (0..$inpside-1)
{
    my @a = split//,$f[$r];
    for my $c (0..$inpside-1)
    {
        $m->[$r+$OFF]->[$c+$OFF] = $a[$c];
    }
}

my $vx = int($side/2);
my $vy = $vx;
my $d = 0; # N E S W
my @dx = qw/0 1 0 -1/;
my @dy = qw/-1 0 1 0/;
my %trans = (
    '.' => 'W',
    'W' => '#',
    '#' => 'F',
    'F' => '.'
);

my $infected = 0;

for my $b (1..10_000_000)
{
    printf("%10d %7d\n", $b, $infected) if $b % 100000 == 0;

    if ($m->[$vy]->[$vx] eq '#')
    {
        $d = ($d+1) % 4;
    }
    elsif ($m->[$vy]->[$vx] eq '.')
    {
        $d = ($d+3) % 4;
    }
    elsif ($m->[$vy]->[$vx] eq 'W')
    {
        $infected++;
    }
    elsif ($m->[$vy]->[$vx] eq 'F')
    {
        $d = ($d+2) % 4;
    }
    else { die }
    $m->[$vy]->[$vx] = $trans{$m->[$vy]->[$vx]};
    $vx += $dx[$d];
    $vy += $dy[$d];
}

print "stage 2: $infected\n";