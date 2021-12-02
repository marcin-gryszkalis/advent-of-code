 #!/usr/bin/perl -nl
push @f,$_;
$s++ if $_ > ($f[-2]//999);
$t++ if $_ > ($f[-4]//999);
print "$s $t";
