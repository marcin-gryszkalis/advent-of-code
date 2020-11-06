#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $showmap = 0;
my $map;

my %dirmap = qw/
    ^ 0
    > 1
    v 2
    < 3
/;

my %revdirmap = reverse %dirmap;

my %curvemap = qw{
    / 0
    \ 1
};

my %vxmap = qw/
    0 0
    1 1
    2 0
    3 -1
/;

my %vymap = qw/
    0 -1
    1 0
    2 1
    3 0
/;

# it turns left the first time, goes straight the second time, turns right the third time, and then repeats
my %turnmap = qw/
    0 3
    1 0
    2 1
/;

my @f = read_file(\*STDIN);
my $i = 0;
for (@f)
{
    chomp;
    my @a = split//;
    $map->[$i++] = \@a;
}

my $carts = {};
my $y = 0;
my $cid = 0;
for my $row (@$map)
{
    my $x = 0;
    for my $e (@$row)
    {
        if ($e =~ /[\<\>^v]/)
        {
            my $c = {};
            $c->{x} = $x;
            $c->{y} = $y;
            $c->{d} = $dirmap{$e};
            $c->{turncount} = 0;
            $c->{cid} = $cid;
            $carts->{$cid++} = $c;

            # remove from map
            $map->[$y]->[$x] = $c->{d} % 2 ? '-' : '|';
        }

        $x++;
    }
    $y++;
}


sub show_map()
{
    return unless $showmap;
    $y = 0;
    for my $row (@$map)
    {
        my $x = 0;
        for my $e (@$row)
        {
            my $found = 0;
            for my $c (values %$carts)
            {
                #print "XXXXXXXXXXXX $x,$y $c->{x},$c->{y}\n";
                if ($c->{x} == $x && $c->{y} == $y)
                {
                    $found = 1;
                    print $revdirmap{$c->{d}};
                }
            }
            print $map->[$y]->[$x] unless $found;
            $x++;
        }
        print "\n";
        $y++;
    }
    print "\n";
}

show_map();

my $crash = 1;
my $tick = 0;
L: while (1)
{
    # movement
    my @clist = sort { $a->{y} <=> $b->{y} || $a->{x} <=> $b->{x} } values %$carts; # to avoid problems with removed carts
    M: for my $c (@clist)
    {
        next unless defined $c;

        my $nx = $c->{x} + $vxmap{$c->{d}};
        my $ny = $c->{y} + $vymap{$c->{d}};
        my $nd = $c->{d};

        for my $c2 (values %$carts)
        {
#            next unless defined $c2;
            if ($nx == $c2->{x} && $ny == $c2->{y})
            {
                printf "%4d: crash %d at %d,%d (carts %d + %d)\n", $tick, $crash, $nx, $ny, $c->{cid}, $c2->{cid};
                $crash++;

                show_map();

                delete $carts->{$c->{cid}};
                delete $carts->{$c2->{cid}};

                next M;
            }
        }

        if ($map->[$ny]->[$nx] =~ /[-|]/)
        {
            # nothing
        }
        elsif ($map->[$ny]->[$nx] =~ m{[/\\]}) # curve
        {
            # vert ^ 0 v 2    / 0 -> TR  \ 1-> TL
            # horz > 1 < 3     / 0 -> TL  \ 1 -> TR
            if (($c->{d} + $curvemap{$map->[$ny]->[$nx]}) % 2 == 0) # right
            {
                $c->{d} = ($c->{d} + 1) % 4;
            }
            else # left
            {
                $c->{d} = ($c->{d} + 3) % 4;
            }
        }
        elsif ($map->[$ny]->[$nx] =~ m{[+]}) # crossing
        {
            $c->{d} = ($c->{d} + $turnmap{$c->{turncount}}) % 4;
            $c->{turncount} = ($c->{turncount} + 1) % 3;
        }

        $c->{x} = $nx;
        $c->{y} = $ny;
    }

    show_map();

    if (scalar keys %$carts == 1) # assume odd number
    {
        my $cid = (keys(%$carts))[0];
        printf "last at: %d,%d\n", $carts->{$cid}->{x}, $carts->{$cid}->{y};
        exit;
    }

    $tick++;
}