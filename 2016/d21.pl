#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my $scrambled = "fbgdceah";

my $pass = "abcdefgh";
my $blen = length($pass);

my @f = read_file(\*STDIN);

my @letters = qw/a b c d e f g h/;
my $it = permutations(\@letters);
my $c = 0;
while (my $parr = $it->next)
{
    $c++;

    my $passcheck = join("", @$parr);
    $pass = $passcheck;

    my $i = 0;
    for $_ (@f)
    {
        $i++;
        chomp;

        if (/swap position (\S+) with position (\S+)/)
        {
            my $a = substr($pass, $1, 1);
            substr($pass, $1, 1) = substr($pass, $2, 1);
            substr($pass, $2, 1) = $a;
        }
        elsif (/swap letter (\S+) with letter (\S+)/)
        {
            eval "\$pass =~ tr/$1$2/$2$1/"; die $@ if $@;
        }
        elsif (/rotate (left|right) (\S+) step/)
        {
            if ($1 eq 'left')
            {
                $pass = substr($pass, $2).substr($pass, 0, $2);
            }
            else
            {
                $pass = substr($pass, -$2).substr($pass, 0, -$2);
            }
        }
        elsif (/rotate based on position of letter (\S+)/)
        {
            my $i = index($pass, $1);
            $i++ if $i >= 4;
            $i++;
            $i = $i % $blen;

            $pass = substr($pass, -$i).substr($pass, 0, -$i);
        }
        elsif (/reverse positions (\S+) through (\S+)/)
        {
            $pass = substr($pass, 0, $1).reverse(substr($pass, $1, $2-$1+1)).substr($pass, $2+1);
        }
        elsif (/move position (\S+) to position (\S+)/)
        {
            $a = substr($pass, $1, 1);
            $pass = $1 == 0 ? substr($pass, 1) : substr($pass, 0, $1).substr($pass, $1 + 1); # pass withouth 1 letter
            if ($2 == 0) # move to beginning
            {
                $pass = $a.$pass
            }
            elsif ($2 == $blen - 1) # last pos
            {
                $pass = $pass.$a;
            }
            else
            {
                $pass = substr($pass, 0, $2).$a.substr($pass, $2);
            }
        }
        else
        {
            die $_;
        }

        die "length changed" if length($pass) != $blen; # sanity check

    }

    if ($passcheck eq "abcdefgh")
    {
        print "Stage 1: $passcheck -> $pass\n";
    }

    if ($pass eq $scrambled)
    {
        print "Stage 2: $passcheck -> $pass\n";
    }
}
