#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce mesh/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = '';
my $stage2 = 0;

my $stack;
while (1)
{
    $_ = shift(@f);
    last unless /\[/;

    $_ .= " ";
    my @a = m/..../g;

    my $i = 0;
    for my $c (@a)
    {
        $i++;
        next unless $c =~ /[A-Z]/;
        unshift(@{$stack->{$i}}, $c);
    }
}

shift(@f); # empty line

for my $stage (1..2)
{
    my $s = clone($stack);
    for (@f)
    {
        my ($cnt, $src, $dst) = $_ =~ /move (\d+) from (\d+) to (\d+)/;

        my @n = ();
        for my $c (1..$cnt)
        {
            my $x = pop(@{$s->{$src}});
            push(@n, $x);
        }

        @n = reverse @n if $stage == 2;
        push(@{$s->{$dst}}, @n);
    }

    my $r = '';
    my $i = 1;
    while (exists $s->{$i})
    {
        $r .= pop(@{$s->{$i++}});
    }
    $r =~ s/[^A-Z]//g;

    printf "Stage $stage: %s\n", $r;
}