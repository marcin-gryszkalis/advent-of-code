#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce mesh/;
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stack;
while (1)
{
    $_ = shift(@f);
    last unless /\[/;

    my $i = 0;
    for (m/....?/g)
    {
        $i++;
        next unless /([A-Z]+)/;
        unshift(@{$stack->[$i]}, $1);
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
            push(@n, pop(@{$s->[$src]}));
        }

        @n = reverse @n if $stage == 2;
        push(@{$s->[$dst]}, @n);
    }

    my $r = join("", map { pop(@$_) } grep { $_ } @$s);
    printf "Stage %s: %s\n", $stage, $r;
}