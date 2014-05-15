#!/usr/bin/env perl
use strict;
$^W=1;
# Copyright (C) 2014 by Heiko Oberdiek <heiko.oberdiek at googlemail.com>
#
# This work may be distributed and/or modified under the
# conditions of the LaTeX Project Public License, either
# version 1.3 of this license or (at your option) any later
# version. The latest version of this license is in
#    http://www.latex-project.org/lppl.txt
# and version 1.3 or later is part of all distributions of
# LaTeX version 2005/12/01 or later.
#
# This work has the LPPL maintenance status "maintained".
#
# This Current Maintainer of this work is Heiko Oberdiek.
#
# This work consists of this file.
#
# This file "check-tds-installation.pl" may be renamed
# to "check-tds-installation" for installation purposes.

my $prg = 'check-tds-installation';
my $version = '1.0';
my $date = '2014-05-15';

my $prg_find = 'find';
my $prg_pwd = 'pwd';
my $prg_rm = 'rm';
my $prg_unzip = 'unzip';

chomp(my $cwd = `$prg_pwd`);

my $dir_build = 'build';
my $dir_build_check = "$dir_build/texmf-check";
my $dir_distrib = 'distrib';

my $usage = <<"END_USAGE";
$prg v$version $date
Syntax: $prg <module> <texmf-root-directory>
END_USAGE

sub run (@) {

    print "[@_]\n";
    my $ret = system(@_);
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
    1;
}

@ARGV == 2 or die $usage;

my $module = shift;
my $dir_root = shift;

my $file_zip = "$dir_distrib/$module.tds.zip";
-f $file_zip or die "!!! Error: File `$file_zip' not found: $!";

-d $dir_root or die "!!! Error: Directory `$dir_root' not found!\n";

-d $dir_build or mkdir $dir_build;
run $prg_rm, '-rf', $dir_build_check if -d $dir_build_check;
mkdir $dir_build_check or
       die "!!! Error: Cannot create directory `$dir_build_check': $!";
run $prg_unzip, '-d', $dir_build_check, $file_zip;

my @files_src = sort map {chomp;s/^$dir_build_check\///;$_}
                `$prg_find $dir_build_check`;
not $! or die "!!! Error: find!\n";

my %dirs;

foreach my $file (@files_src) {
    next if $file eq $dir_build_check;
    my $file_src = "$dir_build_check/$file";
    my $file_dest = "$dir_root/$file";
    if (-f $file_src) {
        $file =~ m|^(.*)/[^/]+$| or die "!!! Error: Parsing `$file'!\n";
        $dirs{$1} = 1;
        if (-f $file_dest) {
            my ($size_src,  $mtime_src)  = (stat $file_src)[7,9];
            my ($size_dest, $mtime_dest) = (stat $file_dest)[7,9];
            my $equal = $size_src == $size_dest;
            if ($equal) {
                local $/;
                undef $/;
                open(IN, '<', $file_src) or die "!!! Error: Cannot open `$file_src': $!";
                my $data_src = <IN>;
                close(IN);
                open(IN, '<', $file_dest) or die "!!! Error: Cannot open `$file_dest': $!";
                my $data_dest = <IN>;
                close(IN);
                $equal = $data_src eq $data_dest;
            }
            next if $equal;
            print "[Different files: $file]\n";
            my @time_src = localtime $mtime_src;
            my @time_dest = localtime $mtime_dest;
            printf "  %04d.%02d.%02d %02d:%02d:%02d % 7d bytes\n",
                $time_src[5] + 1900, $time_src[4] + 1, $time_src[3],
                $time_src[2], $time_src[1], $time_src[0], $size_src;
            printf "  %04d.%02d.%02d %02d:%02d:%02d % 7d bytes\n",
                $time_dest[5] + 1900, $time_dest[4] + 1, $time_dest[3],
                $time_dest[2], $time_dest[1], $time_src[0], $size_dest;
            next;
        }
        print "[Uninstalled file: $file]\n";
        next;
    }
    if (-d $file_src) {
        next if -d $file_dest;
        print "[Uninstalled directory: $file]\n";
        next;
    }
    print "[Unknown file type: $file]\n";
}

foreach my $dir (sort keys %dirs) {
    my @files_dest = sort glob "$dir_root/$dir/*";
    next if $dir eq 'doc/info';
    foreach my $file_dest (@files_dest) {
        my $file = $file_dest;
        $file =~ s/^$dir_root\/// or
                die "!!! Error: Cannot strip base dir of `$file'!\n";
        next if -f "$dir_build_check/$file";
        next if -d $file_dest;
        print "[Extra file: $file]\n";
    }
}

__END__
