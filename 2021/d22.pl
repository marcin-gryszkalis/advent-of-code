#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail reduce/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;

$; = ",";

my @qq;

FOR: for (@f)
{
    next unless /^(on|off)/;
    my $mode = $1;
    my ($x1,$x2,$y1,$y2,$z1,$z2) = /[\d-]+/g;

    #stage1
    # next if
    #     $x1 < -50 ||
    #     $x2 > 50 ||
    #     $y1 < -50 ||
    #     $y2 > 50 ||
    #     $z1 < -50 ||
    #     $z2 > 50 ;

    if ($mode eq 'on')
    {
        my @nq = ();
        my @fq = ();

        my %tq;
        $tq{x1} = $x1;
        $tq{x2} = $x2;
        $tq{y1} = $y1;
        $tq{y2} = $y2;
        $tq{z1} = $z1;
        $tq{z2} = $z2;

        if (scalar(@qq) == 0)
        {
            push(@qq, \%tq);
            next FOR;
        }

        push(@nq, \%tq);
        NQ: while (1)
        {
            my $p = pop(@nq); # p is new one (may come from split)
            last unless defined $p;

#            printf("nqs(%d)\n", scalar @nq);
            print "P: $p->{x1},$p->{x2} $p->{y1},$p->{y2} $p->{y1},$p->{y2}\n";


            my $psplit = 0; # if p got split

            QQ: while (1)
            {
                my $q = pop(@qq);
                last unless defined $q;

                print "Q: $q->{x1},$q->{x2} $q->{y1},$q->{y2} $q->{y1},$q->{y2}\n";
                # no overlap
                if (
                    ($p->{x2} < $q->{x1} || $p->{x1} > $q->{x2}) &&
                    ($p->{y2} < $q->{y1} || $p->{y1} > $q->{y2}) &&
                    ($p->{z2} < $q->{z1} || $p->{z1} > $q->{z2}))
                {
                    push(@fq, $q);
                    next QQ;
                }

                # p in q
                if (
                    ($p->{x1} >= $q->{x1} && $p->{x2} <= $q->{x2}) &&
                    ($p->{y1} >= $q->{y1} && $p->{y2} <= $q->{y2}) &&
                    ($p->{z1} >= $q->{z1} && $p->{z2} <= $q->{z2}))
                {
                    # p lost in q
                    push(@fq, $q);
                    next NQ;
                }

                # q in p
                if (
                    ($q->{x1} >= $p->{x1} && $q->{x2} <= $p->{x2}) &&
                    ($q->{y1} >= $p->{y1} && $q->{y2} <= $p->{y2}) &&
                    ($q->{z1} >= $p->{z1} && $q->{z2} <= $p->{z2}))
                {
                    # q lost in p, but p may overlap with others!
                    # forget about q!
                    next QQ;
                }

                # partial overlap
                $psplit = 1;

                my %sidex;
                my %sidey;
                my %sidez;

                my @sx = (); # split axis
                my @sy = ();
                my @sz = ();

                push(@sx, $q->{x1}, $q->{x2}, $p->{x1}, $p->{x2});
                push(@sy, $q->{y1}, $q->{y2}, $p->{y1}, $p->{y2});
                push(@sz, $q->{z1}, $q->{z2}, $p->{z1}, $p->{z2});

                $sidex{$q->{x1}} = 'L'; $sidex{$q->{x2}} = 'R';
                $sidex{$p->{x1}} = 'L'; $sidex{$p->{x2}} = 'R';
                $sidey{$q->{y1}} = 'L'; $sidey{$q->{y2}} = 'R';
                $sidey{$p->{y1}} = 'L'; $sidey{$p->{y2}} = 'R';
                $sidez{$q->{z1}} = 'L'; $sidez{$q->{z2}} = 'R';
                $sidez{$p->{z1}} = 'L'; $sidez{$p->{z2}} = 'R';

                @sx = sort { $a <=> $b } @sx; @sx = uniq(@sx);
                @sy = sort { $a <=> $b } @sy; @sy = uniq(@sy);
                @sz = sort { $a <=> $b } @sz; @sz = uniq(@sz);

                pop(@sx); shift(@sx);
                pop(@sy); shift(@sy);
                pop(@sz); shift(@sz);

                my @sq;
                push(@sq, $p);
                push(@sq, $q);
                my @sqf = ();
                SQ: while (1)
                {
                    my $s = pop(@sq);
                    last unless defined $s;

                    for my $ax (@sx)
                    {
                        if ($ax > $s->{x1} && $ax < $s->{x2})
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;

                            $n1{x1} = $s->{x1};
                            if ($sidex{$ax} eq 'L')
                            {
                                $n1{x2} = $ax-1;
                                $n2{x1} = $ax;
                            }
                            else
                            {
                                $n1{x2} = $ax;
                                $n2{x1} = $ax+1;
                            }
                            $n2{x2} = $s->{x2};

                            unshift(@sq, \%n1);
                            unshift(@sq, \%n2);
                            next SQ;
                        }
                    }

                    for my $ay (@sy)
                    {
                        if ($ay > $s->{y1} && $ay < $s->{y2})
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;
                            $n1{y1} = $s->{y1};
                            if ($sidey{$ay} eq 'L')
                            {
                                $n1{y2} = $ay-1;
                                $n2{y1} = $ay;
                            }
                            else
                            {
                                $n1{y2} = $ay;
                                $n2{y1} = $ay+1;
                            }
                            $n2{y2} = $s->{y2};
                            unshift(@sq, \%n1);
                            unshift(@sq, \%n2);
                            next SQ;
                        }
                    }

                    for my $az (@sz)
                    {
                        if ($az > $s->{z1} && $az < $s->{z2})
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;
                            $n1{z1} = $s->{z1};
                            if ($sidez{$az} eq 'L')
                            {
                                $n1{z2} = $az-1;
                                $n2{z1} = $az;
                            }
                            else
                            {
                                $n1{z2} = $az;
                                $n2{z1} = $az+1;
                            }
                            $n2{z2} = $s->{z2};
                            unshift(@sq, \%n1);
                            unshift(@sq, \%n2);
                            next SQ;
                        }
                    }

                    push(@sqf, $s);
                }

                # remove dupes from @sq
                my %sqh;
                for my $s (@sqf)
                {
                    $sqh{$s->{x1},$s->{x2},$s->{y1},$s->{y2},$s->{z1},$s->{z2}} = 1;
                }

                @sq = ();
                for my $k (keys %sqh)
                {
                    my @kk = split(/$;/, $k);
                    my %s = ();
                    $s{x1} = $kk[0];
                    $s{x2} = $kk[1];
                    $s{y1} = $kk[2];
                    $s{y2} = $kk[3];
                    $s{z1} = $kk[4];
                    $s{z2} = $kk[5];
                    push(@sq, \%s);
                }

                unshift(@nq, @sq); # push both split p and split q to @nq
                last QQ;

            } # qq

            push(@fq, $p) unless $psplit;
        } # nq
        @qq = @fq;
    }
    else # off
    {

    }

}
print Dumper \@qq;

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;