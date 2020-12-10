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

print "stage 2 (forward tracking): $stage2\n";


my %available = map { $_ => 1 } @f;
my %cache;
sub c
{
    my $i = shift;

    return 1 if $i == 0;
    return $cache{$i} if exists $cache{$i};

    my $s = 0;
    for my $d (1..3)
    {
        $s += c($i-$d) if exists $available{$i-$d};
    }
    $cache{$i} = $s;
    return $s;
}
printf "stage 2 (recursive): %d\n", c($max);


# assume (along with examples and actual input) that gaps are 1 or 3, never 2!
my $groupsize = 0;

my %groupx = ( # number of valid combinations in group of given size
    2 => 1, # 2 elements with 1 gap between - both are required
    3 => 2, # 3 elements, middle can be switched on or off
    4 => 4, # 4 elements, 2 middle can be switched (00,01,10,11)
    5 => 7, # 5 elements, 3 middle (100,010,001,110,101,011,111 - but not 000 -> gap too large)
    6 => 11,# 6 elements, 4 middle (1100,1010,1001,0110,0101,0011, 1110,1101,1011,0111, 1111)
    # note: 6+ no such groups in input
    );
# https://oeis.org/search?q=1+2+4+7+11&sort=&language=&go=Search

my $product = 1;
for my $i (1..$#f)
{
    die "no 2s" if $f[$i] - $f[$i-1] == 2; # assert
    $groupsize++;
    if ($f[$i] - $f[$i-1] == 3)
    {
        $product *= $groupx{$groupsize} if $groupsize > 1;
        $groupsize = 0;
    }
}
printf "stage 2 (assumptions): %d\n", $product;
