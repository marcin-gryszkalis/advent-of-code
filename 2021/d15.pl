 #!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
use List::Util qw/min max first sum product all any uniq head tail/;
use File::Slurp;
use Algorithm::Combinatorics qw(combinations permutations variations);
use Clone qw/clone/;
use Graph::Directed;
no warnings 'recursion';

my @f = read_file(\*STDIN, chomp => 1);

my $g = Graph::Directed->new;

my $wy = scalar(@f);
my $wx = length($f[0]);

my $awy = 5 * $wy;
my $awx = 5 * $wx;

my $y = 0;
for (@f)
{
    my $x = 0;
    for my $e (split//)
    {
        for my $dy (0..4)
        {
            for my $dx (0..4)
            {
                my $ax = $x + $wx*$dx;
                my $ay = $y + $wy*$dy;

                my $ae = (($e - 1) + $dx + $dy) % 9 + 1;

                $g->add_weighted_edge(($ax-1).$;.$ay, "$ax$;$ay", $ae) if $ax > 0;
                $g->add_weighted_edge($ax.$;.($ay-1), "$ax$;$ay", $ae) if $ay > 0;
                $g->add_weighted_edge(($ax+1).$;.$ay, "$ax$;$ay", $ae) if $ax < $awx-1;
                $g->add_weighted_edge($ax.$;.($ay+1), "$ax$;$ay", $ae) if $ay < $awy-1;
            }
        }

        $x++;
    }
    $y++;
}

print "vertices: ".scalar($g->vertices)."\n";
print "edges: ".scalar($g->edges)."\n";

my @p1 = $g->SP_Dijkstra("0$;0", ($wx-1).$;.($wy-1));
my @p2 = $g->SP_Dijkstra("0$;0", ($awx-1).$;.($awy-1));

printf "Stage 1: %s\n", sum(map { $g->get_edge_weight($p1[$_], $p1[$_+1]) } (0..$#p1-1));
printf "Stage 2: %s\n", sum(map { $g->get_edge_weight($p2[$_], $p2[$_+1]) } (0..$#p2-1));
