#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Set::IntSpan qw(grep_set map_set grep_spans map_spans);
BEGIN { $Set::IntSpan::integer = 1 }
$; = ',';

sub setspec($a,$b) { "$a-$b" }
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
        $h->{d} = $1 - $2; # transformation offset
        $h->{s} = new Set::IntSpan(setspec($2, $2 + $3 - 1));
        push(@{$m->{$label}}, $h);
    }
}

### stage 1

my @seeds1 = @seeds;
for my $s (@seeds1)
{
    T: for my $label (@labels)
    {
        for my $r (@{$m->{$label}})
        {
            if ($r->{s}->member($s))
            {
                $s += $r->{d};
                next T;
            }
        }
    }
}
my $stage1 = min(@seeds1);

### stage 2

my @ranges = ();
for my $pair (pairs @seeds)
{
    push(@ranges, new Set::IntSpan(setspec($pair->[0], $pair->[0] + $pair->[1] - 1)));
}

for my $label (@labels)
{
    my @newranges = ();

    R: while (my $range = shift @ranges)
    {
        my $xfered = 0;
        for my $t (@{$m->{$label}})
        {
            my $xr = $t->{s}->intersect($range);
            next if $xr->empty;

            $xfered = 1;
            push(@newranges, new Set::IntSpan(setspec($xr->min + $t->{d}, $xr->max + $t->{d})));

            my @nr = $range->diff($t->{s})->sets(); # diff can give 0, 1 or 2 spans
            push(@ranges, @nr) if @nr;
            next R;
        }

        push(@newranges, $range) unless $xfered; # nothing transformed, copy range as-is
    }

    @ranges = @newranges;
}

my $stage2 = min(map { $_->min } @ranges);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
