#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/

my $rules;
my $src = '';
while (<>)
{
    chomp;
    next if /^\s*$/;
    if (/(\S+)\s*=>\s*(\S+)/)
    {
        $rules->{$2} = $1; # assume destination is uniq
    }
    else
    {
        $src = $_;
    }
}

my $target = 'e';

my $c = 0;
L: while (1)
{
    my $s = $src;
    $c = 0;

    # my @rxs = sort { length($b) <=> length($a) } keys %$rules;
    my @rxs =  keys %$rules;
    while (1)
    {
        my $matched = 0;
        for my $rx (@rxs)
        {
            if ($s =~ s/($rx)/$rules->{$1}/)
            {
                $matched = 1;
                $c++;
                printf "%3d %5d\n", $c, length($s);
                next;
            }

        }

        if (!$matched)
        {
            last L if $s eq 'e';

            print "stuck at $c - $s\n"; # try again - won't help here as it's deterministic :)
            next L;
        }

    }

}
printf "stage 2: %d\n", $c;
