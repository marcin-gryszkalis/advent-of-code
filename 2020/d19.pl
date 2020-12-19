#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my $ff = read_file(\*STDIN);
my @ff2 = split/\n\n/, $ff;

my @rules = split/\n/, $ff2[0];
my @checks = split/\n/, $ff2[1];

my $stage1 = 0;
my $stage2 = 0;

my %rh = map { m/(\d+): (.*)/; $1 => $2 } @rules;

for my $rk (keys %rh)
{
    my $r = $rh{$rk};
    $r = "(?:$r)";
    $r =~ s/"//g;
    $rh{$rk} = $r;
}

sub rr
{
    my $rk = shift;
    my $lvl = shift;

    my $r = $rh{$rk};
    $r =~ s/(\d+)/rr($1,$lvl+1)/ge;

    return $r;
}

sub rr2
{
    my $rk = shift;
    my $lvl = shift;
    my $maxlvl = shift;

    my $r = $rh{$rk};

    if (($rk == 8 || $rk == 11) && $lvl > $maxlvl)
    {
        # skip second part of expression
        my @rs = split/\|/, $r;
        $r = $rs[0].")";
    }

    $r =~ s/(\d+)/rr2($1,$lvl+1,$maxlvl)/ge;

    return $r;
}


my $rx1 = rr(0, 0);
$rx1 =~ s/\s+//g;
$rx1 = '^'.$rx1.'$';

for my $c (@checks)
{
    $stage1++ if $c =~ /$rx1/;
}
print "stage 1: $stage1\n";


$rh{8} = "(?:42 | 42 8)";
$rh{11} = "(?:42 31 | 42 11 31)";

my $maxlvl = 1;
my $prev = 0;
while (1)
{
    my $rx2 = rr2(0, 0, $maxlvl);
    $rx2 =~ s/\s+//g;
    $rx2 = '^'.$rx2.'$';


    my $stage2 = 0;
    for my $c (@checks)
    {
        $stage2++ if $c =~ /$rx2/;
    }

    print "stage 2 (max level $maxlvl): $stage2\n";

    last if $stage2 == $prev;
    $prev = $stage2;
    $maxlvl++;
    sleep(1);
}

