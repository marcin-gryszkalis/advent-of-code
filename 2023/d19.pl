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

#use bigint;

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
        my %oo;
        $oo{x} = $o[0];
        $oo{m} = $o[1];
        $oo{a} = $o[2];
        $oo{s} = $o[3];

        push(@e, \%oo);
    }
}

#print Dumper $rules;
#print Dumper \@e;
#exit;

E: for my $x (@e)
{
    my $w = 'in';
    W: while (1)
    {
        my $status = undef;
        R: for my $r (@{$rules->{$w}})
        {
            print "$x->{x},$x->{m},$x->{a},$x->{s} $w $r\n";
            if ($r =~ /(\w)([<>])(\d+):(\w+)/)
            {
                my $p = $1;
                my $op = $2;
                my $v = $3;
                my $dest = $4;

                if ($op eq '<')
                {
                    if ($x->{$p} < $v)
                    {
                        if ($dest eq 'A')
                        {
                            $stage1 += sum(values(%$x));
                            next E;
                        }
                        elsif ($dest eq 'R')
                        {
                            next E;
                        }
                        else
                        {
                            $w = $dest;
                            next W;
                        }
                    }
                    else
                    {
                        next R;
                    }
                }
                else # >
                {
                    # die $v unless $v !~ /\d+/;
                    # die "$p $x->{$p} $v" unless $x->{$p} !~ /\d+/;
                    if ($x->{$p} > $v)
                    {
                        if ($dest eq 'A')
                        {
                            $stage1 += sum(values(%$x));
                            next E;
                        }
                        elsif ($dest eq 'R')
                        {
                            next E;
                        }
                        else
                        {
                            $w = $dest;
                            next W;
                        }
                    }
                    else
                    {
                        next R;
                    }
                }
            }
            else
            {
                my $dest = $r;
                if ($dest eq 'A')
                {
                    $stage1 += sum(values(%$x));
                    next E;
                }
                elsif ($dest eq 'R')
                {
                    next E;
                }
                else
                {
                    $w = $dest;
                    next W;
                }
            }
        }
    }
}

say $stage1;

my $stage2x = 0;
my $total = 0;
my $ranges;
my @q;
my @qw;
my %mm = qw/x 0 m 1 a 2 s 3/;

push(@q, [[1,4000],[1,4000],[1,4000],[1,4000]]);
push(@qw, 'in');

push(@{$rules->{R}}, 'R');
push(@{$rules->{A}}, 'A');

Q: while (my $x = pop @q)
{
                    $total =
                    ($x->[0]->[1] - $x->[0]->[0] + 1) *
                    ($x->[1]->[1] - $x->[1]->[0] + 1) *
                    ($x->[2]->[1] - $x->[2]->[0] + 1) *
                    ($x->[3]->[1] - $x->[3]->[0] + 1) if $total == 0;

    my $w = pop @qw;

    print $w, Dumper $x;

    R: for my $r (@{$rules->{$w}})
    {
#            print "$x->{x},$x->{m},$x->{a},$x->{s} $w $r\n";
        print "$w $r\n";
        if ($r =~ /(\w)([<>])(\d+):(\w+)/)
        {
            my $p = $1;
            my $op = $2;
            my $v = $3;
            my $dest = $4;
            print "$w $r :: $x->[$mm{$p}]->[0] $x->[$mm{$p}]->[1]\n";

            if ($x->[$mm{$p}]->[0] <= $v && $x->[$mm{$p}]->[1] >= $v) # split
            {
                say "SPLIT";
                my $x1 = clone $x;
                my $x2 = clone $x;

                if ($op eq '<')
                {
                    $x1->[$mm{$p}]->[1] = $v - 1;
                    $x2->[$mm{$p}]->[0] = $v;
                    push(@q, $x1);
                    push(@qw, $dest);

                    $x = $x2;
                    next R;

                }
                else # >
                {
                    $x1->[$mm{$p}]->[1] = $v;
                    $x2->[$mm{$p}]->[0] = $v + 1;

                    push(@q, $x2);
                    push(@qw, $dest);

                    $x = $x1;
                    next R;
                }
            }
            elsif ($x->[$mm{$p}]->[0] > $v && $op eq '<' || $x->[$mm{$p}]->[1] < $v && $op eq '>') # no common part of ranges
            {
                next R;
            }
            elsif ($x->[$mm{$p}]->[0] > $v && $op eq '>' || $x->[$mm{$p}]->[1] < $v && $op eq '<') # whole range inside
            {
                push(@q, clone $x);
                push(@qw, $dest);
                next Q;
            }
        }
        else # simple rule
        {
            my $dest = $r;
print "SIMPLE($dest)\n";
            if ($dest eq 'A')
            {

                $stage2 +=
                    ($x->[0]->[1] - $x->[0]->[0] + 1) *
                    ($x->[1]->[1] - $x->[1]->[0] + 1) *
                    ($x->[2]->[1] - $x->[2]->[0] + 1) *
                    ($x->[3]->[1] - $x->[3]->[0] + 1);

                next Q;
            }
            elsif ($dest eq 'R')
            {
                $stage2x +=
                    ($x->[0]->[1] - $x->[0]->[0] + 1) *
                    ($x->[1]->[1] - $x->[1]->[0] + 1) *
                    ($x->[2]->[1] - $x->[2]->[0] + 1) *
                    ($x->[3]->[1] - $x->[3]->[0] + 1);

                next Q;
            }
            else
            {
                push(@q, clone $x);
                push(@qw, $dest);
                next Q;
            }

        }
    }

    die;
}

say $total;
say $stage2;
say $stage2x;
say $stage2 + $stage2x;
