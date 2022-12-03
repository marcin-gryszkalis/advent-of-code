#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce mesh/;

my @f = read_file(\*STDIN, chomp => 1);

my %vmap = mesh(['a'..'z','A'..'Z'], [1..52]);

sub common
{
    my %cnt;
    for (@_)
    {
        map { $cnt{$_}++ } uniq split//;
    }

    return grep { $cnt{$_} == scalar(@_) } keys %cnt;
}

for my $stage (1..2)
{
    my @r = ();
    if ($stage == 1)
    {
        for (@f)
        {
            my $l = length;
            push(@r, common(substr($_, 0, $l/2), substr($_, $l/2)));
        }
    }
    else
    {
        while (1)
        {
            push(@r, common(pop(@f),pop(@f),pop(@f)));
            last unless @f;
        }
    }

    printf "Stage %d: %s\n", $stage, sum(map { $vmap{$_}} @r);
}
