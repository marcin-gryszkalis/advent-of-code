#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Digest::MD5 qw(md5 md5_hex md5_base64);

# use List::DoubleLinked; -- not circular, other problems

# input:
# 464 players; last marble is worth 71730 points
my $PLR = 464;

for my $stage (1..2)
{
    my $LASTM = 71730;
    $LASTM *= 100 if $stage == 2;

    my $score = {};

    my $i = 1; # marble
    my $p = 0; # player

    # current marble - simple circular double linked list
    my $cm = { v => 0, prv => undef, nxt => undef };
    $cm->{prv} = $cm;
    $cm->{nxt} = $cm;

    while ($i <= $LASTM)
    {
        if ($i % 23 == 0)
        {
            $score->{$p} += $i;
            for (1..7) { $cm = $cm->{prv} }
            $score->{$p} += $cm->{v};
            $cm->{prv}{nxt} = $cm->{nxt};
            $cm->{nxt}{prv} = $cm->{prv};
            $cm = $cm->{nxt};
        }
        else # standard case
        {
            $cm = $cm->{nxt};
            $cm = { v => $i, prv => $cm, nxt => $cm->{nxt} };
            $cm->{prv}{nxt} = $cm;
            $cm->{nxt}{prv} = $cm;
        }

        $i++;
        $p = ($p + 1) % $PLR;

        # printf("%8d max=%d\n", $i, max(values(%$score))) if rand() < 0.0001;
    }
    printf("stage $stage: %d\n", max(values(%$score)));
}