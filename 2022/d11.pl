#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $monkeys0;
my @divs = ();

my $m = undef;
my $x;
for (@f)
{
    if (/Monkey (\d+)/)
    {
        $m->{inspects} = 0;
        $m->{items} = undef;
        $x = $1;
    }
    elsif (/Starting items: (.*)/)
    {
        my @a = $1 =~ m/(\d+)/g;
        $m->{items} = \@a;
    }
    elsif (/Operation: new = (.*)/)
    {
        $m->{op} = $1;
    }
    elsif (/Test: divisible by (\d+)/)
    {
        $m->{divisible} = $1;
        push(@divs, $1);
    }
    elsif (/If true: .*?(\d+)/)
    {
        $m->{ift} = $1;
    }
    elsif (/If false: .*?(\d+)/)
    {
        $m->{iff} = $1;
        $monkeys0->{$x} = clone $m;
    }
}

my $last = scalar %$monkeys0 - 1;
my $divprod = product(@divs); # or lcm

for my $stage (1..2)
{
    my $monkeys = clone $monkeys0;
    for my $r (1..($stage == 1 ? 20 : 10000))
    {
        for my $x (0..$last)
        {
            my $m = $monkeys->{$x};
            while (my $i = shift(@{$m->{items}}))
            {
                my $o = 0;
                eval('$o = ' . $m->{op} =~ s/old/$i/gr);

                $o = int($o/3) if $stage == 1;
                $o %= $divprod;

                my $dest = $o % $m->{divisible} ? $m->{iff} : $m->{ift};
                push(@{$monkeys->{$dest}->{items}}, $o);

                $m->{inspects}++;
            }
        }
    }

    my @inspects  = sort { $b <=> $a } map { $monkeys->{$_}->{inspects} } keys %$monkeys;
    printf "Stage $stage: %s\n", $inspects[0] * $inspects[1];
}
