#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my $or = <>;
chomp $or;
$or = substr($or, 1, -1);

sub longest
{
    my $s = shift;
    my @x = sort { length($b) <=> length($a) } split(/\|/, $s);
    return $x[0];
}

my $r = $or;

# rebuild detours

# ^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$
# to
# ^ENNWSWW(NE|SSSEEN(WN|EE(SW|NNN)))$

# ^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$
# to
# ^ESSWWN(E|NNENN(EESS(WN|SSS)|WWWSSSSE(SW|NNNE)))$

while (1)
{
    last unless $r =~ m{\(([^()]+)\|\)};
    my $p = $+[0]; # index of char after match

    my $level = 0;
    while (1)
    {
        if ($p > length($r))
        {
            $r .= ')';
            last;
        }

        if ($level == 0 && substr($r, $p, 1) =~ /([)|])/)
        {
            substr($r, $p, 1, ")$1");
            last;
        }

        $level++ if (substr($r, $p, 1) eq '(');
        $level-- if (substr($r, $p, 1) eq ')');
        $p++;
    }

    $r =~ s{\(([^()]+)\|\)}{"(".substr($1, 0, length($1) / 2)."|"}e; # halve detours (SSNN -> SS)
}


my $s = $r;
while (1)
{
    last unless ($s =~ s/\(([^()]+)\)/longest($1)/e);
    $s =~ s/\(\|*\)//; # cleanup
}
printf "stage 1: %d\n", length($s);


# count rooms
my $c = () = $r =~ m/[NSEW]/g;
$c++; # +starting point

my $digits = int(log($c)/log(10))+1;


# replace move (ESNW) with uniq id

# ESSWWN(E|NNENN(EESS(WN|)SSS|WWWSSSSE(SW|NNNE)))
# x00x01x02x03x04x05(x06|x07x08x09x10x11(x12x13x14x15(x16x17|)x18x19x20|x21x22x23x24x25x26x27x28(x29x30|x31x32x33x34)))
my $cnter = 0;
sub cnt
{
    my $digits = shift;
    return sprintf "x%0${digits}d", $cnter++;
}

$r =~ s/[NSWE]/cnt($digits)/ge;


my $stage2 = 0;

my $i = 0;
L: while (1)
{
    while (1)
    {
        my $l = length($r);
        $r =~ s/\(\|*\)//g; # cleanup (almost) empty
        $r =~ s/\(\(([^()]+)\)\)/($1)/g; # cleanup dbl ()
        last if $l == length($r);
    }

    my $s = $r;

    while (1)
    {
        last unless ($s =~ s/\(([^()]+)\)/longest($1)/ge);
    }

    my $pathlen = length($s) / (1+$digits);

    last if $pathlen < 1000;
    $stage2++;

    my $best = substr($s, -(1+$digits));
    $r =~ s/\|*$best//;

    print "s2=$stage2 len=$pathlen removed $best\n";
    $i++;
}

print "stage 2: $stage2\n";
