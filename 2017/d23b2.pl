use warnings;
# use strict;


# working solution
use Math::Prime::Util qw/is_prime/;
$b = 106700;
$c = $b+17000;
$h = 0;
while ($b <= $c)
{
    $h++ unless is_prime $b;
    $b += 17;
}
print "$h\n";


# original assembly translated
$h = 0;

$b = 67 * 100 + 100000; # 106700

$c = $b + 17000; # 123700

while (1)
{
    $f = 1;
    $d = 2;

    DE: while ($d < $b)
    {
        $e = 2;

        while ($e < $b)
        {
            $f=0 if $d*$e == $b;

            last DE if $f == 0; # originally non existent optimization, still too long for primes
            $e++;
        }

        $d++;
    }

    $h++ if $f == 0;
    print "$b $h\n";

    if ($b == $c) { print qq{stage 2: $h }; exit(0); }
    $b += 17;
}


