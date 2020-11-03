#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

no warnings 'recursion';

my $rules;
my $src = '';
while (<>)
{
    chomp;
    next if /^\s*$/;
    if (/(\S+)\s*=>\s*(\S+)/)
    {
        $rules->{$1} = [] unless exists $rules->{$1};
        push(@{$rules->{$1}}, $2)
    }
    else
    {
        $src = $_;
    }
}

my $dest;
for my $c (keys %$rules)
{
    my $n = () = $src =~ /$c/g;
    next unless $n > 0;
    for my $r (@{$rules->{$c}})
    {
        for my $i (1..$n)
        {
            my $d = $src;
            my $j = 0;
            $d =~ s/($c)/++$j == $i ? $r : $1/ge;

            $dest->{$d} = 1;
        }
    }
}

printf "stage 1: %d\n", scalar(keys %$dest);



my $target = $src;

my $visited;
my $best = 1000000;
my @rulesources = uniq keys %$rules;
sub search
{
    my $src = shift;
    my $level = shift;

    print "$level $src\n" if rand() < 0.001;
    return if $level > 100;
    for my $c (@rulesources)
    {
        my $n = () = $src =~ /$c/g;
        next unless $n > 0;
        for my $r (@{$rules->{$c}})
        {
            for my $i (1..$n)
            {
                my $d = $src;
                my $j = 0;
                $d =~ s/($c)/++$j == $i ? $r : $1/ge;

                # print(("   " x $level)." $level: $src ($c -> $r) $d\n");
                return if length $d > length $target; # rules always make molecule longer
                #print "btb($d)\n" if exists $visited->{$d} && $visited->{$d} <= $level; # we've been there earlier
                return if exists $visited->{$d} && $visited->{$d} < $level; # we've been there earlier
                next if exists $visited->{$d} && $visited->{$d} == $level; # we've been there earlier
                $visited->{$d} = $level;
                if ($d eq $target)
                {
                    printf "### found target at level %d\n", $level;
                    $best = $level;
                    return;
                }

                search($d, $level+1);
            }
        }
    }
}
search("e", 1);
printf "stage 2: %d\n", $best;
