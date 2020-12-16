#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my $stage1 = 0;
my $stage2 = 0;

my %props;
while (<>)
{
    last if /^\s*$/;

    # departure location: 25-568 or 594-957
    die unless m/(.*):\s+(\d+)-(\d+) or (\d+)-(\d+)/;
    my %h;
    $h{a} = $2;
    $h{b} = $3;
    $h{c} = $4;
    $h{d} = $5;

    $props{$1} = \%h;
}

for my $p (keys %props) # "valid for" hash
{
    for my $k (0..scalar(keys(%props))-1)
    {
        $props{$p}->{vf}->{$k} = 1;
    }
}

<>;
$_ = <>;
chomp;
my @xt = split/,/; # your ticket

<>;
<>;

my @tickets;
while (<>)
{
    chomp;
    my @t = split/,/;
    V: for my $v (@t)
    {
        for my $p (keys %props)
        {
            my $pp = $props{$p};
            next V if ($v >= $pp->{a} && $v <= $pp->{b}) || ($v >= $pp->{c} && $v <= $pp->{d});
        }

        $stage1 += $v;
        # print "invalid value: $v\n";
    }
    push(@tickets, \@t);
}

print "stage 1: $stage1\n";


my @validtickets;
XW: for my $t (@tickets)
{
    my $i = 0;
    V: for my $v (@$t)
    {
        my $valid = 0;
        for my $p (keys %props)
        {
            my $pp = $props{$p};
            if (($v >= $pp->{a} && $v <= $pp->{b}) || ($v >= $pp->{c} && $v <= $pp->{d}))
            {
                $valid = 1;
            }
        }

        next XW unless $valid; # skip invalid ticket
        $i++;
    }

    push(@validtickets, $t);
}

for my $t (@validtickets) # update "valid for" flags
{
    my $i = 0;
    for my $v (@$t)
    {
        for my $p (keys %props)
        {
            my $pp = $props{$p};
            delete $pp->{vf}->{$i} if $v < $pp->{a} || ($v > $pp->{b} && $v < $pp->{c}) || $v > $pp->{d};
        }

        $i++;
    }
}

my %asg = (); # assign field name to index
W: while (%props)
{
    for my $p (keys %props)
    {
        my $pp = $props{$p};
        next unless scalar(%{$pp->{vf}}) == 1;

        $asg{$p} = (keys(%{$pp->{vf}}))[0];

        delete $props{$p};
        for my $q (keys %props)
        {
            my $qq = $props{$q};
            delete $qq->{vf}->{$asg{$p}};
        }

        next W;
    }
}

$stage2 = 1;
for my $a (keys %asg)
{
    next unless $a =~ /^departure/;
    $stage2 *= $xt[$asg{$a}];
}

print "stage 2: $stage2\n";