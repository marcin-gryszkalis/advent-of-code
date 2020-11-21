#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $rules;
while (<>)
{
    chomp;
    my ($a,$b) = split/ =\> /;
    $rules->{$a} = $b;
}

# generate all flips and rotations
while (1)
{
    my $rn = scalar keys %$rules;
    for my $k (keys %$rules)
    {
        $_ = $k;

        if (length($k) == 5) # 2x2
        {
            s{(.)(.)/(.)(.)}{$3$1/$4$2};    $rules->{$_} = $rules->{$k}; # rotate
            s{(..)/(..)}{$2/$1};            $rules->{$_} = $rules->{$k}; # flip h
            s{(.)(.)/(.)(.)}{$2$1/$4$3};    $rules->{$_} = $rules->{$k}; # flip v
        }
        else # 3x3
        {
            s{(.)(.)(.)/(.)(.)(.)/(.)(.)(.)}{$7$4$1/$8$5$2/$9$6$3}; $rules->{$_} = $rules->{$k}; # rotate
            s{(...)/(...)/(...)}{$3/$2/$1};                         $rules->{$_} = $rules->{$k}; # flip h
            s{(.)(.)(.)/(.)(.)(.)/(.)(.)(.)}{$3$2$1/$6$5$4/$9$8$7}; $rules->{$_} = $rules->{$k}; # flip v
        }
    }
    last unless scalar keys %$rules > $rn;
}

my $m = [[ '.','#','.'],[ '.','.','#'],[ '#','#','#']];

my $count = 0;
my $side = 3;
for my $phase (1..18)
{
    my $n = undef;

    my $sstep = $side%2 == 0 ? 2 : 3;
    my $dstep = $side%2 == 0 ? 3 : 4;
    my $newside = $side / $sstep * $dstep;

    my $sr = 0;
    my $dr = 0;
    while ($sr < $side)
    {
        my $sc = 0;
        my $dc = 0;
        while ($sc < $side)
        {
            my $pattern = '';
            my $r = 0;
            while ($r < $sstep)
            {
                my $c = 0;
                while ($c < $sstep)
                {
                    $pattern .= $m->[$sr+$r]->[$sc+$c];
                    $c++;
                }
                $r++;
            }

            my @pa = ( $pattern =~ m/.{$sstep}/g );
            $pattern = join("/",@pa);
            die "s($sc,$sr) $pattern" unless exists $rules->{$pattern};
            my $pattarr = undef;
            for my $pr (split/\//, $rules->{$pattern})
            {
                push(@$pattarr, [split(//, $pr)]);
            }

            $r = 0;
            while ($r < $dstep)
            {
                my $c = 0;
                while ($c < $dstep)
                {
                    $n->[$dr+$r]->[$dc+$c] = $pattarr->[$r]->[$c];
                    $c++;
                }
                $r++;
            }

            $sc += $sstep;
            $dc += $dstep;
        }
        $sr += $sstep;
        $dr += $dstep;
    }

    $side = $newside;
    $m = $n;

    $count = 0;
    for my $r (0..$side-1)
    {
        for my $c (0..$side-1)
        {
            # print $m->[$r]->[$c];
            $count++ if $m->[$r]->[$c] eq '#';
        }
        # print "\n";
    }
    # print "\n";

    printf "phase %2d = %10d %s\n", $phase, $count, ($phase == 5 || $phase == 18) ? "stage" : "";
}
