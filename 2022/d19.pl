#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use MCE::Map;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $m;
for (@f)
{
    # Blueprint 1: Each ore robot costs 4 ore. Each cly robot costs 2 ore. Each obsidian robot costs 3 ore and 14 cly. Each geode robot costs 2 ore and 7 obsidian.
    my @a = m/(\d+)/g;
    my $b = $a[0];

    $m->{$b}->{ore_ore} = $a[1];
    $m->{$b}->{cly_ore} = $a[2];
    $m->{$b}->{obs_ore} = $a[3];
    $m->{$b}->{obs_cly} = $a[4];
    $m->{$b}->{geo_ore} = $a[5];
    $m->{$b}->{geo_obs} = $a[6];

    $m->{$b}->{max_ore} = max($a[1],$a[2],$a[3],$a[5]);
    $m->{$b}->{max_cly} = $a[4];
    $m->{$b}->{max_obs} = $a[6];
}

my $timelimit = 24;

sub dfs($bp, $min, $ore, $cly, $obs, $geo, $r_ore, $r_cly, $r_obs, $r_geo)
{
    state $best;
    state $memoi;

    if ($min == 1)
    {
        $best = 0;
        $memoi = ();
    }

    # memoization
    return $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo} if exists $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo};

    # old, simple but risky and not that effective heurisitc:
    # 2 is set by experiment :/
    # 0 is ok for stage 1 but not stage 2
    # 1 is not good for some input, 2 probably works for 99% of inputs (should be increased along with time limit)
    # we skip this branch if we have less geodes than best at this time during current search minus this parameter
    # becuse sometimes we'll get quick increase later
    # my $best_goat_heur = 2;
    # return -1 if $geo < ($bestgeoat[$min] // 0) - $best_goat_heur;
    # $bestgeoat[$min] = max($bestgeoat[$min] // 0,$geo);

    # break if we're certain that no more geodes can be generated than current best
    my $remaining_time = $timelimit - $min + 1;
    my $max_geo = $geo + $r_geo * $remaining_time + $remaining_time * ($remaining_time + 1) / 2;
    return -1 if $max_geo <= $best;

    if ($min == $timelimit)
    {
        $geo += $r_geo;

        if ($geo > $best)
        {
            $best = $geo;
            # print "BEST $bp: $best ($ore,$cly,$obs,$geo) ($r_ore,$r_cly,$r_obs,$r_geo)\n";
        }
        return $geo;
    }

    my @res = ();
    my $cost = $m->{$bp};

    if ($ore >= $cost->{geo_ore} && $obs >= $cost->{geo_obs})
    {
        my $nore = $ore + $r_ore - $cost->{geo_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs - $cost->{geo_obs};
        my $ngeo = $geo + $r_geo;
        push @res, dfs($bp, $min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs, $r_geo+1);
    }

    if ($ore >= $cost->{obs_ore} && $cly >= $cost->{obs_cly} && $r_obs < $cost->{max_obs})
    {
        my $nore = $ore + $r_ore - $cost->{obs_ore};
        my $ncly = $cly + $r_cly - $cost->{obs_cly};
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        push @res, dfs($bp, $min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs+1, $r_geo);
    }

    if ($ore >= $cost->{cly_ore} && $r_cly < $cost->{max_cly})
    {
        my $nore = $ore + $r_ore - $cost->{cly_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        push @res, dfs($bp, $min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly+1, $r_obs, $r_geo);
    }

    if ($ore >= $cost->{ore_ore} && $r_ore < $cost->{max_ore})
    {
        my $nore = $ore + $r_ore - $cost->{ore_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        push @res, dfs($bp, $min+1, $nore, $ncly, $nobs, $ngeo, $r_ore+1, $r_cly, $r_obs, $r_geo);
    }

    { # no new robots
        my $nore = $ore + $r_ore;
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;

        push @res, dfs($bp, $min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs, $r_geo);
    }

    return $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo} = max(@res);
}

sub process($stage, $b)
{
    my $out = dfs($b, 1, 0, 0, 0, 0, 1, 0, 0, 0);
    print "stage $stage, blueprint $b = $out\n";
    return $out;
}

for my $stage (1..2)
{
    my $blueprint_max = 100;
    if ($stage == 2)
    {
        $timelimit = 32;
        $blueprint_max = 3;
    }

    my @res = mce_map { process $stage, $_ } (1..min(scalar @f, $blueprint_max));

    if ($stage == 1)
    {
        my $bi = 1;
        printf "Stage 1: %s\n", sum map { $_ * $bi++ } @res;
    }
    else
    {
        printf "Stage 2: %s\n", product @res;
    }

}
