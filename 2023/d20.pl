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
use Math::Prime::Util qw/lcm/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $t;
for (@f)
{
    my ($type, $n, $d) = m/([&%]?)(\w+) -> (.*)/;
    my @dst = $d =~ m/(\w+)/g;

    $t->{$n}->{type} = $type;
    $t->{$n}->{dst} = \@dst;
    $t->{$n}->{dsth} = {map { $_ => 1 } @dst};
    $t->{$n}->{st} = 0; # state for flipflops
}

# memory for conj nodes
for my $node (keys %$t)
{
    for my $d (@{$t->{$node}->{dst}})
    {
        next unless exists $t->{$d}; # outputs
        $t->{$d}->{mem}->{$node} = 0;
    }
}

my $neo; # the one who has many inputs and they are all &
for my $node (keys %$t)
{
    next unless $t->{$node}->{type} eq '&';
    next unless scalar(keys %{$t->{$node}->{mem}}) > 1;
    next if scalar(grep { $t->{$_}->{type} ne '&' } keys %{$t->{$node}->{mem}}) > 0;
    $neo = $node;
    last;
}

# we'll trace those with many inputs
my %tr = map { $_ => 1} grep { defined $neo && exists $t->{$_}->{dsth}->{$neo} } keys %$t;

my @lowhigh = (0,0);
my %cycle;

my $i = 0;
L: while (1)
{
    $i++;
    if ($i == 1001)
    {
        printf "Stage 1: %d * %d = %d\n", $lowhigh[0], $lowhigh[1], product(@lowhigh);
        exit if scalar(keys %tr) == 0;
    }

    my @q = ();

    push(@q, [0, 'broadcaster', 'button']);
    while (my $sig = shift(@q))
    {
        my ($p,$n,$src) = @$sig;
        $lowhigh[$p]++;

        next unless exists $t->{$n} && exists $t->{$n}->{type};

        my $m = $t->{$n};
        if ($m->{type} eq '')
        {
            push(@q, map { [$p, $_, $n] } @{$m->{dst}});
        }
        elsif ($m->{type} eq '%')
        {
            if ($p == 0)
            {
                $t->{$n}->{st} = 1 - $m->{st};
                push(@q, map { [$t->{$n}->{st}, $_, $n] } @{$m->{dst}});
            }
        }
        elsif ($m->{type} eq '&')
        {
            $t->{$n}->{mem}->{$src} = $p;
            if (all { $_ == 1 } values %{$t->{$n}->{mem}})
            {
                push(@q, map { [0, $_, $n] } @{$m->{dst}});
            }
            else
            {
                push(@q, map { [1, $_, $n] } @{$m->{dst}});

                if (exists $tr{$n})
                {
                    $cycle{$n} = $i unless exists $cycle{$n};
                    if (all { exists $cycle{$_} } keys %tr)
                    {
                        my @cycled = grep { exists $cycle{$_} && $cycle{$_} > 0 } keys %tr;
                        printf "Stage 2: LCM(%s) = LCM(%s) = %d\n",
                            join(", ", @cycled),
                            join(", ", map { $cycle{$_} } @cycled),
                            lcm(map { $cycle{$_} } @cycled);
                        last L;
                    }
                }
            }
        }
    }
}
