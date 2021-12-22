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


sub cube
{
    my $q = shift;
    return "($q->{x1},$q->{x2})-($q->{y1},$q->{y2})-($q->{z1},$q->{z2})";
}

for my $stage (1..2)
{
    my @qq = (); # list of non-overlaping cubes
    my $i = 1;
    FOR: for (@f)
    {
        last if /xxx/;
        next unless /^(on|off)/;
        my $mode = $1;
        my ($x1,$x2,$y1,$y2,$z1,$z2) = /[\d-]+/g;

        if ($stage == 1)
        {
            next if
                $x1 < -50 ||
                $x2 > 50 ||
                $y1 < -50 ||
                $y2 > 50 ||
                $z1 < -50 ||
                $z2 > 50 ;
        }

        my @nq = ();
        my @fq = ();

        my %tq;
        $tq{x1} = $x1;
        $tq{x2} = $x2;
        $tq{y1} = $y1;
        $tq{y2} = $y2;
        $tq{z1} = $z1;
        $tq{z2} = $z2;

        printf STDERR "%4d: START %s\n", $i++, cube(\%tq);

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
            printf "NEW P: %s\n", cube($p);
            my $qqsize =  scalar(@qq);
            printf(STDERR "QQ(%d)\n", $qqsize) if $qqsize % 1000 == 0;

            my $psplit = 0; # if p got split

            QQ: while (1)
            {
                my $q = pop(@qq);
                last unless defined $q;

    #            print "Q: $q->{x1},$q->{x2} $q->{y1},$q->{y2} $q->{z1},$q->{z2}\n";

                # no overlap
                if (
                    ($p->{x2} < $q->{x1} || $p->{x1} > $q->{x2}) ||
                    ($p->{y2} < $q->{y1} || $p->{y1} > $q->{y2}) ||
                    ($p->{z2} < $q->{z1} || $p->{z1} > $q->{z2}))
                {
    #                printf "No Overlap Q (%s)\n", cube($q);
                    push(@fq, $q);
                    next QQ;
                }

                if ($mode eq 'on') # for off it's just split
                {
                    # p in q
                    if (
                        ($p->{x1} >= $q->{x1} && $p->{x2} <= $q->{x2}) &&
                        ($p->{y1} >= $q->{y1} && $p->{y2} <= $q->{y2}) &&
                        ($p->{z1} >= $q->{z1} && $p->{z2} <= $q->{z2}))
                    {
                        # p lost in q
                        print "P in Q (%s)\n", cube($q);
                        push(@fq, $q);
                        push(@qq, @fq);
                        @fq = ();

                        next NQ;
                    }
                }

                # q in p
                if (
                    ($q->{x1} >= $p->{x1} && $q->{x2} <= $p->{x2}) &&
                    ($q->{y1} >= $p->{y1} && $q->{y2} <= $p->{y2}) &&
                    ($q->{z1} >= $p->{z1} && $q->{z2} <= $p->{z2}))
                {
                    # q lost in p, but p may overlap with others!
                    # forget about q!
                    printf "Q in P, Lost Q (%s)\n", cube($q);
                    next QQ;
                }

                # partial overlap
                $psplit = 1;

                my @sx = (); # split axis
                my @sy = ();
                my @sz = ();

                push(@sx, "L$q->{x1}", "R$q->{x2}", "L$p->{x1}", "R$p->{x2}");
                push(@sy, "L$q->{y1}", "R$q->{y2}", "L$p->{y1}", "R$p->{y2}");
                push(@sz, "L$q->{z1}", "R$q->{z2}", "L$p->{z1}", "R$p->{z2}");

                @sx = sort @sx; @sx = uniq(@sx);
                @sy = sort @sy; @sy = uniq(@sy);
                @sz = sort @sz; @sz = uniq(@sz);

                # pop(@sx); shift(@sx);
                # pop(@sy); shift(@sy);
                # pop(@sz); shift(@sz);

    # print "sx: ", Dumper \@sx;
    # print "sy: ", Dumper \@sy;
    # print "sz: ", Dumper \@sz;
                my @sq;
                push(@sq, $p);
                push(@sq, $q);
                my @sqf = ();
                SQ: while (1)
                {
                    my $s = pop(@sq);
                    last unless defined $s;

                    my $lr;
                    for my $axx (@sx)
                    {
                        die unless $axx =~ /^(.)(.+)/;
                        $lr = $1; my $ax = $2;
    #                    print "$lr :: $ax\n";
                        if (
                            ($ax > $s->{x1} || $ax == $s->{x1} && $lr eq 'R') &&
                            ($ax < $s->{x2} || $ax == $s->{x2} && $lr eq 'L')
                            )
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;

                            $n1{x1} = $s->{x1};
                            if ($lr eq 'L')
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

                    for my $ayy (@sy)
                    {
                        die unless $ayy =~ /^(.)(.+)/;
                        $lr = $1; my $ay = $2;
                        if (
                            ($ay > $s->{y1} || $ay == $s->{y1} && $lr eq 'R') &&
                            ($ay < $s->{y2} || $ay == $s->{y2} && $lr eq 'L')
                            )
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;
                            $n1{y1} = $s->{y1};
                            if ($lr eq 'L')
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

                    for my $azz (@sz)
                    {
                        die unless $azz =~ /^(.)(.+)/;
                        $lr = $1; my $az = $2;
                        if (
                            ($az > $s->{z1} || $az == $s->{z1} && $lr eq 'R') &&
                            ($az < $s->{z2} || $az == $s->{z2} && $lr eq 'L')
                            )
                        {
                            my %n1 = %$s;
                            my %n2 = %$s;
                            $n1{z1} = $s->{z1};
                            if ($lr eq 'L')
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
    print Dumper \%sqh;

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

                    if ($mode eq 'off') # skip these inside of $p
                    {
                        if (
                        ($s{x1} >= $p->{x1} && $s{x2} <= $p->{x2}) &&
                        ($s{y1} >= $p->{y1} && $s{y2} <= $p->{y2}) &&
                        ($s{z1} >= $p->{z1} && $s{z2} <= $p->{z2}))
                        {
                            printf "S inside P, off: %s\n", cube(\%s);
                            next;

                        }
                    }

                    push(@sq, \%s);
                }

                printf "SQ LEFT(%d)\n", scalar(@sq);

                if ($mode eq 'on')
                {
                    unshift(@nq, @sq); # push both split p and split q to @nq
                }
                else
                {
                    unshift(@fq, @sq); # save those left alive to @fq
                    next QQ;
                }
                last QQ;

            } # qq

            if ($mode eq 'on' && !$psplit)
            {
                push(@fq, $p);
            }

            push(@qq, @fq);
            @fq = ();
        } # nq
    #    @qq = @fq; # XXX or push?
        push(@qq, @fq);

    }
    #print Dumper \@qq;

    my $sum = 0;
    for my $q (@qq)
    {
        # printf "sum: %s\n", cube($q);
        $sum +=
            ($q->{x2} - $q->{x1} + 1) *
            ($q->{y2} - $q->{y1} + 1) *
            ($q->{z2} - $q->{z1} + 1);
    }

    printf STDERR "Stage %s: %s\n", $stage, $sum;

}
