readme.txt for project latex-tds, 2009/09/05

TABLE OF CONTENTS
=================
A. Abbreviations, Glossary
B. Project latex-tds
C. Download
D. Installation Hints
E. Copyright, License
F. Manifest
G. Design Principles
H. Remarks
I. Build Hints
J. History


A. ABBREVIATIONS, GLOSSARY
==========================
[CTAN]
    Comprehensive TeX Archive Network.
    FAQ entry: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=archives
    For example, you can resolve the prefix `CTAN:' by using
    `ftp://ftp.ctan.org/tex-archive/'.
[latex-tds]
    The name of this project.
[TDS]
    TeX Directory Structure.
    FAQ entry: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=tds
    Specification: CTAN:tds.zip


B. PROJECT LATEX-TDS
====================

How it has started
------------------
The project started as I wanted to install the new LaTeX release 2005/12/01
that was announced at 2006/04/27. However the files aren't packed in
TDS format, ready for unpacking in the destination directory. And
the documentation files were not yet generated or the provided
PDF files are lacking of basic features such as bookmarks or link support.
Thus this project has started. I thought it could be finished during
the afternoon at the day of the announcement ...

Goals of the project
--------------------
* From the sources a TDS compliant tree is constructed and populated.
  The zipped result is distributed.
* All the documentation is generated from the sources. The PDF files
  are user friendly and provide navigational support with bookmarks
  and links.
* The PDF files are post-processed to reduce the file size.

Scope
-----
I don't have the time to assemble a TeX distribution with
thousands of packages. Therefore I restricted myself to the
LaTeX base distribution and the required bundles.
In the following I will use the term `module' for a package bundle.

Module list
-----------
* base      CTAN:macros/latex/base.zip
            http://www.latex-project.org/guides/lb2.err
            http://www.latex-project.org/guides/lgc2.err
            http://www.latex-project.org/guides/manual.err
            http://www.latex-project.org/guides/tlc2.err
* tools     CTAN:macros/latex/required/tools.zip
* cyrillic  CTAN:macros/latex/required/cyrillic.zip
* amslatex  CTAN:macros/latex/required/amslatex.zip
            CTAN:macros/latex/contrib/amsrefs.zip
            ftp://ftp.ams.org/pub/tex/amslatex.zip
            ftp://ftp.ams.org/pub/tex/amslatex/amsrefs-tds.zip
            ftp://ftp.ams.org/pub/tex/amslatex/amsrefs-ctan.zip
* psnfss    CTAN:macros/latex/required/psnfss.zip
* babel     CTAN:macros/latex/required/babel.zip
* tds       CTAN:tds.zip
* knuth     CTAN:systems/knuth/dist/errata.zip
            CTAN:systems/knuth/dist/etc.zip
            CTAN:systems/knuth/dist/mfware.zip
            CTAN:systems/knuth/dist/texware.zip
            CTAN:systems/knuth/dist/web.zip
            CTAN:systems/knuth/dist/tex.zip
            CTAN:systems/knuth/dist/mf.zip
* latex3    CTAN:install/macros/latex/contrib/expl3.tds.zip
            CTAN:install/macros/latex/contrib/xpackages.tds.zip

Author
------
Heiko Oberdiek <oberdiek at uni-freiburg.de>


C. DOWNLOAD
===========

The home of the project is located at:
  CTAN:macros/latex/contrib/latex-tds/

The following files can be downloaded:
* readme.txt (this file)
* The module distribution files, see the module list above
  for the available modules, e.g:
    base.tds.zip
    tools.tds.zip
    ...
* The sources, mainly the build script, configuration and
  driver files, and patches:
    source.tds.zip
  Some of the used tools are not provided, see section
  `Building Hints'.
* And the universe, the contents of all the ZIP files above,
  merged together:
    latex-tds.tds.zip


C. INSTALLATION HINTS
=====================

Hopefully the result of this project helps you in the installation
process. You get a TDS compliant tree just by unpacking.

Example:
  cd /some/where/texmf
  unzip latex-tds
or unzip's option `-d':
  unzip latex-tds -d /some/where/texmf

Instead of the universe ZIP files single modules can be selected.

Important to remember, point your unpack process right in
the root directory of your TDS tree. The directory structure
in the ZIP files start with the top-level directories:
  doc/latex/base/...
  tex/latex/tools/...
  source/...
Rationale: The root directory of a TDS tree can have different
names, such as texmf-dist, texmf-local, ...

Hints
-----
* Refresh the file name database.
* Be aware that unpacking can insert and update files, but never
  deletes obsolete ones. Remainders of previous releases can
  cause trouble.
* Depending on the module further installation steps can be
  necessary, consult the module's own documentation.

[base]
  * The default texsys.cfg that LaTeX provides is put
    into tex/latex/base. It must be removed, if you need
    a specialized version. Consult your TeX distribution
    and doc/latex/base/source2e.pdf (module ltdirchk).
    Usually changes are not required for many TeX distributions
    such as Unix (web2c), MikTeX, ...
  * Formats need rebuilding (e.g., fmtutil).
[babel]
  * Most hyphenation patterns aren't provided here. Usually you can
    find them somewhere below CTAN:language/hyphenation.
  * Language configuration (language.dat), see the documentation of
    your TeX distribution.
  * Formats need rebuilding.
[psnfss]
  * The map files need further configuring (e.g., updmap).
[graphics]
  * Module graphics doesn't provide all driver files, because some are
    developed independently (pdftex.def, ...).
[latex3]
  * The changes of latex-tds are merged into the official sources
    of expl3. Also expl3 is provided as TDS package:
    CTAN:install/macros/latex/contrib/expl3.tds.zip
    There is nothing left for latex-tds to do. Therefore
    expl3 is removed from module latex3.


D. COPYRIGHT, LICENSE
=====================

Copyright 2006-2009 Heiko Oberdiek.

License is LPPL 1.3c:

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3
of this license or (at your option) any later version.
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3c or later is part of all distributions of LaTeX
version 2005/12/01 or later.

This work has the LPPL maintenance status `maintained'.

The Current Maintainer of this work is Heiko Oberdiek.

See the following section `Manifest' for a list of all files
belonging to the project `latex-tds'.


E. MANIFEST
===========

Included are the projects `adjust_checksum' and `ziptimetree'.
They are projects of their own.

Documentation
-------------
  readme.txt                this file

Licenses
--------
  license/lppl.txt              LPPL (The LaTeX Project Public License)
                                for latex-tds and adjust_checksum
  license/ziptimetree/lgpl.txt  LGPL (GNU Lesser General Public License)
                                for ziptimetree

Scripts
-------
  build.pl                  main script for building the distribution
  lib/adjust_checksum.pl    Perl script that runs a DTX file through
                            LaTeX and corrects its \Checksum if necessary
  lib/ziptimetree.pl        Perl script that generates a ZIP file from
                            a directory tree with sorted entries (LGPL)

Configuration
-------------
  tex/docstrip.cfg          enables TDS feature and creates directories
  tex/errata.cfg            for errata lists of latex/base
  tex/hyperref.cfg          hyperref configuration file
  tex/latex-tds.ini         init file for format generation
  tex/ltnews.cfg            for LaTeX News of latex/base
  tex/ltxdoc.cfg            setup for class ltxdoc
  tex/ltxguide.cfg          setup for the guide manuals in latex/base
                            and required/psnfss
  tex/ltugboat.cls          setup for class ltugboat
  tex/manual.cfg            setup for errata list of the LaTeX manual
                            in latex/base
  tex/tdsguide.cfg          setup for class tdsguide.cls

Documentation driver
--------------------
  tex/ams.drv               generic doc driver for files from the
                            amslatex and babel bundle
  tex/babel.tex             doc driver with patches for babel.drv
  tex/doc_lppl.tex          doc driver for base/lppl.tex
  tex/errata.all            doc driver for knuth/errata/errata.pdf
  tex/errata.drv            doc driver for knuth/errata/errata_*.pdf
  tex/errorlog.drv          doc driver for knuth/errata/errorlog.tex
  tex/expl3.drv             doc driver for latex3/expl3/expl3.tex
  tex/greek-usage.tex       doc driver with patches for babel/usage.tex
  tex/knuth.drv             doc driver for knuth/{texware,mfware,etc}/*.web
  tex/l32eproc.drv          doc driver for latex3/expl3/l32eproc.tex
  tex/ltnews.tex            master file that merges all base/ltnews*.tex
  tex/ltxcheck.drv          doc driver with patches for ltxcheck.tex
  tex/psnfss2e.drv          doc driver with patches for psnfss2e.tex
  tex/source3.drv           doc driver for latex3/expl/source3.tex
  tex/tools-overview.cls    class for tools.tex
  tex/tools.tex             master file for tools overview, generated
                            by the build.pl script from tools/manifest.txt

Patches
-------
  patch/array.dtx.diff      patch for tools/array.dtx
  patch/classes.dtx.diff    patch for base/classes.dtx
  patch/encguide.tex.diff   patch for base/encguide.tex
  patch/logmac.tex.diff     patch for knuth/errata/logmac.tex
  patch/tripman.tex.diff    patch for knuth/tex/tripman.tex
  patch/trapman.tex.diff    patch for knuth/mf/trapman.tex
  patch/utf8ienc.dtx.diff   patch for base/utf8ienc.dtx
  patch/webman.tex.diff     patch for knuth/web/webman.tex


F. DESIGN PRINCIPLES
====================

* Compliance with the latest TDS specification.
* No redundancy.
* User friendly PDF files with navigational support:
  * bookmarks
  * links
* Complete documentation. The documentation generation with
  enhanced PDF files is the tricky part and should be saved
  from the user.
* Output format of generated documentation is PDF, see above.
  Other formats such as DVI or PS are not generated and provided.
* Documentation bundles are preferred to many partial documentation
  files (e.g. source2e.pdf or ltnews.pdf).
* If several expansion stages of a documentation are available,
  then just the most complete expansion stage should be used.
* Files that do not fit in a program sub tree of TDS stay below
  TDS:source (e.g. latexbug.el from latex/base). Then they do not
  get lost at least.
* Page layout: a4paper with reduced vertical margins (exception: ltnews).
  (This also decreases the page number usually.)
* ...


G. REMARKS
==========

Base
----
* source2e.pdf is used instead of many single lt*.pdf files.
* ltnews.pdf is introduced to avoid cluttering the doc directory
  with many single sheet ltnews*.pdf files.
* ...

Tools
-----
* Added: tools.pdf as overview/contents/index file with links
  and short descriptions of the single packages. (It uses
  the data from manifest.txt).
* ...

AmSLaTeX
--------
* The distribution from the AMS ftp site is used, because
  the files are already sorted in TDS:
    ftp://ftp.ams.org/pub/tex/amslatex.zip
    ftp://ftp.ams.org/pub/tex/amsrefs.zip
* ...

Babel
-----
* Babel's TeX files consists of three groups of files:
  1. Hyphenation pattern, see below
  2. Generic files:
     *.ldf (language definition files)
     *.sty (from bbcompat.dtx, these are plain-TeX files,
            LaTeX user have the package babel)
     babel.def, switch.def
     plain.def
     b*plain.tex
     esbst.tex
  3. LaTeX files:
     *.fd
     *enc.def (for package fontenc)
     cp*.def, 8859-8.def, si960.def (for package inputenc)
     babel.sty
     romanidx.tex
     athnum.sty, grmath.sty, grsymb.sty (greek.ins)
     heb*.sty
  Full TDS compliance would use different format subtrees
  for the generic and LaTeX files. However practice (TeX Live, teTeX,
  VTeX, ...) put them in `generic', mainly because of maintenance issues.
  Also babel's *.ins files specify \usedir{tex/generic/babel}.
  There can be problems, if different TDS trees have different
  babel versions installed and the same file can be found both
  in generic and latex. The natural search strategy for TDS compliant
  trees would be to look first in tex/latex across the trees, then
  in tex/generic. Thus it can happen to use files from the same
  package, but different versions.
  --> Therefore latex-tds put theses files in the generic subtree.
* Babel already contains babel.pdf as documentation. It is a superset
  of user.pdf. Thus I have dropped the latter one to avoid redundancy.
  Also the name `babel.pdf' is much more useful (texdoc).
* ...

Knuth
-----
* Current used CTAN -> TDS mapping:
  CTAN:systems/knuth/dist --> TDS:<toplevel>/knuth
* Unsure where to put trip/trap files. Currently they are
  put in TDS:source, because the documentation files
  (tripman.pdf, trapman.pdf) are in TDS:doc. They lists the
  trip/trap files already.
* Not covered is
  CTAN:systems/knuth/dist/lib/
  In TeX Live 2007/2008 the files are installed at different
  locations:
    texmf-dist/fonts/source/public/mflogo/logo10.mf
    texmf-dist/fonts/source/public/mflogo/logo8.mf
    texmf-dist/fonts/source/public/mflogo/logo9.mf
    texmf-dist/fonts/source/public/mflogo/logobf10.mf
    texmf-dist/fonts/source/public/mflogo/logo.mf
    texmf-dist/fonts/source/public/mflogo/logosl10.mf
    texmf-dist/fonts/source/public/misc/grayf.mf
    texmf-dist/fonts/source/public/misc/manfnt.mf
    texmf-dist/fonts/source/public/misc/slant.mf
    texmf-dist/metafont/base/expr.mf
    texmf-dist/metafont/base/io.mf
    texmf-dist/metafont/base/null.mf
    texmf-dist/metafont/base/plain.mf
    texmf-dist/metafont/misc/3test.mf
    texmf-dist/metafont/misc/6test.mf
    texmf-dist/metafont/misc/rtest.mf
    texmf-dist/metafont/misc/test.mf
    texmf-dist/metafont/misc/waits.mf
    texmf-dist/metafont/misc/ztest.mf
    texmf-dist/mft/base/cmbase.mft
    texmf-dist/mft/base/plain.mft
    texmf-dist/tex/generic/misc/null.tex
    texmf-dist/tex/plain/base/manmac.tex
    texmf-dist/tex/plain/base/mftmac.tex
    texmf-dist/tex/plain/base/plain.tex
    texmf-dist/tex/plain/base/story.tex
    texmf-dist/tex/plain/base/testfont.tex
    texmf-dist/tex/plain/base/webmac.tex
    texmf/tex/generic/hyphen/hyphen.tex

LaTeX3
------
* This module tries to cover the stabler stuff that reached CTAN
  from `LaTeX3 project'.
* Sorting into the TDS tree is already done by the `LaTeX3 project'.
* Documentation is regenerated to add bookmarks, ...


H. BUILD HINTS
==============

The most important advice I can give: `forget it'!
The purpose of the source files are rather to show, what was
done in which way.
The *.zip with TDS trees are the goal of the project, not the
build process. Some remarks, if someone wants to build the
modules himself:
* TeX compiler: recent pdfTeX, below 1.30 some of the packages
  will not work.
* An up-to-date LaTeX installation is recommended.
* Additional packages can be necessary, e.g. I had to install
  language/armenian, fonts/tipa, fonts/wsuipa, fonts/fc,
  fonts/utopia, fonts/greek/cbfonts, ...
  Probably TeX Live would be a good idea (I haven't tested).
* Some new packages of mine I will put on CTAN, but at time
  of writing, they aren't available yet.
* PDF post-processing, I have used two steps:
  1. a) I have written a tool that analyzes page stream contents and
        optimizes them (removal of unnecessary color settings, minimize
        translation operations, ...).
        --> pdfbox-rewrite.jar
     b) For reading and writing the PDF file I have used PDFBox
        --> PDFBox-0.7.2.jar (http://www.pdfbox.org/)
     c) To get better results I patched some of the classes
        of PDFBox (especially the write module).
        --> pdfbox-rewrite.jar
  2. The final conversion step was done by Multivalent, because
     it makes a very good job in PDF compression:
     --> Multivalent20060102.jar (http://multivalent.sourceforge.net/)
  Multivalent and PDFBox are available, pdfbox-rewrite.jar, however,
  is just a first prototype, not ripe for a release.
  Therefore this step of post-processing is optional for the
  project latex-tds. The build script looks for the library and
  skips this steps automatically if necessary.
    If you give the build script the option --nopostprocess,
  then it will skip the postprocess steps (building is faster,
  the pdf files a little larger).
    Install the jar files in the directory 'lib' where
  they are expected by the build script.
* Unix, Perl background is expected.
* No support or documentation.


I. HISTORY
==========

2006/04/27
  * Start of the project (without babel, amslatex, psnfss).
2006/06/01
  * Module amslatex added.
2006/06/03
  * Modules psnfss and babel added, now all modules are covered.
2006/06/07
  * The project uploaded to CTAN.
2006/07/31
  * Index added to base/classes.dtx.
  * ZIP files renamed: '*-tds.zip' -> '*.zip'
  * Comment added to ZIP files.
  * Update of readme.txt.
2006/08/26
  * Module tds for CTAN:tds/ added.
  * Obsolete hyphenation patterns added to babel's source directory
    to avoid violation of LPPL.
  * Script adjust_checksum added and scripts are put below TDS:scripts.
  * TDS:makeindex/base/ renamed to TDS:makeindex/latex/
  * Exception for sample2e.tex and small2e.tex that now go into
    TDS:tex/latex/base/.
2006/08/28
  * Default texsys.cfg is generated.
  * adjust_checksum.pl and ziptimetree.pl now moved from the scripts
    branch to TDS:source/latex/latex-tds/lib/.
2006/12/27
  * Fix of ltxguide.cfg that had loaded doc.sty that disturbs the
    verbatim stuff in fntguide.tex.
2007/01/08
  * Fix for documentation of longtable.
2007/03/19
  * Patch for babel/latin.dtx added (babel/3922).
2007/09/04
  * A minor update on CTAN regarding babel:
   iahyphen.tex, icehyph.tex, and lahyph.tex are now symbolic links
   to their location in CTAN:language/hyphenation/. Therefore also
   lahyph.tex is now installed in TDS:tex/generic/hyphen/.
2007/10/18
  * Update of module amslatex because of updated package amsrefs.
  * Fix in latin.dtx.diff.
2007/10/24
  * Update of babel.
  * Update of amsrefs (TDS:tex/latex/amscls -> TDS:tex/latex/amsrefs).
2008/04/01
  * Update of babel (2008/03/17).
2008/04/02
  * Fix: latex/base/*.err added to TDS:source/latex/base/.
2008/04/05
  * Using .tds.zip instead of .zip to follow CTAN:install's naming
    conventions.
2008/06/28
  * Update of babel (2008/06/01).
  * Babel documentation: table of contents reformatted.
2008/07/07
  * Update of babel (2008/07/06).
2008/07/10
  * Module knuth added.
  * Update of babel (2008/07/07).
2008/07/11
  * Fixes and additions for module knuth.
2008/07/25
  * Module amslatex: instr-l.tex vanished from CTAN (but not at AMS side).
  * Some unwanted spaces in generated PDF files fixed.
    (Caused by a wrong package file that was found on my system first.)
2008/08/10
  * Module latex3 added.
  * Module base: CTAN hyperlinks fixed.
  * Module amslatex: Outdated URL fixed in amsldoc.tex.
  * Module babel: Problem with already defined \meta in tb1604.tex fixed.
2008/09/06
  * Module base:
    * Using uptodate versions from LaTeX project page for errata lists.
    * lgc2.err added (LaTeX Graphics Companion, 2. ed.).
    * Various fixes in errata lists.
  * Module tools/array.dtx: documentation fixed (tools/4044).
2008/09/10
  * Module base: Missing title date for utf8ienc.pdf fixed.
2009/09/05
  * Module amslatex: updated.
  * Module latex3: xpackages updated.
  * Module latex3: expl3 removed, because nothing to do.
