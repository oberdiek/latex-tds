#!/usr/bin/env perl
#
# 2008/07/31 First version.
# 2010/10/27 Email address updated.
# 2012/05/12 File `readme.txt' renamed to `README'.
#
use strict;
$^W = 1;

my $prj = 'latex-tds';
my $name = 'Heiko Oberdiek';
my $email = 'heiko.oberdiek@googlemail.com';
my $ctan_dir = 'macros/latex/contrib/latex-tds';
my $license = 'free';
my $freeversion = 'lppl';
my $announce = 1;
my $file = 'latex-tds.zip';
my $filename = 'latex-tds.zip';
my $filetype = 'application/zip';
my $ctan_upload_url = 'http://dante.ctan.org/cgi-bin/ctan-upload.cgi';
my $file_readme = 'README';
my $prg_curl = 'curl';
my $prg_lynx = 'lynx';
my $file_response = 'ctan_response.html';
my $limit = 0;

my $description = <<"END_DESCRIPTION";
CTAN's package description:

  This bundle provides a set of zip file modules containing
  TDS (tds)-compliant trees for items of the LaTeX distribution
  (both the base system and required packages), together with
  `user-friendly' documentation (PDF files with navigation support
  using bookmarks and links).

  A further module (knuth) performs the same service for Knuth's
  software distribution (knuth-dist).
END_DESCRIPTION
my $hist_prolog = <<'END_HIST_PROLOG';
Latest changes (see readme.txt):

END_HIST_PROLOG
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
  --(no)announce     "Announcement is (not) needed"
  --limit <limit>    Limit upload rate (default unit is "k")
  --help             help screen
END_OF_USAGE

use Getopt::Long;
GetOptions(
  'announce!' => \$announce,
  'limit=s' => \$limit,
  'help' => sub { print $usage; exit(0); },
) or die $usage;

# $args{'DoNotAnnounce'} = $announce ? 'Yes' : 'No';
# $args{'DoNotAnnounce'} = 'No';

$limit =~ /^\d+[kKmMgG]?$/ or die "!!! Error: Invalid limit ($limit)!\n";
$limit .= 'k' if $limit =~ /^\d*[1-9]\d*$/;

my $date = '';
open(IN, '<', $file_readme) or die "!!! Error: Cannot open `$file_readme'!\n";
$_ = <IN>;
if (/\s(\d{4}\/\d{2}\/\d{2})$/) {
    $date = $1;
    $args{'version'} = $date;
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
$history = "$hist_prolog$history";
if ($hist_date ne $date) {
    die "!!! Error: Release date ($date) differs from"
        . " last history entry ($hist_date)!\n";
}
$args{'summary'} = "latex-tds $date";
if ($announce) {
    $args{'announce'} = "$description\n$history";
}
else {
    $args{'DoNotAnnounce'} = 'No';
    $args{'notes'} = "$history\n\nAnnouncement is not needed.";
}

my @args;
foreach my $key (sort keys %args) {
    push @args, '--form', "$key=$args{$key}";
};

push @args, $ctan_upload_url;

unshift @args, '--output', $file_response;
unshift @args, '--limit-rate', $limit if $limit;
unshift @args, $prg_curl;

print "$args[0]\n";
for (my $i = 1; $i < @args; $i++) {
    my $argkey = $args[$i++];
    my $argvalue = $args[$i];
    if ($i < @args) {
        if ($argkey eq "--form") {
            print "$argkey\n";
            $argvalue =~ /^(.*)=((.|\n)*)$/;
            my $key = $1;
            my $value = $2;
            if ($value =~ /\n/) {
                my $pre = "" . chr(27) . '[0m' . "\n| " .
                          chr(27) . '[34m';
                $value = join $pre, split /\n/, $value;
                $value = "$pre$value";
            }
            print '       ', chr(27), '[31m', $key, chr(27), '[0m',
                  '=', chr(27), '[34m', $value, chr(27), '[0m', "\n";
        }
        else {
            print "$argkey ", chr(27), '[34m', $argvalue, chr(27), "[0m\n";
        }
    }
    else {
        print "$argkey\n";
    }
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
