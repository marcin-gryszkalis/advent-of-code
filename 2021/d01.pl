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

my $stage1 = 0;
my $stage2 = 0;

for my $i (1..scalar(@f)-1)
{
    $stage1++ if $f[$i] > $f[$i-1];
    $stage2++ if ($f[$i+2]//0) > $f[$i-1];
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;