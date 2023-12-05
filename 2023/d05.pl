#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);
my @seeds = (shift(@f) =~ /(\d+)/g);

my @labels;
my $m;
my $label;
for (@f)
{
    if (/(.*) map:/)
    {
        push(@labels, $label = $1);
        next;
    }

    if (/(\d+)\s+(\d+)\s+(\d+)/) # destination src-begin src-end
    {
        my $h = undef;
        $h->{b} = $2;
        $h->{e} = $2 + $3 - 1;
        $h->{d} = $1 - $2; # offset
        push(@{$m->{$label}}, $h);
    }
}

### stage 1

my @seeds1 = @seeds;
for my $label (@labels)
{
    S: for my $s (@seeds1)
    {
        for my $r (@{$m->{$label}})
        {
            if ($s >= $r->{b} && $s <= $r->{e})
            {
                $s += $r->{d};
                next S;
            }
        }
    }
}
my $stage1 = min(@seeds1);

### stage 2

my @ranges = ();
for my $p (pairs @seeds)
{
    my $r = undef;
    $r->{b} = $p->[0];
    $r->{e} = $p->[0] + $p->[1] - 1;
    push(@ranges, $r);
}

T: for my $label (@labels)
{
    my @newranges = ();

    R: while (my $range = shift @ranges)
    {
        my $xfered = 0;
        for my $r (@{$m->{$label}})
        {
            next if $r->{b} > $range->{e};
            next if $r->{e} < $range->{b};

            $xfered = 1;
            my $xr = undef;
            $xr->{b} = max($range->{b}, $r->{b});
            $xr->{e} = min($range->{e}, $r->{e});
            $xr->{b} += $r->{d};
            $xr->{e} += $r->{d};
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

        push(@newranges, $range) unless $xfered; # nothing transformed, copy range as-is
    }

    @ranges = @newranges;
}

my $stage2 = min(map { $_->{b} } @ranges);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;