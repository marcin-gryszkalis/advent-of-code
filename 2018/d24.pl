#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

use Storable qw(dclone);

my $groups_start;

my %opponent;
$opponent{"Immune System"} = "Infection";
$opponent{"Infection"} = "Immune System";

my $armycount_start;
for my $k (keys %opponent)
{
    $armycount_start->{$k} = 0;
}

my $army;
my @f = read_file(\*STDIN);
for (@f)
{
    chomp;

    if (/^\s*$/)
    {
        next;
    }
    elsif (/(.*):/)
    {
        $army = $1;
        next;
    }
    elsif (/^(\d+) units each with (\d+) hit points(?: \(([^)]+)\))? with an attack that does (\d+) (.*) damage at initiative (\d+)/)
    {
        my %g;

        $g{army} = $army;
        $g{units} = $1;
        $g{hp} = $2;
        my $props = $3;
        $g{damage} = $4;
        $g{power} = $g{units} * $g{damage};
        $g{attack} = $5;
        $g{initiative} = $6;
        $g{weak} = ''; # double damage
        $g{immune} = ''; # no damage

        if (defined $props)
        {
            for my $p (split(/;/,$props))
            {
                if ($p =~ /(weak|immune) to (.*)/)
                {
                    $g{$1} = $2; # no split
                }
                else
                {
                    die $p;
                }
            }
        }

        my $gn = "$army:".($armycount_start->{$army}+1);
        $groups_start->{$gn} = \%g;
        $armycount_start->{$army}++;
    }
    else
    {
        die $_;
    }
}

my $winner = undef;
my $stage1 = 0;
my $stage2 = 0;
my $boost = 0;

BOOST: while (1)
{
    # reset state
    my $groups = dclone($groups_start);
    my $armycount = dclone($armycount_start);

    # apply stage 2 boost
    for my $gn (keys %$groups)
    {
        my $g = $groups->{$gn};
        if ($g->{army} eq 'Immune System')
        {
            $g->{damage} += $boost;
            $g->{power} = $g->{units} * $g->{damage}; # recalc
        }
    }

    my $round = 1;
    FIGHT: while (1)
    {
        # target selection
        my %targets = ();
        my %targeted_by = ();

        for my $gn (
            sort { $groups->{$b}->{power} <=> $groups->{$a}->{power} ||
                    $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative}  }
            grep { $groups->{$_}->{units} > 0 }
            keys %$groups)
        {
            my $g = $groups->{$gn};

            my %potential_damage = ();

            for my $hn (
                grep { $groups->{$_}->{units} > 0 }
                grep { $groups->{$_}->{army} ne $g->{army} }
                keys %$groups)
            {
                my $h = $groups->{$hn};

                if (index($h->{immune}, $g->{attack}) >= 0)
                {
                    $potential_damage{$hn} = 0;
                }
                elsif (index($h->{weak}, $g->{attack}) >= 0)
                {
                    $potential_damage{$hn} = 2 * $g->{power};
                }
                else
                {
                    $potential_damage{$hn} = $g->{power};
                }
            }

            for my $hn (
                sort { $potential_damage{$b} <=> $potential_damage{$a} ||
                        $groups->{$b}->{power} <=> $groups->{$a}->{power} ||
                        $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative} }
                grep { $potential_damage{$_} > 0 }
                grep { $groups->{$_}->{units} > 0 }
                grep { $groups->{$_}->{army} ne $g->{army} }
                keys %$groups)
            {
                next if exists $targeted_by{$hn}; # only one can attack given group
                my $h = $groups->{$hn};
                $targets{$gn} = $hn;
                $targeted_by{$hn} = $gn;
                last;
            }

        }

        # attack!
        for my $gn (sort { $groups->{$b}->{initiative} <=> $groups->{$a}->{initiative}  } keys %$groups)
        {
            my $g = $groups->{$gn};

            next if $g->{units} == 0;
            next unless exists $targets{$gn};

            my $hn = $targets{$gn};
            my $h = $groups->{$hn};

            my $real_damage = 0;
            if (index($h->{immune}, $g->{attack}) >= 0)
            {
                $real_damage = 0;
            }
            elsif (index($h->{weak}, $g->{attack}) >= 0)
            {
                $real_damage = 2 * $g->{power};
            }
            else
            {
                $real_damage = $g->{power};
            }

            my $units_killed = min(int($real_damage / $h->{hp}), $h->{units});
            $h->{units} -= $units_killed;
            $armycount->{$h->{army}}-- if $h->{units} == 0;
            $h->{power} = $h->{units} * $h->{damage};
            my $dead = $h->{units} == 0 ? "dead" : "alive:$h->{units}";
#            print "boost $boost || round $round || attack: $gn [$g->{damage}] -> $hn = $units_killed ($dead)\n";
        }

        for my $k (keys %$armycount)
        {
            if ($armycount->{$k} == 0)
            {
                $winner = $opponent{$k};
                last FIGHT;
            }
        }

        $round++;
        if ($round > 100000)
        {
#            print "loop at boost=$boost\n";
            last FIGHT;
        }
    }

    my $unitsleft = 0;
    for my $k (grep { $groups->{$_}->{army} eq $winner } keys %$groups)
    {
        $unitsleft += $groups->{$k}->{units};
    }

    $stage1 = $unitsleft if $boost == 0;
    $stage2 = $unitsleft if $winner eq 'Immune System';
    last if $stage2 > 0;

    $boost++;
}

print "stage 1: $stage1\n";
print "stage 2: $stage2 (winner: $winner, boost: $boost)\n";
