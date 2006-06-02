\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tools-overview}
  [2006/06/02 Overview for packages of latex/tools]

\LoadClass[a4paper,12pt]{article}

% page layout
\RequirePackage[
  ignoreall,
  hmargin=1in,
  vmargin={.75in,1in},
]{geometry}

\pagestyle{empty}

\RequirePackage{calc}[2005/08/06]

\RequirePackage{hyperref}
\hypersetup{
  colorlinks,
  filecolor=blue,
  pdftitle={LaTeX's Tools Bundle},
  pdfsubject={Overview},
  pdfauthor={Heiko Oberdiek},
  pdfcreator={Project `latex-tds'},
}
\title{Contents of \LaTeX's Tools Bundle}

\let\TO@document\document
\let\TO@enddocument\enddocument
\def\document{%
  \TO@document
  \maketitle
  \toks@={}%
  \setlength{\maxlen}{0pt}%
}
\newlength{\maxlen}
\def\enddocument{%
  \begin{list}{}{%
    \setlength{\leftmargin}{\maxlen + \labelsep}%
    \setlength{\labelwidth}{\maxlen}%
    \setlength{\partopsep}{0pt}%
  }%
    \the\toks@
  \end{list}%
  \TO@enddocument
}
\newcommand{\entry}[2]{%
  \outline{#1}%
  \toks@\expandafter{%
    \the\toks@
    \item[%
      \href{file:#1.pdf}{\printpackage{#1}}%
      \hfill
    ]%
    #2%
  }%
  \setlength{\maxlen}{%
    \maxof{\maxlen}{\widthof{\printpackage{#1}}}%
  }%
  \global\maxlen\maxlen
}
\newcommand*{\printpackage}[1]{%
  \textbf{\large #1:}%
}
\newcommand*{\outline}[1]{%
  \pdfoutline
    attr {/C[0 0 1]}
    user {%
      <<%
        /S/GoToR%
        /F(#1.pdf)%
        /NewWindow true%
        /D[0/XYZ null null null]%
      >>%
    }%
  {[#1]}\relax
}
\renewcommand*{\maketitle}{%
  \begingroup
    \par
    \centering
    \bfseries
    \LARGE
    \@title
    \par
  \endgroup
  \vspace{2em}%
}

\providecommand*{\cs}[1]{%
  \texttt{\textbackslash#1}%
}
\endinput
