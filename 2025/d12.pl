#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations combinations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @l = read_file(\*STDIN, chomp => 1);

my $p;
my $size_p;
my $size_full;
while (1)
{
    $_ = shift @l;
    if (/^\d+x\d+/)
    {
        unshift(@l, $_);
        last;
    }

    if (/^(\d+):/)
    {
        my $id = $1;
        my @x = ();
        while (1)
        {
            $_ = shift @l;
            last if $_ eq '';
            push(@x, $_);
        }
        $p->{$id} = \@x;
        my $t = join("", @x);
        $size_full->{$id} = length $t;
        $size_p->{$id} = length($t =~ s/\.//gr);
    }
}

my $stage1 = 0;
for (@l)
{
    m/^(\d+)x(\d+): (.*)/;
    my $w = $1;
    my $h = $2;
    my @c = split/\s+/, $3;

    my $s_p = 0;
    my $s_f = 0;
    my $i = 0;
    for my $cc (@c)
    {
        $s_p += ($cc * $size_p->{$i});
        $s_f += ($cc * $size_full->{$i++});
    }
    my $b = $w*$h;
    say "board size=$h x $w = $b p-size=$s_p full-size=$s_f";

    next if $s_p > $b;
    die unless $s_f <= $b;
    $stage1++;
}
say $stage1;