#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $m;
for (@f)
{
    # Blueprint 1: Each ore robot costs 4 ore. Each cly robot costs 2 ore. Each obsidian robot costs 3 ore and 14 cly. Each geode robot costs 2 ore and 7 obsidian.
#    s/Blueprint (\d):\s+//;

    my @a = m/(\d+)/g;
    my $b = $a[0];

    $m->{$b}->{ore_ore} = $a[1];
    $m->{$b}->{cly_ore} = $a[2];
    $m->{$b}->{obs_ore} = $a[3];
    $m->{$b}->{obs_cly} = $a[4];
    $m->{$b}->{geo_ore} = $a[5];
    $m->{$b}->{geo_obs} = $a[6];
}

#print Dumper $m;

my $cost;

my $best = 0;
my $memoi;
my $bp = 0;
my $i = 0;

my @track;

my @bestgeoat = ();

sub dfs
{
    $i++;
    my $min = shift;
    my $ore = shift;
    my $cly = shift;
    my $obs = shift;
    my $geo = shift;

    return -1 if $geo < ($bestgeoat[$min] // 0);
    $bestgeoat[$min] = $geo;

    my $r_ore = shift;
    my $r_cly = shift;
    my $r_obs = shift;
    my $r_geo = shift;

    if (exists $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo})
    {
#        print Dumper $memoi;
        return $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo};
    }
    $track[$min-1] = [$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo];

    print "$bp [$min]: $best ($ore,$cly,$obs,$geo) ($r_ore,$r_cly,$r_obs,$r_geo)\n" if $i % 10000 == 0;
    # no warnings;
    # print join(",", @bestgeoat)."\n" if $i % 10000 == 0;
    # use warnings;
    if ($min == 24)
    {
        $ore += $r_ore;
        $cly += $r_cly;
        $obs += $r_obs;
        $geo += $r_geo;

        if ($geo > $best)
        {
            $best = $geo;
            print "BEST $bp: $best ($ore,$cly,$obs,$geo) ($r_ore,$r_cly,$r_obs,$r_geo)\n";
#            print Dumper \@track;
            for my $iii (0..23)
            {
                print "BEST $iii > ".join(" ", @{$track[$iii]})."\n";
            }
        }
        return $geo;
    }

    my @res = ();
    if ($ore >= $cost->{geo_ore} && $obs >= $cost->{geo_obs})
    {
        my $nore = $ore + $r_ore - $cost->{geo_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs - $cost->{geo_obs};
        my $ngeo = $geo + $r_geo;
        my $out = dfs($min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs, $r_geo+1);
        push(@res, $out);
    }
    if ($ore >= $cost->{obs_ore} && $cly >= $cost->{obs_cly})
    {
        my $nore = $ore + $r_ore - $cost->{obs_ore};
        my $ncly = $cly + $r_cly - $cost->{obs_cly};
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        my $out = dfs($min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs+1, $r_geo);
        push(@res, $out);
    }
    if ($ore >= $cost->{cly_ore})
    {
        my $nore = $ore + $r_ore - $cost->{cly_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        my $out = dfs($min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly+1, $r_obs, $r_geo);
        push(@res, $out);
    }
    if ($ore >= $cost->{ore_ore} && $r_ore < 10) # 10?
    { #die $cost->{ore_ore} if $ore < 4;
        my $nore = $ore + $r_ore - $cost->{ore_ore};
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;
        my $out = dfs($min+1, $nore, $ncly, $nobs, $ngeo, $r_ore+1, $r_cly, $r_obs, $r_geo);
        push(@res, $out);
    }

    {
        my $nore = $ore + $r_ore;
        my $ncly = $cly + $r_cly;
        my $nobs = $obs + $r_obs;
        my $ngeo = $geo + $r_geo;

        my $out = dfs($min+1, $nore, $ncly, $nobs, $ngeo, $r_ore, $r_cly, $r_obs, $r_geo);
        push(@res, $out);
    }

    # $ore += $r_ore;
    # $cly += $r_cly;
    # $obs += $r_obs;
    # $geo += $r_geo;

    # memoize
    $memoi->{$min,$ore,$cly,$obs,$geo,$r_ore,$r_cly,$r_obs,$r_geo} = max(@res);

    return max(@res);
}

my @bres;
for my $b (1..scalar(@f))
{

    @track = ();
    @bestgeoat = ();
    $best = 0;
    $cost = $m->{$b};
    $memoi = undef;
    $i = 0;

    #print Dumper $cost; exit;
    $bp = $b;
    my $out = dfs(1, 0, 0, 0, 0, 1, 0, 0, 0);
    push(@bres, $out);
print Dumper \@bres;

}

my $bi = 1;
for my $br (@bres)
{
    $stage1 += ($bi * $bres[$bi-1]);
    $bi++;
}
#print Dumper $memoi;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;