#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs pairmap pairgrep pairfirst pairkeys pairvalues zip mesh/;
use List::MoreUtils qw/firstidx frequency mode pairwise slide minmax minmaxstr/;
# use Algorithm::Combinatorics qw/combinations permutations variations/;
use POSIX qw/ceil floor/;
use Clone qw/clone/;
use MCE::Map;
no warnings 'portable';
$; = ',';

my $f = read_file(\*STDIN, chomp => 1);
my @code = $f =~ m/(\d+)/g;
my $sA = shift @code;
my $sB = shift @code;
my $sC = shift @code;

my ($A,$B,$C);
sub combo($a)
{
    return $a if $a < 4;
    return $A if $a == 4;
    return $B if $a == 5;
    return $C if $a == 6;
    die;
}

sub bin2dec($b) { oct("0b$b") }

sub process
{
    ($A,$B,$C) = @_;
    my @out = ();

    my $ip = 0;
    while (1)
    {
        my $cmd = $code[$ip];
        last unless defined $cmd;

        my $op = $code[$ip+1];

    #    say("$ip: $A $B $C -- ", join(",", @out));
        if ($cmd == 0) # adv
        {
            $A = int($A / (2 ** combo($op)));
        }
        elsif ($cmd == 1) # bxl
        {
            $B = $B ^ $op;
        }
        elsif ($cmd == 2) # bst
        {
            $B = combo($op) % 8;
        }
        elsif ($cmd == 3) # jnz
        {
            if ($A != 0)
            {
                $ip = $op;
                next;
            }
        }
        elsif ($cmd == 4) # bxc
        {
            $B = $B ^ $C;
        }
        elsif ($cmd == 5) # out
        {
            push(@out, combo($op) % 8)
        }
        elsif ($cmd == 6) # bdv
        {
            $B = int($A / (2 ** combo($op)));
        }
        elsif ($cmd == 7) # cdv
        {
            $C = int($A / (2 ** combo($op)));
        }
        else
        {
            die;
        }

        $ip += 2;
    }

    return @out;
}

say "Stage 1: ", join(",", process($sA, $sB, $sC));

my $l = $#code;
my $cc = join(",", @code);

my $treshold_best = 25;
my $crossover_pairs = 20;
my $population = 10000;
my @crowd;

for my $i (0..$population-1)
{
    my $k = '';
    for my $d (0..$l)
    {
        $k .= sprintf("%03b", int(rand(8)));
    }
    push(@crowd, $k);
}

sub mutate($s)
{
    my $n = int rand(4); # number of bits to mutate
    for my $i (1..$n)
    {
        my $pos = int rand(scalar(@code) * 3);
        substr($s, $pos, 1, int rand(2))
    }

    return $s;
}

sub crossover($s, $t)
{
    my $pos = int rand(scalar(@code) * 3);
    my $s1 = substr($s,0,$pos).substr($t,$pos);
    my $t1 = substr($t,0,$pos).substr($s,$pos);
    return ($s1,$t1);
}


my $best = "9" x $l;
for my $gen (0..1000)
{
    my %results = mce_map { my @r = process(bin2dec($_), $sB, $sC); $_ => \@r } @crowd;
    my %scores = ();
    for my $sk (keys %results)
    {
        my $diff = 0;
        my @r = @{$results{$sk}};
        if ($#r != $l)
        {
            $diff = 10000000;
        }
        else
        {
            for my $d (0..$l)
            {
                $diff += abs($code[$d] - $r[$d]);
            }
        }

        if ($diff == 0)
        {
            my $a = bin2dec($sk);
            if ($a < $best)
            {
                $best = $a;
                say "############################### BEST $a -- @r";
                sleep(1);
            }
        }

        $scores{$sk} = $diff;
    }

    my @best = head($treshold_best, sort { $scores{$a} <=> $scores{$b} } keys %scores);

    @crowd = ();
    for my $i (1..$crossover_pairs)
    {
        my $e1 = int rand scalar @best;
        my $e2 = int rand scalar @best;
        my ($a,$b) = crossover($best[$e1], $best[$e2]);
        push(@crowd, $a, $b);
    }

    while (scalar @crowd < $population)
    {
        my $e1 = int rand scalar @best;
        push(@crowd, mutate($best[$e1]));
    }

    for my $b (head(3, @best))
    {
        my $r = join(",", process(bin2dec($b),$sB,$sC));
        say "gen $gen: $b = $scores{$b} -- $r (best = $best)";
    }

    print "\n";
}

