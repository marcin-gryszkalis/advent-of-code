 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);
my $s = shift(@f);
shift(@f);

my %m = map { /(\S+) -> (\S+)/; $1 => $2; } @f;

my $p0;
for my $i (0..length($s)-2)
{
    $p0->{substr($s, $i, 2)}++;
}

for my $step (1..40)
{
    my $p = ();
    for my $h (keys %$p0)
    {
        if (exists $m{$h})
        {
            my ($a, $b) = split//, $h;
            $p->{$a.$m{$h}} += $p0->{$h};
            $p->{$m{$h}.$b} += $p0->{$h};
        }
    }

    $p0 = $p;

    my %c = ();
    for my $a (keys %$p0)
    {
        $c{substr($a, 0, 1)} += $p0->{$a};
    }
    $c{substr($s, -1, 1)}++; # last letter of string is not first in any pair

    printf "$step %s\n", max(values %c) - min(values %c);
}
