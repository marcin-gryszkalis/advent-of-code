#!/usr/bin/perl
use Data::Dumper;

my $f = 0;
my @l = ();
while (<>)
{
    chomp;
    $f += $_;
    push(@l, $_);
}
print "stage 1: $f\n";

$f = 0;
while (1)
{
    for $g (@l)
    {
        $f += $g;
        if (exists $h{$f})
        {
            print "stage 2: $f\n";
            exit;
        }
        $h{$f} = 1;
    }
}

