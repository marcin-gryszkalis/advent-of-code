#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = map { eval $_ } grep { /\[/ } read_file(\*STDIN, chomp => 1);

sub compare
{
    my $i = 0;
    while (1)
    {
        my $l = $_[0]->[$i];        
        my $r = $_[1]->[$i++];

        return -1 if  defined $l && !defined $r;
        return  0 if !defined $l && !defined $r;
        return  1 if !defined $l &&  defined $r;

        my $res = 0;
        if (!ref $l && !ref $r)
        {
            $res = $r <=> $l;
        }
        else
        {
            $res = compare(
                ref $l ? $l : [$l],
                ref $r ? $r : [$r]
            );
        }

        return $res if $res != 0;
    }
}

my $stage1 = 0;
my $i = 0;
while (exists $f[$i])
{
    $stage1 += $i/2 + 1 if compare($f[$i], $f[$i+1]) == 1;
    $i += 2;
}

push(@f, [[2]], [[6]]);

my @d;
$i = 1;
for my $a (sort { compare($b,$a) } @f)
{
    $_ = Dumper $a;
    s/.*=//;
    s/[\s;]+//g;
    push(@d, $i) if /^\[\[[26]\]\]$/;
    $i++;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", product(@d);

