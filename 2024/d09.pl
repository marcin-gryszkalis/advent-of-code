#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = split//, read_file(\*STDIN, chomp => 1);

my @m;
my $i = -1;
@m = map { ($i++ % 2 ? $i/2 : '.') x $_ } @f;

$i = 0;
my $j = $#m;
while (1)
{
    $i++ while $m[$i] ne '.' && $i < $j;
    $j-- while $m[$j] eq '.' && $i < $j;
    last if $i == $j;

    $m[$i] = $m[$j];
    $m[$j] = '.';
}

my $stage1 = sum map { $_ * $m[$_] } grep { $m[$_] ne '.' } (0..$#m);


my $p = 0;
my @idxfree;
my @idxfile;
$i = 0;
for (@f)
{
    if ($i % 2)
    {
        push(@idxfree, { 'pos' => $p, 'len' => $_});
    }
    else
    {
        push(@idxfile, { 'pos' => $p, 'len' => $_, 'id' => $i/2 });
    }

    $i++;
    $p += $_;
}

$j = $#idxfile;
while (1)
{
    last if $idxfile[$j]->{pos} < $idxfree[0]->{pos};

    $i = firstidx { $_->{len} >= $idxfile[$j]->{len} && $_->{pos} < $idxfile[$j]->{pos} } @idxfree;
    if ($i >= 0)
    {
        $idxfile[$j]->{pos} = $idxfree[$i]->{pos};
        $idxfree[$i]->{len} -= $idxfile[$j]->{len};
        $idxfree[$i]->{pos} += $idxfile[$j]->{len};
    }

    $j--;
}

my $stage2 = 0;
for my $e (@idxfile)
{
    $stage2 +=  sum map { $e->{id} * $_ } ($e->{pos}..$e->{pos}+$e->{len}-1);
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;

