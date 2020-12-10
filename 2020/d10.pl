#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
#@f = map { chomp;  } @f;
@f = map { chomp; $_ = int $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my %h;

my $max = max(@f);
push(@f, $max+3);
push(@f, 0);
@f = sort { $a <=> $b } @f;
my $i = 0;
for my $i (0..$#f - 1)
{
    my $d = $f[$i+1] -$f[$i];
    $h{$d}++;
}
$stage1 = $h{1} * $h{3};

print "stage 1: $stage1\n";


my %w;
$w{0} = 1;
for my $i (1..$#f) # skip 0
{
    my $k = $f[$i];
    $w{$k} = ($w{$k-1} // 0) + ($w{$k-2} // 0) + ($w{$k-3} // 0)
}

$stage2 = $w{$max};

for my $k (sort { $b <=> $a } keys %w)
{
    print "$k $w{$k}\n";
}
print "stage 2: $stage2\n";
