#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my $DEBUG = 0;

my @f = read_file(\*STDIN, chomp => 1);

sub cube
{
    my $q = shift;
    return "($q->{x1},$q->{x2})-($q->{y1},$q->{y2})-($q->{z1},$q->{z2})";
}

for my $stage (1..2)
{
    my @qq = (); # list of non-overlaping cubes

    my $i = 1;
    Q: for (@f)
    {
        next unless /^(on|off)/;
        my $mode = $1;
        my ($x1,$x2,$y1,$y2,$z1,$z2) = /[\d-]+/g;

        my $p;
        $p->{x1} = $x1; $p->{x2} = $x2;
        $p->{y1} = $y1; $p->{y2} = $y2;
        $p->{z1} = $z1; $p->{z2} = $z2;

        next if $stage == 1 && any { abs($_) > 50 } values %$p;

        printf("%4d: START %s\n", $i++, cube($p)) if $DEBUG;
        printf("QQ(%d)\n", scalar(@qq)) if $DEBUG;

        my @nq = ();
        QQ: while (my $q = pop(@qq))
        {
            # no overlap
            if (
                $p->{x2} < $q->{x1} || $p->{x1} > $q->{x2} ||
                $p->{y2} < $q->{y1} || $p->{y1} > $q->{y2} ||
                $p->{z2} < $q->{z1} || $p->{z1} > $q->{z2})
            {
                printf("No Overlap Q (%s)\n", cube($q)) if $DEBUG;
                push(@nq, $q);
                next QQ;
            }

            if ($mode eq 'on') # for off we need to split
            {
                # p in q - it can be only in one q (because q contains only non-overlapping cuboids)
                if (
                    $p->{x1} >= $q->{x1} && $p->{x2} <= $q->{x2} &&
                    $p->{y1} >= $q->{y1} && $p->{y2} <= $q->{y2} &&
                    $p->{z1} >= $q->{z1} && $p->{z2} <= $q->{z2})
                {
                    # p lost in q
                    printf("P in Q (%s)\n", cube($q)) if $DEBUG;
                    push(@qq, $q, @nq);
                    next Q;
                }
            }

            # q inside p
            if (
                $q->{x1} >= $p->{x1} && $q->{x2} <= $p->{x2} &&
                $q->{y1} >= $p->{y1} && $q->{y2} <= $p->{y2} &&
                $q->{z1} >= $p->{z1} && $q->{z2} <= $p->{z2})
            {
                # q lost in p, but p may overlap with others!
                # forget about q!
                printf("Q in P, Lost Q (%s)\n", cube($q)) if $DEBUG;
                next QQ;
            }

            # partial overlap

            # in 1D we can split into 2 areas + splitting cube (p)
            # in 2D we can split into 4 areas
            # in 3D - 6 areas
            # we'll put common part of q and every of the 6 areas ino @nq (it will be cuboid too)
            # the areas are:
            # - 2 half-spaces above/below p, infinite in all directions
            # - 2 on left/right - height(x) = height of p, infinite width(y), infinite depth(z),
            # - 2 on front/back - height(x) = height of p, width(y) = width of p, infinite depth(z)
            # assume: values are growing to bottom, right, front

            if ($q->{x1} < $p->{x1}) # top
            {
                my %n = %$q;

                $n{x2} = $p->{x1} - 1;

                printf("+top(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }

            if ($q->{x2} > $p->{x2}) # bottom
            {
                my %n = %$q;

                $n{x1} = $p->{x2} + 1;

                printf("+bottom(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }

            if ($q->{y1} < $p->{y1}) # left
            {
                my %n = %$q;

                $n{y2} = $p->{y1} - 1;
                $n{x1} = max($q->{x1},$p->{x1});
                $n{x2} = min($q->{x2},$p->{x2});

                printf("+left(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }

            if ($q->{y2} > $p->{y2}) # right
            {
                my %n = %$q;

                $n{y1} = $p->{y2} + 1;
                $n{x1} = max($q->{x1},$p->{x1});
                $n{x2} = min($q->{x2},$p->{x2});

                printf("+right(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }

            if ($q->{z1} < $p->{z1}) # back
            {
                my %n = %$q;

                $n{z2} = $p->{z1} - 1;
                $n{x1} = max($q->{x1},$p->{x1});
                $n{x2} = min($q->{x2},$p->{x2});
                $n{y1} = max($q->{y1},$p->{y1});
                $n{y2} = min($q->{y2},$p->{y2});

                printf("+back(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }

            if ($q->{z2} > $p->{z2}) # front
            {
                my %n = %$q;

                $n{z1} = $p->{z2} + 1;
                $n{x1} = max($q->{x1},$p->{x1});
                $n{x2} = min($q->{x2},$p->{x2});
                $n{y1} = max($q->{y1},$p->{y1});
                $n{y2} = min($q->{y2},$p->{y2});

                printf("+front(%s)\n", cube(\%n)) if $DEBUG;
                push(@nq, \%n);
            }


        } # QQ

        # p got cut off the space, now we need to add it back if mode is "on" (and do nothing if mode is "off")
        if ($mode eq 'on')
        {
            printf("ADD P (%s)\n", cube($p)) if $DEBUG;
            push(@nq, $p); #
        }

        @qq = @nq;

    } # Q

    my $sum = 0;
    for my $q (@qq)
    {
        my $a =
            ($q->{x2} - $q->{x1} + 1) *
            ($q->{y2} - $q->{y1} + 1) *
            ($q->{z2} - $q->{z1} + 1);
        printf("sum: %s = %s\n", cube($q), $a) if $DEBUG;
        $sum += $a;
    }

    printf "Stage %s: %s\n", $stage, $sum;

}
