 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;
@f = ($f[0] =~ m/(\d+)/g);

my $stage1 = scalar(@f) * max(@f);
my $stage2 = $stage1 * $stage1;

for my $p (0..max(@f))
{
    my $d1 = sum(map { abs($_ - $p) } @f);
    my $d2 = sum(map { abs($_ - $p) * (abs($_ - $p) + 1) / 2 } @f);
    $stage1 = min($d1, $stage1);
    $stage2 = min($d2, $stage2);
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;