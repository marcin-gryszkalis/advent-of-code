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

my $f = read_file(\*STDIN, chomp => 1);
my @code = $f =~ m/(\d+)/g;
my $sA = shift @code;
my $sB = shift @code;
my $sC = shift @code;

my ($A,$B,$C);
sub combo($a)
{
    return $a if $a < 4;
    return $A if $a == 4;
    return $B if $a == 5;
    return $C if $a == 6;
    die;
}

my $stage1 = 0;
my $stage2 = 0;

sub process
{
    ($A,$B,$C) = @_;
    my @out;

    my $ip = 0;
    while (1)
    {
        my $cmd = $code[$ip];
        last unless defined $cmd;

        my $op = $code[$ip+1];

    #    say("$ip: $A $B $C -- ", join(",", @out));
        if ($cmd == 0) # adv
        {
            $A = int($A / (2 ** combo($op)));
        }
        elsif ($cmd == 1) # bxl
        {
            $B = $B ^ $op;
        }
        elsif ($cmd == 2) # bst
        {
            $B = combo($op) % 8;
        }
        elsif ($cmd == 3) # jnz
        {
            if ($A != 0)
            {
                $ip = $op;
                next;
            }
        }
        elsif ($cmd == 4) # bxc
        {
            $B = $B ^ $C;
        }
        elsif ($cmd == 5) # out
        {
            push(@out, combo($op) % 8)
        }
        elsif ($cmd == 6) # bdv
        {
            $B = int($A / (2 ** combo($op)));
        }
        elsif ($cmd == 7) # cdv
        {
            $C = int($A / (2 ** combo($op)));
        }
        else
        {
            die;
        }

        $ip += 2;
    }

    return join(",", @out);
}

say "Stage 1: ", process($sA, $sB, $sC);
say "Stage 2: ", $stage2;
