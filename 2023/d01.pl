#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my %m = qw/
    one 1
    two 2
    three 3
    four 4
    five 5
    six 6
    seven 7
    eight 8
    nine 9
/;

for my $stage (1..2)
{
    my $sum = 0;
    for my $s (@f)
    {
        $_ = $s;
        if ($stage == 2)
        {
            for my $p (keys %m)
            {
                s/$p/$p$m{$p}$p/g; # overlapping "eightwo"!
            }
        }

        s/^\D+//;
        s/\D+$//;
        $sum  += substr($_,0,1).substr($_,-1);

    }

    printf "Stage $stage: %s\n", $sum;
}


#print Dumper \@f;