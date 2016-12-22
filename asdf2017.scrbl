#lang scribble/sigplan @nocopyright @preprint
@;-*- Scheme -*-

@(require scribble/base
          scriblib/autobib scriblib/footnote
          scribble/decode scribble/core scribble/manual-struct scribble/decode-struct
          scribble/html-properties scribble/tag
          (only-in scribble/core style)
          "utils.rkt" "bibliography.scrbl")

@authorinfo["Robert P. Goldman" "SIFT" "rpgoldman@sift.info"]
@authorinfo["Elias Pipping" "FU Berlin" "elias.pipping@fu-berlin.de"]
@authorinfo["François-René Rideau" "TUNES" "fare@tunes.org"]

@conferenceinfo["ELS 2017" "April 3--4, Brussel, Belgium."]
@copyrightyear{2017}

@title{Demonstration: Building Portable Common Lisp Applications with @(ASDF3.3)}

@abstract{
@(ASDF), the @(de_facto) standard build system for @(CL),
has markedly improved over the years,
in features as well as robustness and portability.
We present a few notable improvements since we last reported on it in 2014:
enhanced mechanisms for single-file delivery of applications;
a reasonably portable @tt{launch-program} layer for asynchronous subprocesses;
a correct incremental build in presence of @(ASDF) extensions,
now with proper phase separation;
enhancements with configuration for source location.
These improvements make @(CL) a better platform for
writing and delivering applications as well as "scripts".
}

@category["D.2.3" "Software Engineering"]{Coding Tools and Techniques}

@keywords{
ASDF,
Build System,
Common Lisp,
Portability,
Application Delivery
}

@section{Introduction}

@hyperlink["https://common-lisp.net/"]{Common Lisp}, @; XXX @~cite[CLHS]
a general-purpose programming language with a
@hyperlink["https://www.dreamsongs.com/Files/Incommensurability.pdf"]{systems paradigm},
@; XXX @~cite[Incommensurability],
has more than ten actively used implementations
on Linux, Windows, macOS, and more.
@hyperlink["https://common-lisp.net/project/asdf/"]{@(ASDF)},
the @(de_facto) standard build system for @(CL),
has matured from a wildly successful experiment
to a universally used, robust, portable tool.
All the while it maintained backward compatibility through several generations of code,
from the original @(ASDF) written by Daniel Barlow in 2002 @; XXX @~cite[ASDF-Manual]
to the versions largely rewritten by François-René Rideau,
@(ASDF2) in 2010, @(ASDF3) in 2013, and now @(ASDF3.3) in 2017.
It is now provided as a loadable extension by all active implementations,
and is notably used by @hyperlink["https://quicklisp.org/"]{Quicklisp},
a growing collection of now over 1400 @(CL) libraries.
We present notable improvements
since we last published on @(ASDF) @~cite[Lisp-Acceptable-Scripting-Language],
beside addressing portability, bugs and bitrot.

@section{Application Delivery}

In 2005, Michael Goffioul implemented "bundle operations",
an extension to @(ASDF) on ECL to create static and dynamic
libraries and executables from Lisp systems.
In 2012, @(FRR) included it in @(ASDF3), and eventually made it
stable and robust across all active Lisp implementations and operating systems.
It is now possible to portably deliver software as a single-file:
as a combined source or compiled file to load into an existing Lisp image,
as an image to serve as the basis for further development,
or as a standalone application.

Since 2015, cffi-toolchain, distributed as part of the de facto standard
C foreign function interface layer
@hyperlink["https://common-lisp.net/project/cffi/"]{CFFI},
further extends @(ASDF3.1) with
the ability to portably deliver applications as a single-file that
contains arbitrary C code and libraries statically-linked into an executable;
it currently only works on three software implementations:
CLISP, CMUCL and SBCL.
Previously this was only practically possible to do with ECL and MKCL,
using the standard @(ASDF3) bundle operations.
Unfortunately, the popular implementation SBCL
currently requires a simple patch.

Loading a Lisp application from source, or even from compiled files,
can take almost a second, or even a few seconds, depending on
the size of the application.
This delay is fine at the start of an interactive development session, but
is unacceptable for many applications accessed at the shell command-line.
For these applications, @(ASDF3) can deliver a standalone executable
that will acceptably start in ten or twenty milliseconds.
However, such executables may take tens to hundreds of megabytes on disk and in memory;
this size overhead is not much by modern standards when a single application runs,
but the size overhead can be prohibitive when deploying a large number
of small scripts and utilities.
This issue can be addressed by delivering a "multicall binary"
à la @hyperlink["https://busybox.net/"]{Busybox};
Zach Beane's @hyperlink["http://www.xach.com/lisp/buildapp/"]{@tt{buildapp}}
provided this capability since 2010 on SBCL,
and more recently CCL;
since 2015, the same capability is available on all implementations,
as it was added to @hyperlink["http://www.cliki.net/cl-launch"]{@tt{cl-launch}},
a portable interface between the Unix shell and @(CL) software.
@; Moreover, libraries now exist to help write Lisp utilities that are callable and
@; usable at the shell command-line as well as at the @(CL) command-line.


@section{Subprocess Management}

@(ASDF1) copied over from its predecessor @(mk-defsystem) @~cite[MK-DEFSYSTEM]
the function @(run-shell-command), that
could synchronously execute commands in a subprocess.
However the function was not very portable;
it could not capture the output (and actually polluted it);
it did not handle quoting well and instead was encouraging brittle code;
it did not work on Windows.

@(ASDF3) offered a new function @(run-program)
as part of its portability library @(UIOP).
The new function fixes all the issues with @(run-shell-command),
and by @(ASDF3.1) it has become a full-fledged portable interface
to synchronously execute commands in subprocesses.
It handles redirection and transformation of input, output and error-output,
error status, etc.
Now in 2016, @(EP) refactored and extended the underlying logic
so that @(ASDF3.2) now exposes to the user
the spawning of asynchronous processes and basic interaction with them,
on those implementations and platforms that offer the capability.
Newly added functions in this context include
@(launch-program), @(wait-process), and @(terminate-process).

With @(run-program) and now @(launch-program),
@(CL) can be used to portably write all kind of programs for which
one would previously use a shell script, except in a much more robust way,
with rich data structures instead of a stringly-typed language,
and higher-order functions and restartable error conditions
instead of the very poor control structures of shell scripting
and other scripting languages
@~cite[Lisp-Acceptable-Scripting-Language] @~cite[CL-Scripting-2015].

@hyperlink["https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/README.md"]{@(UIOP)}
abstracts away the differences
between implementations and between operating systems
while providing a lot of basic functionality,
notably in accessing the filesystem, etc.
It fully replaces many previous less portable or less robust libraries.
However, it is constrained by the requirement that it is pure Lisp code
using interfaces provided by the underlying implementations;
it notably doesn't require the availability of a C compiler.
Therefore, for full coverage of the capabilities offered by operating systems,
it is better to use a library such as
@hyperlink["https://common-lisp.net/project/osicat/"]{@tt{osicat}} or
@hyperlink["https://common-lisp.net/project/iolib/"]{@tt{IOLib}},
that will provide full access to the underlying operating system interfaces
by invoking a C compiler or by linking C libraries via the @tt{CFFI} library.
The previously discussed improvements in application delivery
make that option acceptable in many cases that it once wasn't.


@section{Build Model Correctness}

The original @(ASDF1) introduced a simple and elegant "plan then execute" model
for building software. It also introduced a simple and elegant extensible
object model for extending the build model to support more than just
compiling simple Lisp files (such as CFFI to compile C extensions).
However, these two features were at odds with one another: to load a program
that uses an extension, one would first use @(ASDF) to plan and execute
loading the extension, then one could plan and execute loading
the target program, in two separate phases of planning and execution.
And of course, there could be more than just two phases, and there could also
be libraries that would be used in several phases.

In practice, this simple approach was effective in building
software from scratch, though not necessarily as efficient as possible
since libraries could sometimes unnecessarily
be compiled or loaded more than once.
However, in the case of an incremental build, @(ASDF) would overlook that
a change in one phase could affect the build in a later phase,
and fail to invalidate and re-perform actions accordingly;
in particular, it would not reload a system definition
when this definition itself depended on code that had changed.
It was then up to the user to diagnose the failure and
force a rebuild from scratch.

@(ASDF3.3) fixes this issue by supporting the notion of
a session within which code is built and loaded in several phases;
it tracks the status of traversed actions across phases of a session,
whereby an action can independently be
(1) considered up-to-date or not at the start of the session,
(2) considered done or not for the session,
and (3) considered needed or not during the session.
When it merely checks whether an action is still valid from previous sessions,
@(ASDF3.3) takes special care not to load system definitions
nor perform any other actions that are potentially
either out-of-date or not needed for the session;
there are therefore several variants of traversals for the action graph.

Note that the problem of dependency tracking in the presence
of build extensions is latent in every build system in every language.
Most build systems do not deal well with phase separation;
most that do are language-specific build systems (like @(ASDF)),
but only deal with staging macros or extensions inside the language,
not with building arbitrary code outside the language.
A notable exception is @hyperlink["https://bazel.io/"]{Bazel},
which has an extension language that allows it to build arbitrary languages
(including Lisp @~cite[Bazelisp-2016]), yet still properly handles
dependencies on build system extensions.

To fix the build model in @(ASDF3.3),
some internals were changed in backward-incompatible ways.
Libraries available on Quicklisp were inspected,
and their authors contacted if they were abusing those internals;
those libraries that are still maintained were fixed.


@section{Source Location Configuration}

In 2010, @(ASDF2) introduced a basic principle for all configuration:
@emph{allow each one to contribute what he knows when he knows it,
and do not require anyone to contribute what he does not know}
@~cite[Evolving-ASDF].
In particular, everything should "just work" by default for end-users,
without any need for configuration:
configuration is possible, but is only for power users
and system administrators to specify how their setup differs.

@(ASDF3.1), now distributed with all active implementations,
includes @tt{~/common-lisp/} as well as @tt{~/.local/share/common-lisp/}
in its source-registry by default, so that there is always an obvious place
in which to drop source code so that it will be found by @(ASDF),
whether you want it to be visible to the end-user or not.

@(ASDF2) also heeds the
@hyperlink["https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html"]{XDG}
@; XXX cite? XDG Base Directory Specification, 2010
environment variables to locate its configuration.
Since 2015, @(ASDF) exposes a configuration interface to users
so all Lisp programs may use them and allow users to use the standard
XDG mechanism to redirect where Lisp programs find their configuration.
This mechanism works on Windows as well as on Unix,
though it is less colloquial on Windows.

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
Thus, @(ASDF) can get scanning results at startup in milliseconds
for power users who use this pre-scanning script;
the price they pay is having to re-run this script (or manually edit the file)
whenever they install new software or remove old software.
This is remindful of the bad old days before @(ASDF2),
when power users each had to write their own script to do something equivalent
to manage "link farms", directories full of symlinks to @tt{.asd} files.
But at least, there is now a standardized script for power users to do that,
whereas things just work without any such trouble for normal users.


@section{Conclusion and Future Work}

We have demonstrated how @(ASDF) can be used to
portably and robustly deliver software written in @(CL),
as an alternative to both "scripting" and "programming" languages.
While our implementation is specific to @(CL),
many of the same ideas could be applied to
other programming languages, to extend their ability to deliver
both applications and "scripts".

In the future, there are many features we might want to add,
in dimensions where @(ASDF) lags behind other build systems such as Bazel:
support for cross-compilation to other platforms,
reproducible distributed builds,
building software written in languages other than @(CL),
integration with non-Lisp build systems, etc.

@; Our code is at:
@; @hyperlink["https://common-lisp.net/project/asdf"]{@tt{https://common-lisp.net/project/asdf/}}

@(generate-bib)
