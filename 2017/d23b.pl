#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;


sub xval
{
    my $x = shift;
    $x = "\$reg->{$x}" if $x =~ /[a-z]/;
    return $x;
}

# generate code for eval() - too slow as the algorithm is too slow :)
my $code = '';

my $ip = 0;
my $reg;
for (@f)
{
    if (/(\S+)\s+(\S+)\s+(\S+)?/)
    {
        my $op = $1;
        my $x = $2;
        my $y = $3;
        $reg->{$x} = 0 if $x =~ /[a-z]/;
        $reg->{$y} = 0 if defined $y && $y =~ /[a-z]/;

        $code .= "L$ip: ";
        if ($ip == 30)
        {
            $code .= "print qq{h=\$reg->{h}\\n};";
        }

        if ($op eq 'set')
        {
            $code .= "\$reg->{$x} = ".xval($y)."; # $_\n";
        }
        elsif ($op eq 'sub')
        {
            $code .= "\$reg->{$x} -= ".xval($y).";\n";
        }
        elsif ($op eq 'mul')
        {
            $code .= "\$reg->{$x} *= ".xval($y).";\n";
        }
        elsif ($op eq 'jnz')
        {
            my $np = $ip + $y;

            if ($np < 0 || $np > scalar(@f)-1)
            {
                $code .= "print qq{stage 2: \$reg->{h}}; exit(0);\n";
            }
            else
            {
                $code .= "if (".xval($x)." != 0) { goto L$np; } # $_\n";
            }
        }
        else { die }
    }
    $ip++;
}

print $code;

$reg->{a} = 1;
eval $code;