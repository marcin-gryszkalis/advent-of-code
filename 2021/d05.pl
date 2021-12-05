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

for my $stage (1..2)
{
    my $h = undef;
    for (@f)
    {
        if (my ($x1,$y1,$x2,$y2) = /(\d+)/g)
        {
            my $dx = $x2 <=> $x1;
            my $dy = $y2 <=> $y1;

            next if $stage == 1 && $dx && $dy;

            my $x = $x1;
            my $y = $y1;
            while (1)
            {
                $h->{$x,$y}++;
                last if $x == $x2 && $y == $y2;
                $x += $dx;
                $y += $dy;
            }
        }
    }

    my $cnt = grep { $_ >= 2 } values %$h;
    printf "Stage %d: %d\n", $stage, $cnt;
}
