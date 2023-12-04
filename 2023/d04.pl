#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %cnt = map { $_ => 1 } (1..scalar(@f));

for (@f)
{
    my ($cid, $r1, $r2) = m/Card\s+(\d+): (.*)\|(.*)/g;

    my %win = map { $_ => 1 } ($r1 =~ /(\d+)/g);
    my @myc = ($r2 =~ /(\d+)/g);
    my $p = scalar(grep { exists $win{$_} } @myc);
    next unless $p;

    $stage1 += (2 ** ($p - 1));

    for my $ii ($cid+1 .. $cid+min(scalar @f, $p))
    {
        $cnt{$ii} += $cnt{$cid};
    }

}

$stage2 = sum(values %cnt);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;