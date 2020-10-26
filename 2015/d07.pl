#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

use feature "bitwise"; # https://perldoc.perl.org/perlop#Bitwise-String-Operators

use File::Slurp;
my @f = read_file(\*STDIN);

my %values;

my $i = 0;
my $stage = 1;
EX: while (1)
{
    LL: for my $line (@f)
    {
        chomp $line;

        if (exists $values{"a"})
        {
            my $a = $values{"a"};
            print "stage $stage: a=$a\n";

            # Now, take the signal you got on wire a, override wire b to that signal, and reset the other wires (including wire a)
            %values = ();
            $values{"b"} = $a;
            $stage++;
            exit if $stage>2;
            next EX;
        }

        my ($op,$dest) = split/\s+->\s+/, $line;

        # already calculated, skip this rule
        next if exists $values{$dest};

        $_ = "";
        for my $s (split/\s+/, $op)
        {
            if ($s !~ /^(\d+|[A-Z]+)$/) # not a number or operator, try to substitute
            {
                next LL unless exists $values{$s}; # can't use this rule
                $s = $values{$s}
            }
            $_ .= "$s ";
        }
        s/\s+$//; # trim

        if (/^(\d+)$/)
        {
            $values{$dest} = int($1);
        }
        elsif (/NOT (\d+)/)
        {
            $values{$dest} = (~$1 & 0xffff);
        }
        elsif (/(\d+) AND (\d+)/)
        {
            $values{$dest} = $1&$2;
        }
        elsif (/(\d+) OR (\d+)/)
        {
            $values{$dest} = $1|$2;
        }
        elsif (/(\d+) LSHIFT (\d+)/)
        {
            $values{$dest} = $1 << $2;
        }
        elsif (/(\d+) RSHIFT (\d+)/)
        {
            $values{$dest} = $1 >> $2;
        }
        else
        {
            die("$_ -> $dest");
        }
    }

    $i++;
}
