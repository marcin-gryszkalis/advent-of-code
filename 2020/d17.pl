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
my $M = $ROUNDS+2;
my $N = 2*$M + $W - 2;

$; = ','; # $h{1,2,3}

for my $stage (0..1)
{
    my %mm;

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
                $mm{join($;,@l)} = $e;

                my $d = 0;
                for my $v (@l)
                {
                    $rangemin = $v if $v < $rangemin;
                    $rangemax = $v if $v > $rangemax;
                    $d++;
                }
            }
            $x++;
        }
        $y++;
    }

    my $m = \%mm;
    for my $round (1..$ROUNDS)
    {
        printf "round: %d (hypercube %d ^ %d)\n", $round, ($rangemax-$rangemin+1+2), $DIMENSIONS[$stage];

        my $m2 = clone($m);

        my $dit = variations_with_repetition([$rangemin-1..$rangemax+1], $DIMENSIONS[$stage]);
        while (my $dim = $dit->next)
        {
            my $s = 0;
            my $ddit = variations_with_repetition([-1,0,1], $DIMENSIONS[$stage]);
            while (my $ddim = $ddit->next)
            {
                next if all { $_ == 0 } @$ddim;
                my @l = map { $ddim->[$_] + $dim->[$_] } (0..$DIMENSIONS[$stage]-1);
                $s++ if exists $m->{join($;,@l)};
            }

            my $e = join($;,@$dim);
            if ((exists $m->{$e} && $s >= 2 && $s <= 3) || (!exists $m->{$e} && $s == 3))
            {
                $m2->{$e} = '#';

                my $d = 0;
                for my $v (@$dim)
                {
                    $rangemin = $v if $v < $rangemin;
                    $rangemax = $v if $v > $rangemax;
                    $d++;
                }

            }
            else
            {
                delete $m2->{$e};
            }

        }

        $m = clone($m2);
    }

    printf "stage %d: %d\n", $stage+1, scalar %$m;
}