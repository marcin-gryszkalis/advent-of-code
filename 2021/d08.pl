 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;

my @f = read_file(\*STDIN);
@f = map { chomp; $_ } @f;

my @dm = qw/abcefg cf acdeg acdfg bcdf abdfg abdefg acf abcdefg abcdfg/;
my $i = 0;
my %rm = map { $_ => $i++ } @dm;

my $stage1 = 0;
my $stage2 = 0;

for (@f)
{
    my @sp = split/\|/, $_;
    my @in = ($sp[0] =~ /\S+/g);
    my @out = ($sp[1] =~ /\S+/g);

    @in = map { join("", sort(split//)) } @in;
    @out = map { join("", sort(split//)) } @out;
    my @all = (@in, @out);
    @all = sort { length($a) <=> length($b)} @all;

    my @sx = grep { length($_) == length($dm[1]) || length($_) == length($dm[4]) || length($_) == length($dm[7]) || length($_) == length($dm[8]) } @out;
    $stage1 += scalar(@sx);

    my @dperm = ('a'..'g');
    my $itv = permutations(\@dperm);
    P: while (my $v = $itv->next)
    {
        my $m = join("", @$v);

        my %t = ();
        for my $p (@all)
        {
            my $q = $p;
            eval "\$q =~ tr/abcdefg/$m/";
            $q = join("", sort(split//, $q));

            # print "p($m) $p -> $q\n";
            next P unless exists $rm{$q};
            $t{$p} = $rm{$q};
        }

        my $o = join("", map { $t{$_} } @out);
        $stage2 += $o;

        printf "%s = %d\n", join(" ", sort { $t{$a} <=> $t{$b} } keys(%t)), $o;
    }

}

printf "Stage 1: %s\n", $stage1;
printf "Stage 2: %s\n", $stage2;