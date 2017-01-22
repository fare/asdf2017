#lang at-exp scribble/acmart @[#:format 'sigplan #:authorversion #t]
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
  Application Delivery
}

@title{Building Portable Common Lisp Applications with @(ASDF3.3)}

@abstract{
@(ASDF), the @(de_facto) standard build system for @(CommonLisp) (CL),
has markedly improved over the years,
in features as well as robustness and portability.
We present a few notable improvements since we last reported on it in 2014:
enhanced mechanisms for delivering an application as a single file;
a @tt{launch-program} feature for managing asynchronous subprocesses;
correct incremental builds when @(ASDF) extensions are updated,
with proper phase separation; and
enhancements to the configuration process for source location.
These improvements make @(CL) a better platform not simply for
writing and delivering applications but also
for use in scripting other applications.
}

@rpg{
  I don't think the abstract here really makes an argument.  We enumerate
  a list of 4 improvements and claim that some subset of these improvements
  provides 2 benefits:
  (1) general ASDF goodness, and (2) scripting.  But we leave it
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

The general-purpose programming language
@hyperlink["https://common-lisp.net/"]{Common Lisp} (CL) @; XXX @~cite[CLHS]
@; with a @hyperlink["https://www.dreamsongs.com/Files/Incommensurability.pdf"]{systems paradigm},
@; XXX @~cite[Incommensurability],
has over ten actively used implementations
on Linux, Windows, macOS, etc.
@hyperlink["https://common-lisp.net/project/asdf/"]{@(ASDF)},
the @(de_facto) standard build system for @(CL),
has matured from a wildly successful experiment
to a universally used, robust, portable tool.
While doing so, @(ASDF) has
maintained backward compatibility through several major revisions,
from the original @(ASDF) written by Daniel Barlow in 2002 @; XXX @~cite[ASDF-Manual]
to the versions largely rewritten by François-René Rideau,
@(ASDF2) in 2010, @(ASDF3) in 2013, and now @(ASDF3.3) in 2017.
@(ASDF) is now provided as a loadable extension by all actively maintained CL implementations.
@(ASDF) also provides the system loading infrastructure for 
@hyperlink["https://quicklisp.org/"]{Quicklisp},
a growing collection of now over 1,400 @(CL) libraries.
@rpg{Fix the following: ungrammatical.}
We present notable improvements
since we last published on @(ASDF) @~cite[Lisp-Acceptable-Scripting-Language],
beside addressing portability, bugs and bitrot.

@section{Application Delivery}

Versions 3.2 and 3.3 of @(ASDF) add new facilities for delivering CL
applications.  The initial impetus for adding these features was to
support Embeddable Common Lisp (ECL), an implementation in which CL code may
be translated into C and then compiled.  To support ECL, @(ASDF) added
@emph{bundle operations}, which were later generalized to other CL implementations.
ASDF now supports a wide variety of system delivery options.  Working with
the portable foreign function interface CFFI, @(ASDF) can also bundle libraries
and foreign code with a CL application.  Finally, @(ASDF) has been enhanced to
support rapid application start up.

In 2005, Michael Goffioul implemented bundle operations,
an extension to @(ASDF) on ECL.
Using these bundle operations, @(ASDF) was enabled
to create static and dynamic
libraries and executables from Lisp systems.
In 2012, @(FRR) ported bundle operations to other lisp implementations, and
incorporated it into @(ASDF3).
Bundle operations are now
stable and robust across all active CL implementations and operating systems.
@(ASDF) can now portably deliver software systems as single, bundled files.
Bundled systems can be delivered in a number of different ways:
(1) as a single source file, containing the combined source code for the system and its dependencies;
(2) as a single FASL file;
(3) as a saved lisp image; 
or (4) as a standalone application.

More recently, we have extended @(ASDF)'s bundle operations to handle systems that
incorporate C code and libraries.
To do so, we have built on cffi-toolchain, a part of the @(de_facto) standard
foreign function interface @hyperlink["https://common-lisp.net/project/cffi/"]{CFFI}.
Now ASDF can portably deliver applications as a single executable file
with arbitrary C code and libraries statically linked.
As of 2017, bundling with C code works on three implementations:
Gnu CLISP, ECL, and Steel Bank Common Lisp (SBCL).

@rpg{The following needs to be rewritten to be stand-alone.  Right now, if the reader
isn't familiar with busybox, they will have no idea what we are talking about.}

Loading a large Lisp application, from source or from compiled files,
can take multiple seconds.
This delay is fine at the start of a development session, but
can be unacceptable for interactive use at the shell command-line.
@(ASDF3) can reduce this latency by delivering a standalone executable
that can start in twenty milliseconds.
However such executables occupy tens or hundreds of megabytes
on disk and in memory.
This size overhead is not much by current standards
when a single application runs on a computer;
but it can be prohibitive when deploying a large number
of small scripts and utilities.
A solution is to deliver a "multicall binary"
à la @hyperlink["https://busybox.net/"]{Busybox};
Zach Beane's @hyperlink["http://www.xach.com/lisp/buildapp/"]{@tt{buildapp}}
could do it since 2010, but only worked on SBCL, and more recently CCL;
since 2015, @hyperlink["http://www.cliki.net/cl-launch"]{@tt{cl-launch}},
a portable interface between the Unix shell and all @(CL) implementations,
also adopted the same capability.
@; Moreover, libraries now exist to help write Lisp utilities that are callable and
@; usable at the shell command-line as well as at the @(CL) command-line.

@section{UIOP}

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

@section{Subprocess Management}

@(ASDF) has always supported the ability to run programs.  Originally, this was
done by means of an @italic{ad hoc} @(run-shell-command) function.  Later, as we needed more
functionality and supported more implementations and operating systems, @(run-shell-command)
was replaced by @(run-program), which provides finer-grained control over program
inputs and outputs.  @(ASDF3.2) introduced support for asynchronously running programs
using a new @(launch-program) API function, and extensive refactoring and debugging.

@rpg{The use of the term "polluted" in the following isn't at all clear.
I @emph{think} what is meant is that somehow @(run-shell-command) could introduce
spurious output into the shell process's output.  Is that it?  If so, we should say so.
Also, there's no obvious connection between (1) not handling quoting and (2) encouraging
brittle code, so what does that "instead was" mean?}

@(ASDF1) copied over from its predecessor @(mk-defsystem) @~cite[MK-DEFSYSTEM]
the function @(run-shell-command), that
could synchronously execute commands in a subprocess.
However the function was not very portable;
it could not capture the output (and actually polluted it);
it did not handle quoting well and instead was encouraging brittle code;
it did not work on Windows.

@(ASDF3) offered a new function, @(run-program),
as part of its portability library, @(UIOP).
The new function fixes all the issues with @(run-shell-command),
providing
a full-fledged portable interface
to synchronously execute commands in subprocesses.
@(run-program) handles redirection and transformation of input, output, and error-output,
exit status, etc.
The caller has the option to handle subprocess errors by means of exit codes,
or to have them transformed into CL conditions.

For @(ASDF3.2), @(EP) refactored and extended the logic of @(run-program).
Enabling programmers to spawn and control asynchronous processes
(on those implementations and platforms that offer this capability).
Newly added functions in this context include
@(launch-program), @(wait-process), and @(terminate-process).

With @(run-program) and now @(launch-program),
@(CL) can be used to portably write all kind of programs for which
one would previously have used a shell script, except in a much more robust way,
with rich data structures instead of a ``stringly-typed'' language,
and higher-order functions and restartable error conditions
instead of the very poor control structures of shells
and ``scripting'' languages
@~cite[Lisp-Acceptable-Scripting-Language] @~cite[CL-Scripting-2015].

@section{Build Model Correctness}

The original @(ASDF1) introduced
a simple ``plan then execute'' model for building software.
It also introduced an extensible class hierarchy
so ASDF could be extended in Lisp itself
to support more than just compiling Lisp files.
For example, @(ASDF) extensions for CFFI enable one to
compile code written in C as part of a CL application.

Unfortunately, 
these two features were at odds with one another:
to load a program that uses an @(ASDF) extension,
one would first use @(ASDF) to plan and execute loading the extension,
then one could plan and execute loading the target program,
in two separate phases of planning and execution.
And of course, there could be more than just two phases -- there could be @(ASDF)
extensions that required other extensions in order to load -- and
there could be libraries that would be used in several phases.

In practice, this simple approach was effective in building
software from scratch, though not necessarily as efficient as possible
since libraries could sometimes unnecessarily
be compiled or loaded more than once.
However, in the case of an incremental build, @(ASDF) would overlook that
a change in one phase could affect the build in a later phase,
and fail to invalidate and re-perform actions accordingly.
In particular, it would not reload a system definition
when this definition itself depended on code that had changed.
The user was then responsible for diagnosing the failure and
forcing a rebuild from scratch.

@(ASDF3.3) fixes this issue by supporting the notion of
a session within which code is built and loaded in multiple phases;
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

Note that the problem of dependency tracking in the presence of build extensions
is latent in every build system in every language.
Most build systems do not deal well with phase separation;
most that do are language-specific build systems (like @(ASDF)),
but only deal with staging macros or extensions inside the language,
not with building arbitrary code outside the language.
An interesting case is @hyperlink["https://bazel.build/"]{Bazel},
which does maintain a strict plan-then-build model
yet allows user-provided extensions
(e.g. to support Lisp @~cite[Bazelisp-2016]).
Its extensions, written in a safe restricted DSL,
@; running into plan phase only; (with two subphases, load and analysis)
are not themselves subject to extension using the build system.
@; (yet the DSL being a universal language, you could do it the hard way).

To fix the build model in @(ASDF3.3),
some internals were changed in ways that were not backward compatible.
Libraries available on Quicklisp were inspected,
and their authors contacted if they were (ab)using those internals;
those libraries that are still maintained were fixed.


@section{Source Location Configuration}

In 2010, @(ASDF2) introduced a basic principle for all configuration:
@emph{allow each one to contribute what he knows when he knows it,
and do not require anyone to contribute what he does not know}
@~cite[Evolving-ASDF].
In particular, everything should ``just work'' by default for end-users,
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
This mechanism works on macOS and Windows, as well as on Unix,
but required some interpretation on the part of the @(ASDF) maintainers:
the structure of the Mac filesystem does not agree with the proposed Linux
standard, although they share a common origin, and the Windows layout is
completely different.

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


@section{Conclusion and Future Work}

@rpg{revise...}

We have demonstrated how @(ASDF) can be used to
portably and robustly deliver software written in @(CL),
as an alternative to both ``scripting'' and ``programming'' languages.
While our implementation is specific to @(CL),
many of the same ideas could be applied to other languages,
to extend their ability to deliver both ``scripts'' and applications.

In the future, there are many features we might want to add,
in dimensions where @(ASDF) lags behind other build systems such as Bazel:
support for cross-compilation to other platforms,
reproducible distributed builds,
building software written in languages other than @(CL),
integration with non-Lisp build systems, etc.

@; Our code is at:
@; @hyperlink["https://common-lisp.net/project/asdf"]{@tt{https://common-lisp.net/project/asdf/}}

@(generate-bib)
