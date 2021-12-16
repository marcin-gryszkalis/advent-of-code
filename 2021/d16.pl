#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use bigint;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

sub bin
{
    return oct("0b".shift);
}

my $bits;
my $offset;

sub get($)
{
    die if $offset > length $bits;
    my $len = shift;
    my $s = substr($bits, $offset, $len);
#     print "$offset: get($len) = $s\n";
    $offset += $len;

    return $s;
}

sub getnum($)
{
    return bin(get(shift));
}

sub packet
{
    my $v = getnum(3);
    my $t = getnum(3);

    $stage1 += $v;

    if ($t == 4) # literal value
    {
        my $q;
        while (1)
        {
            my $px = getnum(1);
            $q .= get(4);
            last if $px == 0;
        }
        return bin($q);
    }

    # operators
    my @a = ();

    my $ltid = getnum(1);
    if ($ltid == 0)
    {
        my $subl = getnum(15);
        my $soff = $offset;
        push(@a, packet()) while ($offset < $soff + $subl)
    }
    else # ($ltid == 1)
    {
        my $subc = getnum(11);
        push(@a, packet()) for (1..$subc);
    }

    my $r;
    if ($t == 0) { $r = sum(@a); }
    elsif ($t == 1) { $r = product(@a) }
    elsif ($t == 2) { $r = min(@a) }
    elsif ($t == 3) { $r = max(@a) }
    elsif ($t == 5) { $r = ($a[0] > $a[1] ? 1 : 0) }
    elsif ($t == 6) { $r = ($a[0] < $a[1] ? 1 : 0) }
    elsif ($t == 7) { $r = ($a[0] == $a[1] ? 1 : 0) }
    else { die }

    return $r;
}

my $i = 0;
for (@f)
{
    my $hex = $_;
    printf "Entry %d: %s\n", $i, $hex;

    s/(..)/sprintf("%08b",hex($1))/eg;

    $bits = $_;
    $offset = 0;

    $stage1 = 0;
    $stage2 = packet();

    printf "Entry %d, Stage 1: %s\n", $i, $stage1;
    printf "Entry %d, Stage 2: %s\n\n", $i++, $stage2;
}

