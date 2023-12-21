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
use Digest::MD5 qw(md5 md5_hex md5_base64);

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;


my $x = 0;
my $y = 0;
my $t;

my $startx  = 0;
my $starty  = 0;

for (@f)
{
    $x = 0;
    for my $v (split//)
    {
        $t->{$x,$y} = $v;
        if ($v eq 'S')
        {
            $startx = $x;
            $starty = $y;
        }
        $x++;
    }
    $y++;
}

my $h = $y;
my $w = length($f[0]);
my $maxy = $h - 1;
my $maxx = $w - 1;


my $emptymap = clone $t;
$emptymap->{$startx,$starty} = '.';

$t = $emptymap;

my %p;
$p{$startx,$starty} = 1;

my %msp = ();
my %osc;
my %score;
my %done;
my %decr;
my %mvs;
my %mstrsp;
my %trans;
my %revmap;
my %xmap;

for my $i (1..26501365) # 64)
{
    my %q = ();

    my %mth = ();
    my %ms = ();

    for my $ee (keys %p)
    {
        my ($x,$y) = split($;, $ee);


        for my $dy (-1..1)
        {
            for my $dx (-1..1)
            {
                next unless abs($dx) + abs($dy) == 1;
#print "$ee\n";

                my $nx = $x + $dx;
                my $ny = $y + $dy;

                my ($rx,$ry) = ($nx % $w, $ny % $h);
                next unless exists $t->{$rx,$ry} && $t->{$rx,$ry} eq '.';

                $q{$nx,$ny} = 'O';

                my ($mx,$my) = (floor($nx/$w), floor($ny/$h));
                $mth{$mx,$my} = 1;

#                $ms{$mx,$my}++;

#                print "$ee -> $nx,$ny\n";
            }
        }
    }

    for my $ee (keys %q)
    {
        my ($x,$y) = split($;, $ee);
        my ($mx,$my) = (floor($x/$w), floor($y/$h));
        $ms{$mx,$my}++;
    }

    my %mstrs = ();
    my $newtrans = 0;
    my %mxs = ();
    for my $mi (keys %ms)
    {
        my ($mx,$my) = split($;, $mi);

        my $prevstate = md5_hex('none');
        if (exists $mstrsp{$mi})
        {
            $prevstate = $mstrsp{$mi};
        }

        for my $dy (-1..1)
        {
            for my $dx (-1..1)
            {
                next unless abs($dx) + abs($dy) == 1;

                my $k = exists $mstrsp{$mx + $dx,$my + $dy} ? $mstrsp{$mx + $dx,$my + $dy} : md5_hex('none');
                $prevstate .= ":$k";
            }
        }

        # if (exists $trans{$prevstate})
        # {
        #     $mxs{$trans{$prevstate}}++;
        #     $mstrs{$mi} = $trans{$prevstate};
        # }
#        else
#        {
            my $mstr = '';
            my $mv = 0;
            for my $x (0..$maxx)
            {
                for my $y (0..$maxy)
                {
                    my ($rx,$ry) = ($x + $w * $mx, $y + $h * $my);
                    if (exists $q{$rx,$ry})
                    {
                        $mstr .= 'O';
                        $mv++;
                    }
                    else
                    {
                        $mstr .= $emptymap->{$x,$y};
                    }
                }
            }

            my $cur = md5_hex($mstr);

            $revmap{$cur} = $mstr;

#            say "new map ($mi): $cur $revmap{$cur}" unless exists $xmap{$mi};
            $xmap{$mi} = $i unless exists $xmap{$mi};


            $mstrs{$mi} = $cur;
            $mvs{$cur} = $mv;


            if (exists $trans{$prevstate})
            {
                die "$trans{$prevstate} != $cur" unless $cur eq $trans{$prevstate};
            }

            if (!exists $trans{$prevstate})
            {
                $newtrans++;
            }

            $trans{$prevstate} = $cur;

            $mxs{$cur}++;
 #       }
    }


    for my $y (-7..7)
    {
        print "$i: ";
        for my $x (-7..7)
        {
#            if (exists $xmap{$x,$y}) { printf "%3d ", $mvs{$mstrs{$x,$y}} } else { print "--- " };
            if (exists $xmap{$x,$y}) { printf "%3s ", substr($mstrs{$x,$y},0,3) } else { print "--- " };
        }
        print "\n";
    }

    %mstrsp = %mstrs; # %{clone \%mstrs};


    for my $mi (keys %ms)
    {
        next unless exists $msp{$mi};
        next if exists $done{$mi};

        if (exists $osc{$mi} && $i == $osc{$mi} + 1)
        {
            $score{$mi}->{$i % 2} = $ms{$mi};
            $done{$mi} = $i;
            next;
        }

        $decr{$mi}++ if ($ms{$mi} < $msp{$mi});
        if (exists $decr{$mi} && $decr{$mi} > 3)
        {
            $osc{$mi} = $i;
            $score{$mi}->{$i % 2} = $ms{$mi};
        }
    }


    my $total = 0;
    for my $mi (keys %done)
    {
        $total += $score{$mi}->{$i % 2};
    }

    for my $ee (keys %q)
    {
        my ($x,$y) = split($;, $ee);
        my ($mx,$my) = (floor($x/$w), floor($y/$h));
        next if exists $done{$mx,$my};
        $total++;
    }

    # delete in done!
    # for my $ee (keys %q)
    # {
    #     my ($x,$y) = split($;, $ee);
    #     my ($mx,$my) = (floor($x/$w), floor($y/$h));
    #     if (exists $done{$mx,$my} && $done{$mx,$my} + 3 == $i) # done n rounds ago
    #     {
    #         delete $q{$ee};
    #     }
    # }

    # print Dumper \%ms;
#    print Dumper \%done;
    # print Dumper \%score;
    %p = %q;
    %msp = %ms;

        # my $qq = 0;
        # for my $vi (sort keys %mxs)
        # {
        #     $qq += $mvs{$vi} * $mxs{$vi};
        #     printf "O $vi $revmap{$vi} :: $mvs{$vi} x $mxs{$vi} = %d ($qq)\n", $mvs{$vi} * $mxs{$vi};
        # }


    #my $total0 = sum(values %ms);
    printf "%d: total=%d scalar_p=%d scalar_done=%d sum_ms=%d\n", $i, $total, scalar(keys %p), scalar(keys %done), sum(values %ms);
#    print "newtrans($newtrans)\n";
    #die if $total != $total0;
    #die if $total != scalar(keys %p);

printf "stats -- mvs:%d en:%d mstrs:%d\n", scalar(%mvs), scalar(1), scalar(%mstrs);

#        print Dumper \%mxs;
    if ($newtrans == 0)
    {
        my $xx = sum(map { $mvs{$_} * $mxs{$_} } keys %mxs);

        # for my $vi (keys %mxs)
        # {
        #     print "$vi $revmap{$vi} $mvs{$vi}\n";
        # }
        # say $xx;

        # print Dumper \%mvs;
        # print Dumper \%mxs;
#        print Dumper \%trans;

        ###############################################################

        # have ti fix first transition, as we have trans{none x 5} => start map
        # empty neighbour of fresh map will have such source
        my $hnone = md5_hex('none');
        $trans{join(":", ($hnone x 5))} = $hnone;
        $revmap{$hnone} = 'none!';

        while (1)
        {
            $i++;
            last if $i > 26501365 + 3;


            my %mxs = ();
            my %en = (); # empty neighbours
            for my $mi (keys %mstrsp)
            {
                my ($mx,$my) = split($;, $mi);
                my $prevstate = $mstrsp{$mi};
                for my $dy (-1..1)
                {
                    for my $dx (-1..1)
                    {
                        next unless abs($dx) + abs($dy) == 1;

                        my $k = exists $mstrsp{$mx + $dx,$my + $dy} ? $mstrsp{$mx + $dx,$my + $dy} : md5_hex('none');
                        $prevstate .= ":$k";

                        if (!exists $mstrs{$mx + $dx,$my + $dy})
                        {
                            $en{$mx + $dx,$my + $dy} = 1;
                        }


                    }
                }

                unless (exists $trans{$prevstate})
                {
                    for my $yy (split/:/, $prevstate)
                    {
                        print "XXX $yy -> $revmap{$yy}\n";
                    }
                    die $prevstate;
                }
                $mxs{$trans{$prevstate}}++;
                $mstrs{$mi} = $trans{$prevstate};

            }


#print Dumper \%en;
            for my $mi (keys %en)
            {
                my ($mx,$my) = split($;, $mi);
# print "EN($mi)\n";
                my $prevstate = md5_hex('none');
                for my $dy (-1..1)
                {
                    for my $dx (-1..1)
                    {
                        next unless abs($dx) + abs($dy) == 1;

                        my $k = exists $mstrsp{$mx + $dx,$my + $dy} ? $mstrsp{$mx + $dx,$my + $dy} : md5_hex('none');

                        $prevstate .= ":$k";
                    }
                }

                # print "### $prevstate ###\n" if $mi eq '-5,0';
                # if ($mi eq '-5,0')
                # {
                #     print "-4,0: P $mstrsp{-4,0} X $mstrs{-4,0}\n";
                #     print "-5,1: P $mstrsp{-5,1} X $mstrs{-5,1}\n";
                # }


                if (exists $trans{$prevstate})
                {
                    $mxs{$trans{$prevstate}}++;
                    $mstrs{$mi} = $trans{$prevstate};
  #                  say "new mstrs ($mi): $mi = $trans{$prevstate} $revmap{$trans{$prevstate}}";

#                    say "new map ($mi): $prevstate $trans{$prevstate}" unless exists $xmap{$mi};
                    $xmap{$mi} = $i unless exists $xmap{$mi};

                }


            }

            my $qq = 0;
        for my $vi (sort keys %mxs)
        {
            $qq += $mvs{$vi} * $mxs{$vi};
            printf "N $vi :: $mvs{$vi} x $mxs{$vi} = %d ($qq)\n", $mvs{$vi} * $mxs{$vi};# if $vi eq '05d7bcd292dd648b14a78e5291e76d30';
        }


 printf "stats -- mvs:%d en:%d mstrs:%d\n", scalar(%mvs), scalar(%en), scalar(%mstrs);
            my $xx = sum(map { $mvs{$_} * $mxs{$_} } keys %mxs);
            print "$i: $xx\n";
            #sleep 2;


    # for my $y (-7..7)
    # {
    #     for my $x (-7..7)
    #     {
    #         if (exists $xmap{$x,$y}) { printf "%3d ", $xmap{$x,$y} } else { print "--- " };
    #     }
    #     print "\n";
    # }

    for my $y (-7..7)
    {
        print "$i: ";
        for my $x (-7..7)
        {
            # if (exists $xmap{$x,$y}) { printf "%3d ", $mvs{$mstrs{$x,$y}} } else { print "--- " };
            if (exists $xmap{$x,$y}) { printf "%3s ", substr($mstrs{$x,$y},0,3) } else { print "--- " };
        }
        print " NNN\n";
    }

            %mstrsp = %mstrs;
        }



    }


    # for my $y (-5..5)
    # {
    #     for my $x (-5..5)
    #     {
    #         if (exists $done{$x,$y}) { printf "%3d ", $done{$x,$y} } else { print "--- " };
    #     }
    #     print "\n";
    # }

# for my $y (0..$maxy)
# {
#     for my $x (0..$maxx)
#     {
#         if (exists $p{$x,$y}) { print "O" } else { print $t->{$x,$y} };
#     }
#     print "\n";
# }

}


printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;