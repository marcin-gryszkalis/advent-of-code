#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @input = read_file(\*STDIN);

my $PRINT = 1; # 0 - nothing, 1 - start and end, 2 - every round, 3 - every move

my %hate = qw/G E E G/;
my $ordermap = [ [0,-1], [-1,0], [1,0], [0,1] ]; # x,y
my %power = qw/G 3 E 3/;
my %killed = qw/G 0 E 0/;

my $stage;
my $round;
my $hp;
my $m = [];
for (@input)
{
    chomp;
    my @row = split//;
    push(@$m, \@row);
}

sub findobj($)
{
    my $patt = shift;
    my @ret = ();
    my $y = 0;
    for my $row (@$m)
    {
        my $x = 0;
        for my $col (@$row)
        {
            my %o = ();
            if ($m->[$y]->[$x] =~ /$patt/)
            {
                $o{v} = $m->[$y]->[$x];
                $o{x} = $x;
                $o{y} = $y;
                push(@ret, \%o);
            }
            $x++;
        }
        $y++;
    }

    return @ret;
}

my $nextstep;
sub distance($$$)
{
    my $p = shift;
    my $t = shift;
    my $shortest = shift;
    my $x = $p->{x};
    my $y = $p->{y};
    my %visited = ();
    my @bfs;
    my %e = ();
    $e{x} = $x;
    $e{y} = $y;
    $e{p} = "$x:$y";
    $e{len} = 0;

    push(@bfs, \%e);

    while (1)
    {
        my $f = shift(@bfs);
        last unless defined $f;

        if ($f->{len} > $shortest)
        {
            return -2;
        }

        next if exists $visited{"$f->{x}:$f->{y}"};
        $visited{"$f->{x}:$f->{y}"} = 1;

        for my $o (@$ordermap)
        {
            my $tx = $o->[0];
            my $ty = $o->[1];
            my %g = ();
            $g{x} = $f->{x}+$tx;
            $g{y} = $f->{y}+$ty;

            if ($t->{x} == $g{x} && $t->{y} == $g{y})
            {
                my @pa = split/ /,$f->{p};
                $nextstep->{"$p->{x}:$p->{y} $t->{x}:$t->{y}"} = $pa[1] // "$g{x}:$g{y}";
                return $f->{len}+1;
            }

            next unless $m->[$g{y}]->[$g{x}] eq '.';
            next if exists $visited{"$g{x}:$g{y}"};

            $g{p} = $f->{p}." $g{x}:$g{y}";
            $g{len} = $f->{len} + 1;
            push(@bfs, \%g);
        }

    }

    return -1;
}

sub print_board
{
    my $y = 0;
    for my $row (@$m)
    {
        my $x = 0;
        for my $col (@$row)
        {
            print $m->[$y]->[$x];
            $x++;
        }

        $x = 0;
        for my $col (@$row)
        {
            if ($m->[$y]->[$x] =~ m/[EG]/)
            {
                print " ".$hp->{"$x:$y"};
            }
            $x++;
        }

        print "\n";
        $y++;
    }
    print "\n";
}

sub proceed
{
    $round = 0;
    $killed{E} = $killed{G} = 0;
    my $movedto = {};
    R: while (1)
    {
        $movedto = {}; # reset on ever round

        my @players = findobj("[GE]");
        for my $p (@players)
        {
            if ($PRINT > 2)
            {
                print "round: $round player: $p->{v}=$p->{x}:$p->{y}\n";
                print_board()
            }

            # check if I'm not dead (could be killed earlier this round)
            next if $m->[$p->{y}]->[$p->{x}] eq '.'; # not enough
            next if $movedto->{"$p->{x}:$p->{y}"}; # somebody else moved here, so I must have been killed :)

            # move
            my @targets = findobj("[".$hate{$p->{v}}."]");

            $nextstep = {};
            my $enemy = undef;
            my $enemiesexist = 0;
            M: for my $t (@targets) # find those in range
            {
                next unless $t->{v} eq $hate{$p->{v}};
                $enemiesexist = 1;
                if (abs($t->{x} - $p->{x}) + abs($t->{y} - $p->{y}) == 1)
                {
                    $enemy = $t;
                    last;
                }
            }

            last R unless $enemiesexist;

            if (!defined $enemy) # try to move
            {
                my @opensqs = ();
                my %opensqsh = ();

                for my $t (@targets)
                {
                    next unless $t->{v} eq $hate{$p->{v}};

                    my $x = $t->{x};
                    my $y = $t->{y};
                    for my $o (@$ordermap)
                    {
                        my $tx = $o->[0];
                        my $ty = $o->[1];
                        if ($m->[$y+$ty]->[$x+$tx] eq '.')
                        {
                            next if exists $opensqsh{"$x:$y"}; # no dupes
                            my %e = ();
                            $e{y} = $y+$ty;
                            $e{x} = $x+$tx;
                            $e{v} = '.';
                            push(@opensqs, \%e);
                            $opensqsh{"$e{x}:$e{y}"} = 1;
                        }
                    }
                }

                # find paths
                my @reachablesqs = ();
                my $shortest = 100000000;
                my @opensqs_near = sort { abs($p->{x} - $a->{x}) + abs($p->{y} - $a->{y}) <=> abs($p->{x} - $b->{x}) + abs($p->{y} - $b->{y})} @opensqs;
                for my $osq (@opensqs_near)
                {
                    $osq->{d} = distance($p,$osq,$shortest);
                    if ($osq->{d} > 0) # -1 not found, -2 too long
                    {
                        $shortest = $osq->{d} if $osq->{d} <= $shortest;
                        push(@reachablesqs, $osq);
                    }
                }

                if (scalar(@reachablesqs) > 0)
                {
                    my @nearestsqs = ();
                    for my $rsq (@reachablesqs)
                    {
                        push(@nearestsqs, $rsq) if $rsq->{d} == $shortest;
                    }

                    @nearestsqs = sort { $a->{y} <=> $b->{y} || $a->{x} <=> $b->{x} } @nearestsqs; # reading sort

                    my $target = $nearestsqs[0];
                    my @nps = split/:/, $nextstep->{"$p->{x}:$p->{y} $target->{x}:$target->{y}"}; # move!
                    my $np = { x => $nps[0], y => $nps[1] };

                    $m->[$p->{y}]->[$p->{x}] = '.';
                    my $nhp = $hp->{"$p->{x}:$p->{y}"};
                    $hp->{"$p->{x}:$p->{y}"} = 0;
                    $np->{v} = $p->{v};
                    $p = $np;
                    $m->[$p->{y}]->[$p->{x}] = $p->{v};
                    $hp->{"$p->{x}:$p->{y}"} = $nhp;
                    $movedto->{"$p->{x}:$p->{y}"} = 1;
                }

            }

            my @weakenemies = ();
            my $weakest = 201;
            for my $t (@targets) # try again to find enemy, weakest this time
            {
                next unless $t->{v} eq $hate{$p->{v}};
                if (abs($t->{x} - $p->{x}) + abs($t->{y} - $p->{y}) == 1 && $hp->{"$t->{x}:$t->{y}"} <= $weakest)
                {
                    push(@weakenemies, $t);
                    $weakest = $hp->{"$t->{x}:$t->{y}"};
                }
            }

            if (scalar @weakenemies > 0)
            {
                my @weakestenemies = ();
                foreach my $t (@weakenemies)
                {
                    push(@weakestenemies, $t) if $hp->{"$t->{x}:$t->{y}"} == $weakest;
                }

                @weakestenemies = sort { $a->{y} <=> $b->{y} || $a->{x} <=> $b->{x} } @weakestenemies; # reading sort
                $enemy = $weakestenemies[0];
            }

            # attack
            if (defined $enemy)
            {
                my $hpx = $hp->{"$enemy->{x}:$enemy->{y}"};
                $hpx -= $power{$p->{v}}; # attack power
                $hp->{"$enemy->{x}:$enemy->{y}"} = $hpx;
                if ($hpx <= 0) # dead
                {
                    $hp->{"$enemy->{x}:$enemy->{y}"} = 0;
                    $m->[$enemy->{y}]->[$enemy->{x}] = '.';
                    $killed{$enemy->{v}}++;
                    return if $killed{E} > 0 && $stage == 2;
                }
            }
        }

        print_board() if $PRINT > 1;

        $round++;
    }
}

sub init_board()
{
    $m = [];
    for (@input)
    {
        chomp;
        my @row = split//;
        push(@$m, \@row);
    }

    $hp = {};

    my @players = findobj("[GE]");
    for my $p (@players)
    {
        $hp->{"$p->{x}:$p->{y}"} = 200;
    }
}

$stage = 1;
init_board();
print_board() if $PRINT > 0;
proceed();
print_board() if $PRINT > 0;

my $hps = sum(values %$hp);
printf "stage $stage: round=$round hp-sum=$hps outcome=%d\n", $hps * $round;

$stage = 2;
$power{E} = 4; # binary search would be nice ;)
while (1)
{
    $power{E}++;

    init_board();
    proceed();

    if ($PRINT > 0)
    {
        print "elves power: $power{E}\n";
        print "killed: E:$killed{E} G:$killed{G}\n";
        print_board();
    }

    last if $killed{E} == 0;
}

$hps = sum(values %$hp);
printf "stage $stage: round=$round hp-sum=$hps outcome=%d\n", $hps * $round;
