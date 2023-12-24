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

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $minxy = 7;
my $maxxy = 27;

$minxy = 200000000000000;
$maxxy = 400000000000000;

sub signedstr($x) { ($x >= 0 ? '+' : '').$x }

my @t;
my @eqa;
my @eqb;
my $i = 0;
my $eq = '';
my $eq2 = '';
for (@f)
{
    my @a = /([\d-]+)/g;
    push @t, \@a;

    my ($x1,$y1,$z1,$vx,$vy,$vz) = @a;

    my ($x2,$y2,$z2) = ($x1 + $vx, $y1 + $vy, $z1 + $vz);

    my $pa = ($y2 - $y1) / ($x2 - $x1);
    my $pb = $y2 - $pa * $x2;
    push @eqa, [$pa,$pb] ; # y = pa x + pb
    push @eqb, [$pa,-1,-$pb]; # p1 x + p2 y = p3

    if ($i <= 2)
    {
        $eq .= $x1.signedstr($vx)."a=x+va,";
        $eq .= $y1.signedstr($vy)."a=y+wa,";
        $eq .= $z1.signedstr($vz)."a=y+ua,";

        $eq2 .= "x + t$i * vx == $x1 + t$i * $vx,\n";
        $eq2 .= "y + t$i * vy == $y1 + t$i * $vy,\n";
        $eq2 .= "z + t$i * vz == $z1 + t$i * $vz,\n";
    }
    $i++;


}

$eq =~ s/,\s*$//;

$eq2 = "
from z3 import *

x, y, z = Ints('x y z')
vx, vy, vz = Ints('vx vy vz')
t0, t1, t2 = Ints('t0 t1 t2')
r = Int('r')

solve(
$eq2
r == x+y+z,
)
";


for my $i1 (0..$#eqb-1)
{
    my $t1 = $t[$i1];
    my ($tx1,$ty1,$tz1,$vx1,$vy1,$vz1) = @$t1;

    my $e1 = $eqb[$i1];
    my ($a1,$b1,$c1) = @$e1;

    my $k1 = $eqa[$i1];
    my ($ka1,$kb1) = @$k1;
    for my $i2 ($i1+1..$#eqb)
    {
        my $t2 = $t[$i2];
        my ($tx2,$ty2,$tz2,$vx2,$vy2,$vz2) = @$t2;



        my $e2 = $eqb[$i2];
        my ($a2,$b2,$c2) = @$e2;
        my $k2 = $eqa[$i2];
        my ($ka2,$kb2) = @$k2;

        if ($a1 == $a2)
        {
            print "$i1:$i2 (y = $ka1 x + $kb1 : y = $ka2 x + $kb2) -- parallel\n";
            next;
        }
        ; # the same or parallel

        my $w = $a1*$b2 - $a2*$b1;
        my $wx = $c1*$b2 - $c2*$b1;
        my $wy = $a1*$c2 - $a2*$c1;

        die if $w == 0;
        my $x = $wx / $w;
        my $y = $wy / $w;

        my $insidex = $x >= $minxy && $x <= $maxxy;
        my $insidey = $y >= $minxy && $y <= $maxxy;

        # my $t1future = $ka1 > 0 && $x > $tx1 || $ka1 < 0 && $x < $tx1;
        # my $t2future = $ka2 > 0 && $x > $tx2 || $ka2 < 0 && $x < $tx2;

        my $t1future = $vx1 > 0 && $x > $tx1 || $vx1 < 0 && $x < $tx1;
        my $t2future = $vx2 > 0 && $x > $tx2 || $vx2 < 0 && $x < $tx2;
        print "$i1:$i2 (y = $ka1 x + $kb1 : y = $ka2 x + $kb2) -- $x,$y ($insidex,$insidey,$t1future,$t2future)\n";

        $stage1++ if $insidex && $insidey && $t1future && $t2future;
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;

say "Mathematica: $eq";
say "Python Z3:\n$eq2";