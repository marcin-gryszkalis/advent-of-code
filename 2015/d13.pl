#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
# @f = map { chomp; int $_ } @f;

for my $stage (1..2)
{
    my $h;
    for (@f)
    {
        chomp;
        # Alice would gain 54 happiness units by sitting next to Bob.
        if (m/(\S+) would (gain|lose) (\d+).*\s+(\S+)\./)
        {
            $h->{$1}->{$4} = $2 eq 'gain' ? $3 : -$3;
        }
    }

    my @guests = keys %$h;

    if ($stage == 2)
    {
        for my $g (@guests)
        {
            $h->{$g}->{Santa} = 0;
            $h->{Santa}->{$g} = 0;
        }
        push(@guests, 'Santa');
    }

    #print Dumper $h; exit;
    my $c = scalar @guests;

    my $best = 0;
    my $it = permutations(\@guests);
    while (my $p = $it->next)
    {
        my $s = 0;
        for my $i (0..$c-1)
        {
            my $j = ($i + 1) % $c;
            my $hap1 = $h->{$p->[$i]}->{$p->[$j]};
            my $hap2 = $h->{$p->[$j]}->{$p->[$i]};
            $s += ($hap1 + $hap2);
        }

        if ($s > $best)
        {
            $best = $s;
            print join(" ", @$p)." = $s\n";
        }
    }

    print "stage $stage: $best\n";
}