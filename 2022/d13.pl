#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @ft = read_file(\*STDIN, chomp => 1);
my @f;
for my $a (@ft)
{
    next unless $a =~ /\[/;
    eval "\$a = $a";
    push(@f,$a);
}

my $stage1 = 0;

sub compare
{
    my ($l,$r) = @_;

    my $i = 0;
    while (1)
    {
        if (!exists $l->[$i] && exists $r->[$i])
        {
            return 1;
        }
        elsif (exists $l->[$i] && !exists $r->[$i])
        {
            return -1;
        }
        elsif (!exists $l->[$i] && !exists $r->[$i]) # eol
        {
            return 0;
        }

        my $res = 0;
        if (ref $l->[$i] && !ref $r->[$i])
        {
            $res = compare($l->[$i], [$r->[$i]]);
        }
        elsif (!ref $l->[$i] && ref $r->[$i])
        {
            $res = compare([$l->[$i]], $r->[$i]);
        }
        elsif (ref $l->[$i] && ref $r->[$i])
        {
            $res = compare($l->[$i], $r->[$i]);
        }
        else
        {
            if ($l->[$i] < $r->[$i])
            {
                $res = 1;
            }
            elsif ($l->[$i] > $r->[$i])
            {
                $res = -1;
            }
        }

        return $res if $res != 0;
        $i++;
    }

}

my $i = 0;
while (exists $f[$i])
{
    $stage1 += $i/2 + 1 if compare($f[$i], $f[$i+1]) == 1;
    $i += 2;
}

push(@f,[[2]],[[6]]);

my $d1 = 0;
my $d2 = 0;

$i = 1;
for my $a (sort { compare($b,$a) } @f)
{
    $_ = Dumper $a;
    s/.*=//;
    s/[\s;]+//g;

    $d1 = $i if $_ eq '[[2]]';
    $d2 = $i if $_ eq '[[6]]';

    $i++;
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: $d1 x $d2 = %s\n", $d1 * $d2;