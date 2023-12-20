#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations/;
use Clone qw/clone/;
$; = ',';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

my @tr;
my @tr2;

my $t;
for (@f)
{
    my ($type, $n, $d) = m/([&%]?)(\w+) -> (.*)/;
    my @dst = $d =~ m/(\w+)/g;

    $t->{$n}->{type} = $type;
    $t->{$n}->{dst} = \@dst;
    $t->{$n}->{st} = 0; # for flipflops

    for my $d (@{dst}) # for conj
    {
        next if $d eq 'rx';
        $t->{$d}->{mem}->{$n} = 0;
    }

    push(@tr, $n) if $type eq '&';
    push(@tr2, $n) if $type eq '%';
}

my $high = 0;
my $low = 0;
my %mm = qw/0 low 1 high/;

my %ps;
for my $trx (@tr) { $ps{$trx} = '' }
for my $trx (@tr2) { $ps{$trx} = '' }

@tr = ();
push(@tr,'kj');
for my $i (1..10000000000000000) # 1000
{
    if ($i == 1001)
    {
        say $low;
        say $high;
        say $high * $low;
        $stage1 = $high * $low;

    }
    my @q = ();

    for my $trx (@tr)
    {
        my $ss = join(",", values(%{$t->{$trx}->{mem}}));
        if ($ss ne $ps{$trx})
        {
            printf "$i: $trx=%s\n", $ss;
            $ps{$trx} = $ss;
        }
    }

    # for my $trx (@tr2)
    # {
    #     my $ss = $t->{kj}->{st};
    #     if ($ss ne $ps{$trx})
    #     {
    #         printf "$i: $trx=%s\n", $ss;
    #         $ps{$trx} = $ss;
    #     }
    # }

    push(@q, [0, 'broadcaster', 'button']);
    while (my $sig = shift(@q))
    {
        my ($p,$n,$src) = @$sig;
        #print "$i: $src -$mm{$p}-> $n\n";
        if ($p == 0)
        {
            $low++;
        }
        else
        {
            $high++;
        }

            if ($n eq 'rx' && $p == 0)
            {
                $stage2 = $i;
                say $i;
                exit;
            }

        unless (exists $t->{$n})
        {
#            print "empty($n,$p)\n";
            next;
        }

        my $m = $t->{$n};
        if ($m->{type} eq '')
        {
            for my $d (@{$m->{dst}})
            {
                push(@q, [$p, $d, $n]);
            }
        }
        elsif ($m->{type} eq '%')
        {
            if ($p == 0)
            {
                my $state = 1 - $m->{st};
                if ($state)
                {
                    for my $d (@{$m->{dst}})
                    {
                        push(@q, [1, $d, $n]);
                    }

                }
                else
                {
                    for my $d (@{$m->{dst}})
                    {
                        push(@q, [0, $d, $n]);
                    }
                }
                $t->{$n}->{st} = $state;
            }
        }
        elsif ($m->{type} eq '&')
        {
            $t->{$n}->{mem}->{$src} = $p;
            if (sum(values %{$t->{$n}->{mem}}) == scalar(values %{$t->{$n}->{mem}}))
            {
                #print "$i: LOW $n\n" if $n !~ /(ln|vn|zx|dr|qs|pr|jm|jv)/;

                for my $d (@{$m->{dst}})
                {
                    push(@q, [0, $d, $n]);
                }
            }
            else
            {
                if ($n =~ /(ln|vn|zx|dr)/)
                {
                    print "$i: HIGH $n\n" ;

                }

                for my $d (@{$m->{dst}})
                {
                    push(@q, [1, $d, $n]);
                }
            }
        }

    }
}
printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;