\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{gappyarticle}[2026/07/22 v1.0 Personal article class: Lucida OT fonts, tcolorbox, pgfplots]

% =====================================================================
%  gappyarticle.cls -- personal article class for research notes.
%
%  Usage:
%      \documentclass{gappyarticle}          % defaults to 11pt
%      \documentclass[12pt,twoside]{gappyarticle}
%
%  Any option is forwarded to the standard article class.
%
%  Font directory: by default the Lucida OpenType faces are looked up
%  in "../lucidaot/" relative to the main file.  To point elsewhere,
%  define \fontpath BEFORE \documentclass, e.g.
%      \def\fontpath{/abs/path/to/lucidaot/}
%      \documentclass{gappyarticle}
% =====================================================================

% =====================================================================
%  PORTING TO ANOTHER MACHINE
%
%  Two things must travel with your documents: this class file and the
%  Lucida OpenType fonts.  The texmf symlink and the shell TEXINPUTS that
%  make this class discoverable are local to each machine and do NOT sync
%  (e.g. via Google Drive), so redo the setup once on the new machine:
%
%  1. Copy the shared files into your projects root -- the folder that is
%     the PARENT of each document's folder:
%         <projects-root>/gappyarticle.cls
%         <projects-root>/lucidaot/         (the licensed *.otf files)
%     The class looks for fonts in "../lucidaot/" relative to each
%     document, so every project must sit exactly one level below
%     <projects-root>.  Lucida is a commercial font: copy your own
%     licensed OTFs -- TeX will not install or download them for you.
%     (To keep fonts elsewhere, set \def\fontpath{...} before
%     \documentclass instead.)
%
%  2. Make the class discoverable in EVERY tool -- terminal and GUI
%     editors such as Texpad/Texifier, which do not read your shell
%     profile.  Install it into your personal TeX tree; locate it with
%         kpsewhich -var-value TEXMFHOME
%     (macOS/MacTeX: ~/Library/texmf ; Linux/TeX Live: ~/texmf), then
%         mkdir -p "<TEXMFHOME>/tex/latex/local"
%         ln -s "<projects-root>/gappyarticle.cls" \
%               "<TEXMFHOME>/tex/latex/local/gappyarticle.cls"
%     A plain copy works too; a symlink keeps a single source of truth.
%     No mktexlsr/texhash is needed for files under TEXMFHOME.
%
%  3. Optional, terminal only: to also find shared .sty/.bib files kept
%     in the projects root, add to your shell profile (e.g. ~/.zshrc):
%         export TEXINPUTS=".:<projects-root>:$TEXINPUTS"
%
%  4. Compile with xelatex or lualatex (fontspec loads the Lucida OTFs);
%     two passes resolve \cite/\ref.  Under pdflatex the class falls back
%     to newpx fonts automatically.
% =====================================================================

% ---- Base class: article, default 11pt, all options forwarded -------
\PassOptionsToClass{11pt}{article}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

% ---- Page geometry --------------------------------------------------
\RequirePackage[margin=1in]{geometry}

% ---- Engine detection (pdfTeX vs. Xe/LuaTeX) ------------------------
\RequirePackage{iftex}

% ---- Mathematics ----------------------------------------------------
\RequirePackage{amsmath,amssymb,amsthm,mathtools}

% ---- Tables, floats, algorithms, misc -------------------------------
\RequirePackage{booktabs}
\RequirePackage{algorithm}
\RequirePackage{algpseudocode}
\floatname{algorithm}{Pseudocode}
\RequirePackage{microtype}
\RequirePackage{pgfplots}
\RequirePackage{pgfplotstable}
\RequirePackage[most]{tcolorbox}
\RequirePackage{float}
\RequirePackage{needspace}
\RequirePackage{hyperref}
\RequirePackage{empheq}
\RequirePackage{environ}

\pgfplotsset{compat=1.18}
\hypersetup{colorlinks=true,linkcolor=blue,citecolor=blue,urlcolor=blue}

% ---- Fonts (Lucida OpenType) ----------------------------------------
% Override the directory by defining \fontpath before \documentclass.
\providecommand{\fontpath}{../lucidaot/}
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage{newpxtext}
  \RequirePackage{newpxmath}
\else
  \RequirePackage{fontspec}
  \RequirePackage{unicode-math}
  % Enable TeX input sequences, slightly reduce size.
  \defaultfontfeatures{Ligatures=TeX,Scale=.92}
  % Guard against Lucida/unicode-math symbol clashes.
  \let\eth\relax
  \let\backepsilon\relax
  \let\digamma\relax
  \let\smallsetminus\relax
  % ==== TEXT ====
  \setmainfont[
    Path=\fontpath,
    UprightFont     = LucidaBrightOT.otf,
    ItalicFont      = LucidaBrightOT-Italic.otf,
    BoldFont        = LucidaBrightOT-Demi.otf,
    BoldItalicFont  = LucidaBrightOT-DemiItalic.otf
  ]{LucidaBrightOT}
  \setsansfont[
    Path=\fontpath,
    UprightFont     = LucidaSansOT.otf,
    ItalicFont      = LucidaSansOT-Italic.otf,
    BoldFont        = LucidaSansOT-Demi.otf,
    BoldItalicFont  = LucidaSansOT-DemiItalic.otf
  ]{LucidaSansOT}
  \setmonofont[
    Path=\fontpath
  ]{LucidaSansTypewriterOT.otf}
  % ==== MATH ====
  \setmathfont[
    Path=\fontpath,
    BoldFont = LucidaBrightMathOT-Demi.otf
  ]{LucidaBrightMathOT.otf}
  % ==== EXTRA DISPLAY FACES ====
  \newfontface\LucidaBlackletter[ Path=\fontpath ]{LucidaBlackletterOT.otf}
  \newfontface\LucidaCalligraphy[ Path=\fontpath ]{LucidaCalligraphyOT.otf}
  \newfontface\LucidaHandwriting[ Path=\fontpath ]{LucidaHandwritingOT.otf}
\fi

% ---- Colored callout boxes ------------------------------------------
\newtcolorbox{redbox}[1][] {
  enhanced,
  breakable,
  colback=red!10,
  colframe=red!50!black,
  boxrule=0.6pt,
  arc=2pt,
  left=8pt,
  right=8pt,
  top=6pt,
  bottom=6pt,
  before skip=8pt,
  after skip=8pt,
  title=\textit{#1}
}

% ---- General math shortcuts -----------------------------------------
\newcommand{\dd}{\mathrm{d}}
\newcommand{\E}{\mathbb{E}}
\newcommand{\R}{\mathbb{R}}
\newcommand{\1}{\mathbf{1}}
\newcommand{\sharpe}{\text{SR}}

% ---- TikZ -----------------------------------------------------------
\RequirePackage{tikz}
\usetikzlibrary{arrows.meta}

\endinput
