#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

# for d10a.txt
# my $XLO = 2;
# my $XHI = 5;

my $XLO = 17;
my $XHI = 61;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

my $stage1 = 0;
my $stage2 = 0;

my $bot = {};
my $output = {};

my @f = ();
my @g = ();
for my $s (@ff)
{
    if ($s =~ /^bot (\d+)/)
    {
        my $b = {};
        $b->{fill} = 0;
        $b->{carry} = {};
        $bot->{$1} = $b;

        push(@g, $s);
    }
    else
    {
        push(@f, $s);
    }
}

for my $s (@f)
{
    if ($s =~ /value (\d+) goes to bot (\d+)/)
    {
        my $fill = $bot->{$2}->{fill}; # number of elements on the bot
        die "$s" if $fill >= 2;
        $bot->{$2}->{carry}->{$1} = 1;
        $bot->{$2}->{fill}++;
    }
}

my $i = 0;
my $round = 0;
while (1)
{
    my $s = $g[$i];

    if ($s =~ /bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/)
    {
        my @elements = sort { $a <=> $b } keys %{$bot->{$1}->{carry}};

        if (scalar(@elements) == 2)
        {
            $bot->{$1}->{carry} = {};
            $bot->{$1}->{fill} = 0;

            if ($2 eq 'bot')
            {
                $bot->{$3}->{carry}->{$elements[0]} = 1;
                $bot->{$3}->{fill}++;
            }
            else
            {
                $output->{$3} = $elements[0];
            }

            if ($4 eq 'bot')
            {
                $bot->{$5}->{carry}->{$elements[1]} = 1;
                $bot->{$5}->{fill}++;
            }
            else
            {
                $output->{$5} = $elements[1];
            }

            if ($stage1 == 0 && $elements[0] == $XLO && $elements[1] == $XHI)
            {
                $stage1 = $1;
            }

            if (exists $output->{0} && exists $output->{1} && exists $output->{2})
            {
                $stage2 = $output->{0} * $output->{1} * $output->{2};
            }
        }
    }
    else { die $s; }

    last if $stage1 > 0 && $stage2 > 0;

    $i++;
    if ($i >= scalar @g)
    {
        $i = 0;
        $round++;
        next;
    }
}

print "stage 1: $stage1\n";
print "stage 2: $stage2\n";
