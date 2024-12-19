#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @towels = split(/,\s*/, shift @f);
shift @f;

my @mt;
my %mem;

my $re1 = '^('.join("|", @towels).')+$';
for my $p (@f)
{
    %mem = ();
    @mt = grep { $p =~ /$_/ } @towels;

    next if $p !~ /$re1/;

    $stage1++;
    $stage2 += check($p, '');
}

sub check($p, $s)
{
    return $mem{$s} if exists $mem{$s};
    return 0 if length($s) > length($p);
    return $p eq $s if length($s) == length($p);
    return 0 if substr($p, 0, length($s)) ne $s;
    return $mem{$s} = sum map { check($p, $s.$_) } @mt;
}

say "Stage 1: ", $stage1;
say "Stage 2: ", $stage2;