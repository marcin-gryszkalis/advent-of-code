#!/usr/bin/perl
use Data::Dumper;
use warnings;
use strict;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $key = "iwrupvqb";

my $i = 0;
while (1)
{
    last if md5_hex($key.$i) =~ /^00000/;
    $i++;
}

print "stage 1: $i\n";

while (1)
{
    last if md5_hex($key.$i) =~ /^000000/;
    $i++;
}
print "stage 2: $i\n";
