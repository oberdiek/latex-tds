#!/usr/bin/env perl
use strict;
$^W=1;

my $prj     = 'latex-tds';
my $file    = 'build.pl';
my $version = cvs('$Revision$');
my $date    = cvs('$Date$');
my $author  = 'Heiko Oberdiek';
my $copyright = "Copyright 2006-2012 $author";
chomp(my $license = <<"END_LICENSE");
% $copyright
%
% This file is part of project `$prj'.
%
% It may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3
% of this license or (at your option) any later version.
% The latest version of this license is in
%  http://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2005/12/01 or later.
%
% This work has the LPPL maintenance status `maintained'.
%
% The Current Maintainer of this work is Heiko Oberdiek.
%
% See `README' for a list of all files belonging to the
% project `$prj' and additional information.
%
END_LICENSE

my $time_start = time;

my $url_ctan = 'ftp://dante.ctan.org/tex-archive';
my $url_ams = 'ftp://ftp.ams.org/pub/tex';
my $url_ltxprj = 'http://www.latex-project.org/';

my @required_list = (
    'amslatex',
    'babel',
    'psnfss',
    'cyrillic',
    'graphics',
    'tools'
);
my @pkg_list = (
    'base',
    @required_list,
    $prj,
    'source',
    'tds',
    'knuth',
    'etex',
);

my $zip_comment = <<'END_ZIP_COMMENT';
*************************************************
* This file is part of project 'latex-tds', see *
* CTAN:macros/latex/contrib/latex-tds/README    *
*************************************************
END_ZIP_COMMENT

my $error = "!!! Error:";

my $dir_incoming = 'incoming';
my $dir_incoming_ctan = "$dir_incoming/ctan";
my $dir_incoming_ams = "$dir_incoming/ams";
my $dir_incoming_ltxprj = "$dir_incoming/ltxprj";
my $dir_build = 'build';
my $dir_lib = 'lib';
my $dir_license = 'license';
my $dir_tex = 'tex';
my $dir_patch = 'patch';
my $dir_distrib = 'distrib';
my $dir_texmf = 'texmf';
chomp(my $cwd = `pwd`);
my $dir_cache = "$cwd/cache";

my $jar_pdfbox_rewrite = "$cwd/$dir_lib/pdfbox-rewrite.jar";
my $jar_multivalent = "$cwd/$dir_lib/Multivalent20060102.jar";

my $file_zip_comment = "$cwd/$dir_build/zip-comment.txt";
my $file_tmp = "$cwd/$dir_build/tmp.pdf";
my $file_tmp_o = "$cwd/$dir_build/tmp-o.pdf";
my $file_ctan_distrib = "$cwd/$prj.zip";

my $file_ziptimetree = get_perl_script('ziptimetree');
my $file_adjust_checksum = get_perl_script('adjust_checksum');

my $prg_checksum     = $file_adjust_checksum;
my $prg_bibtex       = "bibtex";
my $prg_chmod        = "chmod";
my $prg_cp           = 'cp -p';
my $prg_curl         = 'curl';
my $prg_docstrip     = 'tex -shell-escape';
my $prg_epstopdf     = 'epstopdf';
my $prg_find         = 'find';
# my $prg_java        = '/work/java-1.5.0/bin/java';
# java 1.6 don't work with the used version of Multivalent
my $prg_java         = 'java';
my $prg_kpsewhich    = 'kpsewhich';
my $prg_ls           = "ls";
my $prg_makeindex    = 'makeindex';
my $prg_mkdir        = 'mkdir';
my $prg_mv           = 'mv';
my $prg_patch        = "patch";
my $prg_lualatex     = 'lualatex';
my $prg_lualatextds  = "lualatex -fmt=$cwd/$dir_build/lualatex-tds";
my $prg_lualatextds2 = "lualatex -fmt=$cwd/$dir_build/lualatex-tds2";
my $prg_pdflatex     = 'pdflatex';
my $prg_pdflatextds  = "pdflatex -fmt=$cwd/$dir_build/pdflatex-tds";
my $prg_pdftex       = "pdftex";
my $prg_recode       = "recode";
my $prg_rm           = "rm";
my $prg_rsync        = "rsync";
my $prg_sed          = "sed";
my $prg_sort         = "sort";
my $prg_texhash      = "texhash";
my $prg_unzip        = 'unzip';
my $prg_weave        = 'weave';
my $prg_wget         = 'wget';
my $prg_zip          = 'zip';
my $prg_ziptimetree  = $file_ziptimetree;

my $prg_latextds = $prg_lualatextds; ### temporarily

$ENV{'TEXINPUTS'}  = "$cwd/tex:.:texmf/tex//:";
$ENV{'BSTINPUTS'}  = '.:texmf/bibtex//:';    # amslatex
$ENV{'TFMFONTS'}   = 'texmf/fonts/tfm//:';   # psnfss
$ENV{'VFFONTS'}    = 'texmf/fonts/vf//:';    # psnfss
$ENV{'INDEXSTYLE'} = '.:texmf/makeindex//:'; # babel
if ($ENV{'TEXMFHOME'}) {
    $ENV{'TEXMFHOME'} = "$cwd/$dir_texmf:$ENV{'TEXMFHOME'}";
}
else {
    $ENV{'TEXMFHOME'} = "$cwd/$dir_texmf:$ENV{'HOME'}/texmf:";
}

sub install ($@);
my $final = 0;
sub final_begin ();
sub final_end ();
sub final_ok ();

### Print title
{
    my $line = "Building $prj, $date $version, $copyright";
    print "$line\n", "=" x length($line), "\n";
}

### Option handling

my $usage = <<"END_OF_USAGE";
Usage: build.pl [options]
General options:
  --(no)download      (check for newer files, disabled by default)
  --(no)postprocess   (pdf files are postprocessed, enabled by default)
  --(no)cache         (use cached pdf files, enabled by default)
Module options:
  --all               (select all modules)
END_OF_USAGE
map { $usage .= "  --(no)$_\n"; } @pkg_list;

my $opt_download    = 0;
my $opt_postprocess = 0;
my $opt_cache       = 1;
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
    'postprocess!' => \$opt_postprocess,
    'cache!'       => \$opt_cache,
) or die $usage;
@ARGV == 0 or die $usage;
@list_modules = grep { $modules{$_}; } @pkg_list;

info("Build modules: @list_modules");

### Format generation
if (@list_modules > 0) {
    section('Format generation');

    ensure_directory($dir_build);
    chdir $dir_build;
    run("$prg_pdflatex -ini -etex ../tex/pdflatex-tds.ini");
    run("$prg_lualatex -ini -etex ../tex/lualatex-tds.ini");
    run("$prg_lualatex -ini -etex ../tex/lualatex-tds2.ini");
    chdir $cwd;
}

### Download
{
    section('Download');

    sub download_ctan_file ($$) {
        my $file      = shift;
        my $ctan_path = shift;
        $ctan_path .= '/' if $ctan_path ne '';
        ensure_directory($dir_incoming_ctan);
        download("$dir_incoming_ctan/$file",
                 "$url_ctan/$ctan_path$file");
    }
    sub download_ctan ($$) {
        my $file      = shift;
        my $ctan_path = shift;
        download_ctan_file("$file.zip", $ctan_path);
    }
    sub download_ams ($$) {
        my $file     = shift;
        my $ams_path = shift;
        $ams_path .= '/' if $ams_path ne '';
        ensure_directory($dir_incoming_ams);
        download("$dir_incoming_ams/$file.zip",
                 "$url_ams/$ams_path$file.zip");
    }
    sub download_err ($) {
        my $name = shift;
        ensure_directory($dir_incoming_ltxprj);
        download("$dir_incoming_ltxprj/$name.err",
                 "$url_ltxprj/guides/$name.err");
    }
    sub download ($$) {
        my $file = shift;
        my $url  = shift;
        return 1 if -f $file and !$opt_download;
        info("download $url\n           --> $file");
        my $cmd = $prg_curl;
        $cmd .= " -4";
        $cmd .= " --disable-epsv";                # for ftp.ams.org
        $cmd .= " --time-cond $file" if -f $file; # download only if newer
        $cmd .= " --remote-time";                 # set file date
        $cmd .= " --output $file";                # target file
        $cmd .= " $url";                          # url
        run($cmd);
        -f $file or die "$error Download failed ($url)!\n";
    }

    download_ctan('base',          'macros/latex');
    download_ctan('doc',           'macros/latex');
    download_ctan('tools',         'macros/latex/required');
    download_ctan('graphics',      'macros/latex/required');
    download_ctan('cyrillic',      'macros/latex/required');
    download_ctan('babel',         'macros/latex/required');
    download_ctan('amslatex',      'macros/latex/required');
    download_ctan('amsrefs',       'macros/latex/contrib');
    # download_ctan('amsrefs.tds',   'install/macros/latex/contrib');
    download_ctan('amscls.tds',    'install/macros/latex/required/amslatex');
    download_ctan('psnfss',        'macros/latex/required');
    download_ctan('tds',           '');
    download_ctan('texware',       'systems/knuth/dist');
    download_ctan('mfware',        'systems/knuth/dist');
    download_ctan('etc',           'systems/knuth/dist');
    download_ctan('web',           'systems/knuth/dist');
    download_ctan('tex',           'systems/knuth/dist');
    download_ctan('mf',            'systems/knuth/dist');
    download_ctan('errata',        'systems/knuth/dist');
    download_ctan('etex_doc',      'systems/e-tex/v2.1');
    download_ams('amscls',         '');
    download_ams('amsmath',        '');
    # download_ams('amsrefs',    'amslatex/amsrefs');
    # download_ams('amsrefs',        '');
    # download_ams('amslatex',       '');
    # download_ams('amsrefs-tds',    'amslatex/amsrefs');
    # download_ams('amsrefs-ctan',   'amslatex/amsrefs');
    download_ams('amsrefs', 'amsrefs');
    download_err('manual');
    download_err('lb2');
    download_err('lgc2');
    download_err('tlc2');
    download_ctan_file('armtex.zip', 'language/armenian');
}

### Remove previous build
section('Remove previous build');
{
    foreach my $pkg (@list_modules) {
        run("$prg_rm -rf $dir_build/$pkg");
        my $distribfile = "$dir_distrib/$pkg.zip";
        unlink $distribfile if -f $distribfile;
    }
    if ($opt_all) {
        unlink $file_ctan_distrib if -f $file_ctan_distrib;
    }
}

### Unpack
section('Unpacking');
{
    my $texmf_ams = "$dir_build/amslatex/texmf";

    sub unpacking ($$$) {
        my $pkg     = shift;
        $modules{$pkg} or return 1;
        my $zipfile = shift;
        my $dir     = shift;
        run("$prg_unzip $zipfile -d$dir");
    }
    sub unpacking_flat ($$$) {
        my $pkg     = shift;
        $modules{$pkg} or return 1;
        my $zipfile = shift;
        my $dir     = shift;
        run("$prg_unzip -j $zipfile -d$dir");
    }
    sub unpack_ctan ($) {
        my $pkg = shift;
        $modules{$pkg} or return 1;
        unpacking($pkg,
                  "$dir_incoming_ctan/$pkg.zip",
                  $dir_build);
    }
    sub unpack_ams ($$) {
        my $name = shift;
        my $zip = shift;
        $modules{'amslatex'} or return 1;
        unpacking('amslatex', $zip, "$texmf_ams");
        my $src = "$dir_build/amslatex/$name";
        ensure_directory($src);
        run("$prg_cp $texmf_ams/source/latex/$name/* $src/");
    }
    sub unpack_psnfss ($) {
        my $name = shift;
        my $dir = "$dir_build/psnfss";
        $modules{'psnfss'} or return 1;
        unpacking('psnfss',
                "$dir/$name.zip",
                  "$dir/texmf");
    }
    sub unpack_knuth ($) {
        my $pkg = 'knuth';
        my $dir = "$dir_build/$pkg";
        my $zipfile = "$dir_incoming_ctan/$_[0].zip";
        $modules{$pkg} or return 1;
        run("$prg_unzip -j $zipfile -d$dir");
    }

    ensure_directory($dir_build);
    unpack_ctan('base');
    if ($modules{'base'}) {
        # replace .err files
        foreach my $name (qw[
            lb2
            lgc2
            manual
            tlc2
        ]) {
            my $file = "$dir_incoming_ltxprj/$name.err";
            my $dest = "$dir_build/base/$name.err";
            run("$prg_cp $file $dest");
        }
        run("$prg_rm -rf $dir_build/base/doc");
        unpacking('base',
                  "$dir_incoming_ctan/doc.zip",
                  "$dir_build/base");
        run("$prg_cp -p $dir_build/base/doc/*.tex $dir_build/base/");
        unpacking('base',
                  "$dir_incoming_ctan/armtex.zip",
                  "$dir_build/base");
    }
    map { unpack_ctan($_); } @required_list;
    if ($modules{'amslatex'}) {
        unpack_ams('amscls', "$dir_incoming_ctan/amscls.tds.zip");
        #unpack_ams('amsrefs', "$dir_incoming_ctan/amsrefs.tds.zip");
        unpack_ams('amsrefs', "$dir_incoming_ams/amsrefs.zip");
        unpack_ams('amsmath', "$dir_incoming_ams/amsmath.zip");
        # because of 00readme.txt and amsrefs.dtx
        # 2012-05-08: 00readme.txt is renamed to README.
        # 2012-05-08: amsrefs.dtx is fixed on CTAN.
        unpacking('amslatex',
                  "$dir_incoming_ctan/amsrefs.zip",
                  "$dir_build/amslatex/ctan");
        run("$prg_cp $dir_build/amslatex/ctan/amsrefs/README "
                . "$dir_build/amslatex/texmf/source/latex/amsrefs/README");
        # run("$prg_cp $dir_build/amslatex/ctan/amsrefs/amsrefs.dtx "
        #         . "$dir_build/amslatex/texmf/source/latex/amsrefs/amsrefs.dtx");
    }
    unpack_psnfss('lw35nfss');
    unpack_psnfss('freenfss');
    unpack_ctan('tds');
    unpack_knuth('texware');
    unpack_knuth('mfware');
    unpack_knuth('etc');
    unpack_knuth('web');
    unpack_knuth('tex');
    unpack_knuth('mf');
    unpack_knuth('errata');
    unpacking_flat('etex',
                   "$dir_incoming/ctan/etex_doc.zip",
                   "$dir_build/etex");
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

    if ($modules{'knuth'}) {
        chdir "$dir_build/knuth";
        my @files = qw[
            trip.fot
            tripin.log
            trip.log
            trip.typ
        ];
        run("$prg_chmod -x @files");
        @files = qw[
            trap.fot
            trapin.log
            trap.log
            trap.pl
            trap.typ
        ];
        run("$prg_chmod -x @files");
        chdir $cwd;
    }

    if ($modules{'amslatex'}) {
        patch("amslatex/amsmath/amsldoc.tex");
    }

#    if ($modules{'babel'}) {
#        map { patch("babel/$_"); } qw[
#        ];
#    }
}

### Install TDS/source
section('Install source');
{
    sub install_gen_source ($$@) {
        my $fmt  = shift;
        my $pkg  = shift;
        my @list = @_;
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        install "texmf/source/$fmt/$pkg", @list;
        chdir $cwd;
    }
    sub install_generic_source ($$@) {
        my $pkg = shift;
        my $dir = shift;
        my @list = @_;
        $modules{$pkg} or return 1;
        chdir "$dir_build/$pkg";
        install "texmf/source/$dir", @list;
        chdir $cwd;
    }
    sub install_source ($@) {
        my $pkg = shift;
        my @list = @_;
        install_gen_source('latex', $pkg, @list);
    }

    install_source 'base', qw[
        *.dtx
        *.fdd
        *.ins
        *.err
        *guide.tex
        ltnews*.tex
        ltx3info.tex
        latexbug.el
        source2e.tex
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
    install_gen_source('generic', 'babel', qw[
        *.ins
        *.dtx
        *.fdd
        *.dat
        usage.tex
        tb*.tex
    ]);
    # babel/manifest.txt: to be removed in a future release
    # already removed: bghyphen.tex, bghyphsi.tex
    install_gen_source('', 'tds', qw[
        Makefile
        tds2texi.el
        tdsguide.cls
        tds.sed
        tds.tex
    ]);
    install_generic_source('knuth', 'knuth/texware', qw[
        dvitype.web
        pltotf.web
        pooltype.web
        tftopl.web
    ]);
    install_generic_source('knuth', 'knuth/mfware', qw[
        gftodvi.web
        gftype.web
        gftopk.web
        mft.web
    ]);
    install_generic_source('knuth', 'knuth/etc', qw[
        vptovf.web
        vftovp.web
    ]);
    install_generic_source('knuth', 'knuth/web', qw[
        tangle.web
        weave.web
        webman.tex
    ]);
    install_generic_source('knuth', 'knuth/tex', qw[
        glue.web
        tex.web
        trip.fot
        tripin.log
        trip.log
        tripman.tex
        tripos.tex
        trip.pl
        trip.tex
        trip.typ
    ]);
    install_generic_source('knuth', 'knuth/mf', qw[
        mf.web
        trap.fot
        trapin.log
        trap.log
        trap.mf
        trap.pl
        trap.typ
        trapman.tex
    ]);
    install_generic_source('knuth', 'knuth/errata', qw[
        errata.one
        errata.two
        errata.three
        errata.four
        errata.five
        errata.six
        errata.seven
        errata.eight
        errata.nine
        errata.ten
        errata.eleven
        errata.tex
        errorlog.tex
        logmac.tex
    ]);
}

### Patch source files after source install
section('Patches after source install');
{
    if ($modules{'base'}) {
        chdir "$dir_build/base";

        # ltdirchk.dtx must be patched to fool it in
        # not having texsys.cfg
        {
            my $file_dtx = 'ltdirchk.dtx';
            my $file_org = 'ltdirchk.dtx.org';
            rename $file_dtx, $file_org;
            open(IN, '<', $file_org) or die "$error Cannot open `$file_org'!\n";
            open(OUT, '>', $file_dtx) or die "$error Cannot write `$file_dtx'!\n";
            while (<IN>) {
                s/openin15=texsys.cfg/openin15=texsys.cfg-not-found/;
                print OUT;
            }
            close(OUT);
            close(IN);
        }

        # base: TDS:makeindex/base -> TDS:makeindex/latex
        {
            my $file_ins = 'docstrip.ins';
            my $file_org = 'docstrip.ins.org';
            rename $file_ins, $file_org;
            open(IN, '<', $file_org) or die "$error Cannot open `$file_org'!\n";
            open(OUT, '>', $file_ins) or die "$error Cannot write `$file_ins'!\n";
            while (<IN>) {
                s|makeindex/base|makeindex/latex|;
                print OUT;
            }
            close(OUT);
            close(IN);
        }

        chdir $cwd;

        patch('base/encguide.tex');
        patch('base/lb2.err');
        patch('base/source2e.tex');
        patch('base/tlc2.err');
        patch('base/utf8ienc.dtx');
        run("$prg_recode latin1..utf8 $dir_build/base/lb2.err");
    }

    if ($modules{'knuth'}) {

        foreach my $file (qw[
            webman.tex
            tripman.tex
            trapman.tex
            logmac.tex
        ]) {
            patch("knuth/$file");
        }

    }

    if ($modules{'amslatex'}) {
        patch("amslatex/amscls/amsclass.dtx");
        patch("amslatex/amsrefs/changes.tex");
        run("$prg_recode latin1..utf8 $dir_build/amslatex/amsrefs/changes.tex");
    }
    
    if ($modules{'babel'}) {
        patch("babel/hebrew.fdd");
    }
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
    docstrip('base',     'unpack');
    docstrip('psnfss',   'psfonts');
    docstrip('cyrillic', 'cyrlatex');
    docstrip('graphics', 'graphics');
    docstrip('graphics', 'graphics-drivers');
    docstrip('tools',    'tools');
    docstrip('babel',    'babel');

    # patch for amsthm.sty, part 1/2
    if ($modules{'amslatex'}) {
        chdir "$dir_build/amslatex/amscls";
        run("$prg_docstrip ams-c1.ins");
        chdir $cwd;
    }
}

section('TDS cleanup');
{
    if ($modules{'amslatex'}) {
        my $dir_tds = "$dir_build/amslatex/texmf";
        sub cleanup_tds ($@) {
            my $sub_tree = shift;

            my @list = map { glob("$dir_tds/$sub_tree/$_"); } @_;
            unlink grep { -f $_; } @list;
            map { rmdir; } grep { -d $_; } @list;
        }

        cleanup_tds 'source/latex/amscls', qw[
            *.bst
            *.template
            diffs-c.txt
        ];
        cleanup_tds 'source/latex/amsmath', qw[
            diffs-m.txt
            amstex.sty
        ];
        run("$prg_mv $dir_tds/source/latex/amsrefs/amsrefs.faq"
            . " $dir_tds/doc/latex/amsrefs/");
        cleanup_tds 'source/latex/amsrefs', qw[
            cite-x*.tex
            jr.bib
            gktest.ltb
        ];
        # CTAN:macros/latex/required/amslatex/other/*
        run("$prg_cp $dir_build/amslatex/other/amsbooka.sty"
            . " $dir_build/amslatex/texmf/tex/latex/amscls/amsbooka.sty");
    }

    if ($modules{'babel'}) {
        my $tds_dir  = "$dir_build/babel/texmf";
        my $from_dir = "$tds_dir/source/generic/babel";

        ### Correction for *.drv files
        run("$prg_mv $from_dir/*.drv $dir_build/babel");
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
            sample2e.tex
            small2e.tex
        ];
        install 'texmf/tex/latex/base', qw[
            texsys.cfg
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
        install('texmf/doc/generic/babel', qw[
            *.txt
            *.heb
            *.bbl
            *.dat
            *.skeleton
            install.OzTeX*
        ]);
        chdir $cwd;
    }

    if ($modules{'tds'}) {
        chdir "$dir_build/tds";
        install('texmf/doc/tds', qw[
            README
            ChangeLog
            tds.html
        ]);
        install('texmf/doc/info', qw[
            tds.info
        ]);
        chdir $cwd;
    }

    if ($modules{'knuth'}) {
        chdir "$dir_build/knuth";
        install('texmf/doc/knuth/tex', qw[
            texbook.tex
        ]);
        install('texmf/doc/knuth/mf', qw[
            mfbook.tex
        ]);
        install('texmf/doc/knuth/errata', qw[
            cm85.bug
            mf84.bug
            tex82.bug
        ]);
        chdir $cwd;
    }

    if ($modules{'etex'}) {
        chdir "$dir_build/etex";
        my $doc_dir = 'texmf/doc/etex/base';
        my $src_dir = 'texmf/source/etex/base';
        ensure_directory($doc_dir);
        ensure_directory($src_dir);
        install($src_dir, qw[
            etex_man.tex etex_man.sty
        ]);
        chdir $cwd;
    }

    # patch for amsthm.sty, part 2/2
    if ($modules{'amslatex'}) {
        chdir "$dir_build/amslatex/amscls";
        my $dest_dir = '../texmf/tex/latex/amscls';
        ensure_directory($dest_dir);
        install($dest_dir, 'amsthm.sty');
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

### Preparation for documentation
if ($modules{'base'}) {
    my $dir_src = "$dir_build/base/armtex";
    my $tds_mf = "$dir_texmf/fonts/source/public/armtex";
    my $tds_tfm = "$dir_texmf/fonts/tfm/public/armtex";
    my $tds_latex = "$dir_texmf/tex/latex/armtex";
    my @tds_mf = map {chomp;$_} glob "$dir_src/mf/*.mf";
    my @tds_tfm = map {chomp;$_} glob "$dir_src/tfm/*.tfm";
    my @tds_latex = map {chomp;$_} glob "$dir_src/latex/*.*";
    install($tds_mf, @tds_mf);
    install($tds_tfm, @tds_tfm);
    install($tds_latex, @tds_latex);
    run("$prg_texhash $dir_texmf");
}

### PDF caching
my $count_cache = 0;
my $count_generate = 0;
sub cache ($$$) {
    my $dir = shift;
    my $name = shift;
    my $sub_generate = shift;
    ensure_directory("$dir_cache/$dir");
    my $file_cache_pdf = "$dir_cache/$dir/$name.pdf";
    my $file_cache_log = "$dir_cache/$dir/$name.log";
    my $file_here_pdf = "$name.pdf";
    my $file_here_log = "$name.log";
    my $generate = 1;
    $generate = 0
            if $opt_cache
            and -f $file_cache_pdf
            and -f $file_cache_log;
    if ($generate) {
        &$sub_generate;
        run("$prg_cp $file_here_pdf $file_cache_pdf");
        run("$prg_cp $file_here_log $file_cache_log");
        $count_generate++;
    }
    else {
        final_begin;
        run("$prg_cp $file_cache_pdf $file_here_pdf");
        run("$prg_cp $file_cache_log $file_here_log");
        final_end;
        $count_cache++;
    }
    final_ok;
    print "--- FINAL LOG: $file_cache_log ---\n\n";
}

### Generate documentation for base
if ($modules{'base'}) {
    section('Documenation: base');

    sub base_guide ($) {
        my $guide = "$_[0]guide";
        cache 'base', $guide, sub {
            my $latextds = $prg_lualatextds;
            $latextds = $prg_lualatextds2 if $guide eq 'usrguide';
            run("$latextds -draftmode $guide");
            run("$latextds -draftmode $guide");
            final_begin;
            run("$latextds $guide");
            final_end;
        };
        install_pdf('base', $guide);
        1;
    }
    sub simple_gen ($$) {
        my $ext  = shift;
        my $base = shift;
        my $file = "$base.$ext";
        my $latextds = $prg_lualatextds;
        $latextds = $prg_pdflatextds if $base eq 'utf8ienc';
        cache 'base', $base, sub {
            run("$latextds -draftmode $file");
            run("$latextds -draftmode $file");
            final_begin;
            run("$latextds $file");
            final_end;
        };
        install_pdf('base', $base);
        1;
    }
    sub complex_dtx ($) {
        my $base = shift;
        my $dtx = "$base.dtx";
        cache 'base', $base, sub {
            run("$prg_lualatextds -draftmode $dtx");
            run_makeindex("$base.idx", 'gind.ist');
            run_makeindex("$base.glo", 'gglo.ist', "$base.gls");
            run("$prg_lualatextds -draftmode $dtx");
            run_makeindex("$base.idx", 'gind.ist');
            run_makeindex("$base.glo", 'gglo.ist', "$base.gls");
            run("$prg_lualatextds -draftmode $dtx");
            final_begin;
            run("$prg_lualatextds $dtx"); # hypdestopt
            final_end;
        };
        install_pdf('base', "$base");
        1;
    }
    sub book_err ($) {
        my $base = shift;
        my $err = "$base.err";
        cache 'base', $base, sub {
            run("$prg_lualatextds -draftmode $err");
            run("$prg_sed -i -e '"
                   . 's/\\\\endinput/\\\\input{errata.cfg}\\n\\\\endinput/'
                   . "' $base.cfg");
            run("$prg_lualatextds -draftmode $err");
            run("$prg_lualatextds -draftmode $err");
            final_begin;
            run("$prg_lualatextds $err"); # hypdestopt
            final_end;
        };
        install_pdf('base', "$base");
        1;
    }
    chdir "$dir_build/base";

    ## source2e
    cache 'base', 'source2e', sub {
        run("$prg_lualatextds -draftmode source2e");
        run_makeindex('source2e.idx', 'gind.ist');
        run_makeindex('source2e.glo', 'gglo.ist', 'source2e.gls');
        run("$prg_lualatextds -draftmode source2e");
        run_makeindex('source2e.idx', 'gind.ist');
        run_makeindex('source2e.glo', 'gglo.ist', 'source2e.gls');
        run("$prg_lualatextds -draftmode source2e");
        final_begin;
        run("$prg_lualatextds source2e"); # hypdestopt
        final_end;
    };
    install_pdf('base', 'source2e');

    ## standard cases
    map { complex_dtx $_ } qw[
        classes
        doc
        docstrip
        letter
    ];
    map { simple_gen 'dtx', $_ } qw[
        alltt
        exscale
        fixltx2e
        graphpap
        ifthen
        inputenc
        latex209
        latexsym
        ltxdoc
        makeindx
        newlfont
        oldlfont
        proc
        slides
        syntonly
        utf8ienc
    ];
    map { simple_gen 'fdd', $_ } qw[
        cmfonts
        slifonts
    ];
    map { book_err $_ } qw[
        tlc2
        lb2
        lgc2
        webcomp
    ];

    ## manual.err
    run("$prg_sed -i -e '"
           . 's/\\\\documentclass{article}/'
           . '\\\\documentclass{article}\\n\\\\input{manual.cfg}/'
           . "' manual.err");
    cache 'base', 'manual', sub {
        run("$prg_lualatextds -draftmode manual.err");
        run("$prg_lualatextds -draftmode manual.err");
        final_begin;
        run("$prg_lualatextds manual.err"); # hypdestopt
        final_end;
    };
    install_pdf('base', 'manual');

    ## guides
    base_guide('cfg');
    base_guide('cls');
    base_guide('cyr');
    base_guide('enc');
    base_guide('fnt');
    base_guide('mod');
    base_guide('usr');

    ## lppl
    cache 'base', 'lppl', sub {
        run("$prg_lualatextds -draftmode doc_lppl");
        run("$prg_lualatextds -draftmode doc_lppl");
        final_begin;
        run("$prg_lualatextds doc_lppl"); # hypdestopt
        run("$prg_mv doc_lppl.pdf lppl.pdf");
        run("$prg_mv doc_lppl.log lppl.log");
        final_end;
    };
    install_pdf('base', 'lppl');

    ## ltxcheck
    cache 'base', 'ltxcheck', sub {
        run("$prg_lualatextds -draftmode ltxcheck.drv");
        final_begin;
        run("$prg_lualatextds ltxcheck.drv");
        final_end;
    };
    install_pdf('base', 'ltxcheck');

    ## ltx3info
    cache 'base', 'ltx3info', sub {
        my $code = <<'END_CODE';
\let\SavedDocumentclass\documentclass
\def\documentclass[#1]#2{
  \SavedDocumentclass[{#1}]{#2}
  \usepackage[colorlinks,pdfusetitle]{hyperref}
}
\input{ltx3info}
END_CODE
        $code =~ s/\s//g;
        run("$prg_lualatextds -draftmode '$code'");
        run("$prg_lualatextds -draftmode '$code'");
        final_begin;
        run("$prg_lualatextds '$code'"); # hypdestopt
        final_end;
    };
    install_pdf('base', 'ltx3info');

    ## ltnews
    my $ltnewsMode_Single = 0;
    my $ltnewsMode_AllInOne = 1;

    my $ltnews = 'ltnews';
    my $lastissue = 0;
    map { $lastissue = $1 if /ltnews(\d+)\.tex/ and $lastissue < $1; }
        glob('ltnews*.tex');
    if ($ltnewsMode_AllInOne) {
        my $file_lastissue = 'ltnews-lastissue.cfg';
        open(LT, '>', $file_lastissue) or die "!!! Error: Cannot write `$file_lastissue'!\n";
        print LT "\\def\\lastissue{$lastissue}\n\\endinput\n";
        close(LT);
        cache 'base', $ltnews, sub {
            my $cmd_ltnews = "$prg_lualatextds $ltnews";
            run($cmd_ltnews);
            run($cmd_ltnews);
            final_begin;
            run($cmd_ltnews);
            final_end;
        };
        install_pdf('base', $ltnews);
    }
    if ($ltnewsMode_Single) {
        for (my $i = 1; $i <= $lastissue; $i++) {
            my $ltnews = 'ltnews';
            $ltnews .= '0' if $i < 10;
            $ltnews .= $i;
            cache 'base', $ltnews, sub {
                run("$prg_pdflatextds $ltnews");
                final_begin;
                run("$prg_pdflatextds $ltnews");
                final_end;
            };
            install_pdf('base', $ltnews);
        }
    }

    chdir $cwd;
}

### Generate documentation for tools
if ($modules{'tools'}) {
    section('Documentation: tools');

    chdir "$dir_build/tools";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        my $latextds = $prg_lualatextds;
        $latextds = $prg_pdflatextds if $entry eq 'bm';
        $latextds = $prg_lualatextds2 if $entry eq 'calc'
                                      or $entry eq 'rawfonts'
                                      or $entry eq 'showkeys';
        my $drv = "$entry.dtx";
        cache 'tools', $entry, sub {
            run("$latextds -draftmode $drv");
            run_makeindex("$entry.idx", 'gind.ist');
            run_makeindex("$entry.glo", 'gglo.ist', "$entry.gls");
            run("$latextds -draftmode $drv");
            run_makeindex("$entry.idx", 'gind.ist');
            run_makeindex("$entry.glo", 'gglo.ist', "$entry.gls");
            run("$latextds -draftmode $drv");
            final_begin;
            run("$latextds $drv"); # hypdestopt
            final_end;
        };
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
$license
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
    cache 'tools', 'tools', sub {
        final_begin;
        run("$prg_pdflatextds tools.tex");
        final_end;
    };
    install_pdf('tools', 'tools');
    chdir $cwd;
}

### Generate documentation for cyrillic
if ($modules{'cyrillic'}) {
    section('Documentation: cyrillic');

    chdir "$dir_build/cyrillic";
    my @list = (glob("*.dtx"), glob("*.fdd"));
    foreach my $entry (@list) {
        my $base = $entry;
        $base =~ s/\.(dtx|fdd)$//;
        cache 'cyrillic', $base, sub {
            run("$prg_lualatextds -draftmode $entry");
            run("$prg_lualatextds -draftmode $entry");
            final_begin;
            run("$prg_lualatextds $entry"); # hypdestopt
            final_end;
        };
        install_pdf('cyrillic', $base);
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
        cache 'graphics', $entry, sub {
            run("$prg_lualatextds -draftmode $entry.dtx");
            run("$prg_lualatextds -draftmode $entry.dtx");
            final_begin;
            run("$prg_lualatextds $entry.dtx"); # hypdestopt
            final_end;
        };
        install_pdf('graphics', $entry);
    }
    my $code = <<'END_CODE';
\makeatletter
\let\documentclass\@@end
\input{grfguide}
END_CODE
    $code =~ s/\s//g;
    run("$prg_lualatextds -draftmode '$code'");
    run("$prg_epstopdf a.ps");
    cache 'graphics', 'grfguide', sub {
        run("$prg_lualatextds -draftmode grfguide");
        run("$prg_lualatextds -draftmode grfguide");
        final_begin;
        run("$prg_lualatextds grfguide");
        final_end;
    };
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
        my $latextds = $prg_lualatextds;
        $latextds = $prg_pdflatextds
                if $doc eq 'testmath'
                or $doc eq 'thmtest'
                or $doc eq 'cite-xs'
                or $doc eq 'mathscinet';
        $latextds = $prg_lualatextds2 if $doc eq 'amsldoc'
                                      or $doc eq 'subeqn'
                                      or $doc eq 'textcmds';
        $latextds = $prg_pdflatex
                if $doc eq 'thmtest';

        symlink $ams_drv, "$doc.drv";
        cache 'amslatex', $doc, sub {
            run("$latextds -draftmode $doc.drv");
            makeindex($doc);
            bibtex($doc);
            run("$latextds -draftmode $doc.drv");
            makeindex($doc);
            run("$latextds -draftmode $doc.drv");
            makeindex($doc);
            run("$latextds -draftmode $doc.drv") if $doc eq 'amsrefs';
            final_begin;
            run("$latextds $doc.drv");
            final_end;
        };
        install_pdf($amspkg, $doc);
    }

    chdir "$dir_build/amslatex/amsmath";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amsmath', $_; } qw[
        amsldoc subeqn technote testmath
        amsbsy amscd amsgen amsmath amsopn amstext amsxtra
    ];
    chdir $cwd;

    chdir "$dir_build/amslatex/amscls";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amscls', $_; } qw[
        amsthdoc instr-l thmtest
        amsclass amsdtx amsmidx upref
    ];
    chdir $cwd;

    chdir "$dir_build/amslatex/amsrefs";
    symlink '../texmf', 'texmf';
    map { generate_doc 'amsrefs', $_; } qw[
        cite-xa cite-xb cite-xh cite-xs
        amsrdoc changes
        amsrefs amsxport ifoption mathscinet pcatcode rkeyval textcmds
    ];
    chdir $cwd;
}

### Generate documentation for psnfss
if ($modules{'psnfss'}) {
    section('Documentation: psnfss');

    chdir "$dir_build/psnfss";

    cache 'psnfss', 'psfonts', sub {
        run("$prg_pdflatextds -draftmode psfonts.dtx");
        final_begin;
        run("$prg_pdflatextds psfonts.dtx");
        final_end;
    };
    install_pdf('psnfss', 'psfonts');

    cache 'psnfss', 'psnfss2e', sub {
        run("$prg_pdflatextds -draftmode psnfss2e.drv");
        run("$prg_pdflatextds -draftmode psnfss2e.drv");
        final_begin;
        run("$prg_pdflatextds psnfss2e.drv");
        final_end;
    };
    install_pdf('psnfss', 'psnfss2e');

    chdir $cwd;
}

### Generate documentation for babel
if ($modules{'babel'}) {
    section('Documentation: babel');

    sub install_babel_pdf ($) {
        install_gen_pdf('generic', 'babel', shift);
    }
    sub simple_doc ($) {
        my $file = shift;
        my $file_base = $file;
        $file_base =~ s/\.\w{3}$//;
        my $latextds = $prg_lualatextds;
        $latextds = $prg_lualatextds2 if $file eq 'athnum.dtx';

        cache 'babel', $file_base, sub {
            run("$latextds -draftmode $file");
            final_begin;
            run("$latextds $file");
            final_end;
        };
        install_babel_pdf($file_base);
    }
    sub generate_babel_doc ($) {
        my $doc  = shift;
        my $drv  = "$cwd/$dir_tex/ams.drv";

        symlink $drv, "$doc.drv";
        cache 'babel', $doc, sub {
            run("$prg_lualatextds -draftmode $doc.drv");
            run("$prg_lualatextds -draftmode $doc.drv");
            run("$prg_lualatextds -draftmode $doc.drv");
            final_begin;
            run("$prg_lualatextds $doc.drv");
            final_end;
        };
        install_babel_pdf($doc);
    }

    chdir "$dir_build/babel";

    my $greek_fdd = 'greek-fdd.drv';
    open(OUT, ">$greek_fdd") or die "$error Cannot open `$greek_fdd'!\n";
    print OUT "\\input{greek.fdd}\n";
    close(OUT);

    map { simple_doc($_); }
        $greek_fdd, qw[
        athnum.dtx
        grmath.dtx
        grsymb.dtx
        bbidxglo.dtx
        bbcompat.dtx
        greek-usage.tex
    ];

    map { generate_babel_doc($_); } qw[
        tb1202
        tb1401
        tb1604
    ];

    cache 'babel', 'babel', sub {
        run("$prg_pdflatextds -draftmode babel.tex");
        run_makeindex('babel.idx', 'bbind.ist');
        run_makeindex('babel.glo', 'bbglo.ist', 'babel.gls');
        run("$prg_pdflatextds -draftmode babel.tex");
        run_makeindex('babel.idx', 'bbind.ist');
        run_makeindex('babel.glo', 'bbglo.ist', 'babel.gls');
        run("$prg_pdflatextds -draftmode babel.tex");
        final_begin;
        run("$prg_pdflatextds babel.tex");
        final_end;
    };
    install_babel_pdf('babel');

    chdir $cwd;
}

### Generate documentation for tds
if ($modules{'tds'}) {
    section('Documentation: tds');

    chdir "$dir_build/tds";

    my $file_tds = 'tds.tex';
    my $file_tds_new = 'tds.new';

    # make nicer references and use CVS date instead of current date
    open(IN, $file_tds) or die "$error Cannot open `$file_tds'!\n";
    open(OUT, '>', $file_tds_new) or die "$error Cannot write `$file_tds_new'!\n";
    while (<IN>) {
        s/Appendix~\\ref/\\appref/g;
        s/Section~\\ref/\\secref/g;
        if (/^% \$Id:.* (\d\d\d\d)\/(\d\d)\/(\d\d) /) {
            print OUT <<"END_TEXT";
\\year=$1\\relax
\\month=$2\\relax
\\day=$3\\relax
END_TEXT
        }
        print OUT;
    }
    close(OUT);
    close(IN);

    cache 'tds', 'tds', sub {
        unlink('tds.aux');
        run("$prg_lualatextds -draftmode $file_tds_new");
        run("$prg_lualatextds -draftmode $file_tds_new");
        final_begin;
        run("$prg_lualatextds $file_tds_new");
        final_end;
    };
    install_gen_pdf('', 'tds', 'tds');

    chdir $cwd;
}

### Generate documentation for knuth
if ($modules{'knuth'}) {
    section('Documentation: knuth');

    chdir "$dir_build/knuth";

    my $knuth_drv = "$cwd/$dir_tex/knuth.drv";

    sub generate_web_doc ($@) {
        my $dir = shift;
        my @list = @_;

        foreach my $entry (@list) {
            symlink $knuth_drv, "$entry.drv";
            cache 'knuth', $entry, sub {
                run("$prg_weave $entry.web")
                        unless $entry eq 'webman'
                            or $entry eq 'tripman'
                            or $entry eq 'trapman';
                run("$prg_pdftex -draftmode $entry.drv");
                final_begin;
                run("$prg_pdftex $entry.drv");
                final_end;
            };
            install_gen_pdf('knuth', $dir, $entry);
        }
    }

    generate_web_doc('texware', qw[
        dvitype
        pltotf
        pooltype
        tftopl
    ]);
    generate_web_doc('mfware', qw[
        gftodvi
        gftype
        gftopk
        mft
    ]);
    generate_web_doc('etc', qw[
        vptovf
        vftovp
    ]);
    generate_web_doc('web', qw[
        tangle
        weave
        webman
    ]);
    generate_web_doc('tex', qw[
        glue
        tex
    ]);
    generate_web_doc('mf', qw[
        mf
    ]);

    cache 'knuth', 'tripman', sub {
        final_begin;
        run("$prg_pdftex tripman");
        final_end;
    };
    install_gen_pdf('knuth', 'tex', 'tripman');

    cache 'knuth', 'trapman', sub {
        final_begin;
        run("$prg_pdftex trapman");
        final_end;
    };
    install_gen_pdf('knuth', 'mf', 'trapman');

    symlink "$cwd/$dir_tex/errorlog.drv", 'errorlog.drv';
    cache 'knuth', 'errorlog', sub {
        final_begin;
        run("$prg_pdftex errorlog.drv");
        final_end;
    };
    install_gen_pdf('knuth', 'errata', 'errorlog');

    # last bug date is used for errata.tex's today
    {
        open(IN, '<', 'errata.tex') or die "$error Cannot open `errata.tex'!\n";
        my @lines = <IN>;
        close(IN);

        my ($day, $month, $year) = (0, 0, 0);
        sub xdays {
            my $y = shift;
            my $m = shift;
            $m -= 1;
            my $d = shift;
            return $y*12*31 + $m*31 +$d;
        }
        foreach $_ (@lines) {
            next unless /^\\bugonpage/;
            next unless m|\((\d\d)/(\d\d)/(\d\d)\)\s*$|;
            my ($d, $m, $y) = ($2, $1, $3);
            $y += 1900;
            $y += 100 if $y < 1970;
            if (xdays($y, $m, $d) > xdays($year, $month, $day)) {
                $year = $y;
                $month = $m;
                $day = $d;
            }
        }

        open(OUT, '>', 'errata.new') or die "$error Cannot open `errata.new'!\n";
        print OUT "\\year=$year\n";
        print OUT "\\month=$month\n";
        print OUT "\\day=$day\n";
        print OUT "\\input errata.tex\n";
        print OUT "\\endinput\n";
        close(OUT);
    }
    foreach my $entry (qw[
        one
        two
        three
        four
        five
        six
        seven
        eight
        nine
        ten
        eleven
        new
    ]) {
        symlink "$cwd/$dir_tex/errata.drv", "errata_$entry.tex";
        cache 'knuth', "errata_$entry", sub {
            final_begin;
            run("$prg_pdftex errata_$entry.tex");
            final_end;
        }
    }
    symlink "$cwd/$dir_tex/errata.all", 'errata.all';
    cache 'knuth', 'errata', sub {
        final_begin;
        run("$prg_pdftex errata.all");
        final_end;
    };
    install_gen_pdf('knuth', 'errata', 'errata');

    chdir $cwd;
}

### Generate documentation for etex
if ($modules{'etex'}) {
    section('Documentation: etex');

    chdir "$dir_build/etex";

    my $entry = 'etex_man';
    my $etex_man_drv = "$cwd/$dir_tex/$entry.drv";
    symlink $etex_man_drv, "$entry.drv";
    cache 'etex', $entry, sub {
        run("$prg_lualatextds -draftmode $entry.drv");
        run("$prg_lualatextds -draftmode $entry.drv");
        final_begin;
        run("$prg_lualatextds $entry.drv");
        final_end;
    };
    install_gen_pdf('etex', 'base', $entry);

    chdir $cwd;
}

### Module source
if ($modules{'source'}) {
    section('Module source');

    my $dir_dest = "$dir_build/source/texmf/source/latex/latex-tds";
    my $dir_scripts = "$dir_build/source/texmf/scripts";

    install $dir_dest, qw[
        build.pl
        README
    ];
    install "$dir_dest/tex", glob("$dir_tex/*.*");
    install "$dir_dest/patch", glob("$dir_patch/*.*");
    install "$dir_dest/lib", $file_ziptimetree;
    install "$dir_dest/lib", $file_adjust_checksum;
    install "$dir_dest/license", "$dir_license/lppl.txt";
    install "$dir_dest/license/ziptimetree", "$dir_license/ziptimetree/lgpl.txt";
    install $dir_distrib, 'README';
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

    # write zip comment file
    open(OUT, '>', $file_zip_comment)
            or die "$error Cannot write file `$file_zip_comment'!\n";
    print OUT $zip_comment;
    close OUT;

    for my $pkg (@list_modules) {
        my $dir_tds = "$dir_build/$pkg/texmf";
        my $file_distrib = "$cwd/$dir_distrib/$pkg.tds.zip";
        if (-d $dir_tds) {
            run_zip($file_distrib, $dir_tds);
        }
        else {
            print "!!! Warning: Missing TDS tree for `$pkg'!\n";
        }
    }

    if ($opt_all) {
        chdir $dir_distrib;
        my $cmd = "$prg_zip -0 $file_ctan_distrib README";
        for my $pkg (sort @pkg_list) {
            $cmd .= " $pkg.tds.zip";
        }
        run($cmd);
        chdir $cwd;
    }
}

### Display result
section('Result');
{
    print <<"END_CACHE";

* PDF cached/generated: $count_cache/$count_generate

END_CACHE

    for my $pkg (@list_modules) {
        my $file = "$dir_distrib/$pkg.tds.zip";
        if (-f $file) {
            system("$prg_ls -l $file");
            system("$prg_ls -l $dir_distrib/README")if $pkg eq 'source';
        }
        else {
            print "!!! Warning: Missing distribution for `$pkg'!\n";
        }
    }
    if ($opt_all) {
        system("$prg_ls -l $file_ctan_distrib");
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

sub install_gen_pdf ($$$) {
    my $fmt         = shift;
    my $pkg         = shift;
    my $file_base   = shift;
    my $file_source = "$file_base.pdf";
    my $dir_dest    = "texmf/doc/$fmt/$pkg";
    my $file_dest   = "$dir_dest/$file_base.pdf";

    ensure_directory($dir_dest);
    if ($opt_postprocess) {
        printsize($file_source, 0);
        if (-f $jar_pdfbox_rewrite) {
            run("$prg_java -jar $jar_pdfbox_rewrite $file_source $file_tmp");
        }
        else {
            run("$prg_cp $file_source $file_tmp");
        }
        run("$prg_java -cp $jar_multivalent tool.pdf.Compress -old $file_tmp");
        run("$prg_mv $file_tmp_o $file_dest");
        printsize($file_dest, 1);
    }
    else {
        run("$prg_cp $file_source $file_dest");
    }
    1;
}
sub install_pdf ($$) {
    my $pkg       = shift;
    my $file_base = shift;

    install_gen_pdf('latex', $pkg, $file_base);
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

sub final_check ($) {
    my $expected = shift;
    $final == $expected
            or die "!!! Error: Wrong final state `$final', expected `$expected'!\n";
}
sub final_begin () {
    final_check(0);
    print "\n--- FINAL BEGIN ---\n";
    $final = 1;
}
sub final_end () {
    final_check(1);
    print "--- FINAL END ---\n\n";
    $final = 2;
}
sub final_ok () {
    final_check(2);
    $final = 0;
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

sub run_zip ($$) {
    my $zip_file = shift;
    my $dir_start = shift;
    run("$prg_ziptimetree --verbose --noroot $zip_file $dir_start");
    run("$prg_zip -z $zip_file <$file_zip_comment");
}

sub info ($) {
    my $msg = shift;
    print "* $msg\n";
    1;
}

sub cvs ($) {
    $_ = shift;
    s/^\$\w+:?\s*(\S*).*\$$/$1/;
    $_ = "v$_" if /\./;
    $_;
}

sub patch ($) {
    my $file  = shift;
    my $patch = $file;
    $patch =~ s/^.*\/([^\/]+)$/$1/;
    run("$prg_patch $dir_build/$file $dir_patch/$patch.diff");
}

sub get_perl_script ($) {
    # Either the source of latex-tds is unpacked as TDS tree,
    # then the perl script is below TDS:scripts/
    # or it can be put into the lib directory $dir_lib that I am using.
    my $script = shift;
    if (-f "$cwd/$dir_lib/$script.pl") {
        $script = "$cwd/$dir_lib/$script.pl";
    }
    else {
        if (-f "$cwd/../../../scripts/latex-tds/$script.pl") {
            $script = "$cwd/../../../scripts/latex-tds/$script.pl";
        }
        else {
            $script = "$cwd/../../../scripts/$script/$script.pl";
        }
    }
    die "$error Script $script.pl not found!\n" unless -f $script;
    run("$prg_chmod +x $script") unless -x $script;
    die "$error Script $script is not executable!\n" unless -x $script;
    $script;
}

__END__
