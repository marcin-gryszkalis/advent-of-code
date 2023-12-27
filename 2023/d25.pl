#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax minmaxstr/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

use Graph::Undirected;
my $g = Graph::Undirected->new(); # An undirected graph.

my $STABLE_TOP_LIMIT = 500;

my @f = read_file(\*STDIN, chomp => 1);

my $t;
my $c;
my $cnt;
for (@f)
{
    my @a = /(\w+)/g;
    for my $i (1..$#a)
    {
        $g->add_edge($a[0], $a[$i]);
    }
}

my %cnt;
my $ii = 0;
my @top;
my $topsp = '';
my $stable = 0;

while ($stable < $STABLE_TOP_LIMIT)
{
    $ii++;

    my $v = $g->random_vertex();
    my $w = $g->random_vertex();
    next if $v eq $w;

    my @path = $g->SP_Dijkstra($v, $w);

    for my $vi (1..$#path)
    {
        my ($p1,$p2) = minmaxstr($path[$vi-1],$path[$vi]);
        $cnt{"$p1:$p2"}++;
    }

    my @toplong = head(6, sort { $cnt{$b} <=> $cnt{$a} } keys %cnt);
    @top = head(3, @toplong);
    printf("%5d ($stable): %s\n", $ii, join(", ", map { "$_ ($cnt{$_})" } @toplong));
   
    my $tops = join(",", sort(@top)); # sort because order in @top doesn't matter 
    if ($tops ne $topsp)
    {
        $stable = 0;
        say "-" x 30;
    }

    $stable++;
    $topsp = $tops;
    
}


for my $e (@top)
{
    my ($v,$w) = split/:/, $e; 
    $g->delete_edge($v,$w);
#   $g->delete_edge(split/:/);
}


my @cc = $g->connected_components();
printf "%s = %d\n", join(" x ", map { scalar(@$_) } @cc), product(map { scalar(@$_) } @cc);

