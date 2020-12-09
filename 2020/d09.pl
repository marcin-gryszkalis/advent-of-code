#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { $_ = int $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my $pre = 25;
my $i = $pre;
while (1)
{
    my $ok = 0;
    A: for my $a ($i-$pre..$i-1)
    {
        for my $b ($a+1..$i-1)
        {
            if ($f[$i] == $f[$a] + $f[$b])
            {
                $ok = 1;
                last A;
            }
        }
    }

    if (!$ok)
    {
        $stage1 = $f[$i];
        last ;
    }

    $i++;
}

$i = 0;
my $j = 0;
my $s = $f[0];
while (1)
{
#    print "$i - $j : $s vs $stage1\n";
    if ($s < $stage1)
    {
        $s += $f[++$j];
    }
    elsif ($s > $stage1)
    {
        $s -= $f[$i++];
    }
    else # if ($s == $stage1)
    {
        $stage2 = max(@f[$i..$j]) + min(@f[$i..$j]);
        last;
    }
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";
