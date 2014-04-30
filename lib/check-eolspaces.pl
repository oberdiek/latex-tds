#!/usr/bin/env perl
use strict;
$^W=1;
#
# check-eolspaces.pl
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
my $found = 0;

for my $file (@ARGV) {
    open(IN, '<', $file) or die "!!! Error: Cannot open `$file': $!\n";
    while (<IN>) {
        s/[\r\n]+$//;
        next unless /\s$/;
        /(\s+)$/;
        my $len = length $1;
        printf "[%s] Line %d: %d trailing space%s\n",
                $file, $., $len, ($len == 1 ? '' : 's');
        $found++;
    }
    close(IN);
}

if ($found) {
    die sprintf "==> %d line%s with trailing spaces found!\n",
                $found, ($found == 1 ? '' : 's');
}
1;
__END__
