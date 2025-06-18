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

#let kron = $times.circle$


= Binary Linear Codes

