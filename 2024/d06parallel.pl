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
use MCE::Map;
    # max_workers => 4,                # Default 'auto'
    # chunk_size => 100,               # Default 'auto'
    # tmp_dir => "/path/to/app/tmp",   # $MCE::Signal::tmp_dir
    # freeze => \&encode_sereal,       # \&Storable::freeze
    # thaw => \&decode_sereal,         # \&Storable::thaw
    # init_relay => 0,                 # Default undef; MCE 1.882+
    # use_threads => 0,                # Default undef; MCE 1.882+
$; = ',';

my @dirs = ( [0,-1], [1,0], [0, 1], [-1, 0] );

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;
my $t;
my $startx;
my $starty;
for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        ($startx, $starty)  = ($x, $y) if $v eq '^';
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

($x, $y) = ($startx, $starty);
my $dir = 0;
my $xed;
while (1)
{
    $xed->{$x,$y} = 1;

    my ($nx, $ny) = ($x + $dirs[$dir]->[0], $y + $dirs[$dir]->[1]);
    last if $nx < 0 || $nx > $maxx || $ny < 0 || $ny > $maxy;
    if ($t->{$nx,$ny} eq '#')
    {
        $dir = ($dir + 1) % 4;
        redo;
    }
    ($x, $y) = ($nx, $ny);
}

$stage1 = keys %$xed;

$stage2 = sum mce_map { loopcheck(split/,/) } keys %$xed;

sub loopcheck($ox, $oy)
{
    return 0 if $t->{$ox,$oy} eq '^' || $t->{$ox,$oy} eq '#';

    my ($x, $y) = ($startx, $starty);
    my $dir = 0;
    my $detect = undef;
    while (1)
    {
        return 1 if exists $detect->{$x,$y,$dir};

        $detect->{$x,$y,$dir} = 1;

        my ($nx, $ny) = ($x + $dirs[$dir]->[0], $y + $dirs[$dir]->[1]);

        return 0 if $nx < 0 || $nx > $maxx || $ny < 0 || $ny > $maxy;
        if ($t->{$nx,$ny} eq '#' || ($nx == $ox && $ny == $oy))
        {
            $dir = ($dir + 1) % 4;
            redo;
        }
        ($x, $y) = ($nx, $ny);
    }
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;
