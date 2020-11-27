#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# Before: [1, 1, 2, 0]
# 8 1 0 3
# After:  [1, 1, 2, 1]

my @s1rules;
my @s2code;
while (<>)
{
    if (/Before:\s+\[(.*)\]/)
    {
        my %r = ();
        $r{before} = join(':', split(/,\s+/, $1));
        $_ = <>; chomp;
        $r{op} = [split(/\s+/)];
        $r{xop} = join("-",split/\s+/);
        $_ = <>; chomp;
        m/After:\s+\[(.*)\]/ or die $_;
        $r{after} = join(':', split(/,\s+/, $1));
        <>;

        push(@s1rules, \%r);
    }
    elsif (/^(\d+.*)/)
    {
        push(@s2code, $1);
    }
}

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

my @ops = qw/addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr/;

my $stage1 = 0;
for my $rule (@s1rules)
{
    my $c = 0;
    my @regsx = split(/:/, $rule->{before});
    for my $o (@ops)
    {
        my @regs = @regsx;
        my $to = $rule->{op};
        my $oregs = $o->(\@regs, $to);
        my $oaf = join(":", @$oregs);

        $c++ if $oaf eq $rule->{after};
    }
    $stage1++ if $c >= 3;
}

printf "stage 1: %s\n", $stage1;

my $stage2 = 0;
my $opmap;
my $opmapx; # rev
L: while (1)
{
    for my $rule (@s1rules)
    {
        my $c = 0;
        my $lastop = '';

        my $to = $rule->{op};
        next if exists $opmapx->{$to->[0]};

        my @regsx = split(/:/, $rule->{before});
        for my $o (@ops)
        {
            next if exists $opmap->{$o};
            my @regs = @regsx;
            my $oregs = $o->(\@regs, $to);
            my $oaf = join(":", @$oregs);

            if ($oaf eq $rule->{after})
            {
                $c++;
                $lastop = $o;
            }
        }

        if ($c == 1 && !exists $opmap->{$lastop})
        {
            $opmap->{$lastop} = $to->[0];
            $opmapx->{$to->[0]} = $lastop;
            last L if scalar(keys %$opmap) == 16;
        }
    }
}

# for my $op (sort keys %$opmap) { print "$op -> $opmap->{$op}\n" }

my @regs = (0,0,0,0);
for my $e (@s2code)
{
    my @o = split/\s+/, $e;
    my $op = $opmapx->{$o[0]};
    $op->(\@regs, \@o);
    # print join(" ", @regs)."\n";
}
printf "stage 2: %d\n", $regs[0];
