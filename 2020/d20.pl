#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);
use Clone qw/clone/;

my @ff = read_file(\*STDIN);
@ff = map { chomp; $_ } @ff;

$; = ',';

my $stage1 = 0;
my $stage2 = 0;

my $i = 0;
my $id;
my %x;
my %vh;
while (1)
{
    $_ = $ff[$i++];
    last unless defined $_;
    if (/Tile (\d+)/)
    {
        my $id = $1;

        my @a = ();
        my $u;
        my $d;
        my $ur;
        my $dr;
        my $l;
        my $r;
        my ($lx,$rx);
        my $lr;
        my $rr;
        for my $row (0..9)
        {
            $_ = $ff[$i++];
            push(@a, $_);
        }

        my %h = ();

        my %ah = ();
        my $y = 0;
        for my $row (@a)
        {
            my $x = 0;
            for my $col (split//,$row)
            {
                $ah{$x,$y} = $col;
                $x++;
            }
            $y++;
        }
        $h{a} = \%ah;
        $h{an} = 10;

        recalc(\%h);

        $vh{$h{u}}++;
        $vh{$h{d}}++;
        $vh{$h{l}}++;
        $vh{$h{r}}++;
        $vh{$h{ur}}++;
        $vh{$h{dr}}++;
        $vh{$h{lr}}++;
        $vh{$h{rr}}++;

        $h{id} = $id;
        $x{$id} = \%h;

    }

#    $stage1 += ;
}

my $N = sqrt(scalar(keys(%x)));

my @xids = ();
for my $id (keys %x)
{
    my $c = 0;
    $c++ if $vh{$x{$id}->{u}} == 2;
    $c++ if $vh{$x{$id}->{d}} == 2;
    $c++ if $vh{$x{$id}->{l}} == 2;
    $c++ if $vh{$x{$id}->{r}} == 2;
    $c++ if $vh{$x{$id}->{ur}} == 2;
    $c++ if $vh{$x{$id}->{dr}} == 2;
    $c++ if $vh{$x{$id}->{lr}} == 2;
    $c++ if $vh{$x{$id}->{rr}} == 2;


    push(@xids, $id) if $c == 4;

    print "$id $c\n";
}
$stage1 = product(@xids);



sub xbtodec
{
    my $i = shift;
    $i =~ y/.#/01/;
    return oct("0b$i");
}

sub recalc
{
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my ($u,$d,$l,$r,$ur,$dr,$lr,$rr);
    for my $x (0..$n-1)
    {
        $ur .= $a{$x,0};
        $dr .= $a{$x,$n-1};
        $u .= $a{$n-$x-1,0};
        $d .= $a{$n-$x-1,$n-1};
    }
    for my $y (0..$n-1)
    {
        $l .= $a{0,$y};
        $r .= $a{$n-1,$y};
        $lr .= $a{0,$n-$y-1};
        $rr .= $a{$n-1,$n-$y-1};
    }

    $e->{u} = xbtodec($u);
    $e->{d} = xbtodec($d);
    $e->{l} = xbtodec($l);
    $e->{r} = xbtodec($r);
    $e->{ur} = xbtodec($ur);
    $e->{dr} = xbtodec($dr);
    $e->{lr} = xbtodec($lr);
    $e->{rr} = xbtodec($rr);
}

sub flipx
{
    print "flipx\n";
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my %h = ();
    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            $h{$x,$y} = $a{$x,$n-$y-1}
        }
    }
    $e->{a} = \%h;
    recalc($e);
}

sub flipy
{
    print "flipy\n";
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my %h = ();
    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            $h{$x,$y} = $a{$n-$x-1,$y}
        }
    }
    $e->{a} = \%h;
    recalc($e);
}

sub rotr
{
    print "rotr\n";
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my %h;
    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            my $ny = $x;
            my $nx = $n - $y - 1;
            $h{$nx,$ny} = $a{$x,$y};
        }
    }

    $e->{a} = \%h;
    recalc($e);
}

sub rotl
{
    print "rotl\n";
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my %h;
    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            my $nx = $y;
            my $ny = $n - $x - 1;
            $h{$nx,$ny} = $a{$x,$y};
        }
    }
    $e->{a} = \%h;
    recalc($e);
}

sub apr
{
    my $e = shift;

    printf "%5d: u=%4d %4d d=%4d %4d l=%4d %4d r=%4d %4d\n",
    $e->{id},
    $e->{u}, $e->{ur},
    $e->{d}, $e->{dr},
    $e->{l}, $e->{lr},
    $e->{r}, $e->{rr};
    for my $y (0..9)
    {
        for my $x (0..9)
        {
            print $e->{a}->{$x,$y};
        }
        print "\n";
    }
    print "\n";

}

print Dumper \%vh;

for my $nid (sort keys %x)
{
    my $e = $x{$nid};
    printf "%5d: u=%4d %4d d=%4d %4d l=%4d %4d r=%4d %4d\n", $nid,
    $e->{u}, $e->{ur},
    $e->{d}, $e->{dr},
    $e->{l}, $e->{lr},
    $e->{r}, $e->{rr};
}


my $start = 0;

$start = $xids[0];
while (1)
{
    last if ($vh{$x{$start}->{r}} == 2 && $vh{$x{$start}->{d}} == 2);
    rotr($x{$start});
#    print "ROTR!\n";
}


my %imgf;
$imgf{0,0} = $start;
print "0 $start\n";

my %used = ();
$used{$start} = 1;
my $y = 0;
X: for my $x (1..$N-1)
{
    my $sid = $imgf{$x-1,$y};
    my $s_r = $x{$sid}->{r};
    print "$x l=$sid border=$s_r\n";
    for my $nid (keys %x)
    {
        next if exists $used{$nid};
        print "nid=$nid\n";
        my $n = $x{$nid};
        if ($s_r == $n->{l})
        {
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
        elsif ($s_r == $n->{lr})
        {
            flipx($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
        elsif ($s_r == $n->{r})
        {
            flipy($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
        elsif ($s_r == $n->{rr})
        {
            flipy($n); flipx($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }

        elsif ($s_r == $n->{u})
        {
            rotl($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
        elsif ($s_r == $n->{ur})
        {
            rotl($n); flipx($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }

        elsif ($s_r == $n->{d})
        {
            rotr($n); flipx($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
        elsif ($s_r == $n->{dr})
        {
            rotr($n);
            $imgf{$x,$y} = $nid;
            $used{$nid} = 1;
            next X;
        }
    }

    die $sid;
}

for my $x (0..$N-1)
{
    Y: for my $y (1..$N-1)
    {
        my $sid = $imgf{$x,$y-1};
        my $s_d = $x{$sid}->{d};

        print "$x,$y u=$sid border=$s_d\n";

        for my $nid (keys %x)
        {
            next if exists $used{$nid};
            print "nid=$nid\n";
            my $n = $x{$nid};
            if ($s_d == $n->{u})
            {
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }
            elsif ($s_d == $n->{ur})
            {
                flipy($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }
            elsif ($s_d == $n->{d})
            {
                flipx($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }
            elsif ($s_d == $n->{dr})
            {
                flipx($n); flipy($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }

            elsif ($s_d == $n->{r})
            {
                rotl($n); flipy($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }
            elsif ($s_d == $n->{rr})
            {
                rotl($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }

            elsif ($s_d == $n->{l})
            {
                rotr($n);
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }
            elsif ($s_d == $n->{lr})
            {
                apr($n) if $nid == 2473;
                rotl($n);
                apr($n) if $nid == 2473;
                flipx($n);
                apr($n) if $nid == 2473;
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next Y;
            }

        }
        die $sid;

    }
}


my $n = $x{$start}->{an};
for my $ye (0..$N-1)
{
    for my $y (0..$n-1)
    {
        for my $xe (0..$N-1)
        {
            my $e = $x{$imgf{$xe,$ye}};
            #die "$xe,$ye" unless defined $e;
            for my $x (0..$n-1)
            {
                print $e->{a}->{$x,$y};
            }
            print " ";
        }
        print "\n";
    }
    print "\n";
}

for my $ye (0..$N-1)
{
    for my $xe (0..$N-1)
    {
        printf "%4d ", $imgf{$xe,$ye};
    }
    print "\n";
}
print "stage 1: $stage1\n";



my %sea = ();
my $ny = 0;
for my $ye (0..$N-1)
{
    for my $y (1..$n-2)
    {
        my $nx = 0;
        for my $xe (0..$N-1)
        {
            my $e = $x{$imgf{$xe,$ye}};
            for my $x (1..$n-2)
            {
                $sea{$nx,$ny} = $e->{a}->{$x,$y};
                $nx++;
            }
        }

        $ny++;
    }
}

my $M = $N * 8;

my %seaobj;
$seaobj{a} = \%sea;
$seaobj{an} = $M;

for my $y (0..$M-1)
{
    for my $x (0..$M-1)
    {
        print $sea{$x,$y};
    }
    print "\n";
}

my @monster_pattern = (
'__________________#_',
'#____##____##____###',
'_#__#__#__#__#__#___',
);

my %monster;
for my $row (@monster_pattern)
{
    my $x = 0;
    for my $col (split//,$row)
    {
        $monster{$x,$y} = $col;
        $x++;
    }
    $y++;
}

my $mxl = length($monster_pattern[0]);
my $myl = scalar(@monster_pattern);

my $round = 0;
W: while (1)
{
    for my $y (0..$M-1)
    {
        for my $x (0..$M-1)
        {
            print $sea{$x,$y};
        }
        print "\n";
    }
    print "\n";


    my $found = 0;
    for my $y (0..$M-1-($myl-1))
    {
        X: for my $x (0..$M-1-($mxl-1))
        {
            for my $my (0..$myl-1)
            {
                for my $mx (0..$mxl-1)
                {
                    next if $monster{$mx,$my} eq '_';

                    next X if $sea{$x+$mx,$y+$my} ne '#';
                }
            }

            $found = 1;
            last W;
        }
    }

    rotr(\%seaobj);
    $round++;
    if ($round == 4)
    {
        flipx(\%seaobj);
    }
    if ($round == 8)
    {
        flipy(\%seaobj);
    }

    %sea = %{$seaobj{a}};
}

%sea = %{$seaobj{a}};
for my $y (0..$M-1-($myl-1))
{
    X: for my $x (0..$M-1-($mxl-1))
    {
        for my $my (0..$myl-1)
        {
            for my $mx (0..$mxl-1)
            {
                next if $monster{$mx,$my} eq '_';

                next X if $sea{$x+$mx,$y+$my} ne '#';
            }
        }

        for my $my (0..$myl-1)
        {
            for my $mx (0..$mxl-1)
            {
                next if $monster{$mx,$my} eq '_';
                $sea{$x+$mx,$y+$my}="O";
            }
        }

    }
}

for my $y (0..$M-1)
{
    for my $x (0..$M-1)
    {
        print $sea{$x,$y};
        $stage2++ if $sea{$x,$y} eq '#';
    }
    print "\n";
}
print "\n";

print "stage 2: $stage2\n";