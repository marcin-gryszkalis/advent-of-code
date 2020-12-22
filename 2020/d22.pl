#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my $ff = read_file(\*STDIN);

my @ps = split/\n\n/, $ff;
my @p1 = split/\n/, $ps[0];
my @p2 = split/\n/, $ps[1];
shift(@p1);
shift(@p2);

sub combat
{
    my ($p1, $p2, $stage, $lvl) = @_;
    my %rep;

    F: while (1)
    {
        my $c = join(" ", @$p1)."|".join(" ", @$p2);
        return 1 if exists $rep{$c};
        $rep{$c} = 1;

        my $a = shift(@$p1);
        my $b = shift(@$p2);

        my $winner = 0;
        if ($stage == 2 && @$p1 >= $a && @$p2 >= $b)
        {
            my @p1c = @$p1[0..$a-1];
            my @p2c = @$p2[0..$b-1];
            $winner = combat(\@p1c, \@p2c, $stage, $lvl+1);
        }

        if ($winner == 1 || ($winner == 0 && $a > $b))
        {
            push(@$p1, ($a,$b));
        }
        else
        {
            push(@$p2, ($b,$a));
        }

        return 2 unless @$p1;
        return 1 unless @$p2;
    }
}

for my $stage (1..2)
{
    my @p1x = @p1;
    my @p2x = @p2;
    my $winner = combat(\@p1x, \@p2x, $stage, 1);

    my $i = 1;
    printf "stage $stage: %d\n", sum(map { $i++ * $_} reverse($winner == 1 ? @p1x : @p2x) );
}
