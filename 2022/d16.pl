#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;
use Graph::Undirected;

my @f = read_file(\*STDIN, chomp => 1);

my $limit = 30;
my $start = 'AA';

my @usable = ();

my %rate;
my $g = Graph::Undirected->new;
for (@f)
{
    /\s(\S\S)\s.*rate=(\d+).*valves?\s(.*)/; # Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    my $src = $1;
    $rate{$src} = $2;
    push(@usable, $src) if $2 > 0;
    for my $dst (split(/,\s+/, $3))
    {
        $g->add_edge($src,$dst);
    }
}

my $apsp = $g->APSP_Floyd_Warshall();

my $best = 0;
my $done;

sub dfs
{
    my $phase = shift; # 0 then 1
    my $src = shift;
    my $time = shift;
    my $open = shift; # open valves by current user
    my $counted = shift; # counted = open by 1st user - checked by 2nd user
    my $flow = shift; # sum of flow from previous steps
    my $track = shift; # track as string

    $open->{$src} = 1;
    my $allpressure = sum(map { $rate{$_} } keys %$open);

    for my $dst (@usable)
    {
        next if $dst eq $src;
        next if exists $counted->{$dst} || exists $open->{$dst};

        my $timediff = $apsp->path_length($src,$dst) + 1;
        next if $time + $timediff > $limit;

        dfs($phase, $dst, $time + $timediff, clone($open), $counted, $flow + $allpressure * $timediff, $track.$dst);
    }

    my $total = $flow + $allpressure * ($limit - $time);

    if (!$phase && !exists $done->{$track}) # start 2nd user
    {
        $done->{$track} = 1;
        dfs(1, $start, 0, undef, $open, $total, $track."|".$start);
    }

    if ($total > $best)
    {
        $best = $total;
        print "best: $best $track\n";
    }
}

print "Stage 1:\n";
dfs(1, $start, 0, undef, undef, 0, $start); # we just start with 2nd phase

$limit -= 4; # time to teach elephant :)
print "Stage 2:\n";
dfs(0, $start, 0, undef, undef, 0, $start);
