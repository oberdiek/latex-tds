#!/usr/bin/env perl
use strict;
$^W=1;
#
# check-ascii.pl
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
# 2014-02-30 v1.0 First version
#
my $non_ascii = 0;
my $lines = 0;

for my $file (@ARGV) {
    open(IN, '<', $file) or die "!!! Error: Cannot open `$file': $!\n";
    while (<IN>) {
        next if /^\p{ascii}*$/;
        while (/([^\p{ascii}]+)/g) {
            my $prefix = sprintf "[%s] Line %s, pos. %s:",
                                 $file, $., pos();
            my $match = $&;
            $lines++;
            $non_ascii += length $match;
            my $bytes = '';
            for my $ch (split //, $match) {
                $bytes .= sprintf '%02X ', ord $ch;
            }
            printf "$prefix $bytes($match)\n";
        }
    }
    close(IN);
}

if ($non_ascii) {
    die sprintf "==> %d non-ASCII byte%s in %d line%s found!\n",
                $non_ascii, ($non_ascii == 1 ? '' : 's'),
                $lines, ($lines == 1 ? '' : 's');
}
1;
__END__
