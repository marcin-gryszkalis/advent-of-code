#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

$_ = <>;
/state (\S)/; # Begin in state A.
my $begin = $1;

$_ = <>;
/after (\d+)/; # Perform a diagnostic checksum after 12317297 steps.
my $finish = $1;

my $turing;
my $c = '';
my $v = 0;
my $m;
while (<>)
{
    if (/In state (\S)/)
    {
        $c = $1;
        $m = {};
    }
    elsif (/If the current value is (\d)/)
    {
        $v = $1;
    }
    elsif (/Write the value (\d)/)
    {
        $m->{$v}->{w} = $1;
    }
    elsif (/Move one slot to the (\S)/)
    {
        $m->{$v}->{d} = $1;
    }
    elsif (/Continue with state (\S)/)
    {
        $m->{$v}->{n} = $1;
        if ($v == 1)
        {
            $turing->{$c} = $m;
        }

    }
}
# print Dumper $turing;

my $N = 10000;
my @tape = (0) x $N;
my $i = 100;
my $s = $begin;
for my $step (1..$finish)
{
    my $inst = $turing->{$s}->{$tape[$i]};
    $tape[$i] = $inst->{w};
    $i += ($inst->{d} eq 'l' ? -1 : 1);
    $s = $inst->{n};

    die if $i < 0 || $i > $N;
    print "$s $step i=$i\n" if $step % 1000000 == 0;
}

printf "stage 1: %d\n", sum(@tape);