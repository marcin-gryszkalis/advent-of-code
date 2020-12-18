#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $stage1 = 0;
my $stage2 = 0;

sub op
{
    return eval(join(" ", @_));
}

sub ev
{
    my $e = shift;

    $e =~ s/\(([^()]+)\)/ev($1)/e while ($e =~ /\(/);
    $e =~ s/(\d+)\s*([\+\*])\s*(\d+)/op($1,$2,$3)/e while ($e =~ /[\*\+]/);

    return $e;
}

sub ev2
{
    my $e = shift;

    $e =~ s/\(([^()]+)\)/ev2($1)/e while ($e =~ /\(/);
    $e =~ s/(\d+)\s*(\+)\s*(\d+)/op($1,$2,$3)/e while ($e =~ /\+/);
    $e =~ s/(\d+)\s*(\*)\s*(\d+)/op($1,$2,$3)/e while ($e =~ /\*/);

    return $e;
}

for (@ff)
{
    $stage1 += ev($_);
    $stage2 += ev2($_);
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";

