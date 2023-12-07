#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my @strengths;
$strengths[1] = [ qw/2 3 4 5 6 7 8 9 T J Q K A/ ];
$strengths[2] = [ qw/J 2 3 4 5 6 7 8 9 T Q K A/ ];

my @hands = ();
my %bids = ();

for (@f)
{
    my ($h,$bid) = split/\s+/;
    push(@hands, $h);
    $bids{$h} = $bid;
}

for my $stage (2..2)
{
    my $i = 0;
    my %strength = map { $_ => $i++ } @{$strengths[$stage]};

    my %figures = ();
    my %h2j = ();

    for my $h (@hands)
    {
        my $hs = join("",sort(split(//,$h)));

        my $hj = $h;
        if ($stage == 2)
        {
            if ($h ne 'JJJJJ') # special case
            {
                my %counts;
                for my $c (split(//,$h)) { $counts{$c}++ }

                my $hnoj = ($h =~ s/J//gr);
                my $mostfreq = (sort( { $counts{$b} <=> $counts{$a} } sort(split(//,$hnoj))))[0];
                $hj =~ s/J/$mostfreq/g;
            }
        }

        $h2j{$h} = $hj;
        my $hjs = join("",sort(split(//,$hj)));

        my $figure = 0;
        if ($hjs =~ /(.)\1\1\1\1/)
        {
            $figure = 6;
        }
        elsif ($hjs =~ /(.)\1\1\1/) # 4
        {
            $figure = 5;
        }
        elsif ($hjs =~ /((.)\2\2(.)\3|(.)\4(.)\5\5)/) # full
        {
            $figure = 4;
        }
        elsif ($hjs =~ /(.)\1\1/) # 3
        {
            $figure = 3;
        }
        elsif ($hjs =~ /(.)\1.?(.)\2/) # 2p
        {
            $figure = 2;
        }
        elsif ($hjs =~ /(.)\1/) # 1p
        {
            $figure = 1;
        }

        $figures{$h} = $figure;
    }

    sub hcomp
    {
        return $figures{$a} <=> $figures{$b} if $figures{$a} != $figures{$b};

        my @aa = split//,$a;
        my @bb = split//,$b;

        for my $ax (@aa)
        {
            my $bx = shift(@bb);
            next if $ax eq $bx;
            return $strength{$ax} <=> $strength{$bx};
        }

        die "the same ($a,$b)";
    }

    my @xh = sort({ hcomp } @hands);

    my $out = 0;
    $i = 1;
    for my $h (@xh)
    {
        print "$h / $h2j{$h} = $figures{$h} ($h2j{$h}) $i * $bids{$h}\n";
        $out += $bids{$h} * $i;
        $i++;
    }

    printf "Stage $stage: %s\n", $out;

}