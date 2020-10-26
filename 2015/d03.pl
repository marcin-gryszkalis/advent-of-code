#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

my %dx = qw/< -1  > 1  ^  0  v 0/;
my %dy = qw/<  0  > 0  ^ -1  v 1/;

$_ = <>;
chomp;

for my $stage (1..2)
{
    my @xa = (0,0);
    my @ya = (0,0);
    my %h = ();
    $h{"0:0"} = 1;
    my $s = 0;
    for my $m (split//)
    {
        $xa[$s] += $dx{$m};
        $ya[$s] += $dy{$m};
        $h{"$xa[$s]:$ya[$s]"} = 1;
        $s = ($s + 1) % $stage;
    }

    my $r = scalar keys %h;
    print "stage $stage: $r\n";
}
