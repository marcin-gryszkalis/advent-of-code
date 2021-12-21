#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations variations_with_repetition);
use Clone qw/clone/;

#my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $p1 = 7;
my $p2 = 10;

# $p1 = 4;
# $p2 = 8;

my $s1 = 0;
my $s2 = 0;

my $d = 1;
my $t = 0;

$p1--; # 0-9
$p2--;


my $w1 = 0;
my $w2 = 0;

sub d
{
    my $p = shift; # we count p, move the other
    my $l = shift;
    my $m = shift;
    my $u = shift;
    my $s1 = shift;
    my $s2 = shift;
    my $q1 = shift;
    my $q2 = shift;

    my $x1 = shift;
    my $x2 = shift;

    my $xx1 = $x1;
    my $xx2 = $x2;

    if ($l > 0)
    {

        if ($p == 1)
        {
            $xx1 = "$x1$m";
            $xx2 = $x2;
        }
        else
        {
            $xx1 = $x1;
            $xx2 = "$x2$m";
        }

        if ($p == 1)
        {
            $q1 = ($q1 + $m) % 10;
            $s1 += ($q1 + 1);
            if ($s1 >= 21)
            {
                $w1 += $u;
                print "p1 won (score=$s1) at level($l) with u=$u (total $w1) x1=$xx1 x2=$xx2\n";
#                exit;
                return;
            }
        }
        else
        {
            $q2 = ($q2 + $m) % 10;
            $s2 += ($q2 + 1);
            if ($s2 >= 21)
            {
                $w2 += $u;
                print "p2 won (score=$s2) at level($l) with u=$u (total $w2) x1=$xx1 x2=$xx2\n";
#                exit;
                return;
            }
        }
    }

    my $qq1 = $q1 + 1;
    my $qq2 = $q2 + 1;
#    print "p=$p l=$l m=$m u=$u q:$qq1 $qq2 s:$s1 $s2 \n";

my %xu = (
3 => 1,
4 => 3,
5 => 6,
6 => 7,
7 => 6,
8 => 3,
9 => 1,
);

    for my $i (3..9)
    {
        d($p == 1 ? 2 : 1, $l+1, $i, $u * $xu{$i}, $s1, $s2, $q1, $q2, $xx1, $xx2);
    }
}

d(2, 0, -1, 1, 0, 0, $p1, $p2, "", "");
print "$w1\n$w2\n";
exit;

# my $i = 0;
# my $it = variations_with_repetition([1,2,3], 3);
# while (my $p = $it->next)
# {
#     $i++;
#     print sum(@$p)."\n";
# }
# exit;
while (1)
{
    $p1 = ($p1 + $d++) % 10;
    $p1 = ($p1 + $d++) % 10;
    $p1 = ($p1 + $d++) % 10;
    $s1 += ($p1 + 1);
    $t += 3;
    last if $s1 >= 1000;

    print "[$d] p1 = $p1 (total $s1)\n";

    $p2 = ($p2 + $d++) % 10;
    $p2 = ($p2 + $d++) % 10;
    $p2 = ($p2 + $d++) % 10;
    $s2 += ($p2 + 1);
    $t += 3;
    last if $s2 >= 1000;

    print "[$d] p2 = $p2 (total $s2)\n";
}

$stage1 = min($s1,$s2) * $t;

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;