 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $o;
my $y = 0;
for (@f)
{
    my $x = 0;
    for my $e (split//)
    {
        $o->{$x,$y} = $e;
        $x++;
    }
    $y++;
}
my $maxy = $y - 1;
my $maxx = length($f[0]) - 1;

my $step = 0;
while (1)
{
    $step++;

    $o->{$_}++ for keys %$o;

    my $f; # who flashed?
    my $scan = 1;
    while ($scan)
    {
        $scan = 0;
        for my $y (0..$maxy)
        {
            for my $x (0..$maxx)
            {
                if ($o->{$x,$y} > 9)
                {
                    $f->{$x,$y} = 1;
                    for my $dx (-1..1)
                    {
                        for my $dy (-1..1)
                        {
                            next if $dx == 0 && $dy == 0;
                            my $x2 = $x + $dx;
                            my $y2 = $y + $dy;
                            next unless exists $o->{$x2,$y2};
                            next if $f->{$x2,$y2};

                            $o->{$x2,$y2}++;
                            $scan = 1;
                        }
                    }

                    $o->{$x,$y} = 0;
                    $stage1++ if $step <= 100;
                }
            }
        }
    }

    print "step: $step\n";
    for my $y (0..$maxy)
    {
        for my $x (0..$maxx)
        {
            print $o->{$x,$y};
        }
        print "\n";
    }
    print "\n";

    if (scalar keys %$f == scalar keys %$o)
    {
        $stage2 = $step;
        last;
    }
}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;