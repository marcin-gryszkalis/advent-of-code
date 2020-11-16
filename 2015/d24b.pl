#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $pcnt = scalar @f;
my $total = sum(@f);
my $gw = $total / 4;

# 1st group can be the size from 1 to (pcnt / 4)
my $found = 0;
my @fnd;
my $bestqe = product(@f); # best valid! qe
for my $gs (1..$pcnt/4)
{
    my $kit = combinations(\@f, $gs);
    KIT: while (my $k = $kit->next)
    {
        next unless sum(@$k) == $gw;

        my $qe = product(@$k);
        next unless $qe < $bestqe;

        my %h = map { $_ => 1 } @f;

        for my $r (@$k)
        {
            delete $h{$r};
        }

        my @r1 = keys %h; # nodes without g1

        for my $g2s (1..$pcnt/4)
        {
            my $k2it = combinations(\@r1, $g2s);

            while (my $k2 = $k2it->next)
            {
                next unless sum(@$k2) == $gw;

                my %h = map { $_ => 1 } @r1;

                for my $r (@$k2)
                {
                    delete $h{$r};
                }

                my @r2 = keys %h; # nodes without g1 and g2

                for my $g3s (1..$pcnt/4)
                {
                    my $k3it = combinations(\@r2, $g3s);
                    while (my $k3 = $k3it->next)
                    {
                        next unless sum(@$k3) == $gw;

                        my %h = map { $_ => 1 } @r2;

                        for my $r (@$k3)
                        {
                            delete $h{$r};
                        }

                        my @r3 = keys %h; # nodes without g1, g2 and g3

                        next unless sum(@r3) == $gw;

                        $found = 1;
                        $bestqe = $qe;

                        printf("g1:%s (qe:%d) g2:%s g3:%s g4:%s\n", join(",", @$k), $qe, join(",", @$k2), join(",", @$k3), join(",", @r3));

                        my @gf = @$k;
                        push(@fnd, \@gf);

                        next KIT;
                    }
                }
            }
        }
    }

    last if $found;
}

my @fnds = sort { product(@$b) <=> product(@$a) } @fnd;
my $g = $fnds[0];

printf "stage 2: %s -- QE: %d\n", join(",", @$g), product(@$g);
