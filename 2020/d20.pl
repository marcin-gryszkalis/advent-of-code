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

my @properties = qw/u d l r ur dr lr rr/;

my @monster_pattern = (
'__________________#_',
'#____##____##____###',
'_#__#__#__#__#__#___',
);

my $stage1 = 0;
my $stage2 = 0;

my $i = 0;
my $id;
my %x;
my %vh; # count borders
while (1)
{
    $_ = $ff[$i++];
    last unless defined $_;
    if (/Tile (\d+)/)
    {
        my $id = $1;

        my %h = ();
        $h{id} = $id;

        my %ah = ();
        my $y = 0;
        for my $row (0..9)
        {
            $_ = $ff[$i++];
            my $x = 0;
            for my $col (split//)
            {
                $ah{$x,$y} = $col;
                $x++;
            }
            $y++;
        }

        $h{a} = \%ah;
        $h{an} = 10;

        recalc(\%h);

        for my $p (@properties)
        {
            $vh{$h{$p}}++;
        }

        $x{$id} = \%h;
    }
}

my $N = sqrt(scalar(keys(%x)));

my @xids = (); # corners
for my $id (keys %x)
{
    my $c = 0;
    for my $p (@properties)
    {
        $c++ if $vh{$x{$id}->{$p}} == 2;
    }

    push(@xids, $id) if $c == 4; # 2 borders * 2 (flip)
}

$stage1 = product(@xids);


# lsb->msb: up->down, right->left
sub recalc
{
    my $e = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};
    my %hp;
    for my $x (0..$n-1)
    {
        $hp{u} .= $a{$n-$x-1,0};
        $hp{d} .= $a{$n-$x-1,$n-1};
        $hp{ur} .= $a{$x,0};
        $hp{dr} .= $a{$x,$n-1};
    }
    for my $y (0..$n-1)
    {
        $hp{l} .= $a{0,$y};
        $hp{r} .= $a{$n-1,$y};
        $hp{lr} .= $a{0,$n-$y-1};
        $hp{rr} .= $a{$n-1,$n-$y-1};
    }

    for my $p (@properties)
    {
        $hp{$p} =~ y/.#/01/;
        $e->{$p} = oct("0b$hp{$p}");
    }
}

sub flipxy_ar
{
    my $a = shift;
    my $n = shift;
    my $axis = shift;
    my %h = ();

    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            $h{$x,$y} = $axis eq 'x' ? $a->{$x,$n-$y-1} : $a->{$n-$x-1,$y};
        }
    }

    return \%h;
}

sub flipxy
{
    my $e = shift;
    my $axis = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};

    $e->{a} = flipxy_ar(\%a, $n, $axis);
    recalc($e) if $n == 10;
}

sub flipx { flipxy(shift, 'x') }
sub flipy { flipxy(shift, 'y') }

sub rotrl_ar
{
    my $a = shift;
    my $n = shift;
    my $dir = shift;
    my %h;
    for my $x (0..$n-1)
    {
        for my $y (0..$n-1)
        {
            my $nx = $dir eq 'r' ? $n - $y - 1 : $y;
            my $ny = $dir eq 'r' ? $x : $n - $x - 1;
            $h{$nx,$ny} = $a->{$x,$y};
        }
    }
    return \%h;
}

sub rotrl
{
    my $e = shift;
    my $dir = shift;
    my %a = %{$e->{a}};
    my $n = $e->{an};

    $e->{a} = rotrl_ar(\%a, $n, $dir);
    recalc($e) if $n == 10;
}

sub rotr { rotrl(shift, 'r') }
sub rotl { rotrl(shift, 'l') }


my $start = $xids[0];
while (1)
{
    last if ($vh{$x{$start}->{r}} == 2 && $vh{$x{$start}->{d}} == 2);
    rotr($x{$start});
}

my %imgf;
$imgf{0,0} = $start;

my %rulesx = (
    l  => '',
    lr => 'flipx',
    r  => 'flipy',
    rr => 'flipy flipx',
    u  => 'rotl',
    ur => 'rotl flipx',
    d  => 'rotr flipx',
    dr => 'rotr',
);

my %used = ();
$used{$start} = 1;
my $y = 0;
X: for my $x (1..$N-1) # first row
{
    my $sid = $imgf{$x-1,$y};
    my $s_r = $x{$sid}->{r};
    for my $nid (keys %x)
    {
        next if exists $used{$nid};
        my $ne = $x{$nid};

        for my $p (@properties)
        {
            if ($s_r == $ne->{$p})
            {
                for my $rule (split/\s+/, $rulesx{$p})
                {
                    flipx($ne) if $rule eq 'flipx';
                    flipy($ne) if $rule eq 'flipy';
                    rotl($ne) if $rule eq 'rotl';
                    rotr($ne) if $rule eq 'rotr';
                }
                $imgf{$x,$y} = $nid;
                $used{$nid} = 1;
                next X;
            }
        }
    }

    die $sid;
}

my %rulesy = (
    u  => '',
    ur => 'flipy',
    d  => 'flipx',
    dr => 'flipx flipy',
    r  => 'rotl flipy',
    rr => 'rotl',
    l  => 'rotr',
    lr => 'rotl flipx',
);

for my $x (0..$N-1) # down columns
{
    Y: for my $y (1..$N-1)
    {
        my $sid = $imgf{$x,$y-1};
        my $s_d = $x{$sid}->{d};

        for my $nid (keys %x)
        {
            next if exists $used{$nid};
            my $ne = $x{$nid};

            for my $p (@properties)
            {
                if ($s_d == $ne->{$p})
                {
                    for my $rule (split/\s+/, $rulesy{$p})
                    {
                        flipx($ne) if $rule eq 'flipx';
                        flipy($ne) if $rule eq 'flipy';
                        rotl($ne) if $rule eq 'rotl';
                        rotr($ne) if $rule eq 'rotr';
                    }
                    $imgf{$x,$y} = $nid;
                    $used{$nid} = 1;
                    next Y;
                }
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

for my $ye (0..$N-1) # ids array
{
    for my $xe (0..$N-1)
    {
        printf "%4d ", $imgf{$xe,$ye};
    }
    print "\n";
}
print "\n";

print "stage 1: $stage1\n\n";


my $sea;
my $ny = 0;
for my $ye (0..$N-1) # merge into the sea
{
    for my $y (1..$n-2)
    {
        my $nx = 0;
        for my $xe (0..$N-1)
        {
            my $e = $x{$imgf{$xe,$ye}};
            for my $x (1..$n-2)
            {
                $sea->{$nx,$ny} = $e->{a}->{$x,$y};
                $nx++;
            }
        }

        $ny++;
    }
}

my $M = $N * 8;

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
W: while (1) # search for monsters
{
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

                    next X if $sea->{$x+$mx,$y+$my} ne '#';
                }
            }

            for my $my (0..$myl-1)
            {
                for my $mx (0..$mxl-1)
                {
                    next if $monster{$mx,$my} eq '_';
                    $sea->{$x+$mx,$y+$my}="O";
                }
            }

            $found = 1;
        }
    }

    last if $found;

    $sea = rotrl_ar($sea, $M, 'r');
    $sea = flipxy_ar($sea, $M, 'x') if $round == 3;

    $round++;
    die if $round > 7; # there are 8 states
}

for my $y (0..$M-1)
{
    for my $x (0..$M-1)
    {
        print $sea->{$x,$y};
        $stage2++ if $sea->{$x,$y} eq '#';
    }
    print "\n";
}
print "\n";

print "stage 2: $stage2\n";