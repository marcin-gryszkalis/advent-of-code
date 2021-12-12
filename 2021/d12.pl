 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Graph::Undirected;
use Clone qw/clone/;

my @f = read_file(\*STDIN, chomp => 1);

my $g = Graph::Undirected->new;
$g->add_edge(/(\S+)-(\S+)/) for @f;

my $nx;
my @sq; # BFS

$nx->{e} = "start";
push(@{$nx->{path}}, $nx->{e});

for my $stage (1..2)
{
    my $cnt = 0;
    push(@sq, $nx);

    while (my $n0 = shift(@sq))
    {
        for my $nb ($g->neighbours($n0->{e}))
        {
            my $n = clone($n0);

            next if $nb eq 'start';
            if ($nb eq 'end')
            {
                $cnt++;
#               print("$stage1: ".join((","), @{$n->{path}}).",end\n");
                next;
            }

            if ($nb =~ /[a-z]/)
            {
                if (exists $n->{visited}->{$nb})
                {
                    next if $stage == 1;

                    my @uq = uniq(values %{$n->{visited}});
                    next if exists $uq[1] || $uq[0] > 1;
                }

                $n->{visited}->{$nb}++;
            }

            push(@{$n->{path}}, $nb);
            $n->{e} = $nb;
            push(@sq, $n);
        }
    }

    printf "Stage $stage: %s\n", $cnt;
}
