#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;
my @ranges;

L: for (@l)
{
    if (/(\d+)-(\d+)/)
    {
        my %r;
        $r{l} = $1;
        $r{r} = $2;
        push(@ranges, \%r);
    }
    elsif (/^(\d+)$/)
    {
        for my $r (@ranges)
        {
            if ($1 >= $r->{l} && $_ <= $r->{r})
            {
                $stage1++;
                next L;
            }
        }
    }
}

@ranges = sort { $a->{l} <=> $b->{l} } @ranges;

my @rranges = ();
my $r = shift(@ranges);
while (1)
{
    my $s = shift(@ranges);
    unless (defined $s)
    {
        push(@rranges, $r);
        last;
    }

    if ($s->{l} <= $r->{r}) # overlapping
    {
        $r->{r} = max($s->{r}, $r->{r});
    }
    else
    {
        push(@rranges, $r);
        $r = $s;
    }
}

for my $r (@rranges)
{
    $stage2 += $r->{r} - $r->{l} + 1;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
