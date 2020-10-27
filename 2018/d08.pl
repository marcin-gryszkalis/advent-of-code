#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

# params
my $workers = 5; # 1 for stage 1, 2 for stage 2 d08a.txt, 5 for stage 2 d08.txt
my $addtime = 60; # 0 for d08a.txt, 60 for d08.txt

use File::Slurp;
my @f = read_file(\*STDIN);

my $dependson;

my $allnodesh = {};
my @done;
my $donenodes;
my $processing;
my $processingnodes;
my @workertimeleft;
for my $w (0..$workers-1) { $workertimeleft[$w] = 0 }


for (@f)
{
    if (/Step (\S+) must be finished before step (\S+) can begin/)
    {
        $allnodesh->{$1} = 1;
        $allnodesh->{$2} = 1;

        $dependson->{$2}->{$1} = 1;
    }
}
my @allnodes = sort keys %$allnodesh;


my $timer = 0;
while (1)
{
    last if scalar @allnodes == scalar @done;

    # time goes by
    for my $w (0..$workers-1)
    {
        if (exists $processing->{$w})
        {
            $workertimeleft[$w]--;
        }
    }

    # finished work
    for my $w (0..$workers-1)
    {
        if (exists $processing->{$w})
        {
            if ($workertimeleft[$w] == 0)
            {
                my $k = $processing->{$w};
                push(@done, $k);
                $donenodes->{$k} = 1;
                for my $l (@allnodes)
                {
                    delete $dependson->{$l}->{$k};
                }

                delete $processing->{$w};
                delete $processingnodes->{$k};
            }
        }
    }

    # find nodes ready to be processed
    my @ready = ();
    for my $k (@allnodes)
    {
        if (
            !exists $donenodes->{$k} && # not done
            !exists $processingnodes->{$k} && # not being processed
            (!exists $dependson->{$k} || scalar(keys(%{$dependson->{$k}})) == 0) # no active dependencies
            )
        {
            push(@ready, $k);
        }
    }
    @ready = sort @ready;

    # new work
    for my $w (0..$workers-1)
    {
        next if exists $processing->{$w};
        my $p = shift(@ready);
        next unless defined $p; # nothing in queue

        $workertimeleft[$w] = ord($p) - ord('A') + 1 + $addtime;
        $processing->{$w} = $p;
        $processingnodes->{$p} = 1;
    }

    my $r = '';
    for my $w (0..$workers-1)
    {
        $r .= sprintf "%s[%d] ", $processing->{$w} // ".", $workertimeleft[$w];
    }
    printf "%4d %40s done:%-10s\n",
        $timer, $r,
        join("", @done);

    $timer++;
#    sleep 1;
}

