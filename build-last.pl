#!/usr/bin/env perl
use strict;
$^W=1;

my $infile = 'build.log';
my $outfile = 'build-last.log';

open(IN, $infile) or die "!!! Error: Cannot open `$infile'!\n";
open(OUT, ">$outfile") or die "!!! Error: Cannot open `$outfile'!\n";

my $log_text = "";
my $prj = "";
my $log = 0;

while (<IN>) {
    if (/^This is /) {
        $log_text = $_;
        $log = 1;
        next;
    }
    if (/^Transcript written on (.*)\.log\./) {
        $prj = $1;
        $log_text .= $_;
        $log = 2;
        next;
    }
    if (/^Pages: / and $log == 2) {
        print OUT "*** START $prj ***\n";
        print OUT $log_text;
        print OUT "*** STOP $prj ***\n\n";
        $log = 0;
        next;
    }
    if ($log == 1) {
        $log_text .= $_;
        next;
    }
}            

close(IN);
close(OUT);

__END__
