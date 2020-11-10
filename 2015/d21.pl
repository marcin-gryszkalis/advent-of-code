#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# input - boss:
my $b_hp_start = 109;
my $b_hp = $b_hp_start;
my $b_dmg = 8;
my $b_armor = 2;

# player
my $p_hp_start = 100;
my $p_hp = $p_hp_start;
my $p_dmg = 0;
my $p_armor = 0;


my %price = qw/
Dagger        8
Shortsword   10
Warhammer    25
Longsword    40
Greataxe     74
Leather      13
Chainmail    31
Splintmail   53
Bandedmail   75
Platemail   102
None          0

Damage+0    0
Damage+1    25
Damage+2    50
Damage+3   100

Defense+0   0
Defense+1   20
Defense+2   40
Defense+3   80
/;

my %weapon = qw/
Dagger      4
Shortsword  5
Warhammer   6
Longsword   7
Greataxe    8
/;

my %armor = qw/
Leather     1
Chainmail   2
Splintmail  3
Bandedmail  4
Platemail   5
None        0
/;

my @rings = qw/
Damage+0
Damage+1
Damage+2
Damage+3
Defense+0
Defense+1
Defense+2
Defense+3
/;

# Rings:      Cost  Damage  Armor
# Damage +1    25     1       0
# Damage +2    50     2       0
# Damage +3   100     3       0
# Defense +1   20     0       1
# Defense +2   40     0       2
# Defense +3   80     0       3

my $best_win = 100000;
my $best_loose = 0;
for my $xw (keys %weapon)
{
    for my $xa (keys %armor)
    {
        my $it = combinations(\@rings, 2);
        while (my $rings = $it->next())
        {
            my $d = $weapon{$xw};
            my $a = $armor{$xa};
            for my $r (@$rings)
            {
                $r =~ /(\S+)\+(\d+)/;
                if ($1 eq 'Damage')
                {
                    $d += $2;
                }
                else
                {
                    $a += $2;
                }
            }

            $p_dmg = $d;
            $p_armor = $a;

            my $adv_dmg = $p_dmg - $b_armor;
            my $adv_arm = $p_armor - $b_dmg;
            my $adv = $adv_dmg + $adv_arm;

            $b_hp = $b_hp_start;
            $p_hp = $p_hp_start;

            my $round = 0;
            while (1)
            {
                last if $b_hp <= 0 || $p_hp <= 0;

                my $hit = -100;
                if ($round % 2 == 0)
                {
                    $hit = max(1, $p_dmg - $b_armor);
                    $b_hp -= $hit;
                }
                else
                {
                    $hit = max(1, $b_dmg - $p_armor);
                    $p_hp -= $hit;
                }

                # printf "%4d %s h(%d) player=$p_hp boss=$b_hp\n", $round, $round % 2 == 0 ? "P" : "B", $hit;
                $round++;
            }

            if ($p_hp > 0) # win
            {
                my $spent = $price{$xw} + $price{$xa} + $price{$rings->[0]} + $price{$rings->[1]};
                if ($spent < $best_win)
                {
                    $best_win = $spent;
                    print "WIN! $spent EQ: $xw $xa $rings->[0] $rings->[1] ===> damage=$p_dmg armor=$p_armor ====> adv-dmg=$adv_dmg adv-arm=$adv_arm adv=$adv\n";

                }
            }
            else
            {
                my $spent = $price{$xw} + $price{$xa} + $price{$rings->[0]} + $price{$rings->[1]};
                if ($spent > $best_loose)
                {
                    $best_loose = $spent;
                    print "LOST $spent EQ: $xw $xa $rings->[0] $rings->[1] ===> damage=$p_dmg armor=$p_armor ====> adv-dmg=$adv_dmg adv-arm=$adv_arm adv=$adv\n";

                }

            }
        }
    }
}
printf "stage 1: %d\n", $best_win;
printf "stage 2: %d\n", $best_loose;