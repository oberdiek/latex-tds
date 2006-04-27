#!/usr/bin/env perl
use strict;
$^W=1;

my $ctan_url = 'ftp://dante.ctan.org/tex-archive';
my @required_list = (
#    'amslatex',
#    'babel',
#    'psnfss',
    'cyrillic',
    'graphics',
    'tools'
);
my @pkg_list = ('base');
push @pkg_list, @required_list;

my $dir_incoming = 'incoming';
my $dir_build = 'build';
my $dir_lib = 'lib';
my $dir_distrib = 'distrib';
chomp(my $cwd = `pwd`);

my $jar_pdfbox_rewrite = "$cwd/$dir_lib/pdfbox-rewrite.jar";
my $jar_multivalent = "$cwd/$dir_lib/Multivalent20060102.jar";

my $file_tmp = "$cwd/$dir_build/tmp.pdf";
my $file_tmp_o = "$cwd/$dir_build/tmp-o.pdf";

my $prg_wget = 'wget';
my $prg_unzip = 'unzip';
my $prg_docstrip = 'tex -shell-escape';
$ENV{'TEXINPUTS'} = "$cwd:.:";
my $prg_copy = 'cp -p';
my $prg_mkdir = 'mkdir -p';
my $prg_pdflatex = 'pdflatex';
my $prg_makeindex = 'makeindex';
my $prg_move = 'mv';
my $prg_java = 'java';
my $prg_zip = 'zip -9r';
my $prg_epstopdf = 'epstopdf';

my $error = "!!! Error:";

### Download
{
    -d $dir_incoming or mkdir $dir_incoming;
    chdir $dir_incoming;
    -f 'base.zip' or system("$prg_wget $ctan_url/macros/latex/base.zip");
    foreach my $pkg (@required_list) {
        my $pkg_zip = "$pkg.zip";
        my $ctan_pkg = "$ctan_url/macros/latex/required/$pkg_zip";
        -f $pkg_zip or system("$prg_wget $ctan_pkg");
    }
    # check result
    my @not_found = ();
    foreach my $pkg (@pkg_list) {
       -f "$pkg.zip" or push @not_found, $pkg;
    }
    chdir $cwd;
    @not_found == 0 or die "$error: Failed downloads: @not_found!\n";
}

### Unpack
{
    -d $dir_build or mkdir $dir_build;
    foreach my $pkg (@pkg_list) {
        system("$prg_unzip $dir_incoming/$pkg.zip -d$dir_build");
    }
}

my $dummy = <<'END_DUMMY';

### Install TDS/source
{
    sub install_source {
        my $pkg = $_[0];
        my $ref_list = $_[1];
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
{
    sub docstrip {
        my $pkg = $_[0];
        my $ins = $_[1];
        chdir "$dir_build/$pkg";
        system("$prg_docstrip $ins.ins");
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

### Correction for *.ist files
{
    chdir "$dir_build/base";
    system("prg_mkdir texmf/makeindex");
    system("prg_move texmf/tex/latex/base/*.ist texmf/makeindex");
}

### Install TDS/tex, TDS/doc files
{
    chdir "$dir_build/base";
    install('texmf/doc/latex/base', [
        '*.txt',
        '*.err',
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
    
    chdir "$dir_build/tools";
    install('texmf/doc/latex/tools', [
        '*.txt'
    ]);
    chdir $cwd;
    
    chdir "$dir_build/graphics";
    install('texmf/doc/latex/graphics', [
        '*.txt'
    ]);
    install('texmf/tex/latex/graphics', [
        '*.def'
    ]);
    chdir $cwd;
    
    chdir "$dir_build/cyrillic";
    install('texmf/doc/latex/cyrillic', [
        '*.txt'
    ]);
    chdir $cwd;
}

### Generate documentation for base
{
    sub base_guide {
        my $guide = "$_[0]guide";
        system("$prg_pdflatex $guide");
        system("$prg_pdflatex $guide");
        system("$prg_pdflatex $guide");
        install_pdf('base', $guide);
        1;
    }
    chdir "$dir_build/base";
    system("$prg_pdflatex source2e");
    system("$prg_makeindex -s gind.ist source2e.idx");
    system("$prg_makeindex -s gglo.ist -o souce2e.glo source2e.gls");
    system("$prg_pdflatex source2e");
    system("$prg_makeindex -s gind.ist source2e.idx");
    system("$prg_makeindex -s gglo.ist -o souce2e.glo source2e.gls");
    system("$prg_pdflatex source2e");
    install_pdf('base', 'source2e');
    base_guide('cfg');
    base_guide('cls');
    base_guide('cyr');
    base_guide('enc');
    base_guide('fnt');
    base_guide('mod');
    base_guide('usr');
    system("$prg_pdflatex doc_lppl");
    system("$prg_pdflatex doc_lppl");
    system("$prg_move doc_lppl.pdf lppl.pdf");
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
    system("$prg_pdflatex '$code'");
    system("$prg_pdflatex '$code'");
    install_pdf('base', 'ltx3info');
    for (my $i = 1; $i <= 17; $i++) {
        my $ltnews = 'ltnews';
        $ltnews .= '0' if $i < 10;
        $ltnews .= $i;
        system("$prg_pdflatex $ltnews");
        system("$prg_pdflatex $ltnews");
        install_pdf('base', $ltnews);
    }
    chdir $cwd;
}

### Generate documentation for tools
{
    chdir "$dir_build/tools";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        system("$prg_pdflatex $entry.dtx");
        system("$prg_makeindex -s gind.ist $entry.idx")
            if -f "$entry.idx";
        system("$prg_makeindex -s gglo.ist -o $entry.glo $entry.gls")
            if -f "$entry.gls";
        system("$prg_pdflatex $entry.dtx");
        system("$prg_makeindex -s gind.ist $entry.idx")
            if -f "$entry.idx";
        system("$prg_makeindex -s gglo.ist -o $entry.glo $entry.gls")
            if -f "$entry.gls";
        system("$prg_pdflatex $entry.dtx");
        install_pdf('tools', $entry);
    }
    chdir $cwd;
}

END_DUMMY

### Generate documentation for cyrillic
{
    chdir "$dir_build/cyrillic";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        system("$prg_pdflatex $entry.dtx");
        system("$prg_pdflatex $entry.dtx");
        install_pdf('cyrillic', $entry);
    }
    chdir $cwd;
}

### Generate documentation for graphics
{
    chdir "$dir_build/graphics";
    my @list = glob("*.dtx");
    map { s/\.dtx$//; } @list;
    foreach my $entry (@list) {
        system("$prg_pdflatex $entry.dtx");
        system("$prg_pdflatex $entry.dtx");
        install_pdf('graphics', $entry);
    }
    my $code = <<'END_CODE';
\makeatletter
\let\documentclass\@@end
\input{grfguide}
END_CODE
    $code =~ s/\s//g;
    system("$prg_pdflatex '$code'");
    system("$prg_epstopdf a.ps");
    system("$prg_pdflatex grfguide");
    system("$prg_pdflatex grfguide");
    system("$prg_pdflatex grfguide");
    install_pdf('graphics', 'grfguide');
    chdir $cwd;
}

### Pack result
{
    -d $dir_distrib or mkdir $dir_distrib;
    for my $pkg (@pkg_list) {
        my $dir_tds = "$dir_build/$pkg/texmf";
        if (-d $dir_tds) {
            chdir $dir_tds;
            system("$prg_zip $cwd/$dir_distrib/$pkg-tds.zip *");
            chdir $cwd;
        }
    }
}

sub install {
    my $dir_target = $_[0];
    my @list = @{$_[1]};

    -d $dir_target or system("$prg_mkdir $dir_target");
    system("$prg_copy @list $dir_target/");
    1;
}

sub install_pdf {
    my $pkg = $_[0];
    my $file_base = $_[1];
    my $file_source = "$file_base.pdf";
    my $dir_dest = "texmf/doc/latex/$pkg";
    my $file_dest = "$dir_dest/$file_base.pdf";

    system("$prg_mkdir $dir_dest") unless -d $dir_dest;
    printsize($file_source, 0);
    system("$prg_java -jar $jar_pdfbox_rewrite $file_source $file_tmp");
    system("$prg_java -cp $jar_multivalent tool.pdf.Compress -old $file_tmp");
    system("$prg_move $file_tmp_o $file_dest");
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

__END__
