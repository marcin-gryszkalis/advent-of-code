#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

#my %r = ();
my @rr;
for (@f)
{
    my $l = length($_);
    my $a = substr($_,0,$l/2);
    my $b = substr($_,$l/2);

    print "$_ $a $b\n";


    my %h = ();
    my %r = ();
    for my $x (split//,$a)
    {
        $h{$x} = 1;
    }

    for my $x (split//,$b)
    {
        $r{$x} = 1 if exists $h{$x};
    }
#    print(Dumper \%r);

    push(@rr, keys %r);

}
    print(Dumper \@rr);
for my $x (@rr)
{
    my $pr;
    if ($x =~ /[a-z]/)
    {
        $pr = ord($x) - ord('a') + 1;
    }
    else
    {
        $pr = ord($x) - ord('A') + 1 + 26;
    }
    print "$x $pr\n";
            $stage1 += $pr;

}
printf "Stage 1: %s\n", $stage1;

my $i = 0;
L: while (1)
{
    last unless exists $f[$i];
    my $a = $f[$i++];
    my $b = $f[$i++];
    my $c = $f[$i++];

    for my $x (('a'..'z','A'..'Z'))
    {
        if ($a =~ /$x/ && $b =~ /$x/ && $c =~ /$x/)
        {
            my $pr;
            if ($x =~ /[a-z]/)
            {
                $pr = ord($x) - ord('a') + 1;
            }
            else
            {
                $pr = ord($x) - ord('A') + 1 + 26;
            }
            print "$x $pr\n";
            $stage2 += $pr;

            next L;
        }
    }
}
printf "Stage 2: %s\n", $stage2;

# 948