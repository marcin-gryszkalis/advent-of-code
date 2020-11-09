#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

for my $stage (1..2)
{
    my %r;
    $r{a} = $stage - 1;
    $r{b} = 0;
    my $ip = 0;

    while (1)
    {
        last if $ip > $#f;

        $_ = $f[$ip];
        #print "ip=$ip a=$r{a} b=$r{b} instr: $_\n";

        # hlf r sets register r to half its current value, then continues with the next instruction.
        if (/hlf (.)/)
        {
            $r{$1} /= 2; $ip++;
        }
        # tpl r sets register r to triple its current value, then continues with the next instruction.
        elsif (/tpl (.)/)
        {
            $r{$1} *= 3; $ip++;
        }
        # inc r increments register r, adding 1 to it, then continues with the next instruction.
        elsif (/inc (.)/)
        {
            $r{$1}++; $ip++;
        }
        # jmp offset is a jump; it continues with the instruction offset away relative to itself.
        elsif (/jmp ([+-]\d+)/)
        {
            $ip += $1;
        }
        # jie r, offset is like jmp, but only jumps if register r is even ("jump if even").
        elsif (/jie (.), ([+-]\d+)/)
        {
            $ip += $r{$1} % 2 == 0 ? $2 : 1;
        }
        # jio r, offset is like jmp, but only jumps if register r is 1 ("jump if one", not odd).
        elsif (/jio (.), ([+-]\d+)/)
        {
            $ip += $r{$1} == 1 ? $2 : 1;
        }
        else # just in case
        {
            die $_;
        }
    }

     printf "stage %d: %d\n", $stage, $r{b};
}