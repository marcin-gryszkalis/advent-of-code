#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;


my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $stage1 = 0;
my $stage2 = 0;

my $a;

my $W = 0;
my $H = 0;

my @dr = qw/-1 -1 -1  0 0  1 1 1/;
my @dc = qw/-1  0  1 -1 1 -1 0 1/;

my %swap =
(
    '#' => 'L',
    'L' => '#',
);

my @tolerance = (4, 5); # per stage


my $r = 0;
my @b = split(//,'.' x ($W+2));
$a->[$r++] = \@b;
for (@ff)
{
    chomp;
    my @b = split//;

    $W = scalar(@b);
    $H++;

    push(@b,'.'); unshift(@b, '.');
    $a->[$r++] = \@b;

}
my @c = split(//,'.' x ($W+2));
$a->[$r++] = \@c;

my $init = clone($a);

for my $stage (1..2)
{
    $a = clone($init);
    my $b = clone($a);

    my $loop = 0;
    while (1)
    {
        # print "$loop:\n";
        # for my $r (1..$H)
        # {
        #     for my $c (1..$W)
        #     {
        #         print $a->[$r]->[$c];
        #     }
        #     print "\n";
        # }
        # print "\n";

        my $ch = 0;
        for my $r (1..$H)
        {
            for my $c (1..$W)
            {
                if ($a->[$r]->[$c] =~ /[L#]/)
                {
                    my $o = 0;

                    for my $d (0..7)
                    {
                        my $xr = $r;
                        my $xc = $c;
                        while (1)
                        {
                            $xr += $dr[$d];
                            $xc += $dc[$d];

                            last if $xr < 1 || $xr > $H || $xc < 1 || $xc > $W;

                            if ($a->[$xr]->[$xc] =~ /[L#]/)
                            {
                                $o++ if $a->[$xr]->[$xc] eq '#';
                                last;
                            }

                            last if $stage == 1;
                        }
                    }

                    if (
                        ($a->[$r]->[$c] eq 'L' && $o == 0) ||
                        ($a->[$r]->[$c] eq '#' && $o >= $tolerance[$stage - 1]))
                    {
                        $ch++;
                        $b->[$r]->[$c] = $swap{$b->[$r]->[$c]};
                    }
                }
            }
        }

        $a = clone($b);

        last if $ch == 0;
        $loop++;
    }

    my $res = 0;
    for my $r (1..$H)
    {
        for my $c (1..$W)
        {
            $res++ if $a->[$r]->[$c] eq '#';
        }
    }

    print "stage $stage: $res\n";

}
