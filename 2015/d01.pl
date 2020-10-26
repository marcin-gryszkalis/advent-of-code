#!/usr/bin/perl
use Data::Dumper;

$_ = <>;
chomp;

# $up = s/\(/(/g;
# $down = s/\)/)/g;
# print "stage 1: ".($up - $down)."\n";

my $i = 1;
my $floor = 0;
my $found = 0;
for my $m (split//)
{
    $floor += ($m eq '(' ? 1 : -1);
    if ($floor == -1 && !$found)
    {
        print "stage 2: $i\n";
        $found = 1;
    }
    $i++;
}
print "stage 1: $floor\n";
