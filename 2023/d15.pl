#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax indexes/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my $s = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %h;
my %focal;

sub hash($v)
{
    return reduce { (($a + $b) * 17) % 256} (0, map {ord} split(//, $v))
}

my @f = split(/,/, $s);
$stage1 = sum( map { hash($_) } @f );

for (@f)
{
    my ($l,$op,$foc) = m/(.*)([=-])(.*)?/;

    my $x = hash($l);

    my $p = $h{$x};

    if ($op eq '-')
    {
        next unless defined $p;

        my $i = firstidx { $_ eq $l } @$p;
        splice(@$p, $i, 1) if $i >= 0;
    }
    else # =
    {
        my $i = firstidx { $_ eq $l } @$p;
        if ($i >= 0)
        {
            $p->[$i] = $l;
        }
        else
        {
            push(@$p, $l);
        }

        $focal{$x,$l} = $foc;
    }

    $h{$x} = $p;
}

for my $x (0..255)
{
    next unless exists $h{$x};

    my $p = $h{$x};
    next unless scalar @$p;

    for my $i (indexes { defined } @$p)
    {
        $stage2 += (1+$x) * (1+$i) * $focal{$x,$p->[$i]};
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
