#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $input = <>;
chomp $input;

$_ = $input;

sub f
{
    my $l = shift;
    my $rep = shift;
    my $rest = shift;

    my $a = substr($rest, 0, $l);
    $a =~ tr/()/<>/;
    return ($a x $rep).substr($rest, $l);
}

$_ = $input;
while (1)
{
    s/\((\d+)x(\d+)\)(.*)/f($1,$2,$3)/e;
    last unless /\(/;
}
printf "stage 1: %d\n", length($_);


$_ = $input;
sub cnt
{
    my $level = shift;
    my $s = shift;
#    print "$level: $s\n";
    my $i = 0;
    my $sum = 0;
    while ($i < length($s))
    {
        if (substr($s, $i) =~ m/^(\((\d+)x(\d+)\))/)
        {
            my $l = $2;
            my $rep = $3;
            my $off = length $1;
            $sum += $rep * cnt($level+1, substr($s, $i+$off, $l));
            $i += ($off + $l);
        }
        elsif (substr($s, $i) =~ m/^([^\(]+)/)
        {
            $sum += length($1);
            $i += length($1);
        }
        else { die "$i $s"}
    }

    return $sum;
}

printf "stage 1: %d\n", cnt(0, $_);

# too slow  (~45 minutes)
# my $step = 0;
# while (1)
# {
#     if (s/^([^\(]+)//)
#     {
#         $xlen += length($1);
#     }
#     s/\((\d+)x(\d+)\)(.{1,$longest})/f(2,$1,$2,$3)/e;
#     printf("%10d: %10d + %10d = %20d\n", $step, $xlen, length($_), $xlen+length($_)) if $step % 1000 == 0;

#     last unless /\(/;
#     $step++;
# }
# printf("%10d: %10d + %10d = %20d\n", $step, $xlen, length($_), $xlen+length($_));

