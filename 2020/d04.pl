#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $ff = read_file(\*STDIN);
$ff =~ s/\n\n/!/g;
$ff =~ s/\n/ /g;
my @f = split/!/, $ff;

my $stage1 = 0;
my $stage2 = 0;
for (@f)
{
    my @a = split/\s+/;
    my %h = ();

    for my $k (@a)
    {
        my ($n,$m) = split/:/, $k;
        $h{$n} = $m;
    }
    $h{cid} = 'xxx';
    next unless scalar(keys %h) == 8;

    $stage1++;

#byr (Birth Year) - four digits; at least 1920 and at most 2002.
    next if $h{byr} !~ /^\d{4}$/ || $h{byr} < 1920 || $h{byr} > 2002;

# iyr (Issue Year) - four digits; at least 2010 and at most 2020.
    next if $h{iyr} !~ /^\d{4}$/ || $h{iyr} < 2010 || $h{iyr} > 2020;

# eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
    next if $h{eyr} !~ /^\d{4}$/ || $h{eyr} < 2020 || $h{eyr} > 2030;

# hgt (Height) - a number followed by either cm or in:
    next unless $h{hgt} =~ m/^(\d+)(cm|in)$/;

# If cm, the number must be at least 150 and at most 193.
    next if  ($2 eq 'cm' && ($1 < 150 || $1 > 193));

# If in, the number must be at least 59 and at most 76.
    next if  ($2 eq 'in' && ($1 < 59 || $1 > 76));

# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
    next unless $h{hcl} =~ /^#[0-9a-f]{6}$/;

# ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
    next unless $h{ecl} =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/;

# pid (Passport ID) - a nine-digit number, including leading zeroes.
    next unless $h{pid} =~ /^\d{9}$/;

# cid (Country ID) - ignored, missing or not.

    $stage2++;
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";