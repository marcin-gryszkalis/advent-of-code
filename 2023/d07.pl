#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my @strengths = qw/23456789TJQKA J23456789TQKA/;

my @hands = ();
my %bids = ();

for (@f)
{
    my ($h,$bid) = split/\s+/;
    push(@hands, $h);
    $bids{$h} = $bid;
}

for my $stage (1..2)
{
    my $i = 0;
    my %strength = map { $_ => $i++ } split//, $strengths[$stage-1];

    my %figures = ();

    for my $h (@hands)
    {
        my $hj = $h;
        if ($stage == 2)
        {
            my @modes = mode(grep { /[^J]/ } split(//,$h));
            my $mostfreq = $modes[1] // 'J'; # modes[0] is the number of occurences
            $hj =~ s/J/$mostfreq/g;
        }

        my %cj = frequency split//,$hj;
        # direct use: 11111 2111 221 311 32 41 5
        $figures{$h} = reverse join("", sort values %cj);
    }

    sub hcomp
    {
        my ($a, $b, $fgs, $str) = @_;
        return $fgs->{$a} cmp $fgs->{$b} if $fgs->{$a} != $fgs->{$b};

        for (zip([split//,$a],[split//,$b]))
        {
            my ($ax,$bx) = @$_;
            return $str->{$ax} <=> $str->{$bx} if $ax ne $bx;
        }

        die "the same ($a,$b)"; # assert uniq-ness
    }

    my @xh = sort({ hcomp($a, $b, \%figures, \%strength) } @hands);

    $i = 1;
    printf "Stage $stage: %s\n", sum map { $bids{$_} * $i++ } @xh;
}