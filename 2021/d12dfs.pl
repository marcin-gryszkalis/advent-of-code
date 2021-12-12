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

# my $g = Graph::Undirected->new; - much slower than simple hash
# $g->add_edge(/(\S+)-(\S+)/) for @f;
my $gg;
for (@f)
{
    /(\S+)-(\S+)/;
    push(@{$gg->{$1}}, $2);
    push(@{$gg->{$2}}, $1);
}

sub p
{
    my ($stage, $lvl, $e, $double, @path) = @_;
    my $cnt = 0;

    for my $nb (@{$gg->{$e}})
    {
        my $pdbl = $double;
        next if $nb eq 'start';

        if ($nb eq 'end')
        {
#           print("$stage : $lvl : ".join((","), @path)."\n");
            $cnt++;
            next;
        }

        if ($nb =~ /[a-z]/)
        {
            if (any { $_ eq $nb } @path)
            {
                next if $stage == 1;
                next if $double;
                $pdbl = 1;
            }

        }

        $cnt += p($stage, $lvl+1, $nb, $pdbl, (@path,$nb));
    }

    return $cnt;
}

for my $stage (1..2)
{
    printf "Stage $stage: %s\n", p($stage, 0, "start", 0, qw/start/);
}
