#!/usr/bin/perl
use Data::Dumper;

$i = 0;
while (<>)
{
    chomp;
    %c = ();
    for $a (split //)
    {
        $c{$a}++;
    }

    %d = reverse %c;
    $d++ if exists $d{2};
    $t++ if exists $d{3};

    my @ar = split//;
    my @ar2 = @ar;
    $a->[$i++] = \@ar2;
}

print "stage 1: d($d) * t($t) = ".($d*$t)."\n";

my $len = scalar(@{$a->[0]});

for my $i (0..scalar(@$a) - 1)
{
    for my $j ($i..scalar(@$a) - 1)
    {
        my $c = 0;
        for my $l (0..$len)
        {
            $c++ if $a->[$i]->[$l] ne $a->[$j]->[$l];
            last if $c > 1;
        }

        my $s = "";
        if ($c == 1)
        {
            print "$i ".join("", @{$a->[$i]})."\n";
            print "$j ".join("", @{$a->[$j]})."\n\n";
            for my $l (0..$len)
            {
                $s .= $a->[$i]->[$l] if $a->[$i]->[$l] eq $a->[$j]->[$l];
            }
            print "stage 2: $s\n";
            exit;
        }
    }
}
