#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Digest::MD5 qw(md5 md5_hex md5_base64);

sub submod($$$)
{
    my ($a, $b, $m) = @_;
    return ($a % $m - $b % $m) % $m;
}

# input:
# 464 players; last marble is worth 71730 points
my $PLR = 464;
my $LASTM = 71730 * 100;


my @h = (0);
my $cnt = 1;

my $score;

my $i = 1; # marble
my $p = 0; # player
my $cm = 0; # current marble pos
while ($i <= $LASTM)
{
    if ($i % 23 == 0)
    {
        my $mm7 = ($cm - 7) % $cnt;
        my $bonus = $i + $h[$mm7];
        $score->{$p+1} += $bonus;
        $cm = $mm7;
        splice(@h, $cm, 1);
        $cnt--;
    }
    else # standard case
    {
        $cm = (($cm + 1) % $cnt) + 1; # to handle adding behind the end
        splice(@h, $cm, 0, $i);
        $cnt++;
    }

    $i++;
    $p = ($p + 1) % $PLR;

    printf("%8d max=%d\n", $i, max(values(%$score))) if rand() < 0.001;
}
printf("stage 1: %d\n", max(values(%$score)));
