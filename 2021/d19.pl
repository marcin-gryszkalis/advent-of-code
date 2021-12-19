#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my $h;

my $sc;
for (@f)
{
    next if /^\s*$/;
    if (/scanner (\d+)/) { $sc = $1; next }
    my @a = /[\d-]+/g;
    push(@{$h->{$sc}}, \@a);
}

my $maxs = max(keys %$h);

$; = ":";

my @xform;

my @uq;
for my $x ((-1,1)) {
for my $y ((-1,1)) {
for my $z ((-1,1)) {
my $itp = permutations([0,1,2]);
PERM: while (my $p = $itp->next)
{
    my $q;
    $q->[0] = $p->[0];
    $q->[1] = $p->[1];
    $q->[2] = $p->[2];
    $q->[3] = $x;
    $q->[4] = $y;
    $q->[5] = $z;

    push(@xform, $q);

    print join(" ", @$q)."\n";
}
}}}

my $c = $h->{0};
my @xformuq;
my %xformh;

for my $x (@xform)
{
    my $d;
    for my $r (@$c)
    {
        my @a = (
            $r->[abs($x->[0])] * ($x->[3]),
            $r->[abs($x->[1])] * ($x->[4]),
            $r->[abs($x->[2])] * ($x->[5]),
            );
        push @$d, \@a;
    }

    # print "\n\n".join(" ", @$x)."\n";
    # my $md5h = md5_hex(Dumper $d);
    # if (!exists($xformh{$md5h}))
    # {
    #     $xformh{$md5h} = 1;
    #     push(@xformuq, $x);
    # }
    #print Dumper $d;
}

my $m; # map


for my $r (@$c)
{
    $m->{$r->[0],$r->[1],$r->[2]} = 0;
}
my %done;
$done{0} = 1;

#print Dumper $m;exit;
while (1)
{
    BIG: for my $i (0..$maxs)
    {
        next if $done{$i};

        my $c = $h->{$i};

        for my $x (@xform)
        {
            my $d;
            for my $r (@$c)
            {
                my @a = (
                    $r->[abs($x->[0])] * ($x->[3]),
                    $r->[abs($x->[1])] * ($x->[4]),
                    $r->[abs($x->[2])] * ($x->[5]),
                    );
                push @$d, \@a;
            }

            for my $p (keys %$m) # for every point on  map
            {
                my @pp = split/$;/,$p;

                # my $ps = $m->{$p}; # which scanner?

                for my $dp (@$d) # end every point on transformed scanner d
                {
                    my @move = (
                        $pp[0] - $dp->[0],
                        $pp[1] - $dp->[1],
                        $pp[2] - $dp->[2],
                        );

                    my $cnt = 0;
                    for my $vp (@$d) # verify others
                    {
                        $cnt++ if (exists $m->{$vp->[0]+$move[0],$vp->[1]+$move[1],$vp->[2]+$move[2]});
                    }

                    if ($cnt >= 12)
                    {
                        for my $r (@$d)
                        {
                            $m->{$r->[0]+$move[0],$r->[1]+$move[1],$r->[2]+$move[2]} = $i;
                        }
printf "match: $i xform(%s) move(%s)\n",join(" ",@$x),join(" ",@move);
                        $done{$i} = 1;
                        next BIG;
                    }
                }

            }

        }
    }

    last if scalar(keys %done) == $maxs+1;
}

print Dumper $m;
$stage1 = scalar(keys %$m);


#print Dumper $h;

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;