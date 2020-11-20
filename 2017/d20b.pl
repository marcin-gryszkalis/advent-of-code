#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $gpu;
my $pi = 0;
while (<>)
{
    chomp;

    my $h;
    s/[^\d-]+/ /g;
    s/^\s+//;
    my @a = split/\s+/;
    my $i = 0;
    for my $e (qw/p v a/)
    {
        for my $ax (qw/x y z/)
        {
            $h->{$e}->{$ax} = $a[$i++];
        }
    }

    $gpu->{$pi++} = $h;
}

my $pkk = scalar keys %$gpu;
my $i = 0;
while (1)
{
    my %collision = ();
    for my $pk (keys %$gpu)
    {
        my $p = $gpu->{$pk};

        my $dist = 0;
        for my $ax (qw/x y z/)
        {
            $p->{v}->{$ax} += $p->{a}->{$ax};
            $p->{p}->{$ax} += $p->{v}->{$ax};
        }

        my $k = join(":", $p->{p}->{x}, $p->{p}->{y}, $p->{p}->{z});

        if (exists $collision{$k})
        {
            delete $gpu->{$collision{$k}} if exists $gpu->{$collision{$k}};
            delete $gpu->{$pk};
        }
        $collision{$k} = $pk;
    }

    my $kk = scalar keys %$gpu;
    if ($kk < $pkk)
    {
        print "$i $kk\n";
        $pkk = $kk;
    }

    $i++;
}