#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my @jets = split//,$f[0];

my $tostop = 2022;

my $stage1 = 0;
my $stage2 = 0;

my $m;
for my $x (0..6)
{
    $m->{$x}->{0} = '#';
}

my $highest = 0; # floor


my @shapes;

####
my $xs = undef;
$xs->{maxx} = 3;
$xs->{maxy} = 0;
$xs->{m}->{0}->{0} = 1;
$xs->{m}->{1}->{0} = 1;
$xs->{m}->{2}->{0} = 1;
$xs->{m}->{3}->{0} = 1;
push(@shapes, $xs);

 #
###
 #
$xs = undef;
$xs->{maxx} = 2;
$xs->{maxy} = 2;
$xs->{m}->{1}->{0} = 1;
$xs->{m}->{0}->{1} = 1;
$xs->{m}->{1}->{1} = 1;
$xs->{m}->{2}->{1} = 1;
$xs->{m}->{1}->{2} = 1;
push(@shapes, $xs);

  #
  #
###
$xs = undef;
$xs->{maxx} = 2;
$xs->{maxy} = 2;
$xs->{m}->{2}->{2} = 1;
$xs->{m}->{2}->{1} = 1;
$xs->{m}->{0}->{0} = 1;
$xs->{m}->{1}->{0} = 1;
$xs->{m}->{2}->{0} = 1;
push(@shapes, $xs);

#
#
#
#
$xs = undef;
$xs->{maxx} = 0;
$xs->{maxy} = 3;
$xs->{m}->{0}->{0} = 1;
$xs->{m}->{0}->{1} = 1;
$xs->{m}->{0}->{2} = 1;
$xs->{m}->{0}->{3} = 1;
push(@shapes, $xs);

##
##
$xs = undef;
$xs->{maxx} = 1;
$xs->{maxy} = 1;
$xs->{m}->{0}->{0} = 1;
$xs->{m}->{1}->{0} = 1;
$xs->{m}->{0}->{1} = 1;
$xs->{m}->{1}->{1} = 1;
push(@shapes, $xs);

# print Dumper @shapes;

my $ii = 0;
my $falling = 0;
my $i = $highest + 3;
my $rx = 0;
my $ry = 0;
my $stopped = 0;
my $shapeid = 0;
my $jetid = 0;
my $r;
while (1)
{
    $ii++;

    if (!$falling)
    {
        $falling = 1;
        $r = $shapes[$shapeid];
        $shapeid = ($shapeid + 1) % 5;
        $ry = $highest + 4;
        $rx = 2;
        # print Dumper $r; exit;
    }

    # jet
    my $nx;
    my $move = $jets[$jetid];
    if ($move eq '<')
    {
        $nx = $rx - 1;
    }
    else
    {
        $nx = $rx + 1;
    }
    $jetid = ($jetid + 1) % scalar(@jets);

    my $ok = 1;
    V1: for my $x (0..$r->{maxx})
    {
        for my $y (0..$r->{maxy})
        {
            next unless exists $r->{m}->{$x}->{$y};
            if ($nx + $x < 0)
            {
                $ok = 0;
                last V1;
            }

            if ($nx + $x > 6)
            {
                $ok = 0;
                last V1;
            }

            if (exists $m->{$nx+$x}->{$ry+$y})
            {
                $ok = 0;
                last V1;
            }
        }
    }
if ($ii == 13)
{
    print Dumper $r;
    print Dumper $ok;
}
    if ($ok)
    {
#        print "!!! $ii moved $move\n";
        $rx = $nx;
    }

    # fall
    my $ny = $ry - 1;

    $ok = 1;
    V2: for my $x (0..$r->{maxx})
    {
        for my $y (0..$r->{maxy})
        {
            next unless exists $r->{m}->{$x}->{$y};
            if (exists $m->{$rx+$x}->{$ny+$y})
            {
                $ok = 0;
                last V2;
            }
        }
    }

    if ($ok)
    {
        $ry = $ny;
    }
    else
    {
        $falling = 0;

        $stopped++;

        for my $x (0..$r->{maxx})
        {
            for my $y (0..$r->{maxy})
            {
                next unless exists $r->{m}->{$x}->{$y};
                $m->{$rx+$x}->{$ry+$y} = '#';
                $highest = max($highest, $ry+$y);
            }
        }

        last if $stopped == $tostop;

    }

    print "\nhighest: $highest\n";
    print "falling = $falling, stopped = $stopped\n";
    print "move $move r=($rx,$ry)\n";

    if ($falling == 0 && $ii < 100)
    {
        for my $y (0..$highest)
        {
            for my $x (0..6)
            {
                print exists $m->{$x}->{$highest - $y} ? '#' : '.';
            }
            print "\n";
        }
        print "\n\n";
    }

#exit;
}
printf "Stage 1: %s\n", $highest;
printf "Stage 2: %s\n", $stage2;