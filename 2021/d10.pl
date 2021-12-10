 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my %v1 = qw/
) 3
] 57
} 1197
> 25137
/;

my %v2 = qw/
( 1
[ 2
{ 3
< 4
/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @s2s;
for (@f)
{
    redo if s/(\[\]|\(\)|\{\}|\<\>)//g;
    next if /^$/; # valid

    if (/^[\[\(\{\<]+$/) # incomplete
    {
        my $t = 0;
        for my $a (reverse split//)
        {
            $t *= 5;
            $t += $v2{$a};
        }
        push(@s2s, $t);
    }
    else # corrupted
    {
        /([\]\)\}\>])/;
        $stage1 += $v1{$1};
    }
}

@s2s = sort { $a <=> $b } @s2s;
$stage2 = $s2s[(scalar(@s2s)-1) / 2];

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;