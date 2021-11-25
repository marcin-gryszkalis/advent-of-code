#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @srccode = read_file(\*STDIN);
@srccode= map { chomp; $_ } @srccode;

for my $stage (1..2)
{
    my $code = '';
    for my $reg ('a'..'d')
    {
        $code .= "my \$$reg = 0;\n";
    }

    $code .= "\$c = ".($stage - 1).";\n";

    my $ip = 0;
    for (@srccode)
    {
        $code .= "L$ip: ";

        s/\s([a-d])/ \$$1/g;
        if (/cpy (\S+) (\S+)/)
        {
            $code .= "$2 = $1;\n";
        }
        elsif (/inc (\S+)/)
        {
            $code .= "$1++;\n";
        }
        elsif (/dec (\S+)/)
        {
            $code .= "$1--;\n";
        }
        elsif (/jnz (\S+) (\S+)/)
        {
            my $nip = $ip + $2;
            $code .= "goto L$nip if $1 != 0;\n";

        }
        else
        {
            die $_;
        }

        $ip++;
    }

    $code .= qq{print("Stage $stage: \$a\\n");};

    print "$code\n\n";
    eval $code;

}
