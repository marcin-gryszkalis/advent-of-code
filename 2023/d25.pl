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
use Graph::Undirected;
$; = ',';

# it's possible to do this for all vertex pairs (~1000^2) but usually gives proper answer after 1000-2000 random selections
my $STABLE_TOP_LIMIT = 500;

my $g = Graph::Undirected->new();
my @f = read_file(\*STDIN, chomp => 1);

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

    slide { $cnt{join(":",minmaxstr($a,$b))}++ } @path;

    my @toplong = head(6, sort { $cnt{$b} <=> $cnt{$a} } keys %cnt);
    @top = head(3, @toplong);
    printf("%5d ($stable): %s\n", $ii, join(", ", map { "$_ ($cnt{$_})" } @toplong));

    my $tops = join(",", sort(@top)); # sort because order in @top doesn't matter
    $stable = 0 if $tops ne $topsp;
    $stable++;
    $topsp = $tops;
}

for (@top)
{
    my ($v,$w) = split/:/;
    $g->delete_edge($v,$w);
}

my @cc = $g->connected_components();
printf "Stage1: %s = %d\n", join(" x ", map { scalar(@$_) } @cc), product(map { scalar(@$_) } @cc);
