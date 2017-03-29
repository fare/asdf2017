#lang at-exp slideshow
#|
Delivering Common Lisp Applications with ASDF 3.3

Slides for presentation at ELS 2017 in Brussels, 2017-04-03

For development, try:
  slideshow --comment-on-slide els2017-slides.ss

NB: Quit with Alt-Q

On demo day, try:
  slideshow --preview --comment --monitor 1 els2017-slides.ss

Output slides for this document may be found at:
  http://fare.tunes.org/files/cs/els2017-slides.pdf

This document is available under the bugroff license.
  http://www.oocities.org/soho/cafe/5947/bugroff.html
|#

(require slideshow
         slideshow/code
         slideshow/code-pict
         slideshow/text
         scheme/gui/base
         slideshow/pict
         pict/color)

(set-margin! 0)

;;; Definitions

(define (color-named name) (send the-color-database find-color name))
(define *blue* (color-named "blue"))
(define *red* (color-named "red"))
(define ~ @t{     })
(define (title-style x) (text x (cons 'bold 'default) 34))
(define (url x) (colorize (tt x) *blue*))
(define (L . x) x)
(define (xlide #:title (title "") . body)
  (apply slide #:title (title-style title) body))
(define (C . x) (para #:align 'center x))
(define (CB . x) (C (apply bt x)))

(slide
 #:title "Delivering Common Lisp Applications with ASDF 3.3"
 @bt{Pushing the Envelope or Therapeutic Fury?}
 ~ ~ ~ ~
 @C{@t{François-René Rideau,} @it{TUNES Project}}
 @t{European Lisp Symposium, 2017-04-03}
 @url{http://github.com/fare/asdf2017/})

(xlide
 #:title "This Talk"
 @para{This Talk: A progress report on @it{ASDF},}
 @para{de facto standard build system for @it{Common Lisp},}
 @para{continued evolution in the tradition of @it{Lisp},}
 @para{a language discovered, not created, in @it{1958}.}
 @comment{Lispers are radical conservatives}
 ~
 @CB{Plan}
 @para{Some Background}
 @para{Recent ASDF Progress}
 @para{Lessons for build systems in any language}
 @para{What lies ahead (for (CL?) build systems)})

(xlide
 (title-style "Some Background"))

(xlide
 #:title "What makes ASDF different"
 @para{DEFSYSTEM: compile & load "systems" @it{in-image}}
 @para{C analogs: @tt{make}, @tt{ld.so}, @tt{pkg-config}, @tt{libc}}
 ~
 @para{Primarily designed for CL code}
 @para{ASDF: extensible in CL itself via OO protocol...}
 @C{... can be made to build anything!}
 ~
 @para{Big focus on backward-compatibility}
 @para{@it{"If it's not backwards, it's not compatible"}})

(xlide
 #:title "Some History"
 @para{1976 Unix Make}
 @para{<1981 LISP MACHINE DEFSYSTEM}
 @para{1990 MK-DEFSYSTEM: portable, pre standard}
 @para{2001 .5 kloc danb's ASDF: extensible OO build}
 @para{2004 1.1 kloc danb's ASDF 1.85: de facto standard}
 @para{2010 3.3 kloc ASDF 2: robust portable configurable}
 @para{2013 9.7 kloc ASDF 3: correct, delivers, uiop}
 @para{2014 11.3 kloc ASDF 3.1: CL as scripting language}
 @para{2017 12.8 kloc ASDF 3.2: C linking, launch-program}
 @para{2017? 13.2 kloc ASDF 3.3: proper phase separation})

(xlide
 #:title "Current Limitations"
 @para{Not declarative enough:}
 @para{CL has ubiquitous global side-effects}
 @para{Only one set of versions, global syntax, etc.}
 ~
 @para{Compared to bazel:}
 @para{No cross-compilation, no determinism, no scalability})

(xlide
 (title-style "New in ASDF"))

(xlide
 #:title "Previously on this show..."
 @para{ASDF 3.1 (2014) ELS, ILC demos:}
 @para{CL as a scripting language}
 ~
 @para{Bazelisp (2016) ELS demo:}
 @para{scalably build executables}
 @para{with statically-linked C extensions})

(xlide
 #:title "2017 Innovations"
 @CB{ASDF 3.2 (January 2017):}
 @para{Application Delivery with static C libraries}
 @para{Asynchronous subprocesses with @tt{launch-program}}
 @para{Source Location Configuration improvements}
 @para{Deprecation infrastructure}
 ~
 @CB{ASDF 3.3 (Real Soon Now 2017):}
 @para{Proper Phase Separation})

(xlide
 #:title "Application Delivery with static C libraries"
 @CB{Previously}
 @para{Extract functions & constants: @tt{:cffi-grovel-file}}
 @para{Compile & link wrappers: @tt{:cffi-wrapper-file}}
 ~
 @CB{New in ASDF 3.2 + cffi-toolchain (2017)}
 @para{Plain C code to link to: @tt{:c-file}}
 @para{cffi-toolchain: one place to deal with C compilation}
 ~
 @para{Not (yet) a general-purpose C build system}
 @para{Missing per-system compile and link flags})

(xlide
 #:title "Example system using C code"
 @code[
(defsystem "foo" :depends-on ("cffi")
  :defsystem-depends-on ("cffi-grovel")
  :serial t
  :component
  ((:cffi-grovel-file "interface-extraction")
   (:cffi-wrapper-file "complex-interfaces")
   (:c-file "some-c-code") ; new in 2017
   (:cl-source-file "some-lisp")))
])

(xlide
 #:title "Loading a system"
 @para{2001: @code[(asdf:operate 'asdf:load-op "foo")]}
 @para{or "short" @code[(asdf:oos 'asdf:load-op "foo")]}
 @para{2009: also @code[(asdf:load-system "foo")]}
 @para{2013: also @code[(asdf:oos :load-op "foo")]}
 @para{2014: also @code[(asdf:make "foo")]})

(xlide
 #:title "Making a binary"
 @bt{ASDF 3.0 (2013): image-based delivery}
 @para{development image @code[(asdf:oos :image-op "foo")]}
 @para{standalone appli. @code[(asdf:oos :program-op "foo")]}
 @para{Any C extensions must be dynamically linked}
 ~
 @bt{ASDF 3.2 (2017): with static C extensions}
 @para{@code[(asdf:oos :static-image-op "foo")]})
 @para{@code[(asdf:oos :static-program-op "foo")]}

(xlide
 #:title "Demo time!"
 @code[(asdf:make "workout-timer/static")])

(xlide
 #:title "Asynchronous subprocesses"
 @C{@bt{ASDF 3.1 (2014):} @tt{run-program}}
 @para{synchronous subprocesses (Unix @it{and} Windows)}
 @para{exit status, optionally error out if not successful}
 @para{I/O redir.: inject into stdin, capture stdout & stderr}
 ~
 @C{@bt{ASDF 3.2 (2017):} @tt{launch-program}}
 @para{asynchronous subprocess (Unix @it{and} Windows)}
 @para{exit status, waiting for processes, killing them}
 @para{I/O redirection, interaction through streams})

(xlide
 #:title "Asynchronous Limitations"
 @para{No event loop to which to integrate}
 @para{No general signal support}
 @para{Can make do with pipes and macros}
 @para{Still @it{way} better than shell programming!}
 ~
 @para{For more serious system programming: @tt{iolib}}
 @para{It requires a C extension—but that's now easier!})

(xlide
 #:title "Source Location Configuration: Before"
 @para{ASDF 1 (2001): push to @code[*central-registry*]}
 @para{early in @code[~/.sbclrc] — and for each implementation!}
 ~
 @para{ASDF 2 (2010): declare hierarchical source-registry}
 @para{@code[~/.config/common-lisp/source-registry.conf]}
 @para{Inherit wider configuration, or override it, from CL…}
 @para{or from shell: @code[CL_SOURCE_REGISTRY], XDG vars}
 ~
 @para{By default @code[~/.local/share/common-lisp/source/]}
 @para{ASDF 3.1 (2014), also @code[~/common-lisp/]})

(xlide
 #:title "Source Location Configuration: After"
 @para{Recursing through large trees can be very slow}
 @para{2015: @tt{.cl-source-registry.cache} for a @tt{:tree}
       Regenerate with a standard @tt{#!/usr/bin/cl} script:
       @tt{asdf/tools/cl-source-registry-cache.lisp}}
 @para{Harkens back to ASDF-1-style symlink farms, but
       only for impatient power users with lots of systems}
 @comment{Everything *just works* for newbies without configuration or administration}
 @para{2015: also multicall binaries with @tt{cl-launch}}
 @comment{@tt{buildapp} did it since 2010, but on SBCL only, then also CCL in 2013}
 ~
 @para{2016: expose interface to XDG base directory}
 @para{XDG also on Windows, modulo ASDF adaptation}
 ~
 @para{ASDF 3.2 (2017): the new release has it all})

(xlide
 #:title "Deprecation Infrastructure"
 @para{@tt{asdf:run-shell-command} was a @it{very} bad API}
 @para{Use @tt{uiop:run-program} instead, as per docstring}
 ~
 @para{In 3.2, using it now issues a @tt{style-warning}}
 @para{In 3.3, full @tt{warning} if used, @bt{breaks} on SBCL}
 @para{In 3.4, @tt{cerror} if used, breaks everywhere}
 @para{In 3.5, @tt{error} if @it{not deleted yet} from codebase}
 ~
 @para{@code[uiop/version] makes staged deprecation easy}
 @para{Part of UIOP 3.2, part of ASDF 3.2 (2017)})

(xlide
 #:title "Proper Phase Separation"
 @para{ASDF extensions: with CLOS. How to load one?}
 @para{Using ASDF!}
 ~
 @para{What if it itself relies on extensions?}
 @para{Build in multiple phases.}
 ~
 @para{What if an extension is modified?}
 @para{Rebuild everything that transitively depends on it.}
 ~
 @para{And what if a library is needed in multiple phases?}
 @para{Only build it once.})

(xlide
 #:title "Improper Phase Separation"
 @para{ASDF 1 had only two phases: plan, then perform}
 @para{(that was its least bug—see ASDF 2 & 3 papers)}
 ~
 @para{If @it{defining} system @code[foo] depends on @code[ext]:}
 @para{ASDF 1: @code[foo.asd] has @code[(oos 'load-op "ext")]}
 @para{ASDF 2: @code[:defsystem-depends-on ("ext")]}
 @para{ASDF 3: make it usable despite package issue}
 ~
 @para{Kind of works. ASDF unaware it's recursively called}
 @para{Missing rebuilds, extra builds, across phases})

(xlide
 #:title "Separating Phases"
 @para{ASDF 3.3: loading the asd file is itself an @it{action}!}
 @para{@code[define-op] — for @it{primary} systems.}
 ~
 @para{Big tricky refactoring of @code[find-system]:}
 @code[find-system > load-asd > operate > perform > load*]
 ~
 @para{ASDF 3 had a cache: only call @code[input-files] once}
 @para{(its API functions define a pure attribute grammar)}
 @para{ASDF 3.3 extends it to a multi-phase @it{session}}
 @para{One @code[plan] per phase, a @code[session] across phases.})

(xlide
 #:title "Traversal of the Action Graph"
 @para{Many kinds of traversals of the graph of @it{actions}:}
 @para{ASDF 1: mark as needed, in this image}
 @para{ASDF 3: mark as needed, in any previous image}
 @para{ASDF 3: go thru all dependencies, e.g. to get list}
 @para{ASDF 3.3: query whether up-to-date}
 @comment{}
 ~
 @para{ASDF 1: 1 bit (keep), plus @it{"magic"} (=bugs)}
 @comment{
   Among other things, ASDF 1 (and 2) had two kind of dependencies,
   regular in-order-to and weaker do-first.
   POIU then ASDF 3 discovered that actually
   there were instead two kinds of actions, needed-in-image or not.
 }
 @para{ASDF 3: 2 bit (needed-in-image), plus @it{timestamp}}
 @para{ASDF 3.3: 3 bit (done), plus @it{phase}})

(xlide
 #:title "Proper Phase Separation: Incompatibilities"
 @para{@code[:defsystem-depends-on] to systems in same file @code[ ]
       (as in the latest @tt{iolib} release)}
 ~
 @para{@code[clear-system] inside @code[perform] @code[ \  \  \  \  \  \  \  \  ]
       (as in lots of systems that use @tt{prove})}
 ~
 @para{@code[operate] in a CL file or @code[perform] method @code[ \  \  \  \  ]
       (temporary exception: @code[(require …)])}
 ~
 @para{Now very bad taste: misnamed secondary system @code[      ]
       (used all over: once a ASDF 1 colloquialism)})

(xlide
 #:title "Proper Phase Separation: How good are we?"
 @para{
   Build extensions is a universal need
 }
 ~
 @para{Most build systems (Make…): on par with ASDF 1}
 @comment{
   Most general build systems are on par with ASDF 1, and
   cannot track dependencies across phases. For instance,
   Make can @tt{include} a target.
 }
 ~
 @para{
   Language-specific builds can be greater (Racket…)
   but not general-purpose.
 }
 @comment{
   Racket separates phases properly, implicitly,
   @it{and} even isolates phases from each other's side-effects.
   But it is not general purpose
 }
 ~
 @para{
   Bazel: non-extensible extension language
 }
 @comment{
  In one sense, Bazel has only two phases, plan and execute,
  and all extensibility happens in the first phase
  (itself divided in load and analysis subphases).
  In another sense, the loading and evaluation of extensions
  may constitute many layered phases, if you encode and interpret
  an extensible language in that non-extensible but universal language (ouch).
 }
 'next
 ~
 @t{ASDF is on the bleeding edge!?}
 @comment{Which is a sad commentary on the state of build systems})

(xlide
 (title-style "Lessons and Opportunities"))

(xlide
 #:title "Evolving ASDF"
 @para{ASDF sucks—less}
 @para{Amazing how much is done with how few klocs}
 @comment{
   It's incredibly primitive,
   yet extraordinarily advanced in some ways!

   Dan Barlow's was a great code adventurer, and
   ASDF 1 is a mixed bag of failed experiments and strokes of pure genius.
 }
 ~
 @para{Ceiling: CL's model of global side-effects}
 @para{Impedes declarativeness, reproducibility, etc.}
 ~
 @para{Evolution is costly (yet consider the alternative)}
 @para{Only gets worse as the code- and user- bases grow}
 ~
 @para{Backward incompatibility takes at least 1-2 years}
 @comment{
   The extensive (but by no means complete) regression test suite
   that we grew since the days of ASDF 1 has proven extremely invaluable.

   Introduce change too fast, and you break things and lose users.
   You can introduce warnings that push users to do the work themselves,
   but you have to be annoying enough, yet if possibly only to maintainers,
   and without the annoyance being drowned in the noise of compiler notes and style warnings.
 }
 @para{Quicklisp: fix it all! And/or issue warnings and wait.}
 @comment{
   Users: can't live with them,
   what's the point of living without them?
 })

(xlide
 #:title "Beyond ASDF?"
 @para{Opportunity for much a better build system}
 ~
 @para{What design is worth starting from scratch?}
 @comment{Or going through a long and hard transition}
 ~
 @para{Core: Pure FRP, CLOS-style OO, versioning}
 @para{plus staging, virtualization, instrumentation}
 ~
 @para{The ultimate purpose of a build system is:}
 @it{Division of labor}
 ~
 @url{http://j.mp/BuildSystems})

(xlide
 #:title "Enjoy ASDF!"
 @para{Common Lisp keeps improving, slowly:}
 @para{AI, e-commerce, games}
 @para{web, desktop or mobile apps; and now scripts @tt{#!}}
 ~
 @para{ASDF also keeps improving, slowly.}
 @para{If there were demand, it could improve faster…}
 ~
 @para[#:align 'center]{Donate to ASDF through the CLF!}
 ~
 @url{https://common-lisp.net/project/asdf/})


#|
TODO: refactor these slides.
WHO IS THE PUBLIC?
WHAT DO THEY KNOW ALREADY?
WHAT DO THEY NOT KNOW YET THAT I WANT THEM TO KNOW?
|#
