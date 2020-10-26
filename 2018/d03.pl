#!/usr/bin/perl
use Data::Dumper;

my $tx = 0;
my $map;
my $ok;
while (<>)
{
    chomp;
    #    #1 @ 1,3: 4x4
    ($cid, $x, $y, $w, $h) = /#(\d+)\s*\@\s*(\d+),(\d+):\s*(\d+)x(\d+)/;

    $ok->{$cid} = 1;

    for my $ix ($x..$x+$w-1)
    {
        for my $iy ($y..$y+$h-1)
        {
            if (exists $map->{$ix}->{$iy})
            {
                delete $ok->{$cid};
                if ($map->{$ix}->{$iy} ne "x")
                {
                    delete $ok->{$map->{$ix}->{$iy}};
                    $map->{$ix}->{$iy} = "x";
                    $tx++;
                }
            }
            else # empty
            {
                $map->{$ix}->{$iy} = $cid;
            }
        }
    }

}

print "stage 1: $tx\n";
print "stage 2: ".((keys(%$ok))[0])."\n";
