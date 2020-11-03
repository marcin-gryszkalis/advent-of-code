#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);


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
my $re = join('|', keys %$rules);

my $c = 0;
L: while (1)
{
    my $s = $src;
    $c = 0;

    while (1)
    {
#        print "$c $s\n";

        my $n = () = $s =~ /($re)/g; # number of matches possible
        my $i = int(rand()*$n) + 1; # we could test them all, but feeling lucky, take random one :)
        my $m = 0;

        if (! ($s =~ s/($re)/++$m == $i ? $rules->{$1} : $1/ge))
        {
            last L if $s eq 'e';

            print "stuck at $c - $s\n"; # try again
            last;
        }

        $c++;
    }

}
printf "stage 2: %d\n", $c;
