#!/usr/bin/env perl
use strict;
$^W=1;

my $url_ctan = 'ftp://dante.ctan.org/tex-archive';
my $url_ams = 'ftp://ftp.ams.org/pub/tex';

my @required_list = (
    'amslatex',
#    'babel',
#    'psnfss',
    'cyrillic',
    'graphics',
    'tools'
);
my @pkg_list = ('base');
push @pkg_list, @required_list;

my $dir_incoming = 'incoming';
my $dir_incoming_ctan = "$dir_incoming/ctan";
my $dir_incoming_ams = "$dir_incoming/ams";
my $dir_build = 'build';
my $dir_lib = 'lib';
my $dir_tex = 'tex';
my $dir_distrib = 'distrib';
chomp(my $cwd = `pwd`);

my $jar_pdfbox_rewrite = "$cwd/$dir_lib/pdfbox-rewrite.jar";
my $jar_multivalent = "$cwd/$dir_lib/Multivalent20060102.jar";

my $file_tmp = "$cwd/$dir_build/tmp.pdf";
my $file_tmp_o = "$cwd/$dir_build/tmp-o.pdf";

my $prg_wget = 'wget';
my $prg_curl = 'curl';
my $prg_unzip = 'unzip';
my $prg_docstrip = 'tex -shell-escape';
$ENV{'TEXINPUTS'} = "$cwd/tex:.:texmf!!:";
my $prg_copy = 'cp -p';
my $prg_mkdir = 'mkdir';
my $prg_pdflatex = 'pdflatex';
my $prg_makeindex = 'makeindex';
my $prg_move = 'mv';
my $prg_java = 'java';
my $prg_zip = 'zip -9r';
my $prg_epstopdf = 'epstopdf';
my $prg_patch = "patch";
my $prg_sed = "sed";
my $prg_chmod = "chmod";
my $prg_rm = "rm";
my $prg_ls = "ls";

my $error = "!!! Error:";

### Option handling

my $usage = <<"END_OF_USAGE";
Usage: build.pl [options]
Options for bundle selection:
  --(no)base
  --(no)tools
  --(no)graphics
  --(no)cyrillic
  --(no)amslatex
  --(no)psnfss    (not implemented)
  --(no)babel     (not implemented)
  --all           select all modules
Other options:
  --download      (check for newer files)
END_OF_USAGE

$::opt_download = 0;
$::opt_all      = 0;
my %modules;

use Getopt::Long;
GetOptions(
    'base!'     => \$modules{'base'},
    'tools!'    => \$modules{'tools'},
    'graphics!' => \$modules{'graphics'},
    'cyrillic!' => \$modules{'cyrillic'},
    'amslatex!' => \$modules{'amslatex'},
    'psnfss!'   => \$modules{'psnfss'},
    'babel!'    => \$modules{'babel'},
    'all!'      => sub { map { $modules{$_} = 1; } @pkg_list; },
    'download!'
) or die $usage;
@ARGV == 0 or die $usage;

info("Build modules: " . join ' ', sort grep {$modules{$_}} @pkg_list);

### Download
if ($::opt_download) {
    section('Download');

    sub download_ctan {
        my $file = $_[0];
        my $ctan_path  = $_[1];
        ensure_directory($dir_incoming_ctan);
        download("$dir_incoming_ctan/$file.zip",
                 "$url_ctan/$ctan_path/$file.zip");
    }
    sub download_ams {
        my $file = $_[0];
        ensure_directory($dir_incoming_ams);
        download("$dir_incoming_ams/$file.zip",
                 "$url_ams/$file.zip");
    }
    sub download {
        my $file = $_[0];
        my $url  = $_[1];
        info("download $url\n           --> $file");
        my $cmd = $prg_curl;
        $cmd .= " --disable-epsv";                # for ftp.ams.org
        $cmd .= " --time-cond $file" if -f $file; # download only if newer
        $cmd .= " --remote-time";                 # set file date
        $cmd .= " --output $file";                # target file
        $cmd .= " $url";                          # url
        run($cmd);
        -f $file or die "$error Download failed ($url)!\n";
    }

    download_ctan('base',     'macros/latex');
    download_ctan('tools',    'macros/latex/required');
    download_ctan('graphics', 'macros/latex/required');
    download_ctan('cyrillic', 'macros/latex/required');
    download_ctan('babel',    'macros/latex/required');
    download_ctan('amslatex', 'macros/latex/required');
    download_ams('amslatex');
    download_ams('amsrefs');
}

### Remove previous build
section('Remove previous build');
{
    foreach my $pkg (@pkg_list) {
        $modules{$pkg} or next;
        run("$prg_rm -rf $dir_build/$pkg");
        my $distribfile = "$dir_distrib/$pkg-tds.zip";
        unlink $distribfile if -f $distribfile;
    }
}

### Unpack
section('Unpacking');
{
    sub unpacking {
        my $pkg     = $_[0];
        my $zipfile = $_[1];
        my $dir     = $_[2];
        run("$prg_unzip $zipfile -d$dir");
    }
    sub unpack_ctan {
        my $pkg = $_[0];
        $modules{$pkg} or return 1;
        unpacking($pkg,
                  "$dir_incoming_ctan/$pkg.zip",
                  $dir_build);
    }
    sub unpack_ams {
        my $ams_pkg = $_[0];
        $modules{'amslatex'} or return 1;
        unpacking('amslatex',
                  "$dir_incoming_ams/$ams_pkg.zip",
                  "$dir_build/amslatex/texmf");
    }

    ensure_directory($dir_build);
    unpack_ctan('base');
    foreach my $pkg (@required_list) {
        unpack_ctan($pkg);
    }
    unpack_ams('amslatex');
    unpack_ams('amsrefs');
}

### Patches
section('Patches');
{
    ; # currently none
}

### Install TDS/source
section('Install source');
{
    sub install_source {
        my $pkg = $_[0];
        my $ref_list = $_[1];
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        install("texmf/source/latex/$pkg", $ref_list);
        chdir $cwd;
    }
    install_source('base', [
        '*.*'
    ]);
    install_source('tools', [
        '*.dtx',
        '*.ins',
        '*.txt'
    ]);
    install_source('graphics', [
        '*.dtx',
        '*.ins',
        '*.txt',
        '*.tex',
        '*.def'
    ]);
    install_source('cyrillic', [
        '*.*'
    ]);
}

### Docstrip
section('Docstrip');
{
    sub docstrip {
        my $pkg = $_[0];
        my $ins = $_[1];
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        run("$prg_docstrip $ins.ins");
        chdir $cwd;
        1;
    }
    docstrip('base', 'unpack');
#    docstrip('babel', 'base');
#    docstrip('psnfss', 'psfonts');
    docstrip('cyrillic', 'cyrlatex');
    docstrip('graphics', 'graphics');
    docstrip('graphics', 'graphics-drivers');
    docstrip('tools', 'tools');
}

### Correction for babel: *.drv files
#{
#    chdir "$dir_build/babel";
#    system("prg_move texmf/tex/generic/babel/*.drv .");
#    chdir $cwd;
#}

section('TDS corrections');
{
    if ($modules{'amslatex'}) {
        my $dir_tds = "$dir_build/amslatex/texmf";
        my $dir;
        $dir = "$dir_tds/bibtex";
        rmdir "$dir/bib/ams";
        rmdir "$dir/bib";
        $dir = "$dir_tds/source/latex/amsrefs";
        unlink "$dir/amsrefs.pdf";
        unlink "$dir/amsrefs.dvi";
        unlink "$dir/mathscinet.pdf";
        unlink "$dir/textcmds.pdf";
        unlink "$dir/textcmds.dvi";
        $dir = "$dir_tds/doc/latex/amscls";
        unlink "$dir/amsrefs.dvi";
        unlink "$dir/textcmds.dvi";
    }
}

### Install TDS/tex, TDS/doc files
section('Install tex doc');
{
    if ($modules{'base'}) {
        chdir "$dir_build/base";
        install('texmf/doc/latex/base', [
            '*.txt',
            'sample2e.tex',
            'small2e.tex'
        ]);
        install('texmf/tex/latex/base', [
            '*.cls',
            'ltpatch.ltx',
            'idx.tex',
            'lablst.tex',
            'latexbug.tex',
            'lppl.tex',
            'testpage.tex'
        ]);
        chdir $cwd;
    }

    if ($modules{'tools'}) {
        chdir "$dir_build/tools";
        install('texmf/doc/latex/tools', [
            '*.txt'
        ]);
        chdir $cwd;
    }

    if ($modules{'graphics'}) {
        chdir "$dir_build/graphics";
        install('texmf/doc/latex/graphics', [
            '*.txt'
        ]);
        install('texmf/tex/latex/graphics', [
            '*.def'
        ]);
        chdir $cwd;
    }

    if ($modules{'cyrillic'}) {
        chdir "$dir_build/cyrillic";
        install('texmf/doc/latex/cyrillic', [
            '*.txt'
        ]);
        chdir $cwd;
    }

my $dummy = <<'END_DUMMY';
    if ($modules{'babel'}) {
        chdir "$dir_build/babel";
        install('texmf/tex/generic/bghyph', [
            'bghyphen.txt',
            'bghyphsi.tex',
            'catmik.tex',
            'mik2t2.tex'
        ]);
        install('texmf/tex/generic/hyphen', [
            'icehyph.tex',
            'lahyph.tex'
        ]);
        chdir $cwd;
    }
END_DUMMY
}

### Generate documentation for base
if ($modules{'base'}) {
    section('Documenation: base');

    sub base_guide {
        my $guide = "$_[0]guide";
        run("$prg_pdflatex $guide");
        run("$prg_pdflatex $guide");
        run("$prg_pdflatex $guide");
        install_pdf('base', $guide);
        1;
    }
    sub simple_dtx {
        my $base = $_[0];
        my $dtx = "$base.dtx";
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx");
        install_pdf('base', $base);
        1;
    }
    sub complex_dtx {
        my $base = $_[0];
        my $dtx = "$base.dtx";
        run("$prg_pdflatex $dtx");
        run("$prg_makeindex -s gind.ist $base.idx");
        run("$prg_makeindex -s gglo.ist -o $base.glo $base.gls");
        run("$prg_pdflatex $dtx");
        run("$prg_makeindex -s gind.ist $base.idx");
        run("$prg_makeindex -s gglo.ist -o $base.glo $base.gls");
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx"); # hydestopt
        install_pdf('base', "$base");
        1;
    }
    sub book_err {
        my $base = $_[0];
        my $err = "$base.err";
        run("$prg_pdflatex $err");
        run("$prg_sed -i -e '"
               . 's/\\\\endinput/\\\\input{errata.cfg}\\n\\\\endinput/'
               . "' $base.cfg");
        run("$prg_pdflatex $err");
        run("$prg_pdflatex $err");
        run("$prg_pdflatex $err"); # hydestopt
        install_pdf('base', "$base");
        1;
    }
    chdir "$dir_build/base";
    run("$prg_pdflatex source2e");
    run("$prg_makeindex -s gind.ist source2e.idx");
    run("$prg_makeindex -s gglo.ist -o souce2e.glo source2e.gls");
    run("$prg_pdflatex source2e");
    run("$prg_makeindex -s gind.ist source2e.idx");
    run("$prg_makeindex -s gglo.ist -o souce2e.glo source2e.gls");
    run("$prg_pdflatex source2e");
    run("$prg_pdflatex source2e"); # hydestopt
    install_pdf('base', 'source2e');
    map { complex_dtx $_ } (
        'doc',
        'docstrip',
        'letter'
    );
    map { simple_dtx $_ } (
        'alltt',
        'classes',
        'exscale',
        'fixltx2e',
        'graphpap',
        'ifthen',
        'inputenc',
        'latex209',
        'latexsym',
        'ltxdoc',
        'makeindx',
        'newlfont',
        'oldlfont',
        'proc',
        'slides',
        'syntonly',
        'utf8ienc'
    );
    map { book_err $_ } (
        'tlc2',
        'lb2',
        'grphcomp',
        'webcomp',
        'webcompg'
    );
    run("$prg_sed -i -e '"
           . 's/\\\\documentclass{article}/'
           . '\\\\documentclass{article}\\n\\\\input{manual.cfg}/'
           . "' manual.err");
    run("$prg_pdflatex manual.err");
    run("$prg_pdflatex manual.err");
    run("$prg_pdflatex manual.err"); # hydestopt
    install_pdf('base', 'manual');
    base_guide('cfg');
    base_guide('cls');
    base_guide('cyr');
    base_guide('enc');
    base_guide('fnt');
    base_guide('mod');
    base_guide('usr');
    run("$prg_pdflatex doc_lppl");
    run("$prg_pdflatex doc_lppl");
    run("$prg_pdflatex doc_lppl"); # hydestopt
    run("$prg_move doc_lppl.pdf lppl.pdf");
    install_pdf('base', 'lppl');
    my $code = <<'END_CODE';
\let\SavedDocumentclass\documentclass
\def\documentclass[#1]#2{
  \SavedDocumentclass[{#1}]{#2}
  \usepackage[colorlinks,pdfusetitle]{hyperref}
}
\input{ltx3info}
END_CODE
    $code =~ s/\s//g;
    run("$prg_pdflatex '$code'");
    run("$prg_pdflatex '$code'");
    run("$prg_pdflatex '$code'"); # hydestopt
    install_pdf('base', 'ltx3info');
#    for (my $i = 1; $i <= 17; $i++) {
#        my $ltnews = 'ltnews';
#        $ltnews .= '0' if $i < 10;
#        $ltnews .= $i;
#        run("$prg_pdflatex $ltnews");
#        run("$prg_pdflatex $ltnews");
#        install_pdf('base', $ltnews);
#    }
    my $ltnews = 'ltnews';
    run("$prg_pdflatex $ltnews");
    run("$prg_pdflatex $ltnews");
    run("$prg_pdflatex $ltnews");
    install_pdf('base', $ltnews);
    chdir $cwd;
}

### Generate documentation for tools
if ($modules{'tools'}) {
    section('Documentation: tools');

    chdir "$dir_build/tools";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        run("$prg_pdflatex $entry.dtx");
        run("$prg_makeindex -s gind.ist $entry.idx")
            if -f "$entry.idx";
        run("$prg_makeindex -s gglo.ist -o $entry.glo $entry.gls")
            if -f "$entry.gls";
        run("$prg_pdflatex $entry.dtx");
        run("$prg_makeindex -s gind.ist $entry.idx")
            if -f "$entry.idx";
        run("$prg_makeindex -s gglo.ist -o $entry.glo $entry.gls")
            if -f "$entry.gls";
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx"); # hydestopt
        install_pdf('tools', $entry);
    }
    chdir $cwd;
}

### Generate documentation for cyrillic
if ($modules{'cyrillic'}) {
    section('Documentation: cyrillic');

    chdir "$dir_build/cyrillic";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx"); # hydestopt
        install_pdf('cyrillic', $entry);
    }
    chdir $cwd;
}

### Generate documentation for graphics
if ($modules{'graphics'}) {
    section('Documentation: graphics');

    chdir "$dir_build/graphics";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx"); # hydestopt
        install_pdf('graphics', $entry);
    }
    my $code = <<'END_CODE';
\makeatletter
\let\documentclass\@@end
\input{grfguide}
END_CODE
    $code =~ s/\s//g;
    run("$prg_pdflatex '$code'");
    run("$prg_epstopdf a.ps");
    run("$prg_pdflatex grfguide");
    run("$prg_pdflatex grfguide");
    run("$prg_pdflatex grfguide");
    install_pdf('graphics', 'grfguide');
    chdir $cwd;
}

### Pack result
section('Distrib');
{
    ensure_directory($dir_distrib);
    for my $pkg (@pkg_list) {
        my $dir_tds = "$dir_build/$pkg/texmf";
        my $file_distrib = "$cwd/$dir_distrib/$pkg-tds.zip";
        if (-d $dir_tds and $modules{$pkg}) {
            chdir $dir_tds;
            run("$prg_chmod -R g-w .");
            run("$prg_zip $file_distrib *");
            chdir $cwd;
        }
    }
}

### Display result
section('Result');
{
    for my $pkg (@pkg_list) {
        $modules{$pkg} or next;
        my $file = "$dir_distrib/$pkg-tds.zip";
        if (-f $file) {
            system("$prg_ls -l $file");
        }
        else {
            print "Failed: $pkg\n";
        }
    }
}

sub install {
    my $dir_target = $_[0];
    my @list = @{$_[1]};

    ensure_directory($dir_target);
    run("$prg_copy @list $dir_target/");
    1;
}

sub install_pdf {
    my $pkg = $_[0];
    my $file_base = $_[1];
    my $file_source = "$file_base.pdf";
    my $dir_dest = "texmf/doc/latex/$pkg";
    my $file_dest = "$dir_dest/$file_base.pdf";

    ensure_directory($dir_dest);
    printsize($file_source, 0);
    run("$prg_java -jar $jar_pdfbox_rewrite $file_source $file_tmp");
    run("$prg_java -cp $jar_multivalent tool.pdf.Compress -old $file_tmp");
    run("$prg_move $file_tmp_o $file_dest");
    printsize($file_dest, 1);
    1;
}

sub printsize {
    my $file = $_[0];
    my $modus = $_[1];
    my @stat = stat($file);
    my $size = @stat[7];
    $size =~ s/(\d)(\d{6})$/$1.$2/;
    $size =~ s/(\d)(\d{3})$/$1.$2/;
    $size = " " x (9 - length($size)) . $size;
    if ($modus == 0) {
        print "*" x 78 . "\n";
        print "* $size  $file\n";
    }
    else {
        print "* $size  $file\n";
        print "*" x 78 . "\n";
        print "\n";
    }
}

sub ensure_directory {
    my $dir = $_[0];

    return 1 if -d $dir;
    run("$prg_mkdir -p '$dir'");
    return 1 if -d $dir;
    die "$error Cannot generate directory `$dir'!\n";
}

sub section {
    my $title = $_[0];

    print "\n=== $title ===\n";
    1;
}

sub run {
    my $cmd = $_[0];

    info("system: $cmd");
    my $ret = system($cmd);
    if ($ret != 0) {
        if ($? == -1) {
            die "$error Failed to execute: $!\n";
        }
        elsif ($? & 127) {
            die "$error Child died with signal "
                . ($? & 127)
                . (($? & 128) ? ' with coredump' : '')
                . "!\n";
        }
        else {
            die "$error Child exited with value " . ($? >> 8) . "!\n";
        }
    }
    1;
}

sub info {
    my $msg = $_[0];
    print "* $msg\n";
    1;
}

__END__
