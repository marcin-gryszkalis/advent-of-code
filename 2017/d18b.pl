#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product/;
use List::MoreUtils qw(uniq);
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations);

use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only');

use threads::shared;
use Thread::Queue;
$| = 1;

# threads
my @thread;
my $tq01;
my $tq10;

my @thwaits :shared = (0,0);
my @thsentcnt :shared = (0,0);

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my $reg;
for (@f)
{
    if (/(\S+)\s+(\S+)\s+(\S+)?/)
    {
        my $x = $2;
        my $y = $3;
        $reg->{$x} = 0 if $x =~ /[a-z]/;
        $reg->{$y} = 0 if defined $y && $y =~ /[a-z]/;
    }
}

sub val
{
    my $x = shift;
    $x = $reg->{$x} if $x =~ /[a-z]/;
    return $x;
}

$SIG{TERM} = sub { exit(1) };

sub thcode
{
    my $qin = shift;
    my $qout = shift;
    my $me = shift;

    $reg->{p} = $me;

    my $ip = 0;
    while (1)
    {
        $_ = $f[$ip];
        if (/^(\S+)\s+(\S+)\s*(\S+)?/)
        {
            my $op = $1;

            my $x = $2;
            my $y = $3 // 'EMPTY';

            my $rs = join(", ", map { "$_ = $reg->{$_}"} sort keys(%$reg));
            printf "PID%d :: [%4s] %-16s -- OP($op) X($x) Y($y) [%s]\n", $me, $ip, $_, $rs;

            if ($op eq 'snd')
            {
                $qout->enqueue(val($x));
                $thsentcnt[$me]++;
            }
            elsif ($op eq 'set')
            {
                $reg->{$x} = val($y);
            }
            elsif ($op eq 'add')
            {
                $reg->{$x} += val($y);
            }
            elsif ($op eq 'mul')
            {
                $reg->{$x} *= val($y);
            }
            elsif ($op eq 'mod')
            {
                $reg->{$x} %= val($y);
            }
            elsif ($op eq 'rcv')
            {
                while (1)
                {
                    $thwaits[$me]++;
                    my $m = $qin->dequeue_nb();
                    if (defined $m)
                    {
                        $reg->{$x} = $m;
                        last;
                    }
                }
                $thwaits[$me] = 0;
            }
            elsif ($op eq 'jgz')
            {
                if (val($x) > 0)
                {
                    $ip += val($y) ;
                    $ip--;
                }
            }
        }
        else { die $_ }

        $ip++;
        last if $ip < 0 || $ip > scalar(@f);
    }
}

# init threads
$tq01 = Thread::Queue->new();
$tq10 = Thread::Queue->new();
$thread[0] = threads->create(\&thcode, ($tq10, $tq01, 0));
$thread[1] = threads->create(\&thcode, ($tq01, $tq10, 1));
my $thalive = 2;

while ($thalive > 0)
{
    for my $i (0..1)
    {
        if ($thread[$i]->is_joinable())
        {
            $thread[$i]->join();
            $thalive--;
        }
    }

    if ($thwaits[0] > 100 && $thwaits[1] > 100) # deadlock
    {
        $thread[0]->kill('SIGTERM');
        $thread[1]->kill('SIGTERM');
        sleep(1);
    }
}


print "stage 2: $thsentcnt[1]\n";