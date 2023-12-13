#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);
push(@f, ''); # add empty line at the end

my $stage1 = 0;
my $stage2 = 0;

my $x = 0;
my $y = 0;

my @rows;
my @cols;

my $i = 0;
for (@f)
{
    if ($_ eq '')
    {
        my $mul = 1;
        for my $oo (\@cols, \@rows)
        {
            my @o = @$oo;
            for my $i (0..$#o-1)
            {
                my $p = join("|", @o[0..$i]);
                my $q = join("|", reverse @o[$i+1..$#o]);

                $p = substr($p,-length($q)) if length $p > length $q;
                $q = substr($q,-length($p)) if length $q > length $p;

                $stage1 += $mul * ($i+1) if $p eq $q;

                my $d = () = ($p ^ $q) =~ m/[^\0]/g;
                $stage2 += $mul * ($i+1) if $d == 1;
            }
            $mul *= 100;
        }

        $y = 0;
        @rows = ();
        @cols = ();

        $i++;
        next;
    }

    $x = 0;
    my $r = '';
    for my $v (split//)
    {
        $r .= $v;
        $cols[$x++] .= $v;
    }
    push(@rows, $r);

    $y++;
    $i++;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
