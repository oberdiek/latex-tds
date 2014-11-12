#!/usr/bin/env perl
use strict;
$^W=1;
#
# check-manifest.pl
#
# Packs a directory tree into a ZIP file with sorted entries
# and corrects file permissions and directory dates.
#
# Copyright 2014 Heiko Oberdiek.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301  USA
#
# Address: heiko.oberdiek at googlemail.com
#
# 2014-11-13 v1.0 First version
#
use Archive::Zip qw[AZ_OK];

my $file_src_readme = 'README.asciidoc';
my $file_dist_source = 'distrib/source.tds.zip';

my $problems = 0;
my %manifest;
my %distrib;

# Read manifest data from the source file of README
{
    open(IN, '<', $file_src_readme) or die "!!! Error: Cannot open '$file_src_readme': $!";
    while (<IN>) {
        last if /^Manifest/i;
    }
    while (<IN>) {
        last if m|^// end of manifest|i;
        if (/^\[.*\bheader\b/) {
            my $line = <IN>;
            if ($line =~ /^\|===/) {
                my $header_line = <IN>;
                next;
            }
        }
        next if /^\|===/;
        if (/^\|\s*([\w\d\.\/\-]+)\s*\|/) {
            $manifest{$1}++;
        }
    }
    close(IN);
    printf "* Files in '%s': %d\n", $file_src_readme, scalar keys %manifest;
}

# Read the distribution source file
{
    my $zip = Archive::Zip->new();
    unless ($zip->read($file_dist_source) == AZ_OK) {
        die sprintf "!!! Error: Cannot open '%s': %s\n", $file_dist_source, $!;
    }
    foreach ($zip->memberNames()) {
        next if m|/$|;
        s|^source/latex/latex-tds/||;
        s|^doc/latex/latex-tds/||;
        $distrib{$_} = 1;
    }
    printf "* Files in '%s': %d\n", $file_dist_source, scalar keys %distrib;
}

# Check for duplicate files in manifest
for my $file (keys %manifest) {
    next if $manifest{$file} == 1;
    $problems++;
    printf "!!! Warning: Duplicate file '%s' in manifest!\n", $file;
}

# Check for missing files in manifest
printf "* Missing files in '%s':\n", $file_src_readme;
for my $file (sort keys %distrib) {
    next if $manifest{$file};
    $problems++;
    print "  - $file\n";
}

# Check for extra files in manifest
printf "* Additional files in '%s':\n", $file_src_readme;
for my $file (sort keys %manifest) {
    next if $distrib{$file};
    $problems++;
    print "  + $file\n";
}

if ($problems) {
    printf "==> %d problem%s found!\n",
            $problems,
            $problems == 1 ? '' : 's';
}
else {
    print "==> OK.\n";
}

$problems == 0;
__END__
