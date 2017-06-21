Delivering Common Lisp Applications with ASDF 3.3
=================================================

This is a proposal for a demonstration at
[ELS 2017](http://2017.programmingconference.org/track/els-2017).

Viewing the article
-------------------

You can find a PDF version of the article (2 pages) at:

  * http://fare.tunes.org/files/asdf2017/asdf2017.pdf


Presentation
------------

The article was
[presented at ELS 2017 (video)](https://www.youtube.com/watch?v=W4YcsP2FZh4&index=7&list=PLA66mD-6yK8yi-nggbOF1dWusHnu2u6hw).

The source for the slides, including some comments,
are in [els2017-slides.ss](els2017-slides.ss),
and a corresponding PDF is at:

  * http://fare.tunes.org/files/asdf2017/els2017-slides.pdf


Notes
-----

The article can be compiled using PLT Racket's Scribble, from
[asdf2017.scrbl](https://github.com/fare/asdf2017/blob/master/asdf2017.scrbl),
using the experimental [acmart](https://github.com/fare/acmart) package.
See the various [Makefile](https://github.com/fare/asdf2017/blob/master/Makefile) targets.

To install the `acmart` package, do:

    git clone https://github.com/fare/acmart.git
    (cd acmart ; raco pkg install)


Reviews
-------

The paper (at commit 9b197f4c) was accepted at ELS 2017 with the following reviews.


### REVIEW 1

PAPER: 3 <br />
TITLE: Demonstration: Delivering Common Lisp Applications with ASDF 3.3 <br />
AUTHORS: Robert Goldman, Elias Pipping and Francois-Rene Rideau <br />
Overall evaluation: 2 (accept)

The paper is a very nice summary of the evolution of ASDF from its inception to its current form and place within the Common Lisp ecosystem.  The description of newer functionalities in ASDF is obviously only hinted given the submission constraints, but it is nevertheless useful.

Minor note: the references in the bibliography should include proper publication details.


### REVIEW 2

PAPER: 3 <br />
TITLE: Demonstration: Delivering Common Lisp Applications with ASDF 3.3 <br />
AUTHORS: Robert Goldman, Elias Pipping and Francois-Rene Rideau <br />
Overall evaluation: 3 (strong accept)

Definitely worthy of presentation. I only have a few minor issues:

Introduction: "multiple seconds" is awkward and not very meaningful. Use "several"? Right after: absolute timings like "twenty milliseconds" don't mean much without specifying the exact conditions, hardware features, etc.

Section 3: it would be nice to see an example of a "super-shell-script" that takes advantage of Lisp features using LAUNCH-PROGRAM.

Section 5: "allow each one" - who are we talking about here?

What is the demo going to show exactly?
