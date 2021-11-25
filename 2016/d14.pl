#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Digest::MD5 qw(md5_hex);

my @hex = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f);

my $RED="\e[31m"; 
my $RST="\e[0m";

my $input = "ahsbgdzn";
# $input = "abc"; # test version

my $h;

my @stretch = qw(0 2016);

sub scan($$)
{
    my $idx = shift;
    my $stretchrounds = shift;
    return if exists $h->{$idx};

    my $xh = md5_hex($input.$idx);
    for my $sr (1..$stretchrounds)
    {
        $xh = md5_hex($xh);
    }

    if ($xh =~ /(.)\1\1/)
    {    
        my $c = $1;
        $h->{$idx}->{three} = hex($c);
    }
    
    for my $k (0..15)
    {
        my $c = $hex[$k];
        if ($xh =~ /$c$c$c$c$c/)
        {
            $h->{$idx}->{five}->{$k} = 1;
        }
    }
 
    $h->{$idx}->{hash} = $xh; 
}

for my $stage(1..2)
{
    $h = undef;
    my $i = 0;
    my $fnd = 0;
    LOOP: while (1)
    {
        scan($i, $stretch[$stage-1]);
    
        if (exists $h->{$i}->{three})
        {
            for my $j ($i+1..$i+1+1000)
            {
                scan($j, $stretch[$stage-1]);
    
                if (exists $h->{$j}->{five}->{$h->{$i}->{three}})
                {
                    $fnd++;
                    my $dist = $j - $i;
                    my $ix = $hex[$h->{$i}->{three}];
                    my $h1 = $h->{$i}->{hash};
                    my $h2 = $h->{$j}->{hash};
                    $h1 =~ s/($ix{3})/$RED$1$RST/;
                    $h2 =~ s/($ix{5})/$RED$1$RST/;
                    
                    print "$stage $fnd: $i ($ix) -> $j [dist=$dist] | $h1 - $h2\n";
                    
                    last LOOP if $fnd == 64;
                    last;
                }
            }
        }
        $i++;
    }

}
