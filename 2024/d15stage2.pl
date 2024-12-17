#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
use Time::HiRes qw/usleep/;
$; = ',';

my $op = {
    '<' => { 'x' => -1, 'y' => 0 },
    '>' => { 'x' => 1, 'y' => 0 },
    '^' => { 'x' => 0, 'y' => -1 },
    'v' => { 'x' => 0, 'y' => 1 }
};

my @f = read_file(\*STDIN, chomp => 1);

my $stage2 = 0;

my $t;

my ($x, $y) = (0, 0);
my ($startx, $starty) = (0, 0);
for (@f)
{
    last if /^$/;
    $x = 0;
    for my $v (split//)
    {
        if ($v eq 'O')
        {
            $t->{$x++,$y} = '[';
            $t->{$x++,$y} = ']';
        }
        elsif ($v eq '#')
        {
            $t->{$x++,$y} = '#';
            $t->{$x++,$y} = '#';
        }
        else
        {
            ($startx, $starty) = ($x, $y) if $v eq '@';
            $t->{$x++,$y} = $v;
            $t->{$x++,$y} = '.';
        }
    }
    $y++;
}

my @path = map { split // } grep { /[<>v^]/ } @f;

my ($h, $w) = ($y, 2*length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

($x, $y) = ($startx, $starty);

M: for my $m (@path)
{
    my $dx = $op->{$m}->{x};
    my $dy = $op->{$m}->{y};

    my @tocheck = ();
    push(@tocheck, [$x,$y]);
    my %checked = ();
    my @tomove = ();

    while (my $o = shift @tocheck)
    {
        my ($cx, $cy) = @$o;

        next if $t->{$cx,$cy} eq '.';
        next if exists $checked{$cx,$cy};
        $checked{$cx,$cy} = 1;
        next M if $t->{$cx+$dx,$cy+$dy} eq '#';

        push(@tocheck, [$cx+$dx,$cy+$dy]);
        push(@tomove, [$cx,$cy]);
        push(@tocheck, [$cx+1,$cy]) if $t->{$cx,$cy} eq '[';
        push(@tocheck, [$cx-1,$cy]) if $t->{$cx,$cy} eq ']';
    }

    for my $o (sort { $dx == 0 ? (-$dy)*( $a->[1] <=> $b->[1] ) : (-$dx)*( $a->[0] <=> $b->[0] ) } @tomove)
    {
        my ($cx, $cy) = @$o;
        $t->{$cx+$dx,$cy+$dy} = $t->{$cx,$cy};
        $t->{$cx,$cy} = '.';
    }

    $x += $dx;
    $y += $dy;

    if (0) # Animation
    {
        for my $py (0..$maxy)
        {
            for my $px (0..$maxx)
            {
                print $t->{$px,$py};
            }
            print "\n";
        }
        usleep(25000);
    }
}

for my $py (0..$maxy)
{
    for my $px (0..$maxx)
    {
        $stage2 += (100 * $py + $px) if $t->{$px,$py} eq '[';
        if ($px == $x && $py == $y) { print "@"; next }
        print $t->{$px,$py};
    }

    print "\n";
}

say "Stage 2: ", $stage2;
