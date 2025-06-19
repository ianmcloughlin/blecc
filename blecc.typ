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

A lot of common sets with their operations can be represented as a field.

A field is a set with two operations, commonly called addition and multiplication, that satisfy certain properties.

Both $RR$ and $CC$ are fields.

$ZZ$ is not because some (most) elements do not have a multiplicative inverse.

Neither is $NN$ for the same reason and also because elements do not have additive inverses.

The set of rational numbers $QQ$ is a field.

=== Finite Fields

A finite field is a field with a finite number of elements.

They have proven incredibly useful is computing.

They always have a prime power number of elements $p^k$.

#grid(columns: 4, gutter: 3em, align: center + horizon,
  $FF_2 = \{0, 1\}$,
  cayley(columns: 3, $plus$, $0$, $1$, $0$, $0$, $1$, $1$, $1$, $0$),
  cayley(columns: 3, $times$, $0$, $1$, $0$, $0$, $1$, $1$, $1$, $1$),
  $a + b = 0 -> -a := b\ a times b = 1 -> a^(-1) = 1/a := b\ $)

== Matrices

$mat(1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1)$

We usually assume the elements of matrices come from a single field.

Matrix multiplication requires addition and multiplication to be defined on the entries.

=== Binary Matrix

A binary matrix is a matrix where the entries come from $FF_2$.

=== Rows

We define a row as the $1 times m$ sub-matrix consisting of a single row of an $n times m$ matrix.

$r_0 &= mat(1, 0, 0, 0)\ r_1 &= mat(0, 1, 0, 0)\ r_2 &= mat(0, 0, 1, 0)\ r_3 &= mat(0, 0, 0, 1)\ $

=== Row Space

The row space of a matrix is the set of all linear combinations of its rows.

A linear combination of rows is formed by multiplying each row by a scalar from the field and adding the resulting matrices.

The scalars are called coefficients, and they can be any element from the field including zero.

${sum_i a_i r_i | a_i in FF_2 }$

=== Linearly Independent Rows

Set of rows ${r_j}$ where only values $a_j in FF_2$ to satisfy the following equation are $forall j[a_j = 0]$.

$sum_j a_j r_j = bb(0)$

where $bb(0)$ is the zero vector with the same length as the rows.

=== Number of Elements

A set of $k$ linearly independent rows from a binary matrix form a set of size $2^k$.

$mat(0,0,0,0;0,0,0,1;0,0,1,0;0,0,1,1;dots.v,dots.v,dots.v,dots.v;1,1,1,1) mat(1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1) = mat(0,0,0,0;0,0,0,1;0,0,1,0;0,0,1,1;dots.v,dots.v,dots.v,dots.v;1,1,1,1)$



== Subset of Rows

$mat(0, 1, 0, 0; 0, 0, 1, 0)$

== Row Space

$mat(0,0;0,1;1,0;1,1) mat(0, 1, 0, 0; 0, 0, 1, 0) = mat(0,0,0,0;0,0,1,0;0,1,0,0;0,1,1,0)$

== Hamming Distance

$d(r_i, r_j) = sum_k [(r_i == r_j) #h(2mm) ? #h(2mm) 0 #h(2mm) : #h(2mm) 1]$

=== Linear code

$d(r_i, r_j) = d(r_i - r_j, bb(0))$

$r_j = [r_j_0, r_j_1, dots] = [r_j_k]$

$-r_j = [-r_j_k]$

=== Binary Linear Code

$r_i - r_j = r_i + (-r_j)$

$-r_j = $

$d(r_i, r_j) = sum_k (r_i_k + r_j_k)$

$d(r_i, r_j) = d(r_i - r_j, bb(0))$
