#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(variations_with_repetition);
use Clone qw/clone/;

my $ROUNDS = 6;
my @DIMENSIONS = qw/3 4/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my @b;
my $W = length($ff[0]);
my $M = $ROUNDS*2;

$; = ','; # $h{1,2,3}

for my $stage (0..1)
{
    my $m;

    my $middle = int((2*$M + $W) / 2);

    my $rangemin = $middle;
    my $rangemax = $middle;

    my $y = 0;
    for (@ff)
    {
        my $x = 0;
        my @a = split//;
        for my $e (@a)
        {
            my @l = ();
            push(@l, $x+$M);
            push(@l, $y+$M);
            push(@l, ($middle) x ($DIMENSIONS[$stage] - 2));
            if ($e eq '#')
            {
                $m->{join($;,@l)} = 1;

                $rangemin = min(@l,$rangemin);
                $rangemax = max(@l,$rangemax);
            }
            $x++;
        }
        $y++;
    }

    for my $round (1..$ROUNDS)
    {
        printf "round: %d (hypercube %d ^ %d)\n", $round, ($rangemax-$rangemin+1+2), $DIMENSIONS[$stage];

        my $m2 = {};

        my $dit = variations_with_repetition([$rangemin-1..$rangemax+1], $DIMENSIONS[$stage]);
        W: while (my $dim = $dit->next)
        {
            my $s = 0;

            my $ddit = variations_with_repetition([-1,0,1], $DIMENSIONS[$stage]);
            while (my $ddim = $ddit->next)
            {
                next if all { $_ == 0 } @$ddim;
                my @l = map { $ddim->[$_] + $dim->[$_] } (0..$DIMENSIONS[$stage]-1);
                $s++ if exists $m->{join($;,@l)};
                next W if $s > 3; # optimization 8%
            }

            my $e = join($;,@$dim);
            if ((exists $m->{$e} && $s >= 2 && $s <= 3) || (!exists $m->{$e} && $s == 3))
            {
                $m2->{$e} = 1;

                $rangemin = min(@$dim,$rangemin);
                $rangemax = max(@$dim,$rangemax);
            }
        }

        $m = $m2;
    }

    printf "stage %d: %d\n", $stage+1, scalar %$m;
}