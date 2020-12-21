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

my $h;
my $hac;
my $allingsh;
my @allings;

for (@ff)
{
    # mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    m/(.*?)\s+\(contains (.*)\)/;
    $a = $1; $b = $2;

    my @ings = split/\s+/,$a;
    my @algs = split/,\s+/,$b;

    for my $al (@algs)
    {
        $h->{$al}->{$_}++ for (@ings);
        $hac->{$al}++;
    }

    $allingsh->{$_}++ for (@ings);
}
@allings = keys %$allingsh;

my $matchia;
my $matchai;
while (1)
{
    AL: for my $al (keys %{$h})
    {
        next if exists $matchai->{$al};
        my $c = $hac->{$al};

        my $m = 0;
        my $mi = 0;
        for my $i (keys %{$h->{$al}})
        {
            next if exists $matchia->{$i};
            if ($h->{$al}->{$i} == $c)
            {
                $m++;
                next AL if $m > 1; # more than 1 match
                $mi = $i;
            }
        }

        if ($mi)
        {
            print "match: $al - $mi\n";
            $matchia->{$mi} = $al;
            $matchai->{$al} = $mi;
        }
    }

    last if scalar(keys %$matchai) == scalar(keys %$h);
}

$stage1 = sum( map { $allingsh->{$_} } grep { !exists $matchia->{$_} } @allings);

$stage2 = join(",", sort { $matchia->{$a} cmp $matchia->{$b} } grep { exists $matchia->{$_} } @allings);

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";