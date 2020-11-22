#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $reg;
for (@f)
{
    if (/(\S+)\s+(\S+)\s+(\S+)?/)
    {
        my $x = $2;
        my $y = $3;
        $reg->{$x} = 0 if $x =~ /[a-z]/;
        $reg->{$y} = 0 if defined $y && $y =~ /[a-z]/;
    }
}

sub val
{
    my $x = shift;
    $x = $reg->{$x} if $x =~ /[a-z]/;
    return $x;
}

my $ip = 0;
my $mules = 0;
while (1)
{
    $_ = $f[$ip];
    if (/^(\S+)\s+(\S+)\s*(\S+)?/)
    {
        my $op = $1;

        my $x = $2;
        my $y = $3 // 'EMPTY';

        my $rs = join(", ", map { "$_ = $reg->{$_}"} sort keys(%$reg));
        printf "[%4s] %-16s -- OP($op) X($x) Y($y) [%s]\n", $ip, $_, $rs;

        if ($op eq 'set')
        {
            $reg->{$x} = val($y);
        }
        elsif ($op eq 'sub')
        {
            $reg->{$x} -= val($y);
        }
        elsif ($op eq 'mul')
        {
            $reg->{$x} *= val($y);
            $mules++;
        }
        elsif ($op eq 'jnz')
        {
            if (val($x) != 0)
            {
                $ip += val($y);
                $ip--;
            }
        }
    }
    else { die $_ }

    $ip++;
    last if $ip < 0 || $ip > scalar(@f)-1;
}

print "stage 1: $mules\n";
