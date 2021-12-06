 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @dps = (80, 256);

my $ff = read_file(\*STDIN);
my @f = split/,/, $ff;

for my $stage (1..2)
{
    my %h = ();
    $h{$_} = 0 for (0..8);
    $h{$_}++ for (@f);

    for my $d (1..$dps[$stage - 1])
    {
        my $z = $h{0};
        $h{$_} = $h{$_+1} for (0..7);
        $h{6} += $z;
        $h{8} = $z;
    }

    printf "Stage %d: %s\n", $stage, sum(values(%h));
}
