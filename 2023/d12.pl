#!/usr/bin/perl
use warnings;
use strict;
use feature qw/state signatures say multidimensional/;
use File::Slurp;
use Data::Dumper;
use List::Util qw/min max first sum sum0 product all any uniq head tail reduce pairs zip mesh/;
use List::MoreUtils qw/firstidx frequency mode slide minmax/;
use POSIX qw/ceil floor/;
use Algorithm::Combinatorics qw/combinations permutations variations combinations_with_repetition variations_with_repetition/;
use Clone qw/clone/;
$; = ',';

no warnings 'recursion';

my @f = read_file(\*STDIN, chomp => 1);

my $stage1 = 0;
my $stage2 = 0;


# naive brute force, valid for stage 1
sub go($p, $counts)
{
    if ($p =~ /\?/)
    {
        my $a = ($p =~ s/\?/./r);
        my $b = ($p =~ s/\?/#/r);
        return go($a, $counts) + go($b, $counts);
    }

    my @x = split/\.+/,$p;
    my @y = grep { $_ != 0 } map { length $_ } @x;
    my $t = join",",@y;
    return $t eq $counts ? 1 : 0;
}

my $numofspaces = 0;
my $numofspaceblocks = 0;
my $maxlenofspaceblock = 0;

my $pp = '';
my @c = ();
my $p;

my %dp = ();

sub go2($usedspaces, $level, $s)
{

#    my $l = length($pp);
    my $dpk = "$level:".length($s);
    return $dp{$dpk} if exists $dp{$dpk};

    # my $q = $p;
    # $q =~ s/[^\.]//g;
    # my $nos = length($q);

    my $v = 0;
    if ($level < $numofspaceblocks - 1)
    {
        my $start = ($level == 0 || $level == $numofspaceblocks - 1) ? 0 : 1;

        for my $i ($start..$maxlenofspaceblock)
        {
            last if $usedspaces + $i > $numofspaces;
            my $t = $s;
            $t .= " " x $i;
            if ($level < scalar(@c))
            {
                $t .= "#" x $c[$level];
    #            die;
            }
            else
            {
                # die;
            }
            my $qq = $pp;
            $qq = substr($qq, 0, length $t) if length($t) < length($qq);
#            $qq =~ s/(\s*(#+\s+){$level}#+).*/$1/;
#print "$level|$pp|qq($qq)($t)\n";
            #$qq = ($pp =~ s/^(.*#).*/$1/r);
            next unless $t =~ /^$qq/;

#            printf "%02d|$usedspaces+$i|$pp|$qq|$t|NOTBAD\n", $level;
            $v += go2($usedspaces + $i, $level + 1, $t)
        }

        $dp{$dpk} = $v;
        return $v;
    }

$s .= " " x (length($pp) - length($s));
if ($s =~ /^$pp$/)
{
    printf "%02d|$pp|$s|HIT\n", $level;
    return 1;
}

return 0;
}

for (@f)
{
    my ($p0,$counts) = split/\s/;

    $p = $p0;

    $p = join('?', (($p0) x 5));
    $counts = join(',', (($counts) x 5));

    @c = ($counts =~ m/\d+/g);

    my $l = length($p);

    my $numofhashesreal = sum(@c);
    my $numofhashes = () = $p =~ /#/g;
    my $numofquestm = () = $p =~ /\?/g;
    my $numofdots = () = $p =~ /\./g;

    $numofspaces = $numofdots + $numofquestm - ($numofhashesreal - $numofhashes);
    print "numbers: #r $numofhashesreal # $numofhashes ? $numofquestm . $numofdots _ $numofspaces\n";
    $numofspaceblocks = length(",$counts," =~ s/\d+//gr);
    $maxlenofspaceblock = $numofspaces - ($numofspaceblocks - 2 - 1);

#    my @cc = (0..$maxlenofspaceblock);
#    my @d = variations_with_repetition(\@cc, $numofspaceblocks);

    $pp = $p;
    $pp =~ s/\./ /g;
    $pp =~ s/\?/./g;
#    $pp =~ s/\.+$//g;

    print "$p|$pp|$counts ($l,$numofspaces,$numofspaceblocks,$maxlenofspaceblock)\n";
    my $v = go2(0, 0, '');
    %dp = ();
#    my $v = go3(0,0,0);
#print Dumper \%dp;
    print "$v = $p $counts\n\n\n";
    $stage1 += $v;
}

printf "Stage 1 = %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;
