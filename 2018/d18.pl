#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $M = 50; # 10 for d18a.txt
my @f = read_file(\*STDIN);

my $h;
my $final_steps = -100;

#my @cnts;
for my $stage (1..2)
{
    my $rounds = $stage == 1 ? 10 : 1_000_000_000;

    my $a;
    my $b;

    my $r = 0;
    my $s = 0;

    my @er = ('.') x ($M+2);
    $a->[$r++] = \@er;
    $b->[$s++] = \@er;
    for (@f)
    {
        chomp;

        my @er = split//;
        push(@er,'.'); unshift(@er, '.');
        $a->[$r++] = \@er;

        my @er2 = split//;
        push(@er2,'.'); unshift(@er2, '.');
        $b->[$s++] = \@er2;
    }
    my @er2 = ('.') x ($M+2);
    $a->[$r++] = \@er2;
    $b->[$s++] = \@er2;

    #my $b;
    my $c;
    for my $step (1..$rounds)
    {

        for my $x (1..$M)
        {
            for my $y (1..$M)
            {
                my $ns =
                    ($a->[$x-1]->[$y-1]) .
                    ($a->[$x-1]->[$y]) .
                    ($a->[$x-1]->[$y+1]) .
                    ($a->[$x]->[$y-1]) .
                    ($a->[$x]->[$y+1]) .
                    ($a->[$x+1]->[$y-1]) .
                    ($a->[$x+1]->[$y]) .
                    ($a->[$x+1]->[$y+1]);

                 my $c_open = () = $ns =~ /[.]/g;
                 my $c_tree = () = $ns =~ /[|]/g;
                 my $c_lumb = () = $ns =~ /[#]/g;

# An open acre will become filled with trees if three or more adjacent acres contained trees. Otherwise, nothing happens.
# An acre filled with trees will become a lumberyard if three or more adjacent acres were lumberyards. Otherwise, nothing happens.
# An acre containing a lumberyard will remain a lumberyard if it was adjacent to at least one other lumberyard and at least one acre containing trees. Otherwise, it becomes open.


                if ($a->[$x]->[$y] eq '.')
                {
                    $b->[$x]->[$y] = ($c_tree >= 3) ? '|' : '.';
                }
                elsif ($a->[$x]->[$y] eq '|')
                {
                    $b->[$x]->[$y] = $c_lumb >= 3 ? '#' : '|';
                }
                elsif ($a->[$x]->[$y] eq '#')
                {
                    $b->[$x]->[$y] = ($c_lumb >= 1 && $c_tree >= 1) ? '#' : '.';
                }
                else { die }
            }
        }

        $c = $a; # swap a/b
        $a = $b;
        $b = $c;


        if ($stage == 2) # cycle finder
        {
            # real beauty :)
            # for my $x (1..$M)
            # {
            #     for my $y (1..$M)
            #     {
            #         print $a->[$x]->[$y];
            #     }
            #     print "\n";
            # }
            # print "\n";

            if ($final_steps == -100)
            {
                my $l = '';
                for my $x (1..$M)
                {
                    $l .= join("", @{$a->[$x]});
                }
                my $md5 = md5_hex($l);
                if (exists $h->{$md5})
                {
                    my $cycle = $step - $h->{$md5};
                    my $nr = $rounds - $h->{$md5};
                    $final_steps = $nr % $cycle; # we need k steps more!
                    print "duplicate! $h->{$md5} vs $step, $final_steps steps more are needed (cycle $cycle)\n";
                }
                $h->{$md5} = $step;
            }

            if ($final_steps > -1)
            {
                $final_steps--;
                if ($final_steps < 0)
                {
                    my $l = '';
                    for my $x (1..$M)
                    {
                        $l .= join("", @{$a->[$x]});
                    }
                    my $md5 = md5_hex($l);
                    print "$step: final md5 = $md5\n";
                    last;
                }
            }
        }

    }

    my $cw = 0;
    my $cl = 0;
    for my $x (1..$M)
    {
        for my $y (1..$M)
        {
            print $a->[$x]->[$y];
            $cw++ if $a->[$x]->[$y] eq '|';
            $cl++ if $a->[$x]->[$y] eq '#';
        }
        print "\n";
    }
    printf "stage $stage: %d\n", $cw*$cl;
}

