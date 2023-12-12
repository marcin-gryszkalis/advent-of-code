#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations combinations_with_repetition variations_with_repetition/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

# naive brute force, valid for stage 1
sub go($p, $counts)
{
    if ($p =~ /\?/)
    {
        my $a = ($p =~ s/\?/./r);
        my $b = ($p =~ s/\?/#/r);
        return go($a, $counts) + go($b, $counts);
    }

    my $t = join(",", grep { $_ != 0 } map { length $_ } split(/\.+/,$p));
    return $t eq $counts ? 1 : 0;
}

my $numofspaces = 0;
my $numofspaceblocks = 0;
my $maxlenofspaceblock = 0;

my $pattern = '';
my @c = ();

my %dp = ();

# every level adds one ### block
sub go2($usedspaces, $level, $s)
{
    # cache key - level (number of ### blocks) + length of string up to now -- f("# #  # ") == f("#  # # ")
    my $dpk = "$level:".length($s);
    return $dp{$dpk} if exists $dp{$dpk};


    if ($level == scalar @c)
    {
        $s .= " " x (length($pattern) - length($s));
        return $s =~ /^$pattern$/ ? 1 : 0;
    }
        
    my $start = $level == 0 ? 0 : 1; # first block can be empty, last as well but we don't add last one here

    my $v = 0;
    for my $i ($start..$maxlenofspaceblock)
    {
        last if $usedspaces + $i > $numofspaces;

        my $t = 
            $s . 
            " " x $i . 
            "#" x $c[$level];

        my $qq = length($t) < length($pattern) ? substr($pattern, 0, length $t) : $pattern;

        next unless $t =~ /^$qq/;

        $v += go2($usedspaces + $i, $level + 1, $t)
    }

    return $dp{$dpk} = $v;
}

for my $stage (1..2)
{
    my $sum = 0;
    for (@f)
    {
        my ($p,$counts) = split/\s/;
    
        if ($stage == 2)
        {
            $p = join('?', (($p) x 5));
            $counts = join(',', (($counts) x 5));
        }
    
        @c = ($counts =~ m/\d+/g);
    
        my $l = length($p);
    
        my $numofhashesreal = sum(@c);
        my $numofhashes = () = $p =~ /#/g;
        my $numofquestm = () = $p =~ /\?/g;
        my $numofdots = () = $p =~ /\./g;
    
        $numofspaces = $numofdots + $numofquestm - ($numofhashesreal - $numofhashes);
        $numofspaceblocks = (() = $counts =~ s/\D+//g) + 2;
        $maxlenofspaceblock = $numofspaces - ($numofspaceblocks - 2 - 1);
    
        $pattern = $p;
        $pattern =~ s/\./ /g;
        $pattern =~ s/\?/./g;
    
        %dp = ();
        $sum += go2(0, 0, '');
    }

    printf "Stage $stage: %s\n", $sum;
}
