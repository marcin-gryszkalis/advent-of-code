#!/usr/bin/perl
use 5.28.0;
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations);

my $OFF = 500;
my $S2 = 50_000_000_000;

my $init = <>;
chomp $init;
$init =~ s/initial state: //;
my @r = (".") x (length($init) + 2*$OFF);
my $i = 0;
for my $e (split//,$init)
{
    $r[$i + $OFF] = $e;
    $i++;
}

my $rules;
while (<>)
{
    chomp;
    next unless /(.....) => (.)/;
    $rules->{$1} = $2;
}

my $step = 1;
my $pv = 0;
while (1)
{
    my @s = @r;
    for my $i (2..scalar(@r)-3)
    {
        $s[$i] = $rules->{join("", @r[$i-2..$i+2])}
    }
    @r = @s;
#    print join("", @r)."\n";

    my $v = 0;
    my $c = 0;
    for my $i (0..scalar(@r)-1)
    {
        if ($r[$i] eq '#')
        {
            $v += ($i - $OFF);
            $c++;
        }
    }
    print "stage 1: $v\n" if $step == 20;

    if ($v == $pv + $c)
    {
        printf "stage 2: %d (step=$step)\n", $v + $c * ($S2 - $step);
        last;
    }

    $pv = $v;
    $step++;
}
