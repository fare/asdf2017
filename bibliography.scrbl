#lang at-exp racket

(require scribble/base scribble/manual scriblib/autobib "utils.rkt")

(provide (all-defined-out))

(define-bib CHINE-NUAL
  #:title "Lisp Machine Manual"
  #:author "Dan Weinreb and David Moon"
  ;; #:publisher "MIT"
  ;; #:url "https://bitsavers.trailing-edge.com/pdf/mit/cadr/chinual_4thEd_Jul81.pdf"
  #:date "1981")

(define-bib Pitman-Large-Systems
  #:author "Kent Pitman"
  #:title "The Description of Large Systems"
  ;; #:type "MIT AI Memo"
  ;; #:number "801"
  ;; #:institution "MIT AI Lab"
  ;; #:url "http://www.nhplace.com/kent/Papers/Large-Systems.html")
  #:date "1984") ;; September

(define-bib AITR-874
  #:author "Richard Elliot Robbins"
  #:title "BUILD: A Tool for Maintaining Consistency in Modular Systems"
  ;; #:url "ftp://publications.ai.mit.edu/ai-publications/pdf/AITR-874.pdf"
  ;; #:institution "MIT AI Lab"
  ;; #:type "MIT AI TR"
  ;; #:number "874"
  #:date "1985") ;; #:month "November"

(define-bib MK-DEFSYSTEM
  #:author "Mark Kantrowitz"
  #:title "Defsystem: A Portable Make Facility for Common Lisp"
  ;; School of Computer Science. Carnegie Mellon University.
  ;; #:url "ftp://ftp.cs.rochester.edu/pub/archives/lisp-standards/defsystem/pd-code/mkant/defsystem.ps.gz"
  #:date "1990") ;; January 1990.

(define-bib Critique-DIN-Kernel-Lisp
  #:author "Henry Baker"
  #:title "Critique of DIN Kernel Lisp Definition Version 1.2"
  ;; #:url "http://www.pipeline.com/~hbaker1/CritLisp.html"
  #:date "1992")

(define-bib Cult-of-Dead-mail
  #:title "Cult of Dead"
  #:author "Jim Benson"
  ;; #:url "http://wiki.squeak.org/squeak/2950"
  #:date "2002")

(define-bib ASDF-Manual
  #:title "ASDF Manual"
  #:author "Daniel Barlow" ;; and contributors?
  ;; #:url "http://common-lisp.net/project/asdf/"
  #:date "2004") ;; 2001—2014

(define-bib faslpath-page
  #:title "faslpath"
  #:author "Peter von Etter"
  ;; #:url "https://code.google.com/p/faslpath/"
  #:date "2009")

(define-bib XCVB-2009
  #:author "François-René Rideau and Spencer Brody"
  #:title "XCVB: an eXtensible Component Verifier and Builder for Common Lisp"
  ;; #:url "http://common-lisp.net/projects/xcvb/"
  ;; International Lisp Conference
  #:date "2009")

(define-bib Software-Irresponsibility
  #:author "François-René Rideau"
  #:title "Software Irresponsibility"
  ;; #:url "http://fare.livejournal.com/149264.html"
  #:date "2009")

(define-bib Evolving-ASDF
  #:author "François-René Rideau and Robert Goldman"
  #:title "Evolving ASDF: More Cooperation, Less Coordination"
  ;; #:url "http://common-lisp.net/project/asdf/doc/ilc2010draft.pdf"
  #:location (proceedings-location "ILC")
  #:date "2010")

(define-bib quicklisp
  #:author "Zach Beane"
  #:title "Quicklisp"
  ;; #:url "http://quicklisp.org/" ;; also see blog.quicklisp.org and xach.livejournal.com archives
  #:date "2011")

;; ASDF 2.26: http://fare.livejournal.com/170504.html

;; <nyef> Looks like quick-build was first implemented on 2012-04-02, so just over two years ago, but there was about a year of bugfixing to get its current form.
;; <nyef> Well, bugfixing and feature enhancement.
(define-bib Quick-build
  #:title "Quick-build (private communication)"
  #:author "Alastair Bridgewater"
  #:date "2012")

(define-bib ASDF3-2014
  #:title "ASDF3, or Why Lisp is Now an Acceptable Scripting Language (extended version)"
  #:author "François-René Rideau"
  ;; #:url "http://fare.tunes.org/files/asdf3/asdf3-2014.html"
  #:date "2014")

(define-bib Lisp-Acceptable-Scripting-Language
  #:title "Why Lisp is Now an Acceptable Scripting Language"
  #:author "François-René Rideau"
  ;; European Lisp Symposium, 2014-05-05
  ;; #:url "http://github.com/fare/asdf3-2013/"
  #:location (proceedings-location "ELS")
  #:date "2014")

(define-bib Incommensurability
  #:title "The Structure of a Programming Language Revolution"
  #:author "Richard P. Gabriel"
  ;; #:url "https://www.dreamsongs.com/Files/Incommensurability.pdf"
  ;; Onward! 2012 Proceedings of the ACM international symposium on New ideas, new paradigms, and reflections on programming and software
  #:location (proceedings-location "Onward!") ;; #:pages "195-214"
  #:date "2012")

(define-bib CL-Scripting-2015
  #:title "Common Lisp as a Scripting Language, 2015 edition"
  #:author "François-René Rideau"
  ;; #:url "http://fare.livejournal.com/184127.html"
  #:date "2015")

(define-bib Bazel
  #:title "Bazel"
  #:author "Google"
  ;; #:url "http://bazel.build/"
  #:date "2015")

(define-bib Bazelisp-2016
  #:title "Building Common Lisp programs using Bazel or Correct, Fast, Deterministic Builds for Lisp"
  #:author "James Y. Knight, François-René Rideau and Andrzej Walczak"
  ;; #:url "http://github.com/qitab/bazelisp"
  #:location (proceedings-location "ELS")
  #:date "2016")

(define-bib XDG-2010
  #:title "XDG Base Directory Specification"
  #:author "Waldo Bastian, Ryan Lortie and Lennart Poettering"
  ;; #:url "https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html"
  #:date "2010")
