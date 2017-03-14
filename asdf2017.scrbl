#lang scribble/acmart @(format "sigplan") @authorversion
@;-*- Scheme -*-

@(require scribble/base
          scriblib/autobib scriblib/footnote
          scribble/decode scribble/core
          scribble/manual-struct scribble/decode-struct
          scribble/html-properties scribble/tag
          (only-in scribble/core style)
          "utils.rkt" "bibliography.scrbl")

@set-top-matter[#:printccs #t #:printacmref #f #:printfolios #f]
@authorinfo["Robert P. Goldman" "SIFT" "rpgoldman@sift.net"]
@authorinfo["Elias Pipping" "FU Berlin" "elias.pipping@fu-berlin.de"]
@authorinfo["François-René Rideau" "TUNES" "fare@tunes.org"]
@conferenceinfo[#:short-name "ELS 2017"
  "The 10th European Lisp Symposium" "April 3--4, 2017" "Brussel, Belgium"]
@copyright-year{2017}
@set-copyright{none}
@acm-doi{}
@ccsxml{
<ccs2012>
<concept>
<concept_id>10011007.10011006.10011073</concept_id>
<concept_desc>Software and its engineering~Software maintenance tools</concept_desc>
<concept_significance>300</concept_significance>
</concept>
</ccs2012>
}

@ccsdesc[300]{Software and its engineering~Software maintenance tools}

@keywords{
  ASDF,
  Build System,
  Common Lisp,
  Portability,
  Application Delivery,
  Demo
}

@title{Delivering Common Lisp Applications with @(ASDF3.3)}

@abstract{
@(ASDF) is the @(de_facto) standard build system for @(CommonLisp) (CL).
In this paper, we discuss the most important improvements
in @(ASDF) versions 3.2 and 3.3.
@(ASDF)'s ability to deliver applications as a single executable file
now allows the static linking of arbitrary code written in C.
We substantially improved @(ASDF)'s portability library @(UIOP),
so its interface to spawn and control external processes
now supports asynchronous processes.
@(ASDF) permits programmers to extend @(ASDF)'s build processes
in an object-oriented way;
until @(ASDF3.2), however, @(ASDF) did not correctly handle
updates to these extensions during incremental builds.
Fixing this involved managing the multiple phases in an @(ASDF) build session.
We also improved @(ASDF)'s source finding:
it provides more usable default behaviors without any configuration;
power users willing to manage its location caching can speed it up;
and it offers better compliance with standard configuration locations.
}

@elias{what does it mean for a build to be correct? it sounds odd. Do
we mean the dependency resolution? if so, can we just say that?} @;
@fare{See the corresponding section.
Before 3.3, a multiphase build may sometimes build too much
(which is a mere performance annoyance)
and sometimes it may build too little, which is very bad:
it can yield incorrect code, error when it should,
or fail to error when it should which can lead users
to unwittingly commit broken code -- we'd sometimes get bitten at ITA.} @;

@rpg{
  I don't think the abstract here really makes an argument.  We enumerate
  a list of 4 improvements and claim that some subset of these improvements
  provides 2 benefits:
  (1) general @(ASDF) goodness, and (2) scripting.  But we leave it
  entirely to the reader to guess the connections between improvements and
  benefits.  Another alternative would be to simply strike the discussion of
  scripting (defer to a different paper),
  since the title is all about delivering
  applications, and doesn't tell the reader we are concerned with scripting.
  Also, I think we need to do one of two things: either (1) agree that scripting
  is like pornography -- we don't have a definition,
  but we know it when we see it
  -- and not put in scare quotes every time we talk about scripting;
  or (2) decide
  that the notion of scripting is problematic, and provide our attempt at a
  definition.
  Right now it seems like we are saying
  "scripting is poorly defined, but we talk about it anyway."}

@fare{
  We have struggled hard to fit within 2 pages, but if you feel we have enough
  material to expand on the topic, we can aim for a longer article with the
  8-page limit. That said, there may or may not be other venues to discuss
  scripting. Actually, maybe we want to publish a separate article on the topic.
}

@fare{
  In any case, I believe I gave a reasonable characterization of scripting
  in my 2014 articles, as programming with low-overhead access to functionality
  from the rest of the system. Therefore,
  (1) being invocable as a script or a command by the rest of the world
      (with cl-launch),
  (2) being able to access the filesystem and invoke other command
      (with uiop and/or inferior-shell),
  (3) not having to explicitly deal with dependency location
      (with the source-registry), and
  (4) not having to explicitly deal with object file management
      (with the output-translations cache).
  Of course, the programming part itself entails a lot of
  (5) string manipulations (including with regexps)
      because the system functionality is exposed as strings.
}

@section{Introduction}

@hyperlink["https://common-lisp.net/"]{Common Lisp} (CL) @; XXX @~cite[CLHS]
is a general-purpose programming language
@; with a @hyperlink["https://www.dreamsongs.com/Files/Incommensurability.pdf"]{systems paradigm},
@; XXX @~cite[Incommensurability],
with over ten active implementations
on Linux, Windows, macOS, etc.
@hyperlink["https://common-lisp.net/project/asdf/"]{@(ASDF)},
the @(de_facto) standard build system for @(CL),
has matured from a wildly successful experiment
to a universally used, robust, portable tool.
While doing so, @(ASDF) has maintained backward compatibility
through many major changes,
from Daniel Barlow's original @(ASDF) in 2002
@; XXX @~cite[ASDF-Manual]
to François-René Rideau's largely rewritten versions,
@(ASDF2) in 2010, @(ASDF3) in 2013, and now @(ASDF3.3) in 2017.
@(ASDF) is provided as a loadable extension
by all actively maintained CL implementations;
it also serves as the system loading infrastructure for
@hyperlink["https://quicklisp.org/"]{Quicklisp},
a growing collection of now over 1,400 @(CL) libraries.
In this paper, we present some of the most notable improvements made to @(ASDF)
since we last reported on it @~cite[Lisp-Acceptable-Scripting-Language],
focusing on improvements to application delivery and subprocess management,
better handling of @(ASDF) extensions, and
source location configuration refinements.

@section{Application Delivery}

@rpg{
Version 3.2 of @(ASDF) added new facilities for delivering CL applications.
The initial impetus for adding these features was to
support Embeddable Common Lisp (ECL), an implementation in which CL code may
be translated into C and then compiled.
To support ECL, @(ASDF) added @emph{bundle operations},
which were later generalized to other CL implementations.
@(ASDF) now supports a wide variety of system delivery options.  Working with
the portable foreign function interface CFFI, @(ASDF) can also bundle libraries
and foreign code with a CL application.
Finally, @(ASDF) has been enhanced to support rapid application start up.
}

@fare{In 2005, Michael Goffioul wrote
an extension to @(ASDF) on ECL, @bydef{bundle operations},
to create static and dynamic libraries and executables from Lisp systems.
In 2012, @(FRR) ported this extension to other @(CL) implementations,
and incorporated it into @(ASDF3).}

@(ASDF3) introduced @bydef{bundle operations},
a portable way to deliver a software system
as a single, bundled file.
This single file can be either:
(1) a source file, concatenating all the source code;
(2) a FASL file, combining all compiled code;
(3) a saved image;
or (4) a standalone application.
In the first two cases, the programmer controls whether or not the bundle
includes with a system all the other systems it transitively depends on.

We made bundle operations stable and robust across
all active @(CL) implementations and operating systems.
We also extended these operations so that
@(ASDF3.2) supports single-file delivery
of applications that incorporate arbitrary C code and libraries.
This feature works in conjunction with CFFI-toolchain,
an extension which we added to the @(de_facto) standard
foreign function interface
@hyperlink["https://common-lisp.net/project/cffi/"]{CFFI}.
CFFI-toolchain statically links arbitrary C code into the Lisp runtime.
As of 2017, this feature works on three implementations:
CLISP, ECL, and SBCL.

Loading a large Lisp application, either from source or from compiled files,
can take several seconds.
@fare{This delay is acceptable at the start of a development session,
but not when invoking interactive programs at the shell command-line.} @;
@elias{what is meant by an instant program?} @;
@fare{programs that users expect to finish in a subjective instant;
say under 40ms including redrawing the prompt.} @;
This delay may be unacceptable in use cases such as small utility programs,
or filters in a Unix pipe chain.
@(ASDF3) can reduce this latency by delivering a standalone executable
that can start in tens of milliseconds.
However, such executables each occupy tens or hundreds of megabytes
on disk and in memory;
this size can be prohibitive when deploying a large number
of small utilities.
One solution is to deliver a ``multicall binary''
à la @hyperlink["https://busybox.net/"]{Busybox}:
a single binary includes several programs;
the binary can be symlinked or hardlinked with multiple names,
and will select which entry point to run based on the name used to invoke it@;
@annotation{; users may also explicitly specify which program to run}.
Zach Beane's @hyperlink["http://www.xach.com/lisp/buildapp/"]{@tt{buildapp}}
has supported such binaries since 2010,
but @tt{buildapp} only works on SBCL, and more recently CCL.
@hyperlink["http://www.cliki.net/cl-launch"]{@tt{cl-launch}},
a portable interface between the Unix shell and all @(CL) implementations,
also has supported multicall binaries since 2015.
@fare{
Moreover, libraries now exist to help write Lisp utilities
that are callable and usable at the shell command-line
as well as at the @(CL) command-line.
}

@annotation{@section{UIOP}}

@fare{
@hyperlink["https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/README.md"]{@(UIOP)}
provides a portability layer, abstracting
away the differences
between implementations and operating systems.
@(UIOP) provides
a lot of basic functionality,
in accessing the filesystem, managing differences in the way implementations
handle behaviors undefined by the ANSI specification, etc.
@(UIOP) fully replaces many less portable or less robust libraries.
@rpg{It would be good to give some examples here, such as CL-FAD,
trivial-xxx}.
@(UIOP) is constrained  by the requirement that it be pure Lisp code
using interfaces provided by the underlying implementations.
In particular, it cannot
require the availability of a C compiler.
}

@fare{
Because of this limitation, @(UIOP) does not
offer full coverage
of the capabilities offered by operating systems.
For additional capabilities,
one may use
@hyperlink["https://common-lisp.net/project/osicat/"]{@tt{osicat}} or
@hyperlink["https://common-lisp.net/project/iolib/"]{@tt{IOLib}}.
These are systems
that compile C code and/or link C libraries via the @tt{CFFI} library.
@; The previously discussed improvements in application delivery
@; make that option acceptable in many cases where it once was not.
}

@section{Subprocess Management}

@(ASDF) has always supported the ability to
synchronously execute commands in a subprocess.
Originally, @(ASDF1) copied over a function @(run-shell-command)
from its predecessor @(mk-defsystem) @~cite[MK-DEFSYSTEM];
but it could not reliably capture command output,
it had a baroque calling convention,
and was not portable (especially to Windows).
@(ASDF3) introduced the function @(run-program) that fixed all these issues,
as part of its portability library @(UIOP).
By @(ASDF3.1) @(run-program) provided a full-fledged portable interface
to synchronously execute commands in subprocesses:
users can redirect and transform input, output, and error-output;
by default, @(run-program) will throw @(CL) conditions when a command fails,
but users can tell it to @tt{:ignore-exit-status},
access and handle exit code themselves.

@(ASDF3.2) introduces support for asynchronously running programs,
using new functions @(launch-program), @(wait-process), and @(terminate-process).
These functions, available on capable implementations and platforms only,
were written by @(EP), who refactored, extended and exposed
logic previously used in the implementation of @(run-program).

@rpg{The use of the term "polluted" in the following isn't at all clear.
I @emph{think} what is meant is that somehow @(run-shell-command) could introduce
spurious output into the shell process's output.  Is that it?  If so, we should say so.
Also, there's no obvious connection between (1) not handling quoting and (2) encouraging
brittle code, so what does that "instead was" mean?}

@fare{
Yes: the old @(run-shell-command) would print the command to
@tt{*verbose-out*}, then execute the command,
redirecting its output also to @tt{*verbose-out*};
there was no way to capture the output without this pollution;
and on CLISP it wouldn't even capture the output.
As for not handling quoting, @(run-shell-command) uses @tt{cl:format}
and the standard usage pattern was to insert pathnames in commands using ~A,
which will be wrong in many, many ways as soon as characters are used
that need escaping from the shell. Even ~S only helps so much, since there
are many ways that shell and Lisp conventions differ regarding either
namestrings or quoting.
In an adversarial setting, this can be a huge security liability.
}

With @(run-program) and now @(launch-program),
@(CL) can be used to portably write all kind of programs
for which one might previously have used a shell script.
Except @(CL)'s rich data structures, higher-order functions,
sophisticated object system, restartable conditions and macros
beat the offering of its scripting alternatives
@~cite[Lisp-Acceptable-Scripting-Language] @~cite[CL-Scripting-2015].

@section{Build Model Correctness}

The original @(ASDF1) introduced
a simple ``plan-then-perform'' model for building software.
It also introduced an extensible class hierarchy
so @(ASDF) could be extended in Lisp itself
to support more than just compiling Lisp files.
For example, some extensions support interfacing with C code.

Unfortunately, these two features were at odds with one another:
to load a program that uses an @(ASDF) extension,
one would in a first phase use @(ASDF) to plan then perform loading the extension;
and one would in a second phase plan then perform loading the target program.
Of course, there could be more than just two phases:
some extensions could themselves require other extensions in order to load, etc.
Moreover, the same libraries could be used in several phases.

In practice, this simple approach was effective
in building software from scratch,
though not necessarily as efficient as possible
since libraries could sometimes unnecessarily
be compiled or loaded more than once.
However, in the case of an incremental build, @(ASDF) would overlook that
a change in one phase could affect the build in a later phase,
and fail to invalidate and re-perform actions accordingly.
Indeed it failed to even consider loading a system definition as an action
that may be invalidated and re-performed
when it depended on code that had changed.
The user was then responsible for diagnosing the failure and
forcing a rebuild from scratch.

@(ASDF3.3) fixes this issue by supporting the notion of
a session in which code is built and loaded in multiple phases.
It tracks the status of traversed actions across phases of a session,
whereby an action can independently be
(1) considered up-to-date or not at the start of the session,
(2) considered done or not for the session,
and (3) considered needed or not during the session.
When @(ASDF3.3) merely checks whether an action is still valid from previous sessions,
it uses a special traversal that carefully avoids either loading system definitions
or performing any other actions that are potentially
either out-of-date or unneeded for the session.

Build extensions are a common user need, though most build systems
fail to offer proper dependency tracking when they change.
Those build systems that do implement proper phase separation
to track these dependencies
are usually language-specific build systems (like @(ASDF)),
but most of them (unlike @(ASDF)) only deal with
staging macros or extensions inside the language,
not with building arbitrary code outside the language.
An interesting case is @hyperlink["https://bazel.build/"]{Bazel},
which does maintain a strict plan-then-perform model
yet allows user-provided extensions
(e.g. to support Lisp @~cite[Bazelisp-2016]).
However, its extensions, written in a safe restricted DSL,
@; running into plan phase only; (with two subphases, load and analysis)
are not themselves subject to extension using the build system.
@; (yet the DSL being a universal language, you could do it the hard way).

To fix the build model in @(ASDF3.3),
some internals were changed in backward-incompatible ways.
Libraries available on Quicklisp were inspected,
and their authors contacted if they were (ab)using those internals;
those libraries that are still maintained were fixed.


@section{Source Location Configuration}

In 2010, @(ASDF2) introduced a basic principle for all configuration:
@emph{allow each person to contribute what they know when they know it,
and do not require anyone to contribute what they do not know}
@~cite[Evolving-ASDF].
In particular, everything should ``just work'' by default for end-users,
without any need for configuration, but
configuration should be possible for ``power users'' and
unusual applications.

@(ASDF3.1), now offered by all active implementations,
includes @tt{~/common-lisp/} as well as @tt{~/.local/share/common-lisp/}
in its source registry by default;
there is thus always an obvious place in which to drop source code
such that @(ASDF) will find it:
under the former for code meant to be visible to end-users,
under the latter for code meant to be hidden from them.

@(ASDF2) and later consult the
@hyperlink["https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html"]{XDG Base Directory}
environment variables @~cite[XDG-2010] when locating its configuration.
Since 2015, @(ASDF) exposes a configuration interface
so all Lisp programs may similarly respect this Unix standard
for locating configuration files.
The mechanism is also made available on macOS and Windows,
though with @(ASDF)-specific interpretations of the standard:
XDG makes assumption about filesystem layout that
do not always have a direct equivalent on macOS, and even less so on Windows.

Finally, a concern for users
with a large number of systems available as source code
was that @(ASDF) could spend several seconds the first time you used it
just to recursively scan filesystem trees in the source-registry
for @tt{.asd} files ---
a consequence of how the decentralized @(ASDF) system namespace is
overly decoupled from any filesystem hierarchy.
Since 2014, @(ASDF) provides a script @tt{tools/cl-source-registry-cache.lisp}
that will scan a tree in advance
and create a file @tt{.cl-source-registry.cache} with the results,
that @(ASDF) will consult.
Power users who use this script can get scanning results at startup
in milliseconds;
the price they pay is having to re-run this script (or otherwise edit the file)
whenever they install new software or remove old software.
This is reminiscent of the bad old days before @(ASDF2),
when power users each had to write their own script to do something equivalent
to manage ``link farms'', directories full of symlinks to @tt{.asd} files.
But at least, there is now a standardized script for power users to do that,
whereas things just work without any such trouble for normal users.


@section{Conclusions and Future Work}

We have demonstrated improvements in how @(ASDF) can be used to
portably and robustly deliver software written in @(CL).
While the implementation is specific to @(CL),
many of the same techniques could be applied to other languages.

In the future, there are many features we might want to add,
in dimensions where @(ASDF) lags behind other build systems such as Bazel:
support for cross-compilation to other platforms,
reproducible distributed builds,
building software written in languages other than @(CL),
integration with non-Lisp build systems, etc.

@; Our code is at:
@; @hyperlink["https://common-lisp.net/project/asdf"]{@tt{https://common-lisp.net/project/asdf/}}

@(generate-bib)
