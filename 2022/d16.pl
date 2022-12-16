#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;
use Graph::Undirected;


my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

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
    my $elephant = shift; # 0 then 1
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
        next if $rate{$dst} == 0;
        next if exists $counted->{$dst};
        next if exists $open->{$dst};

        my $addt = $apsp->path_length($src,$dst) + 1;
        next if $time + $addt > $limit;

        my $add = $allpressure * $addt;
        dfs($elephant, $dst, $time + $addt, clone($open), clone($counted), $flow + $add, $track.$dst);
    }

    my $total = $flow + $allpressure * ($limit - $time);
    if (!$elephant) # 2nd user
    {
        if (!exists $done->{$track})
        {
            $done->{$track} = 1;
            my $counted = clone($open);
            my $open = undef;
            $open->{$start} = 1;
            dfs(1, $start, 0, $open, $counted, $total, $track."|".$start);
        }
    }
    
    if ($total > $best)
    {
        $best = $total;
        print "best: $best $track      \n";
    }
    else
    {

        print "----: $total $track      \r";
    }   
    # calc what we'd get if we stay here
}

my $st;
my $open;
$open->{$start} = 1; # not really
my $counted;
$counted->{$start} = 1;
my $flow = 0;


print "Stage 1:\n";
dfs(1, $start, 0, clone($open), clone($counted), $flow, $start);

$limit -= 4;
print "Stage 2:\n";
dfs(0, $start, 0, clone($open), clone($counted), $flow, $start);

