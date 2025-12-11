#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations combinations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = read_file(\*STDIN, chomp => 1);

my $t;
for (@l)
{
    die unless /(.*):\s+(.*)/;
    my $f = $1;
    my @d = split/\s+/, $2;
    for (@d)
    {
        $t->{$f}->{$_} = 1;
    }
}

my $gcache;
sub g($node, $finish, $start = 0)
{
    $gcache = undef if $start == 1;

    return 1 if $node eq $finish;

    my $vs = 0;
    for my $k (keys %{$t->{$node}})
    {
        $vs += $gcache->{$k} // g($k, $finish);
    }

    return $gcache->{$node} = $vs;
}

say "Stage 1: ", g('you', 'out', 1);
say "Stage 2: ",
    g('svr', 'dac', 1) * g('dac', 'fft', 1) * g('fft', 'out', 1) +
    g('svr', 'fft', 1) * g('fft', 'dac', 1) * g('dac', 'out', 1);

