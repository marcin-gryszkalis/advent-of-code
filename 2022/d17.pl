#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;

my @jets = split//,read_file(\*STDIN, chomp => 1);

my @tostopafter = qw/2022 1000000000000/;

my @shapes;
my @ss = split/\n\n/,
'####

 #
###
 #

###
  #
  #

#
#
#
#

##
##';

my $si = 0;
while (my $s = shift @ss)
{
    my $y = 0;
    my $maxx = 0;
    for my $l (split /\n/,$s)
    {
        my $x = 0;
        for (split //,$l)
        {
            $shapes[$si]->{m}->{$x,$y} = 1 if /#/;
            $x++;
        }
        $maxx = max($maxx,$x-1);
        $y++;
    }
    $shapes[$si]->{maxx} = $maxx;
    $shapes[$si]->{maxy} = $y;
    $si++;
}

for my $stage (1..2)
{
    my $falling = 0; # are we falling?
    my $stopped = 0; # number of stopped rocks

    my $m = undef;
    for my $x (0..6) { $m->{$x,0} = '#' } # floor

    my $highest = 0;
    my $highest_mod = 0; # mod for cycles skipped

    my $r; # current shape
    my $rx = 0; # current rock position
    my $ry = 0;

    my $shapeid = 0;
    my $jetid = 0;

    my $icycle = 0; # cycle detection
    my $ph = 0;
    my $ps = 0;
    my @a_stopped = ();
    my @a_highest = ();

    my $tostop = $tostopafter[$stage - 1];

    while (1)
    {
        # cycle detection
        if ($jetid == 0 && $shapeid == 0 && $highest_mod == 0)
        {
            push(@a_stopped, $stopped - $ps); # we save diffs
            push(@a_highest, $highest - $ph);

            my $headskip = 3; # skip few potential cycles at the beginning
            my $nc = $icycle - $headskip + 1; # number of potential cycles to be checked
            if ($icycle > $headskip && $nc > 1 && $nc % 2 == 0) # must be divisible by 2
            {
                my $s1 = sum(@a_stopped[$headskip+0..$headskip+$nc/2-1]);
                my $s2 = sum(@a_stopped[$headskip+$nc/2..$headskip+$nc-1]);
                my $h1 = sum(@a_highest[$headskip+0..$headskip+$nc/2-1]);
                my $h2 = sum(@a_highest[$headskip+$nc/2..$headskip+$nc-1]);

                if ($s1 == $s2 && $h1 == $h2) # we have a cycle!
                {
                    # cycles to be skipped
                    my $cycles = int($tostop/$s1) - $headskip - 1; # step back a bit and to the rest as always

                    $stopped += $cycles * $s1;
                    $highest_mod = $cycles * $h1;
                }
            }

            $icycle++;
            $ph = $highest;
            $ps = $stopped;
        }

        if (!$falling) # drop new rock
        {
            $falling = 1;
            $r = $shapes[$shapeid];
            $shapeid = ($shapeid + 1) % 5;
            $ry = $highest + 4;
            $rx = 2;
        }

        # jet
        my $nx = $rx + ($jets[$jetid] eq '<' ? -1 : +1);
        $jetid = ($jetid + 1) % scalar(@jets);

        my $ok = 1;
        V1: for my $x (0..$r->{maxx})
        {
            for my $y (0..$r->{maxy})
            {
                next unless exists $r->{m}->{$x,$y};
                next if $nx + $x >= 0 && $nx + $x <= 6 && !exists $m->{$nx+$x,$ry+$y};

                $ok = 0;
                last V1;
            }
        }

        $rx = $nx if $ok;

        # fall
        my $ny = $ry - 1;

        $ok = 1;
        V2: for my $x (0..$r->{maxx})
        {
            for my $y (0..$r->{maxy})
            {
                next unless exists $r->{m}->{$x,$y};
                next unless exists $m->{$rx+$x,$ny+$y};

                $ok = 0;
                last V2;
            }
        }

        if ($ok)
        {
            $ry = $ny;
        }
        else # stop!
        {
            $falling = 0;
            $stopped++;

            # for nice drawing:
            # my @chars = qw/0 @ $ % X M O/;
            # my $c = $chars[$stopped % scalar @chars];
            my $c = 1;

            for my $x (0..$r->{maxx})
            {
                for my $y (0..$r->{maxy})
                {
                    next unless exists $r->{m}->{$x,$y};
                    $m->{$rx+$x,$ry+$y} = $c;
                    $highest = max($highest, $ry+$y);
                }
            }

            last if $stopped == $tostop; # after recalculating $highest
        }

        # draw map
        # if ($falling == 0)
        # {
        #     for my $y (0..$highest)
        #     {
        #         for my $x (0..6)
        #         {
        #             print exists $m->{$x,$highest - $y} ? $m->{$x,$highest - $y} : '.';
        #         }
        #         print "\n";
        #     }
        #     print "\n\n";
        # }

    }

    printf "Stage $stage: %s\n", $highest_mod + $highest;
}