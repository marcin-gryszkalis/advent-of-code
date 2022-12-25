#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;

my @f = read_file(\*STDIN, chomp => 1);

my %snafudigits = qw/
2 2
1 1
0 0
- -1
= -2
/;

sub snafu2dec($a)
{
    my $i = 0;
    return sum(map { (5 ** $i++) * $snafudigits{$_} } reverse split//, $a);
}

sub dec2pent($n)
{
   my $o = "";
   while ($n)
   {
      my $r = $n % 5;
      $o = $r.$o;
      $n = ($n-$r)/5;
   }
   return $o;
}

my %xmap = qw/
0 0
1 1
2 2
3 =
4 -
5 0
/;

sub dec2snafu($a)
{
    my @x = reverse(split(//, dec2pent($a)));
    my $k = 0;
    while (defined $x[$k])
    {
        $x[$k+1]++ if $x[$k] > 2;
        $x[$k] = $xmap{$x[$k]};
        $k++;
    }

    return join("", reverse @x)
}

my $sum = sum(map { snafu2dec($_) } @f);

printf "Stage 1: %s (%s)\n", dec2snafu($sum), $sum;
