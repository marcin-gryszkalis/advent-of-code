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
my $ipreg = shift @f;
$ipreg =~ s/\D+//g;

no strict 'refs';

sub addr { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] + $regs->[$op->[2]]; return $regs }
sub addi { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] + $op->[2]; return $regs }
sub mulr { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] * $regs->[$op->[2]]; return $regs }
sub muli { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] * $op->[2]; return $regs }
sub banr { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] & $regs->[$op->[2]]; return $regs }
sub bani { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] & $op->[2]; return $regs }
sub borr { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] | $regs->[$op->[2]]; return $regs }
sub bori { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]] | $op->[2]; return $regs }

sub setr { my ($regs, $op) = @_; $regs->[$op->[3]] = $regs->[$op->[1]]; return $regs }
sub seti { my ($regs, $op) = @_; $regs->[$op->[3]] = $op->[1]; return $regs }

sub gtir { my ($regs, $op) = @_; $regs->[$op->[3]] = ($op->[1] > $regs->[$op->[2]] ? 1 : 0); return $regs }
sub gtri { my ($regs, $op) = @_; $regs->[$op->[3]] = ($regs->[$op->[1]] > $op->[2] ? 1 : 0); return $regs }
sub gtrr { my ($regs, $op) = @_; $regs->[$op->[3]] = ($regs->[$op->[1]] > $regs->[$op->[2]] ? 1 : 0); return $regs }
sub eqir { my ($regs, $op) = @_; $regs->[$op->[3]] = ($op->[1] == $regs->[$op->[2]] ? 1 : 0); return $regs }
sub eqri { my ($regs, $op) = @_; $regs->[$op->[3]] = ($regs->[$op->[1]] == $op->[2] ? 1 : 0); return $regs }
sub eqrr { my ($regs, $op) = @_; $regs->[$op->[3]] = ($regs->[$op->[1]] == $regs->[$op->[2]] ? 1 : 0); return $regs }

for my $stage (1..1)
{
    my @reg = (0) x 6;
    $reg[0] = $stage;

    my $i = 0;
    while (1)
    {
        my $op = $f[$reg[$ipreg]];

        if ($op =~ /^(\S+) (\d+) (\d+) (\d+)/)
        {
            my $o = $1;
            my @a = split/\s+/, $op;
            my @savereg = @reg;
            my $saveip = $reg[$ipreg];
            $o->(\@reg, \@a);
            printf "%10d ip=%2d [%s] $op [%s]\n", $i, $saveip, join(", ", @savereg), join(", ", @reg) if $i % 10000 == 0;
        }
        else { die $op }

        $reg[$ipreg]++;

        last if $reg[$ipreg] >= scalar @f;
        $i++;
    }

    print "stage %d: %d\n", $reg[0];
}
