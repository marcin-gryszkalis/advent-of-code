#!/usr/bin/perl
use Data::Dumper;

while (<>)
{
    if (/Guard #(\d+) begins shift/)
    {
        $g = $1; next;
    }

    if (/\d+-(\d\d-\d\d) \d\d:(\d\d)] (falls asleep|wakes up)/)
    {
        $date = $1; $min = $2;
        $act = $3;

        if ($act eq 'falls asleep')
        {
            $sleepstart = $min;
        }
        else # wakes up
        {
            $total->{$g} += $min - $sleepstart;
            for my $m ($sleepstart..$min-1)
            {
                $perminute->{$g}->{$m}++;
            }

        }
    }
}

$best = (sort {$total->{$b} <=> $total->{$a}} keys %$total)[0];

$pmb = $perminute->{$best};
$bestmin = (sort {$pmb->{$b} <=> $pmb->{$a}} keys %$pmb)[0];

print "stage 1: guard = $best, minute = $bestmin, result = ".($best*$bestmin)."\n";
# stage 1: guard = 1523, minute = 43, result = 65489


$best = -1;
$bestbestmin = -1;
$bestbestminv = -1;
for $g (keys %$total)
{
    $pmb = $perminute->{$g};
    $bestmin = (sort {$pmb->{$b} <=> $pmb->{$a}} keys %$pmb)[0];
    $bestminv = $perminute->{$g}->{$bestmin};
    if ($bestminv > $bestbestminv)
    {
        $bestbestminv = $bestminv;
        $bestbestmin = $bestmin;
        $best = $g;
    }
}

$x = $perminute->{$best}->{$bestbestmin};
print "stage 2: guard = $best, minute = $bestbestmin, x=$x, result = ".($best*$bestbestmin)."\n";
