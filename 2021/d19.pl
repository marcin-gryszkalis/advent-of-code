#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations variations_with_repetition);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $h;

my $sc;
for (@f)
{
    next if /^\s*$/;
    if (/scanner (\d+)/) { $sc = $1; next }
    my @a = /[\d-]+/g;
    push(@{$h->{$sc}}, \@a);
}

my $maxs = $sc;

my @xform;
my $itv = variations_with_repetition([-1,1], 3);
while (my $v = $itv->next)
{
    my $itp = permutations([0,1,2]);
    while (my $p = $itp->next)
    {
        # without optimization below we'd have 48 transformations (instead of 24 valid)
        # the other 24 is reachable only by single symmetry ("mirror")
        # https://en.wikipedia.org/wiki/Chirality_(mathematics)

        # if I'd generate permutations by swaping https://rosettacode.org/wiki/Permutations_by_swapping
        # then I could skip odd/even ones (depending on product(@$v) == -1)

        my $x = 0; # number of changes - it must be even to stay on right side of the mirror
        my $pj = join("", @$p);
        $x+=0 if $pj =~ /(012)/; # identity
        $x+=1 if $pj =~ /(021|210|102)/; # 1 swap (1 element in place)
        $x+=2 if $pj =~ /(120|201)/; # 2 swaps (no element in place)
        $x++ if $v->[0] < 0;
        $x++ if $v->[1] < 0;
        $x++ if $v->[2] < 0;
        next if $x%2 == 1;

        push(@xform, [@$p,@$v]);
    }
}

$; = ",";
my $m; # map

# scanner no 0
for my $r (@{$h->{0}})
{
    $m->{$r->[0],$r->[1],$r->[2]} = 1;
}

my %done;
$done{0} = 1;

my %scpos;
$scpos{0} = [0,0,0];

while (1)
{
    SCANNER: for my $i (1..$maxs)
    {
        next if $done{$i};

        my $c = $h->{$i};

        for my $x (@xform) # all transforms
        {
            my $d;
            for my $r (@$c)
            {
                my @a = (
                    $r->[$x->[0]] * ($x->[3]),
                    $r->[$x->[1]] * ($x->[4]),
                    $r->[$x->[2]] * ($x->[5]),
                    );
                push @$d, \@a;
            }

            for my $p (keys %$m) # for every point on  map
            {
                my @pp = split/$;/,$p;

                for my $dp (@$d) # end every point on transformed scanner d
                {
                    my @move = (
                        $pp[0] - $dp->[0],
                        $pp[1] - $dp->[1],
                        $pp[2] - $dp->[2],
                        );

                    my $cnt = 0;
                    for my $vp (@$d) # verify others
                    {
                        $cnt++ if exists $m->{$vp->[0]+$move[0],$vp->[1]+$move[1],$vp->[2]+$move[2]};

                        if ($cnt == 12)
                        {
                            printf "match: $i xform(%s) move(%s)\n",join(" ",@$x),join(" ",@move);

                            for my $r (@$d)
                            {
                                $m->{$r->[0]+$move[0],$r->[1]+$move[1],$r->[2]+$move[2]} = 1;
                            }

                            $scpos{$i} = \@move;
                            $done{$i} = 1;

                            next SCANNER;
                        }
                    }

                }

            }

        }
    }

    last if scalar(keys %done) == $maxs+1;
}

$stage1 = scalar(keys %$m);

my $it = combinations([values(%scpos)], 2);
while (my $pos = $it->next)
{
    $stage2 = max(
        $stage2,
        abs($pos->[0]->[0] - $pos->[1]->[0]) +
        abs($pos->[0]->[1] - $pos->[1]->[1]) +
        abs($pos->[0]->[2] - $pos->[1]->[2])
        );
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
