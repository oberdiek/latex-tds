README for project latex-tds
============================

:Author: Heiko Oberdiek
:Version:   2013/02/27

.. contents:: Table of Contents
   :backlinks: entry
.. sectnum::
   :depth: 2
.. |copy| unicode:: U+00A9 .. copyright sign
.. |ge|   unicode:: U+2265 .. greater-than or equal to

Project latex-tds
-----------------

How it has started
~~~~~~~~~~~~~~~~~~
The project started as I wanted to install the new LaTeX release 2005/12/01
that was announced at 2006/04/27. However the files are not packed in
TDS format, ready for unpacking in the destination directory. And
the documentation files were not yet generated or the provided
PDF files are lacking of basic features such as bookmarks or link support.
Thus this project has started. I thought it could be finished during
the afternoon at the day of the announcement ...

Goals of the project
~~~~~~~~~~~~~~~~~~~~
* From the sources a TDS compliant tree is constructed and populated.
  The zipped result is distributed.
* All the documentation is generated from the sources. The PDF files
  are user friendly and provide navigational support with bookmarks
  and links.
* The PDF files are post-processed to reduce the file size.

Scope
~~~~~
I do not have the time to assemble a TeX distribution with
thousands of packages. Therefore I restricted myself to the
LaTeX base distribution and the required bundles.
In the following I will use the term 'module' for a package bundle.

Module list
~~~~~~~~~~~
**base**
  | `CTAN:macros/latex/base.zip <http://mirror.ctan.org/macros/latex/base.zip>`_
  | `CTAN:macros/latex/doc.zip <http://mirror.ctan.org/macros/latex/doc.zip>`_
  | http://www.latex-project.org/guides/lb2.err
  | http://www.latex-project.org/guides/lgc2.err
  | http://www.latex-project.org/guides/manual.err
  | http://www.latex-project.org/guides/tlc2.err

**tools**
  | `CTAN:macros/latex/required/tools <http://mirror.ctan.org/macros/latex/required/tools.zip>`_

**cyrillic**
  | `CTAN:macros/latex/required/cyrillic.zip <http://mirror.ctan.org/:macros/latex/required/cyrillic.zip>`_

**amslatex**
  | `CTAN:install/macros/latex/required/amslatex/amscls.tds.zip <http://mirror.ctan.org/install/macros/latex/required/amslatex/amscls.tds.zip>`_
  | `CTAN:install/macros/latex/required/amslatex/math.tds.zip <http://mirror.ctan.org/install/macros/latex/required/amslatex/math.tds.zip>`_
  | `CTAN:macros/latex/contrib/amsrefs.zip <http://mirror.ctan.org/macros/latex/contrib/amsrefs.zip>`_
  | `CTAN:macros/latex/required/amslatex.zip <http://mirror.ctan.org/macros/latex/required/amslatex.zip>`_
  | ftp://ftp.ams.org/pub/tex/amsrefs/amsrefs.zip
  | ftp://ftp.ams.org/pub/tex/amscls.zip
  | ftp://ftp.ams.org/pub/tex/amsmath.zip
**amsfonts**
  | `CTAN:install/fonts/amsfonts.tds.zip <http://mirror.ctan.org/install/fonts/amsfonts.tds.zip>`_
**psnfss**
  | `CTAN:macros/latex/required/psnfss.zip <http://mirror.ctan.org/macros/latex/required/psnfss.zip>`_
**babel**
  | `CTAN:macros/latex/required/babel.zip <http://mirror.ctan.org/macros/latex/required/babel.zip>`_
**tds**
  | `CTAN:tds.zip <http://mirror.ctan.org/tds.zip>`_
**knuth**
  | `CTAN:systems/knuth/dist/errata.zip <http://mirror.ctan.org/systems/knuth/dist/errata.zip>`_
  | `CTAN:systems/knuth/dist/etc.zip <http://mirror.ctan.org/systems/knuth/dist/etc.zip>`_
  | `CTAN:systems/knuth/dist/mfware.zip <http://mirror.ctan.org/systems/knuth/dist/mfware.zip>`_
  | `CTAN:systems/knuth/dist/texware.zip <http://mirror.ctan.org/systems/knuth/dist/texware.zip>`_
  | `CTAN:systems/knuth/dist/web.zip <http://mirror.ctan.org/systems/knuth/dist/web.zip>`_
  | `CTAN:systems/knuth/dist/tex.zip <http://mirror.ctan.org/systems/knuth/dist/tex.zip>`_
  | `CTAN:systems/knuth/dist/mf.zip <http://mirror.ctan.org/systems/knuth/dist/mf.zip>`_
**etex**
  | `CTAN:systems/e-tex/v2.1/etex_doc.zip <http://mirror.ctan.org/systems/e-tex/v2.1/etex_doc.zip>`_

Author
~~~~~~
Heiko Oberdiek <heiko.oberdiek at googlemail.com>

Home
~~~~
CTAN home with distribution files:
  `CTAN:macros/latex/contrib/latex-tds/ <http://mirror.ctan.org/macros/latex/contrib/latex-tds/>`_

Source repository (without distribution files):
  https://github.com/oberdiek/latex-tds


Abbreviations, Glossary
-----------------------
:CTAN:
    | Comprehensive TeX Archive Network.
    | FAQ entry: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=archives
    | For example, you can resolve the prefix ``CTAN:`` by using
      ``http://mirror.ctan.org/``
:latex-tds:
    The name of this project.
:TDS:
    | TeX Directory Structure.
    | FAQ entry: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=tds
    | Specification: http://www.ctan.org/pkg/tds


Download
--------

The home of the project is located at:
  `CTAN:/macros/latex/contrib/latex-tds/ <http://mirror.ctan.org/macros/latex/contrib/latex-tds/>`_

The following files can be downloaded:

* ``README``, ``README.html``, ``README.pdf``:
  The README file in different formats.

* ``<module>.tds.zip``: The module distribution files,
  see section `Module list`_ above
  for the available modules.

* ``source.tds.zip``: The sources, mainly the build script, configuration and
  driver files, and patches.
  Some of the used tools are not provided, see section
  `Build Hints`_.

* ``latex-tds.tds.zip``: The universe, the contents of all the ZIP files above,
  merged together.

Installation Hints
------------------

Hopefully the result of this project helps you in the installation
process. You get a TDS compliant tree just by unpacking.

Example:

.. code:: bash

  $ cd /some/where/texmf
  $ unzip latex-tds

or unzip's option ``-d``:

.. code:: bash

  $ unzip latex-tds -d /some/where/texmf

Instead of the universe ZIP file single modules can be selected.

Important to remember, point your unpack process right in
the root directory of your TDS tree. The directory structure
in the ZIP files start with the top-level directories::

  doc/latex/base/...
  tex/latex/tools/...
  source/...

Rationale: The root directory of a TDS tree can have different
names, such as texmf-dist, texmf-local, ...

Hints
~~~~~
* Refresh the file name database.
* Be aware that unpacking can insert and update files, but never
  deletes obsolete ones. Remainders of previous releases can
  cause trouble.
* Depending on the module further installation steps can be
  necessary, consult the module's own documentation.

Module base
^^^^^^^^^^^
  * The default +texsys.cfg+ that LaTeX provides is put
    into +TDS:tex/latex/base+. It must be removed, if you need
    a specialized version. Consult your TeX distribution
    and +TDS:doc/latex/base/source2e.pdf+ (module ltdirchk).
    Usually changes are not required for many TeX distributions
    such as Unix (web2c), MikTeX, ...
  * Formats need rebuilding (e.g., fmtutil).

Module babel
^^^^^^^^^^^^
  * Most hyphenation patterns are not provided here. Usually you can
    find them somewhere below `CTAN:language/hyphenation <http://mirror.ctan.org/language/hyphenation/>`_.
  * Language configuration (``language.dat``), see the documentation of
    your TeX distribution.
  * Formats need rebuilding.

Module psnfss
^^^^^^^^^^^^^
  * The map files need further configuring (e.g., updmap).

Module graphics
^^^^^^^^^^^^^^^
  * Module graphics does not provide all driver files, because some are
    developed independently (``pdftex.def``, ...).


Copyright, License
------------------

Copyright |copy| 2006-2013 Heiko Oberdiek.

License is LPPL 1.3c:

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3
of this license or (at your option) any later version.
The latest version of this license is in

  http://www.latex-project.org/lppl.txt

and version 1.3c or later is part of all distributions of LaTeX
version 2005/12/01 or later.

This work has the LPPL maintenance status 'maintained'.

The Current Maintainer of this work is Heiko Oberdiek.

See the following section `Manifest`_ for a list of all files
belonging to the project 'latex-tds'.


Manifest
--------

Included are the projects 'adjust_checksum' and 'ziptimetree'.
They are projects of their own.

Documentation
~~~~~~~~~~~~~
=======  =========
README   this file
=======  =========

Licenses
~~~~~~~~
+-----------------------------+------------------------------------------+
| license/lppl.txt            | LPPL (The LaTeX Project Public License)  |
|                             | for latex-tds and adjust_checksum        |
+-----------------------------+------------------------------------------+
|license/ziptimetree/lgpl.txt | LGPL (GNU Lesser General Public License) |
|                             | for ziptimetree                          |
+-----------------------------+------------------------------------------+

Scripts
~~~~~~~
+--------------------------+-------------------------------------------------+
| build.pl                 | main script for building the distribution       |
+--------------------------+-------------------------------------------------+
| lib/adjust_checksum.pl   | Perl script that runs a DTX file through LaTeX  |
|                          | and corrects its ``\Checksum`` if necessary     |
+--------------------------+-------------------------------------------------+
| lib/ziptimetree.pl       | Perl script that generates a ZIP file from      |
|                          | a directory tree with sorted entries (LGPL)     |
+--------------------------+-------------------------------------------------+


Configuration
~~~~~~~~~~~~~
+--------------------------+---------------------------------------------+
| tex/docstrip.cfg         | enables TDS feature and creates directories |
+--------------------------+---------------------------------------------+
| tex/errata.cfg           | for errata lists of latex/base              |
+--------------------------+---------------------------------------------+
| tex/hyperref.cfg         | hyperref configuration file                 |
+--------------------------+---------------------------------------------+
| tex/ltnews.cfg           | for LaTeX News of latex/base                |
+--------------------------+---------------------------------------------+
| tex/ltxdoc.cfg           | setup for class ltxdoc                      |
+--------------------------+---------------------------------------------+
| tex/ltxguide.cfg         | setup for the guide manuals in latex/base   |
|                          | and required/psnfss                         |
+--------------------------+---------------------------------------------+
| tex/ltugboat.cls         | setup for class ltugboat                    |
+--------------------------+---------------------------------------------+
| tex/lualatex-tds.ini     | init file for format generation for LuaTeX  |
+--------------------------+---------------------------------------------+
| tex/lualatex-tds2.ini    | init file for LuaTeX format without LM Math |
+--------------------------+---------------------------------------------+
| tex/manual.cfg           | setup for errata list of the LaTeX manual   |
|                          | in latex/base                               |
+--------------------------+---------------------------------------------+
| tex/pdflatex-tds.ini     | init file for format generation for pdfTeX  |
+--------------------------+---------------------------------------------+
| tex/tdsguide.cfg         | setup for class ``tdsguide.cls``            |
+--------------------------+---------------------------------------------+


Documentation driver
~~~~~~~~~~~~~~~~~~~~
+--------------------------+------------------------------------------------------+
| tex/ams.drv              | generic doc driver for files from the                |
|                          | amslatex and babel bundle                            |
+--------------------------+------------------------------------------------------+
| tex/babel.tex            | doc driver with patches for ``babel.drv``            |
+--------------------------+------------------------------------------------------+
| tex/doc_lppl.tex         | doc driver for ``base/lppl.tex``                     |
+--------------------------+------------------------------------------------------+
| tex/errata.all           | doc driver for ``knuth/errata/errata.pdf``           |
+--------------------------+------------------------------------------------------+
| tex/errata.drv           | doc driver for ``knuth/errata/errata_*.pdf``         |
+--------------------------+------------------------------------------------------+
| tex/errorlog.drv         | doc driver for ``knuth/errata/errorlog.tex``         |
+--------------------------+------------------------------------------------------+
| tex/etex_man.drv         | doc driver for ``etex/etex_man.tex``                 |
+--------------------------+------------------------------------------------------+
| tex/greek-usage.tex      | doc driver with patches for ``babel/usage.tex``      |
+--------------------------+------------------------------------------------------+
| tex/knuth.drv            | doc driver for                                       |
|                          | ``knuth/{texware,mfware,etc}/*.web``                 |
+--------------------------+------------------------------------------------------+
| tex/ltnews.tex           |master file that merges all ``base/ltnews*.tex``      |
+--------------------------+------------------------------------------------------+
| tex/ltxcheck.drv         | doc driver with patches for ``ltxcheck.tex``         |
+--------------------------+------------------------------------------------------+
| tex/psnfss2e.drv         | doc driver with patches for ``psnfss2e.tex``         |
+--------------------------+------------------------------------------------------+
| tex/tools-overview.cls   | class for ``tools.tex``                              |
+--------------------------+------------------------------------------------------+
| tex/tools.tex            | master file for tools overview, generated            |
|                          | by the ``build.pl`` script from                      |
|                          | ``tools/manifest.txt``                               |
+--------------------------+------------------------------------------------------+

Patches
~~~~~~~
=======================  ============================
Diff/patch file          Patched file
=======================  ============================
patch/amsclass.dtx.diff  amslatex/amsclass.dtx
patch/amsfndoc.def.diff  amsfonts/amsfndoc.def
patch/amsfndoc.tex.diff  amsfonts/amsfndoc.tex
patch/amsldoc.tex.diff   amslatex/amsldoc.tex
patch/changes.tex.diff   amslatex/amsrefs/changes.tex
patch/encguide.tex.diff  base/encguide.tex
patch/hebrew.fdd.diff    babel/hebrew.fdd
patch/logmac.tex.diff    knuth/errata/logmac.tex
patch/source2e.tex.diff  base/source2e.tex
patch/tlc2.err.diff      base/tlc2.err
patch/tripman.tex.diff   knuth/tex/tripman.tex
patch/trapman.tex.diff   knuth/mf/trapman.tex
patch/utf8ienc.dtx.diff  base/utf8ienc.dtx
patch/webman.tex.diff    knuth/web/webman.tex
=======================  ============================


Design Principles
-----------------

* Compliance with the latest TDS specification.
* No redundancy.
* User friendly PDF files with navigational support:
  ** bookmarks
  ** links
* Complete documentation. The documentation generation with
  enhanced PDF files is the tricky part and should be saved
  from the user.
* Output format of generated documentation is PDF, see above.
  Other formats such as DVI or PS are not generated and provided.
* Documentation bundles are preferred to many partial documentation
  files (e.g. ``source2e.pdf`` or ``ltnews.pdf``).
* If several expansion stages of a documentation are available,
  then just the most complete expansion stage should be used.
* Files that do not fit in a program sub tree of TDS stay below
  ``TDS:source`` (e.g. ``latexbug.el`` from latex/base). Then they do not
  get lost at least.
* Page layout: ``a4paper`` with reduced vertical margins (exception: ltnews).
  (This also decreases the page number usually.)
* ...


Remarks
-------

Base
~~~~
* ``source2e.pdf`` is used instead of many single ``lt*.pdf`` files.
* ``ltnews.pdf`` is introduced to avoid cluttering the doc directory
  with many single sheet ``ltnews*.pdf`` files.
* Patch for ``ltfssdcl.dtx``: Checksum fixed.
* ...

Tools
~~~~~
* Added: ``tools.pdf`` as overview/contents/index file with links
  and short descriptions of the single packages. (It uses
  the data from ``manifest.txt``).
* ...

Babel
~~~~~
* Babel's TeX files consists of three groups of files:

  #. Hyphenation pattern, see below
  #. Generic files:
       * ``*.ldf`` (language definition files)
       * ``*.sty`` (from ``bbcompat.dtx``, these are plain TeX files,
         LaTeX user have the package babel)
       * ``babel.def``, ``switch.def``
       * ``plain.def``
       * ``b*plain.tex``
       * ``esbst.tex``
  #. LaTeX files:
       * ``*.fd``
       * ``*enc.def`` (for package fontenc)
       * ``cp*.def``, ``8859-8.def``, ``si960.def`` (for package inputenc)
       * ``babel.sty``
       * ``romanidx.tex``
       * ``athnum.sty``, ``grmath.sty``, ``grsymb.sty`` (``greek.ins``)
       * ``heb*.sty``

  Full TDS compliance would use different format subtrees
  for the generic and LaTeX files. However practice (TeX Live, teTeX,
  VTeX, ...) put them in ``generic``, mainly because of maintenance issues.
  Also babel's ``*.ins`` files specify ``\usedir{tex/generic/babel}``.
  There can be problems, if different TDS trees have different
  babel versions installed and the same file can be found both
  in generic and latex. The natural search strategy for TDS compliant
  trees would be to look first in ``tex/latex`` across the trees, then
  in tex/generic. Thus it can happen to use files from the same
  package, but different versions.
  Therefore latex-tds put these files in the ``generic`` subtree.

* Babel already contains ``babel.pdf`` as documentation. It is a superset
  of ``user.pdf``. Thus I have dropped the latter one to avoid redundancy.
  Also the name ``babel.pdf`` is much more useful (texdoc).
* ...

Knuth
~~~~~
* Current CTAN -> TDS mapping in use:
  ``CTAN:systems/knuth/dist`` -> ``TDS:<toplevel>/knuth``
* Unsure where to put trip/trap files. Currently they are
  put in ``TDS:source``, because the documentation files
  (``tripman.pdf``, ``trapman.pdf``) are in ``TDS:doc``. They lists the
  trip/trap files already.
* Not covered is
  `CTAN:systems/knuth/dist/lib/ <http://mirror.ctan.org/systems/knuth/dist/lib/>`_
  In TeX Live 2007/2008 the files are installed at different
  locations::

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

e-TeX
~~~~~
* Only the manual 'etex_man' is covered by this module.


Build Hints
-----------

The most important advice I can give: *Forget it*!
The purpose of the source files are rather to show, what was
done in which way.
The ``*.zip`` with TDS trees are the goal of the project, not the
build process. Some remarks, if someone wants to build the
modules himself:

* TeX compiler: LuaTeX and pdfTeX (|ge| 1.30).
* An up-to-date LaTeX installation, at least TeX Live 2012.
* Additional packages can be necessary, e.g.
  `CTAN:language/armenian/armtex.zip <http://mirror.ctan.org/language/armenian/armtex.zip>`_
  is not part of TeX Live 2012.
* Most of the PDF files are generated using lualatex and package
  'fontspec' that uses the Latin Modern fonts as default. They
  are available as OpenType fonts. LuaTeX generates with OpenType
  fonts considerably smaller PDF files. Also PDF object stream
  compression is used (PDF 1.5). Therefore the further
  post-processing of PDF files are currently dropped.
* (Outdated since 2011-07-01) PDF post-processing, I have used two steps:
   #. First step:

     a. I have written a tool that analyzes page stream contents and
        optimizes them (removal of unnecessary color settings, minimize
        translation operations, ...)
        -> ``pdfbox-rewrite.jar``.
     b. For reading and writing the PDF file I have used PDFBox
        -> ``PDFBox-0.7.2.jar`` (http://pdfbox.apache.org/).
     c. To get better results I patched some of the classes
        of PDFBox (especially the write module)
        -> ``pdfbox-rewrite.jar``.

   #. The final conversion step was done by Multivalent, because
      it makes a very good job in PDF compression:
      -> ``Multivalent20060102.jar`` (http://multivalent.sourceforge.net/)

  Multivalent and PDFBox are available, ``pdfbox-rewrite.jar``, however,
  is just a first prototype, not ripe for a release.
  Therefore this step of post-processing is optional for the
  project latex-tds. The build script looks for the library and
  skips this steps automatically if necessary.

  If you give the build script the option ``--nopostprocess``,
  then it will skip the postprocess steps (building is faster,
  the pdf files a little larger).

  Install the jar files in the directory ``lib`` where
  they are expected by the build script.

* Unix, Perl background is expected.
* No support or documentation.


History
-------

:2006/04/27:
  * Start of the project (without babel, amslatex, psnfss).
:2006/06/01:
  * Module amslatex added.
:2006/06/03:
  * Modules psnfss and babel added, now all modules are covered.
:2006/06/07:
  * The project uploaded to CTAN.
:2006/07/31:
  * Index added to base/classes.dtx.
  * ZIP files renamed: ``\*-tds.zip`` -> ``*.zip``
  * Comment added to ZIP files.
  * Update of ``readme.txt``.
:2006/08/26:
  * Module tds for `CTAN:tds/ <http://mirror.ctan.org/tds/>`_ added.
  * Obsolete hyphenation patterns added to babel's source directory
    to avoid violation of LPPL.
  * Script adjust_checksum added and scripts are put below ``TDS:scripts``.
  * ``TDS:makeindex/base/`` renamed to ``TDS:makeindex/latex/``
  * Exception for ``sample2e.tex`` and ``small2e.tex`` that now go into
    ``TDS:tex/latex/base/``.
:2006/08/28:
  * Default ``texsys.cfg`` is generated.
  * ``adjust_checksum.pl`` and ``ziptimetree.pl`` now moved from the ``scripts``
    branch to ``TDS:source/latex/latex-tds/lib/``.
:2006/12/27:
  * Fix of ``ltxguide.cfg`` that had loaded doc.sty that disturbs the
    verbatim stuff in ``fntguide.tex``.
:2007/01/08:
  * Fix for documentation of longtable.
:2007/03/19:
  * Patch for ``babel/latin.dtx`` added (babel/3922).
:2007/09/04:
  * A minor update on CTAN regarding babel:
    ``iahyphen.tex``, ``icehyph.tex``, and ``lahyph.tex`` are now symbolic links
    to their location in `CTAN:language/hyphenation/ <http://mirror.ctan.org/language/hyphenation/>`_.
    Therefore also
    ``lahyph.tex`` is now installed in ``TDS:tex/generic/hyphen/``.
:2007/10/18:
  * Update of module amslatex because of updated package amsrefs.
  * Fix in ``latin.dtx.diff``.
:2007/10/24:
  * Update of babel.
  * Update of amsrefs (``TDS:tex/latex/amscls`` -> ``TDS:tex/latex/amsrefs``).
:2008/04/01:
  * Update of babel (2008/03/17).
:2008/04/02:
  * Fix: ``latex/base/*.err`` added to ``TDS:source/latex/base/``.
:2008/04/05:
  * Using ``.tds.zip`` instead of .zip to follow ``CTAN:install``'s naming
    conventions.
:2008/06/28:
  * Update of babel (2008/06/01).
  * Babel documentation: table of contents reformatted.
:2008/07/07:
  * Update of babel (2008/07/06).
:2008/07/10:
  * Module knuth added.
  * Update of babel (2008/07/07).
:2008/07/11:
  * Fixes and additions for module knuth.
:2008/07/25:
  * Module amslatex: ``instr-l.tex`` vanished from CTAN (but not at AMS side).
  * Some unwanted spaces in generated PDF files fixed.
    (Caused by a wrong package file that was found on my system first.)
:2008/08/10:
  * Module latex3 added.
  * Module base: CTAN hyperlinks fixed.
  * Module amslatex: Outdated URL fixed in ``amsldoc.tex``.
  * Module babel: Problem with already defined ``\meta`` in ``tb1604.tex`` fixed.
:2008/09/06:
  * Module base:
    ** Using uptodate versions from LaTeX project page for errata lists.
    ** ``lgc2.err`` added (LaTeX Graphics Companion, 2. ed.).
    ** Various fixes in errata lists.
  * Module tools: ``array.dtx``: documentation fixed (tools/4044).
:2008/09/10:
  * Module base: Missing title date for utf8ienc.pdf fixed.
:2009/09/05:
  * Module amslatex: updated.
  * Module latex3: xpackages updated.
  * Module latex3: expl3 removed, because nothing to do.
:2009/09/25:
  * Module amslatex: updated.
  * Module babel: updated.
  * Update of LaTeX, release 2009/09/24.
:2009/12/07:
  * Module amslatex: Unhappily the ``.zip`` files are quite a mess,
    because they contain a mixup of old and new versions.
    Tried to sort this out and fix the last update.
  * Module latex3: xpackages removed, because nothing to do.
  * Module latex3 removed, nothing left to do.
:2010/05/04:
  * Module base: page layout for source2e fixed (changes, index).
  * Module base: update of ``.err`` files.
:2010/10/27:
  * Module amslatex: amscls and amsrefs updated.
  * Module etex added (only for etex_man).
  * Erratas updated.
:2011/03/10:
  * Module base: patch for latex/4148 (Missing ``\label`` and ``\ref`` in ``lppl.tex``).
:2011/04/18:
  * Module amslatex: There is an outdated version of amsthm.sty in
    `CTAN:install/macros/latex/required/amslatex/amscls.tds.zip <http://mirror.ctan.org/install/macros/latex/required/amslatex/amscls.tds.zip>`_.
    The package ``amsthm.sty`` is now generated from the source.
  * Using TDS tree for missing packages that are not part of TeX Live.
    Module base: `CTAN:language/armenian/armtex.zip <http://mirror.ctan.org/language/armenian/armtex.zip>`_.
:2011/06/24:
  * Module amslatex: Two downloads from AMS server removed, because
    the files are not longer available (and they are on CTAN).
  * Module amslatex: 00readme.txt and amsrefs.dtx taken from
    `CTAN:macros/latex/contrib/amsrefs.zip <http://mirror.ctan.org/macros/latex/contrib/amsrefs.zip>`_ instead of
    `CTAN:install/macros/latex/contrib/amsrefs.tds.zip <http://mirror.ctan.org/install/macros/latex/contrib/amsrefs.tds.zip>`_
    because the later archive file is out of sync.
:2011/06/30:
  * Module base:
    ** Update of LaTeX, release 2011/06/27.
    ** Patch ``ltpatch.ltx`` to match the kernel version.
    ** Patch ``lppl.tex.diff`` removed (no longer needed).
    ** Patch ``ltfssdcl.dtx.diff`` added (checksum fixed).
  * Module tools: Release 2011/06.
  * Module babel: Release 2011/06.
:2011/07/01:
  * PDF generation:

    * Use of LuaTeX instead of pdfTeX for most of the files.
    * Use of package 'fontspec' with Latin Modern fonts as
      default in OpenType format (smaller PDF file sizes).
      The post-processing of PDF files is skipped.
    * Various patches and fixes for LuaLaTeX and package 'fontspec'.
  * Module base:

    * Update of LaTeX.
    * Patches ``ltpatch.ltx.diff`` and ``ltfssdcl.dtx.diff`` removed
      (no longer needed).
  * Module tools: Update.
:2011/07/03:
  * build.pl:

    * Caching for PDF generation added.
    * 'FINAL' markers in the output of ``build.pl``
      for final (Lua|pdf)TeX runs.
:2011/07/26:
  * PDF generation: Use of package unicode-math with Latin Modern Math
    where possible.
:2011/08/10:
  * Update of tools.
:2011/10/05:
  * Update of tools (varioref).
:2011/11/16:
  * Update of babel.
:2012/05/12:
  * Update of amslatex (amsrefs).
  * Update of ``readme.txt`` that is renamed to ``README`` (CTAN convention).
  * Update of ``tlc2.err``.
:2013/02/14:
  * Update of amslatex (amsrefs).
  * Module amslatex: ``cite-x*.tex``, ``jb.bib`` in ``TDS:source/``, because
    these files are now classified as test files.
  * Module base: ``lb2.err`` and ``tlc2.err`` updated.
  * Change in version control system from CVS to git with public
    source repository.
:2013/02/15:
  * Module amsfonts added.
:2013/02/25:
  * Patch file ``lb2.err.diff`` removed by call of sed inside ``build.pl``.
  * ``README`` rewritten in text document format `AsciiDoc <http://www.methods.co.nz/asciidoc/>`_
    and added as HTML and PDF files.
  * ``README.asciidoc`` updated.
  * ``Makefile``: Target 'check-links' added.
:2013/02/26:
  * ``README`` generated from ``README.rst`` via ``README.html``.
:2013/02/27:
  * ``README.pdf`` generated by wkhtmltopdf via ``README.html``.
