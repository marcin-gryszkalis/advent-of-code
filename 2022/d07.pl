#!/usr/bin/perl
use v5.36;
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);
shift @f; # skip cd /

my $stage1 = 0;
my $stage2 = 0;

my $d = 'ROOT';

my $tt;
$tt->{$d}->{SIZE} = 0;
$tt->{$d}->{FP} = $d;

for (@f)
{
    print "d($d)\n";
    if (/\$ cd (\S+)/)
    {
        my $n = $1;
        if ($n eq '..')
        {
            $d =~ s{/[^/]+$}{};
        }
        else
        {
            $d .= "/$n";

            my @p = split(m{/}, $d);
            my $xt = $tt;
            for my $pe (@p)
            {
                unless (defined $xt->{$pe})
                {
                    $xt->{$pe}->{SIZE} = 0;
                    $xt->{$pe}->{FP} = $d;
                }
                $xt = $xt->{$pe};
            }

        }
       # $d =~ s{/+}{/}g;
    }
    elsif (/\$ ls/)
    {
        # nop
        next;
    }
    elsif (/dir (\S+)/)
    {
        my @p = split(m{/}, $d);
        my $xt = $tt;
        for my $pe (@p)
        {
            unless (defined $xt->{$pe})
            {
                $xt->{$pe}->{SIZE} = 0;
                $xt->{$pe}->{FP} = $d;
            }
            $xt = $xt->{$pe};
        }

    }
    elsif (/(\d+) (\S+)/)
    {
        my $xs = $1;

        my @p = split(m{/}, $d);
        my $xt = $tt;
        for my $pe (@p)
        {
            $xt->{$pe}->{SIZE} += $xs;
            $xt = $xt->{$pe};
        }

    }
    else
    {
        die $_;
    }

# print Dumper $tt;

}
print Dumper $tt;

my @stack;
push(@stack, $tt);
my $ft;
while (1)
{
    my $xt = pop(@stack);
    last unless defined $xt;
    for my $k (keys %$xt)
    {
        push(@stack, $xt->{$k}) unless $k eq 'SIZE' or $k eq 'FP';
    }

    next unless exists $xt->{SIZE};
    $ft->{$xt->{FP}} = $xt->{SIZE};

    $stage1 += $xt->{SIZE} if $xt->{SIZE} < 100000;
}

my $tofree = 30000000 - (70000000 - $tt->{ROOT}->{SIZE});
for my $k (sort { $ft->{$a} <=> $ft->{$b} } keys %$ft)
{
    # say "$k $ft->{$k}";
    if ($ft->{$k} > $tofree)
    {
        $stage2 = $ft->{$k};
        last;
    }
}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;