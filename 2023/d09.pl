#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

for (@f)
{
    my $h = undef;
    $h->[0] = [m/[\d+-]+/g];

    while (1)
    {
        my @n = slide { $b - $a } @{$h->[-1]};
        push @$h, \@n;
        last if all { $_ == 0 } @n;
    }

    push(@{$h->[-1]}, 0);

    for my $l (reverse(0..scalar(@$h)-2))
    {
        push(@{$h->[$l]}, pop(@{$h->[$l]}) + pop(@{$h->[$l+1]}));
        unshift(@{$h->[$l]}, shift(@{$h->[$l]}) - shift(@{$h->[$l+1]}));
    }

    $stage1 += pop(@{$h->[0]});
    $stage2 += shift(@{$h->[0]});
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
