#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);


my @f = read_file(\*STDIN);

# A room is real (not a decoy)
# if the checksum is the five most common letters in the encrypted name, in order, with ties broken by alphabetization. For example:

sub caesar
{
    my ($r, $i) = @_;

    $r = ord($r);
    $r -= ord('a');
    $r = ($r + $i) % 26;
    $r = chr($r + ord('a'));
    return $r;
}

# aaaaa-bbb-z-y-x-123[abxyz]
my $stage1 = 0;
for (@f)
{
    chomp;
    die unless /([a-z-]+)(\d+)\[(.*)\]/;
    my $l = $1;
    my $r = $1;
    my $sector = $2;
    my $checksum = $3;

    my $h = {};
    $l =~ s/-//g;
    for my $a (split//, $l)
    {
        $h->{$a}++;
    }

    my @c = sort { $h->{$b} <=> $h->{$a} || $a cmp $b } keys %$h;
    my $c2 = join("", @c);

    # print "$_ ($r) -> $c2 vs $checksum\n";
    if ($c2 =~ /^$checksum/)
    {
        $stage1 += $sector;

        $r =~ s/([a-z])/caesar($1,$sector)/eg;
        if ($r =~ /northpole/)
        {
            print "stage 2: $sector\n";
        }
#        print "$r\n";
    }
}

printf "stage 1: %d\n", $stage1;