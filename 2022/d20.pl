#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
$; = ',';

my @key = qw/1 811589153/;
my @repeat = qw/1 10/;

my @f = read_file(\*STDIN, chomp => 1);

my $l = scalar(@f);

my @t;


for my $stage (0..1)
{
    my $start = undef;
    my $b = undef;
    my @ot;
    for (@f)
    {
        my %x = ();
        $start = \%x unless defined $start;
        %x = ( v => $_ * $key[$stage], p => $b, n => undef );
#    $x{p}{n} = \%x if defined $x{p}{n};
    
    push(@ot, \%x);
    $b = \%x;
}
my $end = $b;
#print Dumper $start; exit;
my $x = $end;
while (1)
{
    my $y = $x;
    if (defined $x->{p})
    {
        $x = $x->{p};
        $x->{n} = $y;
    }
    else
    {
        $x->{p} = $end;
        $end->{n} = $x;
        last;
    }
}


sub qp($q)
{
    my $xp = $q;
    my $i = 0;
    while (1)
    {
        print "$xp->{v}, ";
        #print "($xp->{p}->{v} $xp->{v} $xp->{n}->{v}), ";
        $xp = $xp->{n};
        last if $xp == $q;
        last if $i++ > 20;
    }
    print "\n";
}

# $x = $start;
for my $r (1..$repeat[$stage])
{

for my $i (0..$l-1)
{

#    qp($start);

    $x = $ot[$i];

    my $v = $x->{v};
    next if $v == 0;
    my $vv = abs($v) % ($l - 1);
    next if $vv == 0;

# when going forward I place it AFTER pos found
# when going backward I place it BEFORE pos found, so do I step more and place if AFTER

    my $d = $x;

    # remove $x
    $x->{p}{n} = $x->{n};
    $x->{n}{p} = $x->{p};

#    printf "move: $v or %d\n", $v % ($l - 1);
    if ($v > 0)
    {
        for (1..$vv)
        {
            $d = $d->{n};
        }
    }
    elsif ($v < 0)
    {
        for (1..$vv+1)
        {
            $d = $d->{p};
        }
    }

        # insert at new place
        my $od = $d;
        $x->{p} = $d;
        $x->{n} = $od->{n};
        $d->{n}{p} = $x;
        $d->{n} = $x;

}
}
# qp($start);


my $xp = $start;
my $zat = undef;
my $i = 0;
my @q = ();
while (1)
{
    push(@q, $xp->{v});
    $zat = $i if $xp->{v} == 0;
#    print "$xp->{v}\n";
    $i++;
    $xp = $xp->{n};
    last if $xp == $start;
    die $i if $i > $l + 100;
}


printf "Stage %d: %s\n", $stage+1,
$q[($zat + 1000) % $l] +
$q[($zat + 2000) % $l] +
$q[($zat + 3000) % $l];


}
