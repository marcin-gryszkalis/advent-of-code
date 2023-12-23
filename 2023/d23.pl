#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $x = 0;
my $y = 0;
my $t;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        $x++;
    }
    $y++;
}

my ($h, $w) = ($y, length($f[0]));
my ($maxy, $maxx) = ($h - 1, $w - 1);

my ($startx, $starty)  = (1, 0);
my ($endx, $endy) = ($maxx-1, $maxy);

for my $stage (1..2)
{
    my $edge = undef;
    my $succ = undef;

    my $exits; # exits from node

    for my $x (0..$maxx)
    {
        for my $y (0..$maxy)
        {
            next if $t->{$x,$y} eq '#';

            my @nexits = ();
            my $allexits = 0;
            for my $dy (-1..1)
            {
                for my $dx (-1..1)
                {
                    next unless abs($dx) + abs($dy) == 1;

                    my ($nx, $ny) = ($x + $dx, $y + $dy);
                    next unless exists $t->{$nx,$ny};
                    next if $t->{$nx,$ny} eq '#';

                    $allexits++;

                    if ($stage == 1)
                    {
                        next if $dx == 1 && $t->{$nx,$ny} eq '<';
                        next if $dx == -1 && $t->{$nx,$ny} eq '>';
                        next if $dy == 1 && $t->{$nx,$ny} eq '^';
                        next if $dy == -1 && $t->{$nx,$ny} eq 'v';
                    }

                    push(@nexits, [$nx,$ny]);
                }
            }

            $exits->{$x,$y} = \@nexits if $allexits > 2;
        }
    }

    $exits->{$startx,$starty} = [[$startx,$starty+1]];
    $exits->{$endx,$endy} = [[$endx,$endy-1]];

    # build a graph
    # every edge is found twice (a-b, b-a)
    for my $sxsy (keys %$exits)
    {
        for my $e (@{$exits->{$sxsy}})
        {
            my ($x,$y) = @$e;

            my $visited = undef;
            $visited->{$sxsy} = 1;

            # walk between nodes
            my $i = 0;
            W: while (1)
            {
                $visited->{$x,$y} = 1;
                $i++;

                if (exists $exits->{$x,$y})
                {
                    die "more that one edge between nodes $sxsy and $x,$y" if exists $edge->{$sxsy,"$x,$y"};
                    print "path $sxsy ---[$i]--> $x,$y\n";
                    $edge->{$sxsy,"$x,$y"} = $i;
                    push(@{$succ->{$sxsy}}, "$x,$y");
                    last;
                }

                for my $dy (-1..1)
                {
                    for my $dx (-1..1)
                    {
                        next unless abs($dx) + abs($dy) == 1;
                        my ($nx, $ny) = ($x + $dx, $y + $dy);
                        next unless exists $t->{$nx,$ny};
                        next if $t->{$nx,$ny} eq '#';

                        if ($stage == 1)
                        {
                            next if $dx == 1 && $t->{$nx,$ny} eq '<';
                            next if $dx == -1 && $t->{$nx,$ny} eq '>';
                            next if $dy == 1 && $t->{$nx,$ny} eq '^';
                            next if $dy == -1 && $t->{$nx,$ny} eq 'v';
                        }

                        next if exists $visited->{$nx,$ny};
                        ($x, $y) = ($nx, $ny);
                        next W; # only 1 way from non-node
                    }
                }

                last;
            }
        }

    }

    my @q = ();
    my $visited = undef;

    push(@q, ["$startx,$starty",$visited,0,0]); ## ,["$startx,$starty"]]);
    my $mmm = 0;
    my $i = 0;
    while (@q)
    {
        my ($vx,$v,$lvl,$fwd,$p) = @{pop(@q)};

        $v->{$vx} = 1;

        if ($vx eq "$endx,$endy")
        {
            printf("%20d: (max=%d)\n", $i, max($fwd,$mmm)) if $fwd > $mmm || $i % 10_000 == 0;
            $mmm = max($fwd,$mmm);
            $i++;
            #printf "!!!!!! (max=$mmm) $fwd (%s)\n", join(" ",@$p);
        }

        for my $s (grep { !exists $v->{$_} } @{$succ->{$vx}})
        {
            push(@q, [$s, clone($v), $lvl+1, $fwd + $edge->{$vx,$s}]); ## , $p]);
        }
    }


    printf "Stage $stage: %s\n", $mmm;
}
# 6874
