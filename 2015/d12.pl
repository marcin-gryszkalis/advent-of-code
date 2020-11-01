#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use JSON;

my $json = <>;
chomp $json;

# test string (stage 1=33, 2=16)
# $json = qq/[[1,2,3],[1,{"c":"red","b":2},3],{"d":"red","e":[1,2,3,4],"f":5},[1,"red",5]]/;

$_ = $json;
my $s = 0;
s/(-?\d+)/$s+=$1/eg;
print "stage 1: $s\n";

# stage 2 probably could be done with regexp with recursive groups
# but we'll do some json walking :)

sub check_hash
{
    my $h = shift;

    # check properties first
    for my $k (keys %$h)
    {
        next unless ref $h->{$k} eq ''; # scalar, not reference
        if ($h->{$k} eq "red")
        {
            return 0;
        }
    }

    # check sub hashes and arrays
    for my $k (keys %$h)
    {
        if (ref $h->{$k} eq 'HASH')
        {
            my $r = check_hash($h->{$k});
            delete $h->{$k} if $r == 0;
        }
        elsif (ref $h->{$k} eq 'ARRAY')
        {
            check_array($h->{$k});
        }
    }

    return 1;
}

sub check_array
{
    my $a = shift;

    for my $i (0..$#$a)
    {
        if (ref $a->[$i] eq 'HASH')
        {
            my $r = check_hash($a->[$i]);
            delete @{$a}[$i] if $r == 0;
        }
        elsif (ref $a->[$i] eq 'ARRAY')
        {
            check_array($a->[$i]);
        }
    }
}

my $j = decode_json $json;
if (ref $j eq 'ARRAY')
{
    check_array($j);
}
else
{
    check_hash($j);
}

$_ = encode_json($j);
$s = 0;
s/(-?\d+)/$s+=$1/eg;
print "stage 2: $s\n";
