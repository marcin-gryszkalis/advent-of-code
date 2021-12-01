 #!/usr/bin/perl -nl
unshift(@f, $_);
$s++ if $_ > ($f[1]//999);
$t++ if $_ > ($f[3]//999);
print "$s $t";
