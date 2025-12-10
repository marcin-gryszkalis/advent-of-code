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

my $stage2 = 0;
my $stage1 = 0;

my @l = read_file(\*STDIN, chomp => 1);

my $buttons;
my $lights;
my $jolts;
my $i = 0;
for (@l)
{
    die unless /\[(.*)\]\s+(.*)\s+\{(.*)\}/;
    my $lg = $1;
    my $bs = $2;
    my $jl = $3;

    $lg =~ tr/.#/01/;
    $lights->[$i] = $lg;

    $jolts->[$i] = [split/,/,$jl];

    for my $b ($bs =~ /\(([\d\,]+)\)/g)
    {
        say "b=$b";
        push(@{$buttons->[$i]}, [split(/,/, $b)]);
    }
    $i++;
}

L: for my $i (0..$#l)
{
    my @but = @{$buttons->[$i]};

    for my $k (1..$#but)
    {
        my $ic = combinations(\@but, $k);
        while (my $p = $ic->next)
        {
            my @tlight = (0) x length($lights->[$i]);

            for my $pp (@$p)
            {
                for my $m (@$pp)
                {
                    $tlight[$m] = 1 - $tlight[$m];
                }
            }

#            say "$i $k: ".join("", @tlight).' '.join("", @light);
            if (join("", @tlight) eq $lights->[$i])
            {
                say "min $i = $k / $#but";
                $stage1 += $k;
                next L;
            }
        }

    }
}

say "Stage 1: ", $stage1;

L2: for my $i (0..$#l)
{
    my @but = @{$buttons->[$i]};

    my @sj = (0) x scalar(@{$jolts->[$i]});

    for my $k (1..50)
    {
        say "$i $k";
        my $ic = combinations_with_repetition(\@but, $k);
        C: while (my $p = $ic->next)
        {
            my @tjolts = @sj;

            for my $pp (@$p)
            {
                for my $m (@$pp)
                {
                    $tjolts[$m]++;
                    next C if $tjolts[$m] > $jolts->[$i]->[$m];
                }
            }

            #say "$i $k: ".join(",", @tjolts).' <=> '.join(",", @{$jolts->[$i]});
            if (join(",", @tjolts) eq join(",", @{$jolts->[$i]}))
            {
                say "min $i = $k / $#but";
                $stage2 += $k;
                next L2;
            }
        }

    }

    die "not found";
}

say "Stage 2: ", $stage2;
