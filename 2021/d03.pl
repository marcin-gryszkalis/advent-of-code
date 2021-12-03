 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my @c;
for (@f)
{
    my $i = 0;
    for my $b (split//)
    {
        $c[$i++] += $b;
    }
}
my $l = scalar(@f) / 2;
my $g = join("", map { $_ > $l ? 1 : 0 } @c);
my $e = $g;
$e =~ tr/01/10/;
$stage1 = oct("0b".$g) * oct("0b".$e);

my @r;
for my $rn (0..1) # rating number
{
    my @f2 = @{clone([@f])};

    my $pos = 0;
    while(1)
    {
        my $cc = sum(map { substr($_, $pos, 1) } @f2);
        my $l = scalar(@f2) / 2;
        my $mcb = ($cc >= $l ? 1 : 0) ^ $rn;
        @f2 = grep { substr($_, $pos, 1) eq $mcb } @f2;
        if (scalar(@f2) == 1)
        {
            push(@r, pop(@f2));
            last;
        }

        $pos++;
    }

}

$stage2 = oct("0b".pop(@r)) * oct("0b".pop(@r));

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;