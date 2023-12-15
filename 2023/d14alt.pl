#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax indexes/;
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

my $max = 1_000_000_000 - 1;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->[$x++] .= $v;
    }
    $y++;
}

my ($h, $w) = ($y, $x);
my ($maxx, $maxy) = ($w - 1, $h - 1);

sub load($tt)
{
    sum map { sum map { $maxx - $_ + 1 } indexes { $_ eq 'O' } split// } @$tt;
}

my %v;
my %maps;
for my $c (0..$max)
{
    for my $dir (1..4)
    {
        # move
        for my $s (@$t)
        {
            my $n = $s =~ s/(\.+)O/O$1/g;
            redo if $n;
        }

        $stage1 = load($t) unless $stage1;

        # rotate
        my $nt = undef;
        for (@$t)
        {
            $x = $maxx;
            for my $v (split//)
            {
                $nt->[$x--] .= $v;
            }
        }
        $t = $nt;
    }

    my $h = join(":", @$t);

    if (exists $v{$h})
    {
        my $off = $v{$h};
        my $len = $c - $v{$h};
        my $target = ($max - $off) % $len + $off;
        $stage2 = load([split(/:/, $maps{$target})]);
        last;
    }

    $v{$h} = $c;
    $maps{$c} = $h;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;