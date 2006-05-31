#!/usr/bin/env perl
use strict;
$^W=1;

my $dir_incoming = 'incoming';
my $dir_incoming_ams = "$dir_incoming/ams";
my $url_ctan = 'ftp://dante.ctan.org/tex-archive/macros/latex';
my $url_ams = 'ftp://ftp.ams.org/pub/tex';
my $prg_wget = 'wget -N';
my $prg_curl = 'curl';
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

# CTAN download

-d $dir_incoming or mkdir $dir_incoming;
chdir $dir_incoming;

system("$prg_wget $url_ctan/base.zip");
foreach my $pkg (@required_list) {
    system("$prg_wget $url_ctan/required/$pkg.zip");
}

chdir $cwd;

# AMS download

download_ams('amslatex.zip');
download_ams('amsrefs.zip');

sub download_ams {
    my $file = $_[0];
    my $url = "$url_ams/$file";
    my $file = "$dir_incoming_ams/$file";
    print "* $url\n";
    -d $dir_incoming_ams or mkdir $dir_incoming_ams;
    my $cmd = $prg_curl;
    $cmd .= " --disable-epsv";                #
    $cmd .= " --time-cond $file" if -f $file; # download only if newer
    $cmd .= " --remote-time";                 # set file date
    $cmd .= " --output $file";                # target file
    $cmd .= " $url";                          # url
    system($cmd);
}

__END__
