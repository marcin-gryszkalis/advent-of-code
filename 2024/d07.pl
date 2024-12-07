#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations variations_with_repetition/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my %opfns = (
    '+' => sub { return $_[0] + $_[1] },
    '*' => sub { return $_[0] * $_[1] },
    '.' => sub { return $_[0] . $_[1] },
);

for my $stage (1..2)
{
    my @ops = qw/+ */;
    push(@ops, '.') if $stage == 2;

    my $total = 0;

    F: for (@f)
    {
        my @vals = split/:?\s+/;
        my $sum = shift @vals;

        my $i = variations_with_repetition(\@ops, $#vals);
        C: while (my $c = $i->next)
        {
            my @v = @vals;
            my $s = shift @v;
            while (my $u = shift @v)
            {
                my $o = shift @$c;
                $s = $opfns{$o}($s,$u);
                next C if $s > $sum;
            }

            if ($s == $sum)
            {
                $total += $sum;
                next F;
            }
        }
    }

    say "Stage $stage: ", $total;
}
