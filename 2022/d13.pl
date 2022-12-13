#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;


sub compare
{
    my ($l,$r) = @_;

    my $li = 0;
    my $ri = 0;
    while (1)
    {
        if (!exists $l->[$li] && exists $r->[$ri])
        {
 #           print "left out $li\n";
            return 1;
        }
        elsif (exists $l->[$li] && !exists $r->[$ri])
        {
            #print "right out $ri\n";
            return -1;
        }
        elsif (!exists $l->[$li] && !exists $r->[$ri]) # eol
        {
            #print "both out $li $ri\n";
            return 0;
        }

        my $res = 0;
        if (ref $l->[$li] && !ref $r->[$ri])
        {
            $res = compare($l->[$li], [$r->[$ri]]);
        }
        elsif (!ref $l->[$li] && ref $r->[$ri])
        {
            $res = compare([$l->[$li]], $r->[$ri]);
        }
        elsif (ref $l->[$li] && ref $r->[$ri])
        {
            $res = compare($l->[$li], $r->[$ri]);
        }
        else # compare ints
        {
            # comapre ints
            if ($l->[$li] < $r->[$ri])
            {
                $res = 1;
            }
            elsif ($l->[$li] > $r->[$ri])
            {
                $res = -1;
            }
        }

        return $res if ($res != 0);

        # else - continue

        $li++;
        $ri++;
    }

}

my @ff;
for my $a (@f)
{
    next unless $a =~ /\[/;
    eval "\$a = $a";
    push(@ff,$a);
}

my $i = 0;
my $pi = 1;
while (exists $ff[$i])
{
    my $l = $ff[$i];
    my $r = $ff[$i+1];

    my $res = compare($l, $r);
    $stage1 += $pi if $res == 1;
    print "out $pi $res $stage1\n";
    $i+=2;
    $pi++;
}


push(@ff,[[2]]);
push(@ff,[[6]]);
#print Dumper \@ff; exit;

my $d1 = 0;
my $d2 = 0;
my @g = sort { compare($b,$a) } @ff;

$i = 1;
for my $a (@g)
{
    $_ = Dumper $a;
    s/.*=//;
    s/\s+//g;
    s/;//g;
    print "$_\n";
    $d1 = $i if $_ eq '[[2]]';
    $d2 = $i if $_ eq '[[6]]';
    $i++;
}
$stage2 = $d1 * $d2;
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: $d1 x $d2 = %s\n", $stage2;