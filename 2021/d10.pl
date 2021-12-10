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

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $stage1 = 0;
my $stage2 = 0;

my @s2s;
for (@f)
{
    while (1)
    {
        my $p = $_;

        s/\[(\s*?)\]/ $1 /g;
        s/\((\s*?)\)/ $1 /g;
        s/\{(\s*?)\}/ $1 /g;
        s/\<(\s*?)\>/ $1 /g;

        last if /^\s+$/;

        if ($p eq $_)
        {
            if (/^[ \[\(\{\<]+$/) # incomplete
            {
                s/\s+//g;
                $_ = reverse;
                my $t = 0;
                for my $a (split//)
                {
                    $t *= 5;
                    $t += $v2{$a};
                }
                push(@s2s, $t);
            }
            else
            {
                /([\]\)\}\>])/; # corrupted
                $stage1 += $v1{$1};
            }

            last;
        }
    }
}

@s2s = sort { $a <=> $b } @s2s;
$stage2 = $s2s[(scalar(@s2s)-1) / 2];

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;