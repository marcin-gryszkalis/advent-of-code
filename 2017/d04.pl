#!/usr/bin/perl
use Data::Dumper;
use List::Util qw/min max/;
use File::Slurp;

my @f = read_file(\*STDIN);

my $ok1 = 0;
my $ok2 = 0;
L: for (@f)
{
    chomp;
    my @a = split/\s+/;

    my %h1 = ();
    my %h2 = ();

    my $bad1 = 0;
    my $bad2 = 0;
    for my $w (@a)
    {
        $bad1 = 1 if exists $h1{$w};
        $h1{$w} = 1;

        $w = join("", sort(split(//, $w)));

        $bad2 = 1 if exists $h2{$w};
        $h2{$w} = 1;

        last if $bad1 && $bad2;
    }

    $ok1++ unless $bad1;
    $ok2++ unless $bad2;
}

printf "stage 1: %d\n", $ok1;
printf "stage 2: %d\n", $ok2;