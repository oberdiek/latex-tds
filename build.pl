#!/usr/bin/env perl
use strict;
$^W=1;

my $time_start = time;
my $prj = 'latex-tds';

my $url_ctan = 'ftp://dante.ctan.org/tex-archive';
my $url_ams = 'ftp://ftp.ams.org/pub/tex';

my @required_list = (
    'amslatex',
    'babel',
    'psnfss',
    'cyrillic',
    'graphics',
    'tools'
);
my @pkg_list = ('base', @required_list, $prj, 'src');

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

my $prg_checksum  = "adjust_checksum";
my $prg_bibtex    = "bibtex";
my $prg_chmod     = "chmod";
my $prg_cp        = 'cp -p';
my $prg_curl      = 'curl';
my $prg_docstrip  = 'tex -shell-escape';
my $prg_epstopdf  = 'epstopdf';
my $prg_java      = 'java';
my $prg_ls        = "ls";
my $prg_makeindex = 'makeindex';
my $prg_mkdir     = 'mkdir';
my $prg_mv        = 'mv';
my $prg_patch     = "patch";
my $prg_pdflatex  = 'pdflatex';
my $prg_rm        = "rm";
my $prg_rsync     = "rsync";
my $prg_sed       = "sed";
my $prg_unzip     = 'unzip';
my $prg_wget      = 'wget';
my $prg_zip       = 'zip -9r';

$ENV{'TEXINPUTS'} = "$cwd/tex:.:texmf/tex//:";
$ENV{'BSTINPUTS'} = '.:texmf/bibtex//:';  # amslatex
$ENV{'TFMFONTS'}  = 'texmf/fonts/tfm//:'; # psnfss
$ENV{'VFFONTS'}   = 'texmf/fonts/vf//:';  # psnfss

my $error = "!!! Error:";

my $license_tex = <<'END_LICENSE';
%
% Copyright 2006 Heiko Oberdiek
%
% This file is part of project `latex-tds'.
%
% It may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
% 
% The Current Maintainer of this work is Heiko Oberdiek.
%
% The list of all files belonging to the project `latex-tds' is
% given in the file `manifest.txt'. See also `readme.txt' for
% additional information.
%
END_LICENSE
chomp $license_tex;

sub install ($@);

### Option handling

my $usage = <<"END_OF_USAGE";
Usage: build.pl [options]
General options:
  --(no)download      (check for newer files, disabled by default)
  --(no)postprocess   (pdf files are postprocessed, enabled by default)
Module options:
  --all               (select all modules)
END_OF_USAGE
map { $usage .= "  --(no)$_\n"; } @pkg_list;

my $opt_download    = 0;
my $opt_postprocess = 1;
my $opt_all         = 0;
my %modules;
my @list_modules;

use Getopt::Long;
GetOptions(
    ( map { ("$_!" => \$modules{$_}); } @pkg_list ),
    'all' =>
        sub {
            $opt_all = 1;
            map { $modules{$_} = 1; } @pkg_list;
        },
    'download!'    => \$opt_download,
    'postprocess!' => \$opt_postprocess
) or die $usage;
@ARGV == 0 or die $usage;
@list_modules = grep { $modules{$_}; } @pkg_list;

info("Build modules: @list_modules");

### Download
{
    section('Download');

    sub download_ctan ($$) {
        my $file      = shift;
        my $ctan_path = shift;
        ensure_directory($dir_incoming_ctan);
        download("$dir_incoming_ctan/$file.zip",
                 "$url_ctan/$ctan_path/$file.zip");
    }
    sub download_ams ($) {
        my $file = shift;
        ensure_directory($dir_incoming_ams);
        download("$dir_incoming_ams/$file.zip",
                 "$url_ams/$file.zip");
    }
    sub download ($$) {
        my $file = shift;
        my $url  = shift;
        return 1 if -f $file and !$opt_download;
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
    download_ctan('psnfss',   'macros/latex/required');
    download_ams('amslatex');
    download_ams('amsrefs');
}

### Remove previous build
section('Remove previous build');
{
    foreach my $pkg (@list_modules) {
        run("$prg_rm -rf $dir_build/$pkg");
        my $distribfile = "$dir_distrib/$pkg-tds.zip";
        unlink $distribfile if -f $distribfile;
    }
}

### Unpack
section('Unpacking');
{
    sub unpacking ($$$) {
        my $pkg     = shift;
        my $zipfile = shift;
        my $dir     = shift;
        run("$prg_unzip $zipfile -d$dir");
    }
    sub unpack_ctan ($) {
        my $pkg = shift;
        $modules{$pkg} or return 1;
        unpacking($pkg,
                  "$dir_incoming_ctan/$pkg.zip",
                  $dir_build);
    }
    sub unpack_ams ($) {
        my $name = shift;
        $modules{'amslatex'} or return 1;
        unpacking('amslatex',
                  "$dir_incoming_ams/$name.zip",
                  "$dir_build/amslatex/texmf");
    }
    sub unpack_psnfss ($) {
        my $name = shift;
        my $dir = "$dir_build/psnfss";
        $modules{'psnfss'} or return 1;
        unpacking('psnfss',
                  "$dir/$name.zip",
                  "$dir/texmf");
    }

    ensure_directory($dir_build);
    unpack_ctan('base');
    map { unpack_ctan($_); } @required_list;
    unpack_ams('amslatex');
    unpack_ams('amsrefs');
    unpack_psnfss('lw35nfss');
    unpack_psnfss('freenfss');
}

### Patches
section('Patches');
{
    ; #
    
    if ($modules{'psnfss'}) {
        chdir "$dir_build/psnfss";
        run("$prg_checksum psfonts.dtx");
        chdir $cwd;
    }
}

### Install TDS/source
section('Install source');
{
    sub install_source ($@) {
        my $pkg  = shift;
        my @list = @_;
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        install "texmf/source/latex/$pkg", @list;
        chdir $cwd;
    }

    install_source 'base', qw[
        *.dtx
        *.fdd
        *.ins
        *guide.tex
        ltnews*.tex
        source2e.tex
        ltx3info.tex
        latexbug.el
    ];
    install_source 'tools', qw[
        *.dtx
        *.ins
    ];
    install_source('graphics',
        '*.dtx',
        '*.ins',
        '*.tex'
    );
    install_source('cyrillic',
        '*.dtx',
        '*.fdd',
        '*.ins',
    );
    install_source('psnfss',
        'psnfss2e.tex',
        '*.dtx',
        '*.ins'
    );
    install_source('babel',
        '*.ins',
        '*.dtx',
        '*.fdd',
        #?# '*.tex',
        '*.dat',
    );
}

### Docstrip
section('Docstrip');
{
    sub docstrip ($$) {
        my $pkg = shift;
        my $ins = shift;
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        run("$prg_docstrip $ins.ins");
        chdir $cwd;
        1;
    }
    docstrip('base', 'unpack');
    docstrip('babel', 'base');
    docstrip('psnfss', 'psfonts');
    docstrip('cyrillic', 'cyrlatex');
    docstrip('graphics', 'graphics');
    docstrip('graphics', 'graphics-drivers');
    docstrip('tools', 'tools');
}

section('TDS cleanup');
{
    if ($modules{'amslatex'}) {
        sub cleanup_tds ($@) {
            my $dir_tds = "$dir_build/amslatex/texmf";
            my $sub_tree = shift;
            
            my @list = map { glob("$dir_tds/$sub_tree/$_"); } @_;
            unlink grep { -f $_; } @list;
            map { rmdir; } grep { -d $_; } @list;
        }

        cleanup_tds 'bibtex', qw[
            bib/ams
            bib
        ];
        cleanup_tds 'source/latex/amscls', qw[
            *.bst
            *.template
            diffs-c.txt
        ];
        cleanup_tds 'source/latex/amsmath', qw[
            diffs-m.txt
            amstex.sty
        ];
        cleanup_tds 'source/latex/amsrefs', qw[
            *.dvi
            *.pdf
            amsrefs.faq
            cite-x*.tex
            jr.bib
            gktest.ltb
        ];
        cleanup_tds 'doc/latex/amscls', qw[
            amsrefs.dvi
            textcmds.dvi
        ];
        # CTAN:macros/latex/required/amslatex/other/*
        run("$prg_cp $dir_build/amslatex/other/amsbooka.sty"
            . " $dir_build/amslatex/texmf/tex/latex/amscls/amsbooka.sty");
    }

    if ($modules{'babel'}) {
        ### Correction for *.drv files
        my $basedir = "$dir_build/babel";
        run("$prg_mv $basedir/texmf/tex/generic/babel/*.drv $basedir");
        ### Correction for *.ist files
        my $dir = "$basedir/texmf/makeindex/babel";
        ensure_directory($dir);
        run("$prg_mv $basedir/texmf/tex/generic/babel/*.ist $dir");
    }
}

### Install TDS/tex, TDS/doc files
section('Install tex doc');
{
    if ($modules{'base'}) {
        chdir "$dir_build/base";
        install 'texmf/doc/latex/base', qw[
            00readme.txt
            autoload.txt
            bugs.txt
            changes.txt
            l*.txt
            manifest.txt
            patches.txt
            t*.txt
            sample2e.tex
            small2e.tex
        ];
        install 'texmf/tex/latex/base', qw[
            *.cls
            ltpatch.ltx
            idx.tex
            lablst.tex
            latexbug.tex
            lppl.tex
            testpage.tex
            ltxcheck.tex
        ];
        chdir $cwd;
    }

    if ($modules{'tools'}) {
        chdir "$dir_build/tools";
        install 'texmf/doc/latex/tools', qw[
            changes.txt
            manifest.txt
            readme.txt
        ];
        chdir $cwd;
    }

    if ($modules{'graphics'}) {
        chdir "$dir_build/graphics";
        install('texmf/doc/latex/graphics',
            '*.txt'
        );
        install('texmf/tex/latex/graphics',
            '*.def'
        );
        chdir $cwd;
    }

    if ($modules{'cyrillic'}) {
        chdir "$dir_build/cyrillic";
        install('texmf/doc/latex/cyrillic',
            '*.txt'
        );
        chdir $cwd;
    }
    
    if ($modules{'psnfss'}) {
        chdir "$dir_build/psnfss";
        install('texmf/doc/latex/psnfss',
            '*.txt'
        );
        install('texmf/doc/latex/psnfss/test',
            '*test*.tex'
        );
        install('texmf/fonts/enc/dvips/psnfss',
            '8r.enc'
        );
        install('texmf/fonts/map/dvips/psnfss',
            '*.map'
        );
        chdir $cwd;
    }
    
    if ($modules{'babel'}) {
        chdir "$dir_build/babel";
        install('texmf/doc/generic/babel',
            '*.txt',
            '*.heb',
            '*.bbl',
            '*.dat',
            '*.skeleton',
            'install.OzTeX*'
        );
        chdir $cwd;
    }

my $dummy = <<'END_DUMMY';
    if ($modules{'babel'}) {
        chdir "$dir_build/babel";
        install('texmf/tex/generic/bghyph',
            'bghyphen.txt',
            'bghyphsi.tex',
            'catmik.tex',
            'mik2t2.tex'
        );
        install('texmf/tex/generic/hyphen',
            'icehyph.tex',
            'lahyph.tex'
        );
        chdir $cwd;
    }
END_DUMMY
}

### Generate documentation for base
if ($modules{'base'}) {
    section('Documenation: base');

    sub base_guide ($) {
        my $guide = "$_[0]guide";
        run("$prg_pdflatex $guide");
        run("$prg_pdflatex $guide");
        run("$prg_pdflatex $guide");
        install_pdf('base', $guide);
        1;
    }
    sub simple_dtx ($) {
        my $base = shift;
        my $dtx = "$base.dtx";
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx");
        install_pdf('base', $base);
        1;
    }
    sub complex_dtx ($) {
        my $base = shift;
        my $dtx = "$base.dtx";
        run("$prg_pdflatex $dtx");
        run_makeindex("$base.idx", 'gind.ist');
        run_makeindex("$base.glo", 'gglo.ist', "$base.gls");
        run("$prg_pdflatex $dtx");
        run_makeindex("$base.idx", 'gind.ist');
        run_makeindex("$base.glo", 'gglo.ist', "$base.gls");
        run("$prg_pdflatex $dtx");
        run("$prg_pdflatex $dtx"); # hydestopt
        install_pdf('base', "$base");
        1;
    }
    sub book_err ($) {
        my $base = shift;
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
    run_makeindex('source2e.idx', 'gind.ist');
    run_makeindex('source2e.glo', 'gglo.ist', 'source2e.gls');
    run("$prg_pdflatex source2e");
    run_makeindex('source2e.idx', 'gind.ist');
    run_makeindex('source2e.glo', 'gglo.ist', 'source2e.gls');
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
    run("$prg_mv doc_lppl.pdf lppl.pdf");
    install_pdf('base', 'lppl');
    run("$prg_pdflatex ltxcheck.drv");
    run("$prg_pdflatex ltxcheck.drv");
    install_pdf('base', 'ltxcheck');
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
    my $lastissue = 0;
    map { $lastissue = $1 if /ltnews(\d+)\.tex/ and $lastissue < $1; }
        glob('ltnews*.tex');
    my $cmd_ltnews =
            "$prg_pdflatex '\\def\\lastissue{$lastissue}\\input{$ltnews}'";
    run($cmd_ltnews);
    run($cmd_ltnews);
    run($cmd_ltnews);
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
        run_makeindex("$entry.idx", 'gind.ist');
        run_makeindex("$entry.glo", 'gglo.ist', "$entry.gls");
        run("$prg_pdflatex $entry.dtx");
        run_makeindex("$entry.idx", 'gind.ist');
        run_makeindex("$entry.glo", 'gglo.ist', "$entry.gls");
        run("$prg_pdflatex $entry.dtx");
        run("$prg_pdflatex $entry.dtx"); # hydestopt
        install_pdf('tools', $entry);
    }
    
    # Generate overview
    my $infile = 'manifest.txt';
    my $texfile = "$cwd/$dir_tex/tools.tex";
    my @time = localtime(time);
    my ($mday, $month, $year) = splice @time, 3, 3;
    my $release_info = sprintf "%04d/%02d/%02d Tools overview (HO)",
        $year + 1900, $month + 1, $mday;
    open(OUT, ">$texfile") or die "$error Cannot open `$texfile'!\n";
    print OUT <<"END_HEADER";
\\NeedsTeXFormat{LaTeX2e}
\\ProvidesFile{tools.tex}%
  [$release_info]
$license_tex
\\documentclass{tools-overview}
\\begin{document}
END_HEADER
    my $entry;
    my %db;
    open(IN, $infile) or die "$error Cannot open `$infile'!\n";
    while (<IN>) {
        next if /^%/;
        next if /^\s*$/;
        if (/^(\S+)\.dtx/) {
            $entry = $1;
            $db{$entry} = '';
            next;
        }
        s/\\(\w+)/\\cs{\1}/g;
        s/(LaTeX|TeX)/\\\1\{\}/g;
        s/`([^']+)'/\\emph{\1}/g;
        s/Indent The/Indent the/; # typo
        s/Requies/Requires/; # typo
        $db{$entry} .= $_;
    }
    close(IN);
    $db{'layout'} = <<'END_LAYOUT';
    Produces an overview of the layout of the current document.
END_LAYOUT
    $db{'trace'} = <<'END_TRACE';
    The package helps to suppress and to control the amount of tracing
    output (\cs{tracingall}) by taming calc and making NFSS less noisy.
END_TRACE
    for my $entry (sort keys %db) {
        my $text = $db{$entry};
        $text =~ s/^\s*/  /mg;
        chomp $text;
        print OUT <<"END_ENTRY";
\\entry{$entry}{%
$text
}%
END_ENTRY
    }
    print OUT <<'END_TRAILER';
\end{document}
END_TRAILER
    close(OUT);
    run("$prg_pdflatex tools.tex");
    install_pdf('tools', 'tools');
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

### Generate documentation for amslatex
if ($modules{'amslatex'}) {
    section('Documentation: amslatex');

    sub makeindex ($) {
        my $doc = shift;
        my $style;
        $style = 'gind.ist' unless $doc eq 'amsldoc';
        run_makeindex("$doc.idx", $style);
    }

    sub bibtex ($) {
        my $doc = shift;

        if ($doc =~ /^cite-x[bh]$/) {
            run("$prg_bibtex $doc");
        }
    }

    sub generate_doc ($$) {
        my $amspkg = shift;
        my $doc = shift;
        my $ams_drv = "$cwd/$dir_tex/ams.drv";

        symlink $ams_drv, "$doc.drv";
        run("$prg_pdflatex $doc.drv");
        makeindex($doc);
        bibtex($doc);
        run("$prg_pdflatex $doc.drv");
        makeindex($doc);
        run("$prg_pdflatex $doc.drv");
        makeindex($doc);
        run("$prg_pdflatex $doc.drv");
        run("$prg_pdflatex $doc.drv") if $doc eq 'amsrefs';
        install_pdf($amspkg, $doc);
    }

    chdir "$dir_build/amslatex/math";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amsmath', $_; } qw[
        amsldoc subeqn technote testmath
        amsbsy amscd amsgen amsmath amsopn amstext amsxtra
    ];
    chdir $cwd;

    chdir "$dir_build/amslatex/classes";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amscls', $_; } qw[
        amsthdoc instr-l thmtest
        amsclass amsdtx amsmidx upref
    ];
    chdir $cwd;

    chdir "$dir_build/amslatex/amsrefs";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amscls', $_; } qw[
        cite-xa cite-xb cite-xh cite-xs
        amsrefs amsxport ifoption mathscinet pcatcode rkeyval textcmds
    ];
    chdir $cwd;
}

### Generate documentation for psnfss
if ($modules{'psnfss'}) {
    section('Documentation: psnfss');

    chdir "$dir_build/psnfss";
    run("$prg_pdflatex psfonts.dtx");
    run("$prg_pdflatex psfonts.dtx");
    install_pdf('psnfss', 'psfonts');
    
    run("$prg_pdflatex psnfss2e.drv");
    run("$prg_pdflatex psnfss2e.drv");
    run("$prg_pdflatex psnfss2e.drv");
    install_pdf('psnfss', 'psnfss2e');
    
    chdir $cwd;
}

### Module src
if ($modules{'src'}) {
    section('Module src');
    
    my $dest_dir = "$dir_build/src/texmf/source/latex/latex-tds";
    install $dest_dir, qw[
        build.pl
    ];
    install "$dest_dir/tex", glob("$dir_tex/*.*");
}

### Module latex-tds
if ($modules{$prj}) {
    section('Module latex-tds');

    my $dir = "$dir_build/$prj";
    ensure_directory($dir);
    my $cmd_rsync = "$prg_rsync " . join ' ', qw[
        --recursive
        --times
        --perms
        --owner
        --group
        --hard-links
    ];
    for (@pkg_list) {
        next if $_ eq $prj;
        my $reftree = "$dir_build/$_";
        next unless -d "$reftree/texmf";
        run("$cmd_rsync --link-dest=$cwd/$reftree $reftree/texmf $dir");
    }
}

### Pack result
section('Distrib');
{
    ensure_directory($dir_distrib);
    for my $pkg (@list_modules) {
        my $dir_tds = "$dir_build/$pkg/texmf";
        my $file_distrib = "$cwd/$dir_distrib/$pkg-tds.zip";
        if (-d $dir_tds) {
            chdir $dir_tds;
            run("$prg_chmod -R g-w .");
            run("$prg_zip $file_distrib *");
            chdir $cwd;
        }
        else {
            print "!!! Warning: Missing TDS tree for `$pkg'!\n";
        }
    }
}

### Display result
section('Result');
{
    for my $pkg (@list_modules) {
        my $file = "$dir_distrib/$pkg-tds.zip";
        if (-f $file) {
            system("$prg_ls -l $file");
        }
        else {
            print "!!! Warning: Missing distribution for `$pkg'!\n";
        }
    }
    
    # display time
    my $time_diff = time - $time_start;
    my $time_str = sprintf "%d:%02d:%02d\n",
                           $time_diff / 3600,
                           ($time_diff % 3600) / 60,
                           ($time_diff % 3600) % 60;
    $time_str =~ s/^0:0?//;
    print "* Elapsed time: $time_str\n";    
}

sub install ($@) {
    my $dir_target = shift;
    my @list       = @_;

    ensure_directory($dir_target);
    run("$prg_cp @list $dir_target/");
    1;
}

sub install_pdf ($$) {
    my $pkg         = shift;
    my $file_base   = shift;
    my $file_source = "$file_base.pdf";
    my $dir_dest    = "texmf/doc/latex/$pkg";
    my $file_dest   = "$dir_dest/$file_base.pdf";

    ensure_directory($dir_dest);
    if ($opt_postprocess) {
        printsize($file_source, 0);
        run("$prg_java -jar $jar_pdfbox_rewrite $file_source $file_tmp");
        run("$prg_java -cp $jar_multivalent tool.pdf.Compress -old $file_tmp");
        run("$prg_mv $file_tmp_o $file_dest");
        printsize($file_dest, 1);
    }
    else {
        run("$prg_cp $file_source $file_dest");
    }
    1;
}

sub printsize ($$) {
    my $file  = shift;
    my $modus = shift;
    my $size  = (stat($file))[7];
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

sub ensure_directory ($) {
    my $dir = shift;

    return 1 if -d $dir;
    run("$prg_mkdir -p '$dir'");
    return 1 if -d $dir;
    die "$error Cannot generate directory `$dir'!\n";
}

sub section ($) {
    my $title = shift;

    print "\n=== $title ===\n";
    1;
}

sub run ($) {
    my $cmd = shift;

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

sub run_makeindex ($;$$) {
    my $input_file  = shift;
    my $style_file  = shift;
    my $output_file = shift;

    return 1 unless -f $input_file;
    my $cmd = $prg_makeindex;
    $cmd .= " -s $style_file" if $style_file;
    $cmd .= " -o $output_file" if $output_file;
    $cmd .= " $input_file";
    run($cmd);
}

sub info ($) {
    my $msg = shift;
    print "* $msg\n";
    1;
}

__END__
