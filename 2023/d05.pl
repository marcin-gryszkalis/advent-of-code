#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 9999999999;
my $stage2 = 9999999999;

my @t = qw/seed soil fertilizer water light temperature humidity location/;

my @seeds = (shift(@f) =~ /(\d+)/g);

my $m;
my $label;
for (@f)
{
    if (/(.*) map:/)
    {
        $label = $1;
        next;
    }

    if (/(\d+)\s+(\d+)\s+(\d+)/) # destination src-begin src-end
    {
        my $h = undef;
        $h->{b} = $2;
        $h->{e} = $2 + $3 - 1;
        $h->{d} = $1;
        push(@{$m->{$label}}, $h);

        next;
    }
}

for my $s (@{clone(\@seeds)})
{
    T: for my $i (0..scalar(@t)-2)
    {
        my $l0 = $t[$i];
        my $l1 = $t[$i+1];

        for my $r (@{$m->{"$l0-to-$l1"}})
        {
            if ($s >= $r->{b} && $s <= $r->{e})
            {
                $s = $r->{d} + $s - $r->{b};
                next T;
            }
        }
    }

    $stage1 = min($s, $stage1);
}


my @ranges = ();
while (my $s0 = shift @seeds)
{
    my $s1 = shift @seeds;

    my $r = undef;
    $r->{b} = $s0;
    $r->{e} = $s0 + $s1 - 1;

    push(@ranges, $r);
}


T: for my $i (0..scalar(@t)-2)
{
    my $l0 = $t[$i];
    my $l1 = $t[$i+1];

    my @newranges = ();

    R: while (my $range = shift @ranges)
    {
#        print "$i r: ($range->{b} - $range->{e})\n";

        my $xfered = 0;
        for my $r (@{$m->{"$l0-to-$l1"}})
        {
            next if $r->{b} > $range->{e};
            next if $r->{e} < $range->{b};

            my $xr = undef;
            $xr->{b} = max($range->{b}, $r->{b});
            $xr->{e} = min($range->{e}, $r->{e});
            $xr->{b} = $r->{d} + $xr->{b} - $r->{b};
            $xr->{e} = $r->{d} + $xr->{e} - $r->{b};
            push(@newranges, $xr);

            if ($r->{b} > $range->{b}) # add what's outside of transformation
            {
                my $xr = undef;
                $xr->{b} = $range->{b};
                $xr->{e} = $r->{b} - 1;
                push(@ranges, $xr);
            }

            if ($r->{e} < $range->{e})
            {
                my $xr = undef;
                $xr->{b} = $range->{e};
                $xr->{e} = $r->{e} + 1;
                push(@ranges, $xr);
            }

            next R;
        }

        unless ($xfered) # nothing transformed, copy range as-is
        {
            push(@newranges, $range);
        }
    }

    @ranges = @newranges;
}

for my $range (@ranges)
{
    $stage2 = min($stage2, $range->{b});
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;