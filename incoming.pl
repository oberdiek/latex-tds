#!/usr/bin/env perl
use strict;
$^W=1;

my $dir_incoming = 'incoming';
my $url_ctan = 'ftp://dante.ctan.org/tex-archive/macros/latex';
my $prg_wget = 'wget -N';
chomp(my $cwd = `pwd`);

my @required_list = (
    'cyrillic',
    'graphics',
    'tools',
    # currently not used by latex-tds:
    'amslatex',
    'babel',
    'psnfss'
);

-d $dir_incoming or mkdir $dir_incoming;
chdir $dir_incoming;

system("$prg_wget $url_ctan/base.zip");
foreach my $pkg (@required_list) {
    system("$prg_wget $url_ctan/required/$pkg.zip");
}

chdir $cwd;

__END__
