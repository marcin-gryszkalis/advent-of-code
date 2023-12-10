#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;

my $startx  = 0;
my $starty  = 0;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        if ($v eq 'S')
        {
            $startx = $x;
            $starty = $y;
        }
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;

my $l; # pipe
my $a;
for my $ddy (-1..1)
{
    for my $ddx (-1..1)
    {
        $x = $startx;
        $y = $starty;
        next if abs($ddx) + abs($ddy) != 1;
        my $nx = $x + $ddx;
        my $ny = $y + $ddy;
        next unless exists $t->{$nx,$ny};
        $a = $t->{$nx,$ny};

        if (
            $a eq '-' && abs($ddx) == 1 ||
            $a eq '|' && abs($ddy) == 1 ||
            $a eq 'J' && ($ddx == 1 || $ddy == 1) ||
            $a eq '7' && ($ddx == 1 || $ddy == -1) ||
            $a eq 'F' && ($ddx == -1 || $ddy == -1) ||
            $a eq 'L' && ($ddx == -1 || $ddy == 1)
            )
        {
            $l->{$x,$y} = 1;
            $x = $nx;
            $y = $ny;
            last;
        }
    }
}

my $c = 0;
S: while (1)
{
    $c++;
#    print "$c $x,$y (pa = $a)\n";
    $l->{$x,$y} = 1;
    die if $c > $maxx*$maxy;

    my @out = ();
    if ($a eq '|')
    {
        push(@out, [$x,$y-1]);
        push(@out, [$x,$y+1]);
    }
    elsif ($a eq '-')
    {
        push(@out, [$x-1,$y]);
        push(@out, [$x+1,$y]);
    }
    elsif ($a eq 'L')
    {
        push(@out, [$x,$y-1]);
        push(@out, [$x+1,$y]);
    }
    elsif ($a eq 'J')
    {
        push(@out, [$x,$y-1]);
        push(@out, [$x-1,$y]);
    }
    elsif ($a eq 'F')
    {
        push(@out, [$x,$y+1]);
        push(@out, [$x+1,$y]);
    }
    elsif ($a eq '7')
    {
        push(@out, [$x,$y+1]);
        push(@out, [$x-1,$y]);
    }

    for my $o (@out)
    {
        my ($nx,$ny) = @$o;
        die unless exists $t->{$nx,$ny};

        $a = $t->{$nx,$ny};

        next if exists $l->{$nx,$ny};
        die if $a eq '.';

        $l->{$x,$y} = 1;
        $x = $nx;
        $y = $ny;
        next S;
    }

    last S; # end of pipe, no out
}

$stage1 = ($c+1) / 2;

# cleanup and count
my $dots = 0;
for my $x (0..$maxx)
{
    for my $y (0..$maxy)
    {
        $t->{$x,$y} = '.' unless exists $l->{$x,$y};
        $dots++ if $t->{$x,$y} eq '.';
    }
}

# place some Os on the border
for my $x (0..$maxx)
{
    for my $y (0..$maxy)
    {
        if ($t->{$x,$y} eq '.' && ($x == 0 || $x == $maxx || $y == 0 || $y == $maxy))
        {
            $t->{$x,$y} = 'O';
            $dots--;
        }
    }
}

while (1) # flood fill
{
    my $pdots = $dots;
    for my $x (0..$maxx)
    {
        Y: for my $y (0..$maxy)
        {
            next unless $t->{$x,$y} eq '.';
            for my $dy (-1..1)
            {
                for my $dx (-1..1)
                {
                    next if abs($dx) + abs($dy) != 1;
                    my $nx = $x + $dx;
                    my $ny = $y + $dy;
                    next unless exists $t->{$nx,$ny};

                    if ($t->{$nx,$ny} eq 'O')
                    {
                        $t->{$x,$y} = 'O';
                        $dots--;
                        next Y;
                    }
                }
            }

        }
    }

    last if $pdots == $dots || $dots == 0;
}

YY: for my $y (0..$maxy)
{
    XX: for my $x (0..$maxx)
    {
        if ($t->{$x,$y} =~ /[OI]/)
        {
            my $st = $t->{$x,$y};

            my $xf = 0;
            my $xl = 0;
            my $p = '';
            my $ny = $y;
            for my $nx ($x+1 .. $maxx) # go right
            {
                last unless exists $t->{$nx,$ny};
                my $a = $t->{$nx,$ny};
                if ($t->{$nx,$ny} eq '.')
                {
                    $p =~ s/[-OI]//g;
                    my $q = $p;
                    while (1)
                    {
                        $p =~ s/(.*)\|(.*)\|(.*)/$1$2$3/;
                        $p =~ s/(.*)F(.*)7(.*)/$1$2$3/;
                        $p =~ s/(.*)7(.*)F(.*)/$1$2$3/;
                        $p =~ s/(.*)L(.*)J(.*)/$1$2$3/;
                        $p =~ s/(.*)J(.*)L(.*)/$1$2$3/;
                        $p =~ s/(.*)L(.*)7(.*)/$1$2$3|/;
                        $p =~ s/(.*)7(.*)L(.*)/$1$2$3|/;
                        $p =~ s/(.*)F(.*)J(.*)/$1$2$3|/;
                        $p =~ s/(.*)J(.*)F(.*)/$1$2$3|/;
                        last if $p eq $q;
                        $q = $p;
                    }
#print "p($p)\n";
                    if ($p eq '|')
                    {
                        $st = $st eq 'O' ? 'I' : 'O';
                    }

                    $t->{$nx,$ny} = $st;
                    $dots--;
                    last YY if $dots == 0;
                    next XX;
                }
                $p .= $a;
            }

        }
    }
}

die $dots if $dots > 0;

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print $t->{$x,$y};
        $stage2++ if $t->{$x,$y} eq 'I';
    }
    print "\n";
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;