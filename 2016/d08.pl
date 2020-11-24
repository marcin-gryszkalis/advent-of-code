#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $NX = 50;
my $NY = 6;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $t;
push @$t, [('.')x$NX] for (0..$NY-1);

for (@f)
{
    if (/rect (\d+)x(\d+)/)
    {
        my $nx = $1;
        my $ny = $2;
        for my $x (0..$nx-1)
        {
            for my $y (0..$ny-1)
            {
                $t->[$y]->[$x] = '#';
            }
        }

    }
    elsif (/rotate column x=(\d+) by (\d+)/)
    {
        my $x = $1;
        my $sh = $2;

        my @a = ();
        for my $i (0..$NY-1)
        {
            push(@a, $t->[$i]->[$x]);
        }
        push(@a, splice(@a, 0, $NY-$sh));
        for my $i (0..$NY-1)
        {
            $t->[$i]->[$x] = $a[$i];
        }

    }
    elsif (/rotate row y=(\d+) by (\d+)/)
    {
        my $y = $1;
        my $sh = $2;

        my @a = @{$t->[$y]};
        push(@a, splice(@a, 0, $NX-$sh));
        $t->[$y] = \@a;
    }
    else {die $_}
}

my $stage1 = 0;
for my $y (0..$NY-1)
{
    for my $x (0..$NX-1)
    {
        print $t->[$y]->[$x];
        $stage1++ if  $t->[$y]->[$x] eq '#';
    }
    print "\n";
}
print "stage 1: $stage1\n";
