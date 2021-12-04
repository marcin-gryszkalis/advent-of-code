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
@f = grep {/\d/} map { chomp; $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my @b = split/,/, shift @f;

my $t; # tables
my $h; # hits
my $bc = scalar(@f) / 5;

for my $tn (0..$bc-1)
{
    my $tab = ();
    for my $x (0..4)
    {
        my @r = (shift(@f) =~ /\d+/g);
        for my $y (0..4)
        {
            $t->{$tn}->{$x,$y} = $r[$y];
            $h->{$tn}->{$x,$y} = 0;
        }
    }
}

my $wnb;
LOOP: while (1)
{
    my $n = shift @b;
    last unless defined $n;

    for my $tn (0..$bc-1)
    {
        for my $x (0..4)
        {
            for my $y (0..4)
            {
                $h->{$tn}->{$x,$y} = 1 if $t->{$tn}->{$x,$y} == $n;
            }
        }
    }

    for my $tn (0..$bc-1)
    {
        next if exists $wnb->{$tn};
        for my $x (0..4)
        {
            my $sx = 0;
            my $sy = 0;
            for my $y (0..4)
            {
                $sx += $h->{$tn}->{$x,$y};
                $sy += $h->{$tn}->{$y,$x};
            }

            if ($sx == 5 || $sy == 5)
            {
                my $r = 0;
                for my $xx (0..4)
                {
                    for my $yy (0..4)
                    {
                        $r += $t->{$tn}->{$xx,$yy} if $h->{$tn}->{$xx,$yy} == 0;
                    }
                }

                $stage1 = $r * $n if $stage1 == 0;
                $stage2 = $r * $n;
                $wnb->{$tn} = 1;
            }

        }
    }

}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;