#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my %rev = qw/jmp nop nop jmp/;

my $stage1 = 0;
my $stage2 = 0;

my %h = ();
my $acc = 0;
my $ip = 0;

while (1)
{
    if (exists $h{$ip})
    {
        $stage1 = $acc;
        last;
    }
    $h{$ip} = 1;

    my ($op,$arg) = split/\s+/, $ff[$ip];

    $ip += $arg - 1 if $op eq 'jmp';
    $acc += $arg if $op eq 'acc';
    $ip++;
}

my @f = @ff;
K: for my $k (0..scalar(@ff)-1)
{
    next if $ff[$k] =~ /acc/;
    @ff = @f;

    my ($op,$arg) = split/\s+/, $ff[$k];
    $ff[$k] = "$rev{$op} $arg";

    %h = ();
    $acc = 0;
    $ip = 0;

    while (1)
    {
        if ($ip >= @ff)
        {
            $stage2 = $acc;
            last K;
        }

#        print "$k $ip acc=$acc $ff[$ip]\n";

        next K if exists $h{$ip};
        $h{$ip} = 1;

        my ($op,$arg) = split/\s+/, $ff[$ip];

        $ip += $arg - 1 if $op eq 'jmp';
        $acc += $arg if $op eq 'acc';
        $ip++;
    }
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";
