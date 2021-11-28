#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my %nummap = qw/
first 1
second 2
third 3
fourth 4/;
my $maxfloor = 4;

my @ff = read_file(\*STDIN);
@ff = map {
    chomp;
    s/promethium/qpromethium/g; # promethium & plutonium - pure evil!
    $_ } @ff;

my $map;
# The first floor contains a thulium generator, a thulium-compatible microchip, a plutonium generator, and a strontium generator.
for (@ff)
{
    m/^The (\S+)/;
    my $floor = $nummap{$1};

    s/(\S)\S+-compatible\s+microchip/$map->{uc($1)."M"}=$floor/eg;
    s/(\S)\S+\s+generator/$map->{uc($1)."G"}=$floor/eg;
}

$map->{EE} = 1;

# stage 2:
# $map->{UG} = 1;
# $map->{UM} = 1;
# $map->{WG} = 1;
# $map->{WM} = 1;



sub hashmap($)
{
    my $xmap = shift;
    my $h = '';
    for my $k (sort keys %$xmap)
    {
        $h .= $xmap->{$k};
    }
    return $h;
}

sub draw2str($)
{
    my $xstate = shift;
    my $xmap = $xstate->{map};
    my $s = "";
    $s .= "level: $xstate->{level}\n";
    for my $fd (1..$maxfloor)
    {
        my $f = $maxfloor+1-$fd;

        $s .= "F$f ";
        for my $k (sort keys %$xmap)
        {
            $s .= $xmap->{$k} == $f ? "$k " : ".  ";
        }

        $s .= "\n";
    }
    $s .= "\n";
    return $s;
}

my $state;
$state->{map} = clone($map);
$state->{level} = 0;
$state->{hash} = hashmap($state->{map});
$state->{path} = draw2str($state);
my @sq;
push(@sq, clone($state));

my $visited->{$state->{hash}} = 1;

my $best = 1000;
my $cnt = 0;
while (1)
{
    $cnt++;

    # $state = shift(@sq);
    $state = pop(@sq);

    print "$cnt: level($state->{level}) queue(".scalar(@sq).")\n" if $cnt % 1000 == 0;
    # print draw2str($state);

    if ($state->{hash} =~ /^${maxfloor}+$/) # all on 4th floor :)
    {
        print $state->{path};
        print "Found: $state->{level}\n";
        $best = $state->{level};
#        next;
        exit;
    }

    my $srcf = $state->{map}->{EE};
    for my $dstf (max(1, $srcf - 1)..min($maxfloor, $srcf + 1))
    {
        next if $dstf == $srcf;

        my @srcitems = ();
        for my $k (sort keys %{$state->{map}})
        {
            next if $k eq 'EE';
            push(@srcitems, $k) if $state->{map}->{$k} == $srcf;
        }
        push(@srcitems, '--'); # add "nothing" element to allow moving 1 item

        my $it = combinations(\@srcitems, 2);
        MOVE: while (my $ps = $it->next)
        {
            my $nstate = clone($state);
            $nstate->{map}->{EE} = $dstf;

            # check for conflict in elevator
            next if $ps->[0] eq '--' && $ps->[1] eq '--'; # elevator needs at least 1 item

            if ($ps->[0] ne '--' && $ps->[1] ne '--') # no checks if one of items is "nothing"
            {
                my $pk0 = substr($ps->[0], 0, 1);
                my $pt0 = substr($ps->[0], 1, 1);
                my $pk1 = substr($ps->[1], 0, 1);
                my $pt1 = substr($ps->[1], 1, 1);
                next if $pk0 ne $pk1 && $pt0 ne $pt1; # different kind and different type (as we allow different types of same kind and different kinds of same type)
            }

            # move them
            for my $p (@$ps)
            {
                $nstate->{map}->{$p} = $dstf unless $p eq '--';
            }

            # if ($state->{hash} eq '44433')
            # {
            #     print "$srcf -> $dstf : $ps->[0] $ps->[1]\n";
            #     print draw2str($nstate);
            # }

            my $h = hashmap($nstate->{map});
            next if exists $visited->{$h}; # we've been here anyway

            $visited->{$h} = 1; # we may skip this version as well, but this would save us checking for conflicts

            # now check for conflicts at destination floor AND src floor
            for my $floorcheck ($srcf, $dstf)
            {
                for my $p (sort keys %{$state->{map}})
                {
                    next if $nstate->{map}->{$p} != $floorcheck;
                    my $pk = substr($p, 0, 1);
                    my $pt = substr($p, 1, 1);
                    next if $pt ne 'M';
                    if ($nstate->{map}->{"${pk}G"} != $floorcheck) # microchip doesn't have generator of its kind on this floor - it's not safe
                    {
                        for my $q (sort keys %{$state->{map}}) # so check for evil generators
                        {
                            next if $nstate->{map}->{$q} != $floorcheck;
                            my $qk = substr($q, 0, 1);
                            my $qt = substr($q, 1, 1);
                            next if $qt ne 'G';

                            # oh! it generator of different kind is here, it would fry $p microchip which is not safe
                            next MOVE;
                        }
                    }
                }
            }

            # no conflicts, hurray!
            $nstate->{level}++;
            $nstate->{hash} = $h;
            $nstate->{path} .= draw2str($nstate);
            push(@sq, $nstate);
        }
    }
}

