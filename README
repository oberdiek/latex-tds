readme.txt for project latex-tds, 2007/10/18

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
* tools     CTAN:macros/latex/required/tools.zip
* cyrillic  CTAN:macros/latex/required/cyrillic.zip
* amslatex  CTAN:macros/latex/required/amslatex.zip
            ftp://ftp.ams.org/pub/tex/amslatex.zip
            ftp://ftp.ams.org/pub/tex/amsrefs.zip
* psnfss    CTAN:macros/latex/required/psnfss.zip
* babel     CTAN:macros/latex/required/babel.zip
* tds       CTAN:tds.zip

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
    base.zip
    tools.zip
    ...
* The sources, mainly the build script, configuration and
  driver files, and patches:
    source.zip
  Some of the used tools are not provided, see section
  `Building Hints'.
* And the universe, the contents of all the ZIP files above,
  merged together:
    latex-tds.zip

It is possible that some or all ZIP archive files are also available
in the install subtree, then possible locations could be:
  CTAN:install/macros/latex/base.zip
  CTAN:install/macros/latex/required/tools.zip
  ...


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


D. COPYRIGHT, LICENSE
=====================

Copyright 2006, 2007 Heiko Oberdiek.

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
  tex/ltnews.cfg            for LaTeX News of latex/base
  tex/ltxdoc.cfg            setup for class ltxdoc
  tex/ltxguide.cfg          setup for the guide manuals in latex/base
                            and required/psnfss
  tex/manual.cfg            setup for errata list of the LaTeX manual
                            in latex/base
  tex/tdsguide.cfg          setup for class tdsguide.cls

Documentation driver
--------------------
  tex/ams.drv               generic doc driver for files from the
                            amslatex and babel bundle
  tex/babel.tex             doc driver with patches for babel.drv
  tex/doc_lppl.tex          doc driver for base/lppl.tex
  tex/greek-usage.tex       doc driver with patches for babel/usage.tex
  tex/ltnews.tex            master file that merges all base/ltnews*.tex
  tex/ltxcheck.drv          doc driver with patches for ltxcheck.tex
  tex/psnfss2e.drv          doc driver with patches for psnfss2e.tex
  tex/tools-overview.cls    class for tools.tex
  tex/tools.tex             master file for tools overview, generated
                            by the build.pl script from tools/manifest.txt

Patches
-------
  patch/classes.dtx.diff    patch for base/classes.dtx
  patch/albanian.dtx.diff   patch for babel/albanian.dtx
  patch/athnum.dtx.diff     patch for babel/athnum.dtx
  patch/bbcompat.dtx.diff   patch for babel/bbcompat.dtx
  patch/finnish.dtx.diff    patch for babel/finnish.dtx
  patch/frenchb.dtx.diff    patch for babel/frenchb.dtx
  patch/greek.ins.diff      patch for babel/greek.ins
  patch/latin.dtx.diff      patch for babel/latin.dtx


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
* It is unclear, which hyphenation patterns are in the control of babel.
  Comparing the version of duplicate hyphenation pattern files
  in CTAN, I decided:
  * iahyphen.tex -> TDS:tex/generic/hyphen
  * icehyph.tex  -> TDS:tex/generic/hyphen
  * lahyph.tex -> TDS:source/generic/babel
  * The Bulgarian patterns are removed, because they form a new CTAN
    project: CTAN:language/hyphenation/bghyphen
* It seems, nobody has generated the documentation since a long time.
  Several patches are necessary for error free compiling.
* ...


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
