 #!/usr/bin/perl
use warnings;
use strict;

my $h = 0;
my $d = 0;
my $a = 0;

while (<>)
{
    $h += $1 if /forward (\d+)/;
    $d += $a * $1 if /forward (\d+)/;
    $a += $1 if /down (\d+)/;
    $a -= $1 if /up (\d+)/;
}

printf "Stage 1: %s\n", $h * $a;
printf "Stage 2: %s\n", $h * $d;