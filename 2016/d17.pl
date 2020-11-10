#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

use Digest::MD5 qw(md5 md5_hex md5_base64);

my $passcode = "qzthpkfp";

# If your passcode were ihgpwlah, the shortest path would be DDRRRD, the longest path would take 370 steps.
# $passcode = "ihgpwlah";

my @dl = qw/U D L R/;
my @dx = qw/0 0 -1 1/;
my @dy = qw/-1 1 0 0/;

my $best = 0;
L: for my $stage (1..2)
{
    my @bfs = (); # queue

    my @step = (0, 0, $passcode);
    push(@bfs, \@step);

    while (my $s = shift(@bfs))
    {
        my ($x, $y, $pass) = @$s;
        next if $x < 0 || $x > 3 || $y < 0 || $y > 3;

        if ($x == 3 && $y == 3)
        {
            my $path = substr($pass, length($passcode));
            if ($stage == 1)
            {
                printf "stage 1: %s\n", $path;
                next L;
            }

            $best = length($path) if length($path) > $best;
            next;
        }

        my $dh = md5_hex($pass);
        for my $i (0..3)
        {
            my $d = substr($dh, $i, 1);
            next unless $d =~ /[bcdef]/; # b, c, d, e, or f - open
            my $nx = $x + $dx[$i];
            my $ny = $y + $dy[$i];

            my @newstep = ($nx, $ny, $pass.$dl[$i]);
            push(@bfs, \@newstep);
        }
    }
}

printf "stage 2: %d\n", $best;