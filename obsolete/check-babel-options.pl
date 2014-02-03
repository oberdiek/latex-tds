#!/usr/bin/env perl
use strict;
$^W=1;

my $babel = `kpsewhich babel.sty`;
chomp $babel;
my $outfile = 'temp_babel.tex';
my $opts = "\n";
my $txt = "\n";

open(IN, '<', $babel) or die "!!! Error: Cannot open `$babel'!\n";
while (<IN>) {
    if (/^\\DeclareOption{([^}]+)}/) {
        my $option = $1;
        next if $option =~ /^active/;
        next if $option =~ /^KeepShorthandsActive/;
        $opts .= "  $option,\n";
        $txt .= "\\selectlanguage{$option}\n";
    }
}
close(IN);

open(OUT, '>', $outfile) or die "!!! Error: Cannot open `$outfile'!\n";
print OUT <<"__END_OUT__";
\\documentclass{article}
\\usepackage[$opts]{babel}
\\begin{document}$txt\\end{document}
__END_OUT__
close(OUT);

__END__
