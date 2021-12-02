 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

for my $stage (1..2)
{
    my $h = 0;
    my $d = 0;
    my $a = 0;

    if ($stage == 1)
    {
        for $_ (@f)
        {
            $h += $1 if /forward (\d+)/;
            $d += $1 if /down (\d+)/;
            $d -= $1 if /up (\d+)/;
        }
    }
    else
    {
        for $_ (@f)
        {
            $d += $a * $1 if /forward (\d+)/;
            $h += $1 if /forward (\d+)/;
            $a += $1 if /down (\d+)/;
            $a -= $1 if /up (\d+)/;
        }
    }

    printf "Stage %d: %s\n", $stage, $h * $d;
}