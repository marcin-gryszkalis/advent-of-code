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

my %dirs = (
    'l' => [-1,0],
    'r' => [1,0],
    'u' => [0,-1],
    'd' => [0,1]
);

my %exitmap = qw/
    lu J
    ru L
    dl 7
    dr F
    du |
    lr -
/;
my %rexitmap = reverse %exitmap;

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

# find starting point
my $a;
my @exits = ();
for my $d (keys %dirs)
{
    my ($dx,$dy) = @{$dirs{$d}};
    $x = $startx;
    $y = $starty;
    my $nx = $x + $dx;
    my $ny = $y + $dy;
    next unless exists $t->{$nx,$ny};
    $a = $t->{$nx,$ny};
    push(@exits, $d) if
        $d eq 'u' && $a =~ /[7F\|]/ ||
        $d eq 'd' && $a =~ /[JL\|]/ ||
        $d eq 'l' && $a =~ /[LF-]/ ||
        $d eq 'r' && $a =~ /[J7-]/;
}
my $exitcode = join("", sort @exits);
my ($dx,$dy) = @{$dirs{$exits[0]}};
$x = $startx + $dx;
$y = $starty + $dy;
$a = $t->{$x,$y};
$l->{$startx,$starty} = 1;

# traverse pipe
my $c = 0;
S: while (1)
{
    $c++;
    $l->{$x,$y} = 1;
    die if $c > $maxx*$maxy;

    for my $o (map { [$x + $_->[0], $y + $_->[1]] } map { $dirs{$_} } split(//, $rexitmap{$a}))
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

# flood fill (not really needed)
# my @fillq = grep { $t->{$_} eq 'O' } keys %$t;
# while (my $xy = pop(@fillq))
# {
#     my ($x,$y) = split /$;/, $xy;
#     for my $d (values %dirs)
#     {
#         my ($dx,$dy) = @$d;
#         my $nx = $x + $dx;
#         my $ny = $y + $dy;
#         next unless exists $t->{$nx,$ny} && $t->{$nx,$ny} eq '.';

#         $t->{$nx,$ny} = 'O';
#         $dots--;
#         push(@fillq, "$nx$;$ny");
#     }
# }

# replace S with actual pipe shape
$t->{$startx,$starty} = $exitmap{$exitcode};

YY: for my $y (0..$maxy)
{
    my $st = 'O';
    my $have = 0;
    for my $x (0..$maxx)
    {
        my $a = $t->{$x,$y};

        if ($a eq '.')
        {
            $t->{$x,$y} = $st;
            $dots--;
            last YY if $dots == 0;
            next;
        }

        die "$x,$y $a ne $st" if $a =~ /[OI]/ && $a ne $st;

        next if $a =~ /[OI-]/;

        if ($a =~ /[FL]/)
        {
            $have = $a;
            next;
        }

        next if "$have$a" =~ /(F7|LJ)/;

        # change side for FJ, L7 and |
        $st = $st eq 'O' ? 'I' : 'O';
    }
}

for my $y (0..$maxy)
{
    for my $x (0..$maxx)
    {
        print $t->{$x,$y};
    }
    print "\n";
}

die $dots if $dots > 0;

$stage2 = scalar(grep { $_ eq 'I' } values %$t);

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;