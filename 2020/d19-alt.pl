#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

use Parse::Earley; # other option is Marpa::R2
my $parser = new Parse::Earley;

my $ff = read_file(\*STDIN);
my @ff2 = split/\n\n/, $ff;
my $grammar = $ff2[0];
my @checks = split/\n/, $ff2[1];

$grammar =~ s/"/'/g;
$grammar =~ s/(\d+)/R$1/g;

$parser->grammar($grammar);

for my $stage (1..2)
{

    if ($stage == 2)
    {
        $parser->grammar("R8: R42 | R42 R8");
        $parser->grammar("R11: R42 R31 | R42 R11 R31");
    }

    my $sum = 0;
    for my $c (@checks)
    {
        $parser->start('R0');

        while (1)
        {
            $parser->advance($c);
            my $f = $parser->fails($c, 'R0') // 0;
            my $m = $parser->matches_all($c, 'R0') // 0;

            $sum++ if $m;
            last if $f || $m;
        }

    }
    print "stage $stage: $sum\n";
}