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

my @f = split(/,/, $s);
for (@f)
{
    my $x = 0;
    for my $c (split//)
    {
        $x += ord($c);
        $x *= 17;
        $x %= 256;
    }
    $stage1 += $x;

    my ($l,$op,$foc) = m/(.*)([=-])(.*)?/;

    $x = 0;
    for my $c (split//,$l)
    {
        $x += ord($c);
        $x *= 17;
        $x %= 256;
    }

    my $p = undef;
    $p = $h{$x} if exists $h{$x};

    if ($op eq '-')
    {
        next unless defined $p;

        for my $i (0..$#$p)
        {
            if ($p->[$i] eq $l)
            {
                splice(@$p, $i, 1);
                last;
            }
        }
    }
    else # =
    {
        my $changed = 0;
        if (defined $p)
        {
            for my $i (0..$#$p)
            {
                if ($p->[$i] eq $l)
                {
                    $p->[$i] = $l;
                    $focal{$x,$l} = $foc;
                    $changed = 1;
                    last;
                }
            }
        }

        unless ($changed)
        {
            push(@$p, $l);
            $focal{$x,$l} = $foc;
        }
    }

    $h{$x} = $p;
}

for my $x (0..255)
{
    next unless exists $h{$x};

    my $p = $h{$x};
    next unless scalar @$p;

    for my $i (0..$#$p)
    {
        $stage2 += (1+$x) * (1+$i) * $focal{$x,$p->[$i]};
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;