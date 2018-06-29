
\documentclass[sigplan,10pt,noacm]{acmart}
\settopmatter{printfolios=false,printccs=false,printacmref=false}

\acmConference{A Research Agenda for Formal Methods in The Netherlands}%
  {September 3--4}%
  {Lorentz Center, Leiden, The Netherlands}
\acmYear{2018}
\acmISBN{} % \acmISBN{978-x-xxxx-xxxx-x/YY/MM}
\acmDOI{} % \acmDOI{10.1145/nnnnnnn.nnnnnnn}
\startPage{1}

\setcopyright{none}

%include polycode.fmt

\bibliographystyle{ACM-Reference-Format}
\citestyle{acmauthoryear}

\usepackage{xcolor}
\newcommand{\todo}[1]{\textcolor{red}{\textbf{TODO: #1}}}
\usepackage{bussproofs}

\begin{document}

\title{Programming with dependent types }
\author{Wouter Swierstra}

\affiliation{
  \institution{Universiteit Utrecht}
  \country{The Netherlands}
}
\email{w.s.swierstra@@uu.nl}
\maketitle


Computer programs manipulate data. This data comes in many different
shapes and sizes: the telephone numbers stored in our smartphone; the
salary calculations done in Excel spreadsheets; or the customer
addresses stored in a database. Many modern programming languages use
a \emph{type system} to classify data and rule out nonsensical
calculations. For instance, multiplying a customer's telephone number
and address is a nonsensical calculation. A (static) type system rules
out such calculations before a program is run. Indeed, Simon Peyton
Jones famously described static type systems as ``\emph{the world's most
successful formal method.}''

Yet not all developers are enamored of statically typed
languages. Some of the most common points of critique include:
\begin{itemize}
\item Simply typed languages can only prevent simple errors, such as
  mixing up the order of arguments passed to a method. In reality,
  programs are full of rich properties that cannot be enforced effectively
  by a type system.
\item Requiring a program to be type correct before it can be executed
  bogs down the development process. Programmers should not spend
  their time writing code, rather than fixing type errors. Static
  types may help ensure safety, but makes programs harder to write.
\item Not all type information may be known when a program is first
  written. Code that needs to interface with a database or other
  external data source may not know the type of all data involved
  before its execution. Similarly, some methods---such as
  \texttt{printf} or those using C's \texttt{varargs}---are
  notoriously difficult to type statically.
\end{itemize}
This note aims to illustrate how some of these limitations may be
tackled by embracing \emph{programming languages with dependent
  types}. In particular, it aims to show how current research on such
languages provides a novel perspective on the benefits of statically
typed programming and formal methods in general.

\subsection*{Types are not expressive}

There is a deep connection between types and mathematical logic known
as the \emph{Curry-Howard
  correspondence}~\cite{propositions-as-types}. Simply stated, this
correspondence states that every type system may be viewed as a
logic. Every type in this system corresponds to a unique logical
proposition; every program corresponds to a unique proof. To
illustrate this point, consider the rules for \emph{modus ponens} in logic and
the typing rule for function application:

%format ^^^ = "\quad"
\begin{center}
\begin{tabular}{cp{10mm}c}
\AxiomC{|p -> q|}
\AxiomC{|p|}
\BinaryInfC{|q|}
\DisplayProof
  &  
  &
\AxiomC{|f : a -> b|}
\AxiomC{|x : a|}
\BinaryInfC{|f(x) : b|}
\DisplayProof
\end{tabular}
\end{center}

\noindent These rules are strikingly similar! The Curry-Howard
correspondence shows how this is no coincidence---this similarity
extends to richer logics and languages.

A common complaint about statically typed languages is \emph{the lack
  of expressivity}, typically phrased in a sentence starting with
``static types cannot\ldots''---and such criticism is often correct for
the type systems used by many mainstream languages. The `logic'
underlying such type systems is an (embarrassingly unsound)
propositional logic in which you cannot express any interesting
properties. To say anything meaningful about the behaviour of
programs, we need \emph{quantifiers} in our logic.

Viewed through the Curry-Howard lens, adding quantifiers our logic
amounts to shifting from a simply typed programming language to one
with \emph{dependent types}. Per Martin-L\"of was one of the first to
propose a single dependently typed language to model proof and
computation~\cite{pml}.  Dependent types are the foundations on which
modern interactive proof assistants, such as Coq and Lean, are built.
To illustrate the importance of quantification, consider the following
three type signatures:
%format exists = "\exists"
%format forall = "\forall\!"
%format . = "."
%format f1 = f "_1"
%format f2 = f "_2"
%format f3\ = f "_3"
\begin{code}
f1 :  List Int -> List Int
f2 :  forall a . Order a -> List a -> List a
f3 :  forall a . Order a -> (xs : List a) -> exists ys : List a, Sorted xs ys
\end{code}
Judging from its type, first function could do anything from reversing
the list to incrementing every element. The type associated with |f2|
is much more restrictive: the parametric polymorphism---induced by the
universal quantifier---ensures that any elements in the output list
must also occur in the input~\cite{free}. Crucially, such
quantification is restricted to \emph{types} in most languages. In
contrast, the last type signature uses a \emph{dependent type} to
specify exactly that the list returned must be the sorted permutation
of the input list |xs|.

Of course, \emph{sorting} has a clear specification, that may be
lacking in real world\todo{don't say real world} code. Nonetheless,
such code is typically full of invariants, many of which cannot be
expressed in a simple type system. Instead of abandoning static typing
altogether, it might be better to explore languages where these
invariants can be described. This offer programmers a spectrum of
correctness: from basic code hygine to full blown mechanised proofs of
functional correctness.

\subsection*{``Computer says know''}

A common perspective on static types states that the type-correct
programs are only a subset of all meaningful programs. A static type
system polices the development process, slapping the wrist of any
careless developer that dares adventure outside the subset of programs
considered valid.

Personally, I prefer a slightly different perspective. Humans do not
produce software by writing random strings and subsequently checking
which ones happen to correspond to well-typed programs. Instead,
software design is an intellectual activity. Consider the work by
Felleisen How To Design Programs, one of the few methodological
approaches to program development. We study a problem and break it
into subproblems. We figure out the inputs and outputs of our
functions. We write example inputs and outputs, and turn these into
tests. Only then we start to code.

Types fit naturally in this philosophy. Viewing types as a partial
specification; showing that the types of a large system fit together
is a proof that the system satisfies its specification.

By writing types, the code follows naturally. IDEs with Intellisense
use static type information to suggest how to complete a definition. 
Programmers who have worked with systems such as Agda and Idris, will
acknowledge that most of the thought is in the design of the types;
once these are known, the program writes itself (with a little help
from the IDE).

Going even further, dataype generic programming shows how we can
generate new functions from the structure of our data types.

The purpose of a static type system is not \emph{only} to rule out bad
programs (`computer says no'); a type provides information about the
values that inhabit it (`computer says know'). 
There is more to types than \emph{no-ing} bad programs; \emph{knowing}
the types provide a valuable clue to a programs development. As Conor
McBride put it: ``\emph{is a type a lifebuoy or a lamp}?''

\subsection*{Just-in-time static typing}

What if not all my types are known statically? One of the key rules in
a dependently typed programming language is the \emph{conversion rule}:
%{
%format vdash = "\vdash"
%format sigma = "\sigma"
%format tau = "\tau"
%format Gamma = "\Gamma"
%format betaeq = "\equiv _{\beta}"
\begin{center}
\AxiomC{|Gamma vdash t : sigma|}
\AxiomC{|sigma betaeq tau|}  
\BinaryInfC{|Gamma vdash t : tau|}
\DisplayProof
\end{center}
%}
This rule states that types are interchangeable up to evaluation.

As a result, we can \emph{compute} new types once we know \emph{some}
arguments. A common example is typing |printf| in this style:

But this is not the only such situation. For example, when interfacing
with an unknown database, we might ask for a description of certain
tables, parse the response, and compute the corresponding types.

Languages like F\# have shown how type providers---facilitating the
computation of new types from data---are very useful.  Dependently
typed languages take this one step further.

\subsection*{Looking ahead}

Despite these advantages, there is still much research and development
necessary before dependently typed languages can expect widespread adoption.

High barrier to entry -- better type error messages, training material, etc.

Implementation quirks, unexplored design space, bells and whistles of Coq

Robust implementations, great IDEs, not always appreciated as novel
research contributions; efficient compilation; integration with
existing languages.

Not a silver bullet; still need testing; still immature in many
respects; but an interesting idea that deserves further research.

\bibliography{wouter}

\end{document}

%%% Local Variables:
%%% mode: latex
%%% TeX-master: t
%%% TeX-command-default: "lhs2pdf"
%%% End: 


