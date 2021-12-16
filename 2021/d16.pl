#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use bigint;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

sub bin
{
    return oct("0b".shift());
}

sub packet
{
    my $p = shift;

    my $v = bin(substr($p,0,3));
    $stage1 += $v;

    my $t = bin(substr($p,3,3));

#    print "packet v($v) t($t)\n";

    $p = substr($p, 6);
    if ($t == 4)
    {
        my $q;
        my $l = 0;
        while (1)
        {
            my $q1 = substr($p,0,1);
            my $q2 = substr($p,1,4);
            $q .= $q2;
            $l += 5;
            $p = substr($p, 5);
            last if $q1 eq '0';
        }

        return ($p, bin($q));
    }
    else
    {
        my @a = ();

        my $ltid = bin(substr($p,0,1));
        $p = substr($p, 1);
        if ($ltid == 0)
        {
            my $subl = bin(substr($p,0,15));
            $p = substr($p, 15);
            my $sp = $p;
            while (1)
            {
                my $uv;
                ($sp,$uv) = packet(substr($sp,0,$subl));
                push(@a,$uv);
                last if $sp eq '';
            }
            $p = substr($p, $subl);
        }
        else # ltid 1
        {
            my $subc = bin(substr($p,0,11));
            $p = substr($p, 11);
            for (1..$subc)
            {
                my $uv;
                ($p,$uv) = packet($p);
                push(@a,$uv);
            }
        }

        my $r;
        if ($t == 0) { $r = sum(@a); }
        elsif ($t == 1) { $r = product(@a) }
        elsif ($t == 2) { $r = min(@a) }
        elsif ($t == 3) { $r = max(@a) }
        elsif ($t == 5) { $r = ($a[0] > $a[1] ? 1 : 0) }
        elsif ($t == 6) { $r = ($a[0] < $a[1] ? 1 : 0) }
        elsif ($t == 7) { $r = ($a[0] == $a[1] ? 1 : 0) }
        else { die }

        return ($p, $r);
    }
}

my $i = 0;
for (@f)
{
    my $hex = $_;
    s/(..)/sprintf("%08b",hex($1))/eg;

    $stage1 = 0;

    while (1)
    {
        ($_,$stage2) = packet($_);
        last if /^0*$/;
    }

    printf "Entry %d, Stage 1: %s\n", $i, $stage1;
    printf "Entry %d, Stage 2: %s\n", $i++, $stage2;
}

