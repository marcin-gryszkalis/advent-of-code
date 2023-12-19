#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my %mm = qw/x 0 m 1 a 2 s 3/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $rules;
my @e;
for (@f)
{
    if (m/(\w+)\{(.*)\}/)
    {
        my $r = $1;
        my $s = $2;
        my @c = split/,/, $s;
        $rules->{$r} = \@c;
    }
    elsif (m/\{(.*)\}/)
    {
        my $s = $1;
        my @o = $s =~ m/(\d+)/g;
        push(@e, \@o);
    }
}

push(@{$rules->{R}}, 'R');
push(@{$rules->{A}}, 'A');

E: for my $x (@e)
{
    my $w = 'in';
    W: while (1)
    {
        R: for my $r (@{$rules->{$w}})
        {
            if ($r =~ /(\w)([<>])(\d+):(\w+)/)
            {
                my ($p,$op,$v,$dest) = @{^CAPTURE};
                if ($op eq '<' && $x->[$mm{$p}] < $v || $op eq '>' && $x->[$mm{$p}] > $v)
                {
                    $w = $dest;
                    next W;
                }
            }
            else
            {
                if ($r eq 'A')
                {
                    $stage1 += sum(@$x);
                    next E;
                }
                elsif ($r eq 'R')
                {
                    next E;
                }
                else
                {
                    $w = $r;
                    next W;
                }
            }
        }
    }
}

my @q;
my @qw;

push(@q, [[1,4000],[1,4000],[1,4000],[1,4000]]);
push(@qw, 'in');

Q: while (my $x = pop @q)
{
    my $w = pop @qw;

    R: for my $r (@{$rules->{$w}})
    {
        if ($r =~ /(\w)([<>])(\d+):(\w+)/)
        {
            my ($p,$op,$v,$dest) = @{^CAPTURE};

            if ($x->[$mm{$p}]->[0] <= $v && $x->[$mm{$p}]->[1] >= $v) # split
            {
                my $x1 = clone $x;
                my $x2 = clone $x;

                if ($op eq '<')
                {
                    $x1->[$mm{$p}]->[1] = $v - 1;
                    $x2->[$mm{$p}]->[0] = $v;
                    push(@q, $x1);
                    push(@qw, $dest);

                    $x = $x2;
                }
                else # >
                {
                    $x1->[$mm{$p}]->[1] = $v;
                    $x2->[$mm{$p}]->[0] = $v + 1;

                    push(@q, $x2);
                    push(@qw, $dest);

                    $x = $x1;
                }
            }
            elsif ($x->[$mm{$p}]->[0] > $v && $op eq '<' || $x->[$mm{$p}]->[1] < $v && $op eq '>') # no common part of ranges
            {
                next Q;
            }
            elsif ($x->[$mm{$p}]->[0] > $v && $op eq '>' || $x->[$mm{$p}]->[1] < $v && $op eq '<') # whole range inside
            {
                push(@q, $x);
                push(@qw, $dest);
                next Q;
            }
        }
        else # simple rule
        {
            my $dest = $r;
            if ($dest eq 'A')
            {
                $stage2 += product map { $x->[$_]->[1] - $x->[$_]->[0] + 1 } (0..3);
            }
            elsif ($dest eq 'R')
            {

            }
            else
            {
                push(@q, $x);
                push(@qw, $dest);
            }
            next Q;
        }
    }

    die;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;