#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;

$_ = <>;
my @inp = split/\s+/;

my $sum = 0;
my $idx = 0;

sub rec
{
    my $sub_nodes = $inp[$idx++];
    my $metadata_entries = $inp[$idx++];
    rec() for (1..$sub_nodes);
    $sum += $inp[$idx++] for (1..$metadata_entries);
}

rec();
printf "stage 1: %d\n", $sum;

$idx = 0;
sub rectwo
{
    my @nodes_list = ();
    my $node_sum = 0;
    my $sub_nodes = $inp[$idx++];
    my $metadata_entries = $inp[$idx++];
    if ($sub_nodes > 0)
    {
        push(@nodes_list, rectwo()) for (1..$sub_nodes);
        for (1..$metadata_entries)
        {
            my $m = $inp[$idx++];
            if ($m > 0 && $m <= scalar(@nodes_list))
            {
                $node_sum += $nodes_list[$m - 1];
            }
        }
    }
    else
    {
        for (1..$metadata_entries)
        {
            $node_sum += $inp[$idx++];
        }
    }
    return $node_sum;
}

printf "stage 2: %d\n", rectwo();
