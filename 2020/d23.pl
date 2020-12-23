#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my $startx = "598162734";
#test case:
#$startx = "389125467";

my @a = split//, $startx;

my @moves_ps = (100, 10_000_000);
my @add_ps = (0, 1_000_000);

for my $stage (0..1)
{
    my $moves = $moves_ps[$stage];
    my $add = $add_ps[$stage];

    my $minv = 1;
    my $maxv = max(@a);

    my %qs = (); # quick search ;)

    my $start = { v => $a[0], nxt => undef };
    $qs{$a[0]} = $start;

    my $p = $start;
    my $cm;
    for ((@a[1..$#a], $maxv+1..$add))
    {
        $cm = { v => $_, nxt => undef };
        $p->{nxt} = $cm;

        $qs{$_} = $cm;

        $p = $cm;
    }

    $maxv = max($maxv,$add);

    $cm->{nxt} = $start; # close the cycle

    $cm = $start;
    for my $round (1..$moves)
    {
        my $a1 = $cm->{nxt};
        my $a2 = $cm->{nxt}->{nxt};
        my $a3 = $cm->{nxt}->{nxt}->{nxt};

        $cm->{nxt} = $a3->{nxt}; # cut

        my $dest = $cm->{v};
        while (1)
        {
            $dest--;
            $dest = $maxv if $dest < $minv;
            last if $dest != $a1->{v} && $dest != $a2->{v} && $dest != $a3->{v};
        }

        my $k = $qs{$dest}->{nxt}; # paste
        $qs{$dest}->{nxt} = $a1;
        $a3->{nxt} = $k;

        $cm = $cm->{nxt};
    }

    $cm = $qs{1};

    if ($stage == 0)
    {
        my $stage1 = '';
        for ($minv..$maxv-1)
        {
            $cm = $cm->{nxt};
            $stage1 .= $cm->{v};
        }

        print "stage 1: $stage1\n";
    }
    else
    {
        my $v1 = $cm->{nxt}->{v};
        my $v2 = $cm->{nxt}->{nxt}->{v};
        printf "stage 2: %d x %d = %d\n", $v1, $v2, $v1*$v2;
    }

}
