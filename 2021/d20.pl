#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $p = shift @f;
shift @f;

my $infinite_trick = substr($p,0,1) eq '#';

my $minx = 5;
my $miny = 5;
my $maxx = $minx + length($f[0]) + 5;
my $maxy = $miny + scalar(@f) + 5;

my $x = $minx+2;
my $y = $miny+2;

my $h;
$; = ",";
for (@f)
{
    $x = $minx + 2;
    my @a = split//;
    for (@a)
    {
        $h->{$x,$y} = '#' if $_ eq '#';
        $x++;
    }
    $y++;
}

sub pixel
{
    my ($xx,$yy,$ll) = @_;

    if ($infinite_trick && ($xx < $minx || $yy < $miny || $xx > $maxx || $yy > $maxy))
    {
        return $ll%2 ? 1 : 0;
    }

    return (exists $h->{$xx,$yy}) ? 1 : 0;
}

my $hh;
for my $l (1..50)
{
    $hh = clone($h);
    for my $y ($miny-2..$maxy+2)
    {
        for my $x ($minx-2..$maxx+2)
        {
            my $s;
            for my $dy (-1..1)
            {
                for my $dx (-1..1)
                {
                    $s .= pixel($x+$dx,$y+$dy,$l);
                }
            }
            my $o = substr($p, oct("0b$s"), 1);

            if ($o eq '#')
            {
                $hh->{$x,$y} = '#';
            }
            else
            {
                delete $hh->{$x,$y} if exists $hh->{$x,$y};
            }
        }
    }

    $h = $hh;
    # for my $y ($miny-2..$maxy+2)
    # {
    #     for my $x ($minx-2..$maxx+2)
    #     {
    #         print (exists $h->{$x,$y} ? "#" : ".");
    #     }
    #     print "\n";
    # }

    $minx--;
    $miny--;
    $maxx++;
    $maxy++;

    $stage1 = scalar keys(%$h) if $l == 2;
}

$stage2 = scalar keys(%$h);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;