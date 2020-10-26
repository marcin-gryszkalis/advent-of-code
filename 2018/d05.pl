#!/usr/bin/perl
use Data::Dumper;

$a = <>;
chomp $a;

@t = split(//,$a);
my $c = scalar @t;

while (1)
{
    my $j = 0;
    my $i = 1;
    my $dj = 1;
    my $found = 0;
    while (1)
    {
        if (abs(ord($t[$i]) - ord($t[$j])) == 0x20)
        {
            $t[$i] = $t[$j] = '_';
            $found++;
            $dj = -1;
        }
        elsif ($found)
        {
            $dj = 1;
            $j = $i - 1;
        }

        last if $i >= $c || $j < 0;
        $j = $j + $dj;
        $i++;
    }

    $a = join("", @t);
    $a =~ s/_+//g;
    @t = split(//,$a);

    last unless $found;
    print length($a)."\n";
}

print length($a)." $a\n";
