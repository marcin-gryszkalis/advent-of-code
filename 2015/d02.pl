#!/usr/bin/perl
use Data::Dumper;

my $total = 0;
my $total_ribbon = 0;
while (<>)
{
    chomp;
    ($l,$w,$h) = split/x/;
    @a = sort { $a <=> $b } ($l,$h,$w);
    @b = sort { $a <=> $b } ($l * $w, $w * $h, $h * $l);
    $slack = $b[0];
    my $sum = 2*$b[0] + 2*$b[1] + 2*$b[2] + $slack;
    $total += $sum;

    my $ribbon = 2*$a[0] + 2*$a[1] + $a[0]*$a[1]*$a[2];
#    print join("x",@b)."\n";
#    printf "%d %d %d\n",2*$b[0],2*$b[1],$b[0]*$b[1]*$b[2];
    $total_ribbon += $ribbon;
}

print "stage 1: $total\n";
print "stage 2: $total_ribbon\n";