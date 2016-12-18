#lang scribble/sigplan @nocopyright @preprint
@;-*- Scheme -*-

@(require scribble/base
          scriblib/autobib scriblib/footnote
          scribble/decode scribble/core scribble/manual-struct scribble/decode-struct
          scribble/html-properties scribble/tag
          (only-in scribble/core style)
          "utils.rkt" "bibliography.scrbl")

@authorinfo["Robert P. Goldman" "SIFT" "rpgoldman@sift.info"]
@authorinfo["Elias Pipping" "FU Berlin" "pipping.elias@icloud.com"]
@authorinfo["François-René Rideau" "TUNES" "fare@tunes.org"]

@conferenceinfo["ELS 2017" "April 3--4, Brussel, Belgium."]
@copyrightyear{2017}

@title{Demonstration: Building Portable Common Lisp Applications with @(ASDF3.3)}

@abstract{
@(ASDF), the @(de_facto) standard build system for @(CL),
has notably improved over the years.
Since we last reported on it in 2014, it has seen many improvements
in robustness and portability, notably:
enhanced mechanisms for single-file delivery of applications;
a reasonably portable @tt{launch-program} layer for asynchronous subprocesses
under its ubiquitously portable synchronous @tt{run-program};
a correct incremental build
in presence of @(ASDF) extensions loaded by @(ASDF) itself,
with now properly supported phase separation;
enhancements with configuration.
}

@(define (sf . str) (make-element 'sf (decode-content str)))

@category["D.2.3" "Software Engineering"]{Coding Tools and Techniques}

@keywords{
ASDF,
Build System,
Common Lisp,
Portability,
Application Delivery
}

@section{Introduction}

Common Lisp, a general-purpose programming language
with a systems paradigm @~cite[Incommensurability],
has more than ten actively used implementations
on Linux, Windows, macOS, and more.
@(ASDF), the @(de_facto) standard build system for @(CL),
has matured from a widely successful experiment in 2002,
to a universally used robust portable tool,
while maintaining backward compatibility through several generations of code,
from the original @(ASDF) in 2002 to @(ASDF2) in 2010, @(ASDF3) in 2013,
and now @(ASDF3.3) in 2017.
It is provided as a loadable extension by all active implementations,
and is notably used by Quicklisp @~cite[quicklisp],
a growing collection of now over 1400 @(CL) libraries.
We will present notable improvements
since we last published on @(ASDF) @~cite[Lisp-Acceptable-Scripting-Language],
beside general robustness and portability fixes and addressing bitrot.

@section{Application Delivery}

Michael Goffioul in 2005 implemented "bundle operations" as
an extension to @(ASDF) on ECL to create static and dynamic
libraries and executables from Lisp systems.
In 2012, @(FRR) ported it to other Lisp implementations
then made part of @(ASDF3).
This functionality has since received a lot of attention
to make it stable and robust across Lisp implementations and Operating Systems.
Therefore, it is now possible on all implementations to create
a single-file deliverable for your library or your application,
either as a combined FASL file (compiler output)
to load into an existing Lisp implementation,
or as an executable image that either
can serve as the basis for further development
or can be a standalone application.
Where portability is paramount, you can even deliver all your code
as a single concatenated source file.

Since 2015, @tt{cffi-toolchain}, distributed as part of the de facto standard
C foreign function interface layer CFFI, further extends @(ASDF3.1) with
the ability to portably deliver applications as a single-file that
contains arbitrary C code and libraries statically-linked into an executable;
it currently only works on three software implementations: CLISP, CMUCL and SBCL.
Previously this was only practically possible to do with ECL and MKCL,
using the standard @(ASDF3) bundle operations.
Unhappily, the popular implementation SBCL currently requires a simple patch
to support statically-linked libraries.

Loading a Lisp application from source, or even from compiled files,
can take almost a second, or even a few seconds, depending on
the size of the application.
This is fine at the start of an interactive session,
but can be unacceptable when delivering an application
to be accessed at the shell command-line.
A Lisp application delivered as a standalone executable using @(ASDF3)
can start in ten or twenty milliseconds which makes it acceptable
for interactive use at the shell command-line; but it has a size overhead of
tens or hundreds of megabytes on disk and in memory,
which is totally acceptable for most applications, but not for delivering
lots of small scripts and utilities.
To bridge this gap, Zach Beane's @tt{buildapp} has been able to deliver
"multicall binaries" à la Busybox since 2010 on SBCL (and now CCL);
since 2015, @tt{cl-launch},
the portable interface between the Unix shell and @(CL) software
can now do the same on all implementations @~cite[CL-Scripting-2015].
Libraries now also exist to help write Lisp utilities that are callable and
usable at the shell command-line as well as at the @(CL) command-line.


@section{Subprocess Management}

@(ASDF1) copied over the function @(run-shell-command)
from @(mk-defsystem) @~cite[MK-DEFSYSTEM], that
allowed to synchronously execute commands in a subprocess.
However the function was not very portable;
it couldn't capture the output (and actually polluted it);
it didn't handle quoting well and instead was encouraging brittle code;
it didn't work on Windows.

@(ASDF3) offered a new function @(run-program)
as part of its portability library @(UIOP).
The new function fixed all the above issues with @(run-shell-command),
and by @(ASDF3.1) it has become a full-fledged portable interface
to synchronously executing subprocesses;
it handles redirection and transformation of input, output and error-output,
error status, etc.
Now in 2016, Elias Pipping carved a function @(launch-program) into @(ASDF) 3.2,
which offers a portable interface to asynchronous execution of subprocesses
on the implementations that allow it at all.

With @(run-program) and now @(launch-program),
@(CL) can be used to portably write all kind of programs for which
one would previously use a shell script, except in a much more robust way,
with rich data structures instead of a stringly-typed language,
and higher-order functions and restartable error conditions
instead of the very poor control structures of shell scripting
and other scripting languages
@~cite[Lisp-Acceptable-Scripting-Language] @~cite[CL-Scripting-2015].

@(UIOP) abstracts away the differences between
implementations and between operating systems
while providing a lot of basic functionality,
notably in accessing the filesystem, etc.
It fully replaces many previous less portable or less robust libraries.
However, it is constrained by the requirement that it is pure Lisp code
using interfaces provided by the implementations out of the box;
it notably doesn't require the availability of a C compiler.
Therefore, for full coverage of the capabilities offered by operating systems,
it is better to use a library such as @tt{osicat} or @tt{IOLib},
that will provide full access to the underlying operating system interfaces
by invoking a C compiler or by linking C libraries via the @tt{CFFI} library.
The previously discussed improvements in application delivery
make that option acceptable in many cases that it once wasn't.


@section{Build Model Correctness}

The original @(ASDF1) introduced a simple and elegant "plan then execute" model
for building software. It also introduced a simple and elegant extensible
object model for extending the build model to support more than just
compiling simple Lisp files (such as CFFI to compile C extensions).
However, these two features were at odds: because to load a program
that uses an extension, you would first use @(ASDF) to plan and execute
the loading of the extension, then you could plan and load the loading
of the target program, in two separate phases of planning and execution.
And of course, there could be more than just two phases, and there could also
be libraries used in several phases.

In practice, things worked well enough when building a program from scratch,
except for some libraries sometimes being compiled or loaded multiple times.
But if you tried an incremental build, @(ASDF) could sometimes overlook how
a change in one phase could affect the build in a latter phase, and fail to
invalidate and recompile actions of the latter phase.
Users had to notice that the build was wrong and
to manually force a rebuild from scratch.

@(ASDF3.3) fixes this issue by properly supporting the notion of
a session within which code is built and loaded in several phases;
it will maintain a status for traversed actions across phases of a session,
whereby an action can independently be
(1) kept from a previous session or invalid at the start of the session,
(2) done or not done for the session,
and (3) needed or not needed during the session.
While merely checking whether an action is still valid from previous sessions,
special care is taken not to effect build side-effect of potentially
either out-of-date or not needed for the session;
there are therefore several variants of traversals for the action graph.

Note that the problem of correctly tracking dependencies in presence
of build extensions is a problem that people have in every build system
in every language. Most build systems do not deal well with phase separation,
and most that do are, like @(ASDF), language-specific build systems
that only deal with macros inside the language but not with
allowing building arbitrary code outside the language.
A notable exception is Bazel, that has an extension language
that allows it to build for arbitrary languages
(including Lisp @~cite[Bazelisp-2016]), and properly handles
dependencies on build system extensions.
@; Citation needed?

@(ASDF3.3) also includes some backward-incompatible changes to internals,
that were necessary to clean up the build model.
Authors of free software libraries available on Quicklisp were contacted
if they were abusing those internals;
and those who still maintain them fixed them.
But if anyone has proprietary software that directly accesses @(ASDF) internals
they will have to feel the pain and fix any breakage by themselves.


@section{Source Location Configuration}

In 2010, @(ASDF2) introduced a basic Principle for all configuration:
@emph{allow each one to contribute what he knows when he knows it,
and do not require anyone to contribute what he doesn't know}
@~cite[Evolving-ASDF].
In particular, everything should "just work" by default for end-users,
without any need for configuration:
configuration is possible, but is only for power users
and system administrators to specify how their setup differs.

@(ASDF3.1), now distributed with all active implementations,
includes @tt{~/common-lisp/} as well as @tt{~/.local/share/common-lisp/}
in its source-registry, so that there is always an obvious place in which
to drop source code so that it will be found by @(ASDF),
whether you want it to be visible to the end-user or not.

@(ASDF2) also heeds the XDG environment variables to locate its configuration.
Since 2015, @(ASDF) exposes a configuration interface to users
so all Lisp programs may use them and allow users to use the standard
XDG mechanism to redirect where Lisp programs find their configuration.
This mechanism works on Windows as well as on Unix,
though it is less colloquial on Windows.

Finally, a concern for users with a large number of systems available as source
code was that @(ASDF) could spend several seconds the first time you used it
just to recursively scan filesystem trees in the source-registry
for @tt{.asd} files. Since 2014, @(ASDF) provides a script
@tt{tools/cl-source-registry-cache.lisp} that will scan a tree in advance
and create a file @tt{.cl-source-registry.cache} with the results, that
@(ASDF) will consult. Thus, power-users can have @(ASDF) have the scanning
results at startup in milliseconds; the price they pay is having to re-run
the scanning script whenever they install new software or remove old software
(or edit the file), just like they had to in the bad old days of @(ASDF1),
when power users each had to write their own script to do something equivalent.
But at least, there is now a standardized script for power users to do it,
whereas things just work without such trouble for normal users.


@section{Conclusion and Future Work}

We have demonstrated how @(ASDF) can be used to
portably and robustly deliver software written in @(CL),
as an alternative to both "scripting" and "programming" languages.
Some of the lessons learned could be applied to other programming languages beside @(CL).

In the future, there are many features we might want to add,
in dimensions where @(ASDF) lags behind other build systems
such as Bazel @~cite[Bazelisp-2016]:
support for cross-compilation to other platforms,
reproducible distributed builds,
building software written in other languages than @(CL),
integration with non-Lisp build systems, etc.

@; Our code is at:
@; @hyperlink["https://common-lisp.net/project/asdf"]{@tt{https://common-lisp.net/project/asdf/}}

@(generate-bib)
