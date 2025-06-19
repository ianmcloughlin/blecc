#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot
#import "@preview/quill:0.7.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/physica:0.9.5": *

#show: thmrules
#let nonumthm = thmbox("theorem", "Theorem").with(numbering: none)
#let note = thmbox("note", "Note").with(numbering: none)

#show heading: set block(above: 12mm, below: 6mm, spacing: 3em)
#let proof = thmproof("proof", "Proof")
#set math.mat(delim: "[")
#show figure.where(kind: raw): set align(start)
#set math.cases(gap: 1em)

#let cayley = table.with(
  align:center,
  stroke: (x, y) => {
    (top: (thickness: 0.2pt))
    (left: (thickness: 0.2pt))
    if x == 0 {
      (left: none)
    }
    if y == 0 {
      (top: none)
    }
    if x == 1 {
      (right: none, left: (thickness: 1pt))
    }
    if y == 1 {
      (bottom: none, top: (thickness: 1pt))
    }
  },)

= Binary Linear Codes

== Fields

#grid(columns: 3, gutter: 3em, align: center + horizon,
  $FF_2 = \{0, 1\}$,
  cayley(columns: 3, $plus$, $0$, $1$, $0$, $0$, $1$, $1$, $1$, $0$),
  cayley(columns: 3, $times$, $0$, $1$, $0$, $0$, $1$, $1$, $1$, $1$))

== Matrices

$mat(1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1)$

=== Rows

$r_0 &= mat(1, 0, 0, 0)\ r_1 &= mat(0, 1, 0, 0)\ r_2 &= mat(0, 0, 1, 0)\ r_3 &= mat(0, 0, 0, 1)\ $

=== Row Space

${sum_i a_i r_i | a_i in FF_2 }$

=== Number of Elements

$2^k$ where $k$ is the number of linearly independent rows.

$mat(0,0,0,0;0,0,0,1;0,0,1,0;0,0,1,1;dots.v,dots.v,dots.v,dots.v;1,1,1,1) mat(1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1) = mat(0,0,0,0;0,0,0,1;0,0,1,0;0,0,1,1;dots.v,dots.v,dots.v,dots.v;1,1,1,1)$

=== Linearly Independent Rows

Set of rows ${r_j}$ where only values $a_j in FF_2$ to satisfy the following equation are $forall j[a_j = 0]$.

$sum_j a_j r_j = bb(0)$

where $bb(0)$ is the zero vector with the same length as the rows.

== Subset of Rows

$mat(0, 1, 0, 0; 0, 0, 1, 0)$

== Row Space

$mat(0,0;0,1;1,0;1,1) mat(0, 1, 0, 0; 0, 0, 1, 0) = mat(0,0,0,0;0,0,1,0;0,1,0,0;0,1,1,0)$