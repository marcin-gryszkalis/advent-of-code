 #!/usr/bin/perl
use warnings;
use strict;
use List::Util qw/min max first sum product all any uniq head tail/;

my @f = (<> =~ m/(\d+)/g);
printf "Stage 1: %s\n", min(map { my $p = $_; sum(map { abs($_ - $p) } @f) } (0..max(@f)));;
printf "Stage 2: %s\n", min(map { my $p = $_; sum(map { abs($_ - $p) * (abs($_ - $p) + 1) / 2 } @f) } (0..max(@f)));;