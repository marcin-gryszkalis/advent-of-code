#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# input - boss:
my $b_hp_start = 71;
my $b_dmg = 10;

# player
my $p_hp_start = 50;
my $p_mana = 500;

# Magic Missile costs 53 mana. It instantly does 4 damage.
# Drain costs 73 mana. It instantly does 2 damage and heals you for 2 hit points.
# Shield costs 113 mana. It starts an effect that lasts for 6 turns. While it is active, your armor is increased by 7.
# Poison costs 173 mana. It starts an effect that lasts for 6 turns. At the start of each turn while it is active, it deals the boss 3 damage.
# Recharge costs 229 mana. It starts an effect that lasts for 5 turns. At the start of each turn while it is active, it gives you 101 new mana.

my @status;

my $stage = 0;
my $best = 10000000;
sub dfs
{
    my ($round, $p_hp, $b_hp, $mana, $mana_used, $spell_shield, $spell_poison, $spell_recharge, $newspell) = @_;

    # stage2 only:
    if ($stage == 2 && $round %2 == 0)
    {
        $p_hp--;
        return if $p_hp <= 0;
    }

    $status[$round] = sprintf "%4d %4s plr=%3d boss=%3d   mana=%d mana-used=%d shield=%d poison=%d recharge=%d newspell=%s\n",
                        $round, $round % 2 == 0 ? "PLYR" : "BOSS", $p_hp, $b_hp, $mana, $mana_used, $spell_shield, $spell_poison, $spell_recharge, $newspell // '-';

    if (defined $newspell)
    {
        if ($newspell eq 'magicmissile')
        {
            $b_hp -= 4;
            $mana -= 53;
            $mana_used += 53;
        }
        elsif ($newspell eq 'drain')
        {
            $b_hp -= 2;
            $p_hp += 2;
            $mana -= 73;
            $mana_used += 73;
        }
        elsif ($newspell eq 'shield')
        {
            $spell_shield = 6;
            $mana -= 113;
            $mana_used += 113;
        }
        elsif ($newspell eq 'poison')
        {
            $spell_poison = 6;
            $mana -= 173;
            $mana_used += 173;
        }
        elsif ($newspell eq 'recharge')
        {
            $spell_recharge = 5;
            $mana -= 229;
            $mana_used += 229;
        }
        else { die $newspell }

        return if $mana < 0; # If you cannot afford to cast any spell, you lose.
        return if $mana_used > $best;
    }

    # spells work on both players' turns
    if ($spell_shield)
    {
        $spell_shield--;
    }

    if ($spell_poison)
    {
        $b_hp -= 3;
        $spell_poison--;
    }

    if ($spell_recharge)
    {
        $mana += 101;
        $spell_recharge--;
    }

    if ($b_hp <= 0) # win!
    {
        if ($mana_used < $best)
        {
            $best = $mana_used;
            print "$round: best=$best\n";
            # for my $rr (0..$round) { print $status[$rr] } print "\n";
        }
        return;
    }

    if ($round % 2 == 0) # player
    {
        for my $s (qw/magicmissile drain shield poison recharge/)
        {
            dfs($round+1, $p_hp, $b_hp, $mana, $mana_used, $spell_shield, $spell_poison, $spell_recharge, $s);
        }
    }
    else # boss
    {
        my $armor = $spell_shield > 0 ? 7 : 0;
        $p_hp -= max(1, $b_dmg - $armor);
        return if $p_hp <= 0; # lost

        dfs($round+1, $p_hp, $b_hp, $mana, $mana_used, $spell_shield, $spell_poison, $spell_recharge);
    }

}

$stage = 1;
$best = 1000000;
dfs(0, $p_hp_start, $b_hp_start, $p_mana, 0, 0, 0, 0);
printf "stage $stage: %d\n", $best;

$stage = 2;
$best = 1000000;
dfs(0, $p_hp_start, $b_hp_start, $p_mana, 0, 0, 0, 0);
printf "stage $stage: %d\n", $best;

