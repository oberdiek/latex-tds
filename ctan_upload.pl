#!/usr/bin/env perl
#
# 2008/07/31 First version.
#
use strict;
$^W = 1;

my $prj = 'latex-tds';
my $name = 'Heiko Oberdiek';
my $email = 'oberdiek@uni-freiburg.de';
my $ctan_dir = 'macros/latex/contrib/latex-tds';
my $license = 'free';
my $freeversion = 'lppl';
my $DoNotAnnounce = 0;
my $file = 'latex-tds.zip';
my $filename = 'latex-tds.zip';
my $filetype = 'application/zip';
my $ctan_upload_url = 'http://dante.ctan.org/cgi-bin/ctan-upload.cgi';
my $file_readme = 'readme.txt';
my $prg_curl = 'curl';
my $prg_lynx = 'lynx';
my $file_response = 'ctan_response.html';

my $description = <<"END_DESCRIPTION";
CTAN's package description:

  This bundle provides a set of zip file modules containing
  TDS (tds)-compliant trees for items of the LaTeX distribution
  (both the base system and required packages), together with
  `user-friendly' documentation (PDF files with navigation support
  using bookmarks and links).

  A further module (knuth) performs the same service for Knuth's
  software distribution (knuth-dist).

Latest changes (see readme.txt):

END_DESCRIPTION
my $hist_prefix = '  ';

my %args = (
    'contribution'  => $prj,
    'name'          => $name,
    'email'         => $email,
    'directory'     => $ctan_dir,
    'license'       => $license,
    'freeversion'   => $freeversion,
    'SUBMIT'        => 'Submit contribution',
    'file'          => "\@$file;type=$filetype;filename=$filename",
);

my $usage = <<"END_OF_USAGE";
$0\n
Syntax: $0 [options]
Options:
  --noannounce   "Announcement is not needed"
  --help         help screen
END_OF_USAGE

use Getopt::Long;
my $DoNotAnnounce = 'No';
GetOptions(
  'noannounce' => sub { $DoNotAnnounce = 'Yes' },
  'help' => sub { print $usage; exit(0); },
) or die $usage;

if ($DoNotAnnounce) {
    $args{'DoNotAnnounce'} = $DoNotAnnounce;
}

my $date = '';
open(IN, '<', $file_readme) or die "!!! Error: Cannot open `$file_readme'!\n";
$_ = <IN>;
if (/\s(\d{4}\/\d{2}\/\d{2})$/) {
    $date = $1;
}
else {
    die "!!! Error: Cannot find release date in `$file_readme'!\n";
}
my $history = '';
my $hist_date = '';
while (<IN>) {
    if (/^(\d{4}\/\d{2}\/\d{2})$/) {
        $hist_date = $1;
        $history = "$hist_prefix$_";
        next;
    }
    if ($hist_date) {
        $history .= "$hist_prefix$_";
    }
}
close(IN);

$history =~ s/(\s+)$//;
$history or die "!!! Error: History not found in `$file_readme'!\n";
if ($hist_date ne $date) {
    die "!!! Error: Release date ($date) differs from"
        . " last history entry ($hist_date)!\n";
}
$args{'summary'} = "latex-tds $date";
$args{'announce'} = "$description$history";

my @args;
foreach my $key (sort keys %args) {
    push @args, '--form', "$key=$args{$key}";
};

push @args, $ctan_upload_url;

unshift @args, $prg_curl, '--output', $file_response;

my $formflag = 0;
foreach my $arg (@args) {
    if ($formflag) {
        $arg =~ /^(.*)=((.|\n)*)$/;
        my $key = $1;
        my $value = $2;
        print '       ', chr(27), '[31m', $key, chr(27), '[0m',
              '=', chr(27), '[34m', $value, chr(27), '[0m', "\n";
    }
    else {
        print "$arg\n";
    }
    $formflag = ($arg =~ /--form/) ? 1 : 0;
}

print "\n*** Press <return> to continue *** ";
$_ = <STDIN>;

sub run (@) {
    my @args = @_;
    my $ret = system @args;
    if ($ret != 0) {
        if ($? == -1) {
            die "!!! Error: Failed to execute: $!\n";
        }
        elsif ($? & 127) {
            die "!!! Error: Child died with signal "
                . ($? & 127)
                . (($? & 128) ? ' with coredump' : '')
                . "!\n";
        }
        else {
            die "!!! Error: Child exited with value " . ($? >> 8) . "!\n";
        }
    }
}
run @args;
-f $file_response or die "!!! Error: Missing response!\n";

run $prg_lynx, '-dump', $file_response;

sub urlencode ($) {
    my $str = shift;
    $str =~ s/([^A-Za-z0-9\.\-_ ])/sprintf("%%%02X", ord($1))/seg;
    $str =~ s/ /+/g;
    $str;
}

__END__
