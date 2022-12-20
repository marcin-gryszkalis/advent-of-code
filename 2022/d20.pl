#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;
$; = ',';

my @key = qw/1 811589153/;
my @repeat = qw/1 10/;

my @f = read_file(\*STDIN, chomp => 1);
my $l = scalar(@f);

for my $stage (0..1)
{
    # array ot references to original elements (original indexes)
    my @ot;

    # create dual-linked circular list
    my $b = undef;
    for (@f)
    {
        my $x = { v => $_ * $key[$stage], p => undef, n => undef };
        if (defined $b)
        {
            $x->{p} = $b;
            $x->{p}{n} = $x
        }
        push(@ot, $x);
        $b = $x;
    }

    my $start = $ot[0];

    # connect ends
    $b->{n} = $ot[0];
    $start->{p} = $b;

    for my $r (1..$repeat[$stage])
    {
        while (my ($i,$x) = each @ot)
        {
            my $v = $x->{v};
            next if $v == 0;

            my $vv = abs($v) % ($l - 1);
            next if $vv == 0;

            # remove $x
            $x->{p}{n} = $x->{n};
            $x->{n}{p} = $x->{p};

            # find destination
            # when going forward I place it AFTER pos found
            # when going backward I place it BEFORE pos found, so do I step more and place if AFTER
            $vv++ if $v < 0;

            my $d = $x;
            for (1..$vv) { $d = $d->{$v > 0 ? "n" : "p"} }

            # insert at new place
            $x->{p} = $d;
            $x->{n} = $d->{n};
            $d->{n}{p} = $x;
            $d->{n} = $x;
        }
    }


    my @q = ();
    my $xp = $start;
    for (0..$l-1)
    {
        push(@q, $xp->{v});
        $xp = $xp->{n};
    }

    my $zat = first { $q[$_] == 0  } 0..$#q;

    printf "Stage %d: %s\n", $stage+1,
        $q[($zat + 1000) % $l] +
        $q[($zat + 2000) % $l] +
        $q[($zat + 3000) % $l];
}
