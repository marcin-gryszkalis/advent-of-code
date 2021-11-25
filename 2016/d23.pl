 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @srccode0 = read_file(\*STDIN);
@srccode0 = map { chomp; $_ } @srccode0;

# optimized code in d23mod.txt (original in d23.txt)

# replaced 2 nested loops

# cpy b c
# add c a
# cpy 0 c
# jnz c -2
# dec d
# jnz d -5

# with multiplication (new opcodes)

# cpy b c
# mul d c
# add c a
# cpy 0 c
# cpy 0 d
# jnz d -5 # noop

my @starts = qw/7 12/;

my $r;
sub val
{
    my $x = shift;
    $x = $r->{$x} if $x =~ /[a-z]/;
    return $x;
}

for my $stage (1..2)
{
    my $srccode = clone(\@srccode0); # tgl modifies it

    for my $reg ('a'..'d')
    {
        $r->{$reg} = 0;
    }

    $r->{a} = $starts[$stage-1];

    my $ip = -1;
    my $c = 0;
    while (1)
    {
        $c++;

        $ip++;
        last if $ip < 0 || $ip > scalar(@$srccode)-1;

        $_ = $srccode->[$ip];
        if (/^(\S+)\s+(\S+)\s*(\S+)?/)
        {
            my $op = $1;

            my $x = $2;
            my $y = $3 // 'EMPTY';

            my $rs = '';
            for my $reg ('a'..'d')
            {
                $rs .= "$reg=$r->{$reg} ";
            }

#            print "$c: [$ip] $_ REG: $rs\n" if $c % 100000 == 0 || $op eq 'tgl';

            if ($op eq 'cpy')
            {
                next if $y =~ /\d/; # 2nd arg is number = invalid
                $r->{$y} = val($x);
            }
            elsif ($op eq 'add') # new opcode!
            {
                next if $y =~ /\d/; # 2nd arg is number = invalid
                $r->{$y} += val($x);
            }
            elsif ($op eq 'mul') # new opcode!
            {
                next if $y =~ /\d/; # 2nd arg is number = invalid
                $r->{$y} *= val($x);
            }
            elsif ($op eq 'inc')
            {
                next if $y =~ /\d/; # 2nd arg is number = invalid
                $r->{$x}++;
            }
            elsif ($op eq 'dec')
            {
                next if $y =~ /\d/; # 2nd arg is number = invalid
                $r->{$x}--;
            }
            elsif ($op eq 'jnz')
            {
                if (val($x) != 0)
                {
                    $ip += val($y);
                    $ip--;
                }
            }
            elsif ($op eq 'tgl')
            {
                my $x = val($x);
                next unless exists $srccode->[$ip + $x]; # If an attempt is made to toggle an instruction outside the program, nothing happens.

                my $t = $srccode->[$ip + $x];
                if ($t =~ /^(\S+)\s+(\S+)\s*(\S+)?/)
                {
                    my $top = $1;
                    my $tx = $2;
                    my $ty = $3 // 'EMPTY';

                    # For two-argument instructions, jnz becomes cpy, and all other two-instructions become jnz.
                    if ($ty ne 'EMPTY')
                    {
                        if ($top eq 'jnz')
                        {
                            $top = 'cpy';
                        }
                        else
                        {
                            $top = 'jnz';
                        }
                    }
                    else # For one-argument instructions, inc becomes dec, and all other one-argument instructions become inc.
                    {
                        if ($top eq 'inc')
                        {
                            $top = 'dec';
                        }
                        else
                        {
                            $top = 'inc';
                        }

                    }

                    $srccode->[$ip + $x] = "$top $tx $ty";
                }
                else
                {
                    die "tgl: $t"
                }

            }
            else
            {
                die $_;
            }
        }
        else { die $_ }
    }

    print "stage $stage: $r->{a}\n";
}
