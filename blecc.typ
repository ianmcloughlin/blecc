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


= Quantum Error Correction


== Classical Repetition Codes


=== Encode

$
0 |-> 000 \
1 |-> 111
$

=== Decode

$
a b c |-> cases(
  0 #h(4mm) "if" a + b + c #h(1mm) < #h(1mm) 2,
  1 #h(4mm) "otherwise", 
)
$


=== Probability of Received Words

Let probability of bit flip be $p$ and the bits be independent.

#figure(
table(
  columns: 3,
  [received], [$op("P")$ if $000$ sent], [$op("P")$ if $111$ sent],
   $000$,      $(1-p)^3$             ,  $p^3$                 ,
   $001$,      $p(1-p)^2$            ,  $p^2(1-p)$            ,
   $010$,      $p(1-p)^2$            ,  $p^2(1-p)$            ,
   $011$,      $p^2(1-p)$            ,  $p(1-p)^2$            ,
   $100$,      $p(1-p)^2$            ,  $p^2(1-p)$            ,
   $101$,      $p^2(1-p)$            ,  $p(1-p)^2$            ,
   $110$,      $p^2(1-p)$            ,  $p(1-p)^2$            ,
   $111$,      $p^3$                 ,  $(1-p)^3$             ,
),
caption: [Probability of received words.],
)


==== Example: #let p = 0.05; p = #p

#let P(flips, n) = calc.round(calc.pow(p, flips) * calc.pow(1-p, n - flips), digits: 4)

#figure(
table(
  columns: 3,
  [received], [$op("P")$ if $000$ sent], [$op("P")$ if $111$ sent],
   $000$    ,  $#P(0, 3)$            ,  $#P(3, 3)$,
   $001$    ,  $#P(1, 3)$            ,  $#P(2, 3)$,
   $010$    ,  $#P(1, 3)$            ,  $#P(2, 3)$,
   $011$    ,  $#P(2, 3)$            ,  $#P(1, 3)$,
   $100$    ,  $#P(1, 3)$            ,  $#P(2, 3)$,
   $101$    ,  $#P(2, 3)$            ,  $#P(1, 3)$,
   $110$    ,  $#P(2, 3)$            ,  $#P(1, 3)$,
   $111$    ,  $#P(3, 3)$            ,  $#P(0, 3)$,
),
caption: [Probability of received words when $p = #p$.],
)


===== Probability of Less than Two Flips

$
op("P")("< 2") &= (1-p)^3 + 3p(1-p)^2\
              &= 1 - 3p + 3p^2 - p^3 + 3p - 6p^2 + 3p^3 \
              &= 1 - 3p^2 + 2p^3 \
              &= 0.99275
$


=== Probability of Error with the Code

#figure(
cetz.canvas({
  // Set-up a thin axis style
  cetz.draw.set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)), legend: (stroke: .25pt))

  plot.plot(size: (12, 8),
    x-tick-step: 0.1,
    x-min: 0.0, x-max: 1.0,
    y-tick-step: 0.1, y-min: 0.0, y-max: 1.0,
    legend: (9.1, 1.7),
    {
      plot.add(x => 3*x*x - 2*x*x*x, domain: (0.0, 1.0), label: "Code")
      plot.add(x => x, domain: (0.0, 1.0), label: "No code")
    })
}),
caption: [$op("P")("error") = 1 - op("P")("< 2") = 3p^2 - 2p^3$],
placement: none)


=== Simulate

#figure(rect(
```python
# Numerical arrays and operations.
import numpy as np

# Bit error rate - independent.
p = 0.1

# Random binary data.
data = np.random.binomial(1, 0.5, 10000)
# Encoding.
encoded = data
# Noise.
noise = np.random.binomial(1, p, encoded.shape)
# Received data, after noise.
received = (encoded + noise) % 2
# Decoding.
decoded = received
# Error rate.
error_rate = (decoded != data).sum() / len(data)

# Show.
print(f'Error rate: {100.0 * error_rate:0.4f}%')
# Error rate: 10.2200%
```, inset: 10mm), placement: none,
caption: [Without error correction, the error rate is $p$.])

#figure(rect(
```python
# Numerical arrays and operations.
import numpy as np

# Bit error rate - independent.
p = 0.1

# Random binary data.
data = np.random.binomial(1, 0.5, 10000)
# Encoding.
encoded = data.repeat(3)
# Noise.
noise = np.random.binomial(1, p, encoded.shape)
# Received data, after noise.
received = (encoded + noise) % 2
# Decoding - majority vote.
decoded = (received.reshape(-1, 3).sum(axis=1) >= 2).astype(int)
# Error rate.
error_rate = (decoded != data).sum() / len(data)

# Show.
print(f'Error rate: {100.0 * error_rate:0.4f}%')
# Error rate: 2.9800%
```, inset: 10mm), placement: none,
caption: [With error correction.])


== No Quantum Repetition Code

#note[$
&x = x^2 \
=> &x^2 - x = 0 \
=> &x(x - 1) = 0 \
=> &x = 0 "or" x = 1
$]

#note[$
|(a + b i)^2| &= |a^2 + 2a b i - b^2|\
              &= |(a^2 - b^2) + 2a b i|\
              &= sqrt((a^2 + b^2)^2 + 4 a^2 b^2)\
              &= sqrt(a^4 - 2a^2b^2 + b^4 + 4a^2 b^2)\
              &= sqrt(a^4 + 2a^2 b^2 + b^4)\
              &= sqrt((a^2 + b^2)^2)\
              &= a^2 + b^2\
              &= |a + b i|^2\
=> |braket(psi_0, psi_1)^2| &= |braket(psi_0, psi_1)|^2
$]


#nonumthm("No Cloning Theorem")[There is no state vector $ket(phi)$ in the Hilbert space $cal(H)$ and no unitary operator $op("U")$ on $cal(H) #kron cal(H)$ such that $op("U")(ket(psi) #kron ket(phi)) = ket(psi) #kron ket(psi)$ for all $ket(psi)$ in $cal(H)$.]
#proof[

  Suppose $op("U")$ existed and note that $braket(phi)$ = 1 and $op("U")^dagger op("U") = bb(1)$.

  Consider two states $ket(psi_0)$ and $ket(psi_1)$ in $cal(H)$.
 
  $
  braket(psi_0, psi_1) &= braket(psi_0, psi_1) braket(phi, phi) \
                       &= (bra(psi_0) #kron bra(phi)) (ket(psi_1) #kron ket(phi)) \
                       &= (bra(psi_0) #kron bra(phi)) U^dagger U (ket(psi_1) #kron ket(phi)) \
                       &= (U(ket(psi_0) #kron ket(phi)))^dagger U (ket(psi_1) #kron ket(phi)) \
                       &= (ket(psi_0) #kron ket(psi_0))^dagger (ket(psi_1) #kron ket(psi_1)) \
                       &= (bra(psi_0) #kron bra(psi_0)) (ket(psi_1) #kron ket(psi_1)) \
                       &= braket(psi_0, psi_1) braket(psi_0, psi_1)\
                       &= braket(psi_0, psi_1)^2
  $
  #v(8mm)
  $
  => |braket(psi_0, psi_1)| &= |braket(psi_0, psi_1)^2| \
                            &= |braket(psi_0, psi_1)|^2 \
  => |braket(psi_0, psi_1)| &= 0 text("or") 1 \
  |braket(psi_0, psi_1)|    &= 0 => psi_0 perp psi_1 \
  |braket(psi_0, psi_1)|    &= 1 => psi_0 = e^(i theta)  psi_1
  $

  So, $op("U")$ can only work for orthogonal states or equivalent states.
]


== Bit Flip Code

$
alpha ket(0) + beta ket(1) -> alpha ket(000) + beta ket(111)
$


=== Encode

$
ket(psi_0) &= alpha ket(000) + beta ket(001) \
ket(psi_1) &= op("CX")_(01) ket(psi_0) \
           &= alpha ket(000) + beta ket(011) \
ket(psi_2) &= op("CX")_(02) ket(psi_1) \
           &= alpha ket(000) + beta ket(111)
$

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(1), ctrl(2), rstick($alpha ket(000) + beta ket(111)$, n: 3), [\ ],
lstick($ket(0)$)                    , targ() , 1      , 1                                             , [\ ],
lstick($ket(0)$)                    , 1      , targ() , 1                                             ,     )
), placement: none, caption: [Encoding for bit flip code.])


=== Error Example

$
ket(psi_2) &= alpha ket(000) + beta ket(111) \
ket(psi_3) &= X_1 ket(psi_2) \
           &= alpha ket(010) + beta ket(101)
$

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(1), ctrl(2), 1  , rstick($alpha ket(010) + beta ket(101)$, n: 3), [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("X")$, 1                                             , [\ ],
lstick($ket(0)$)                    , 1      , targ() , 1  , 1                                             ,     )
), placement: none, caption: [Bit flip error example.])


=== Syndrome Setup

$
ket(psi_3) &= alpha ket(010) + beta ket(101)
$

Choose two of the three pairs of qubits.

$
ket(psi_4) &= ket(00) #kron ket(psi_3) = alpha ket(00010) + beta ket(00101) \
ket(psi_5) &= op("CX")_(03) ket(psi_4) = alpha ket(00010) + beta ket(01101) \
ket(psi_6) &= op("CX")_(13) ket(psi_5) = alpha ket(01010) + beta ket(01101) \
ket(psi_7) &= op("CX")_(04) ket(psi_6) = alpha ket(01010) + beta ket(11101) \
ket(psi_8) &= op("CX")_(24) ket(psi_7) = alpha ket(01010) + beta ket(01101)
$

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), 1  , ctrl(3) , 1      , ctrl(4), 1      , 1, [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("X")$, 1       , ctrl(2), 1      , 1      , 1, [\ ],
lstick($ket(0)$)  , 1      , targ() , 1  , 1       , 1      , 1      , ctrl(2), 1, [\ ],
lstick($ket(0)$)  , 1      , 1      , 1  , targ()  , targ() , 1      , 1      , 1, [\ ],
lstick($ket(0)$)  , 1      , 1      , 1  , 1       , 1      , targ() , targ() , 1,     )
), placement: none, caption: [Syndrome setup for bit flip code.])


=== Measure

Measure qubits 3 and 4 to get 1 and 0 respectively.

$
ket(psi_9) = alpha ket(010) + beta ket(101)
$

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), 1        , ctrl(3), 1      , ctrl(4), 1      , 1      ,                          [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("X")$, 1      , ctrl(2), 1      , 1      , 1      ,                          [\ ],
lstick($ket(0)$)  , 1      , targ() , 1        , 1      , 1      , 1      , ctrl(2), 1      ,                          [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , targ() , targ() , 1      , 1      , meter(), setwire(2), rstick($1$), [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , 1      , 1      , targ() , targ() , meter(), setwire(2), rstick($0$),     )
), placement: none, caption: [Measuring bit flip code.])


=== Correct

The $1$ means qubits 0 and 1 disagree.

The $0$ means qubits 0 and 2 agree.

$=>$ correct qubit $1$.

$
ket(psi_(10)) &= X_1 ket(psi_9) = alpha ket(000) + beta ket(111)
$

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), 1        , ctrl(3) , 1      , ctrl(4), 1      , 1        , 1            , [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("X")$, 1       , ctrl(2), 1      , 1      , $op("X")$, 1            , [\ ],
lstick($ket(0)$)  , 1      , targ() , 1        , 1       , 1      , 1      , ctrl(2), 1        , 1            , [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , targ()  , targ() , 1      , 1      , meter()  , 1, setwire(0), [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , 1       , 1      , targ() , targ() , meter()  , 1, setwire(0),     )
), placement: none, caption: [Correcting bit flip error example.])


=== Disentangle

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), 1        , ctrl(3), 1      , ctrl(4), 1      , 1        , ctrl(1)   , ctrl(2), rstick($ket(psi)$), [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("X")$, 1      , ctrl(2), 1      , 1      , $op("X")$, targ()    , 1      , rstick($ket(0)$)  , [\ ],
lstick($ket(0)$)  , 1      , targ() , 1        , 1      , 1      , 1      , ctrl(2), 1        , 1         , targ() , rstick($ket(0)$)  , [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , targ() , targ() , 1      , 1      , meter()  , setwire(0), 1                          , [\ ],
lstick($ket(0)$)  , 1      , 1      , 1        , 1      , 1      , targ() , targ() , meter()  , setwire(0), 1                          ,     )
), placement: none, caption: [Disentangle bit flip code.])


== Phase Flip Code

$
ket(psi) &= alpha ket(0) + beta ket(1)
$


=== Encode

#note[$
&ket(+) = 1/(sqrt(2)) ket(0) + 1/sqrt(2) ket(1) \
&=> ket(+++) = 1/(2 sqrt(2)) ket(000) + 1/(2 sqrt(2)) ket(001) + 1/(2 sqrt(2)) ket(010) + 1/(2 sqrt(2)) ket(011) \
& #h(10mm) + 1/(2 sqrt(2)) ket(100) + 1/(2 sqrt(2)) ket(101) + 1/(2 sqrt(2)) ket(110) + 1/(2 sqrt(2)) ket(111) \
&= 1/(2 sqrt(2)) (ket(000) + ket(001) + ket(010) + ket(011) + ket(100) + ket(101) + ket(110) + ket(111)) \
$
$
&ket(-) = 1 / (  sqrt(2)) ket(0)   -  1/(  sqrt(2)) ket(1) \
&=> ket(---) = 1 / (2 sqrt(2)) ket(000) -  1/(2 sqrt(2)) ket(001) - 1/(2 sqrt(2)) ket(010) + 1 / (2 sqrt(2)) ket(011) \
& #h(10mm) - 1/(2 sqrt(2)) ket(100) + 1 / (2 sqrt(2)) ket(101) + 1/(2 sqrt(2)) ket(110) - 1 / (2 sqrt(2)) ket(111) \
&= 1/(2 sqrt(2)) (ket(000) - ket(001) - ket(010) + ket(011) - ket(100) + ket(101) + ket(110) - ket(111)) \
$]

$
ket(psi_0) =& alpha ket(000) + beta ket(001) \
ket(psi_1) =& op("CX")_(01) ket(psi_0) = alpha ket(000) + beta ket(011) \
ket(psi_2) =& op("CX")_(02) ket(psi_1) = alpha ket(000) + beta ket(111) \
ket(psi_3) =& H_0 ket(psi_2) \
           =& alpha 1/sqrt(2) ket(000) + alpha 1/sqrt(2) ket(001) + beta  1/sqrt(2) ket(110) - beta  1/sqrt(2) ket(111) \
ket(psi_4) =& H_1 ket(psi_3) \
           =& alpha 1/2 ket(000) + alpha 1/2 ket(010) + alpha 1/2 ket(001) + alpha 1/2 ket(011) \
           +& beta  1/2 ket(100) - beta  1/2 ket(110) - beta  1/2 ket(101) + beta  1/2 ket(111)
$
$
ket(psi_5) =& H_2 ket(psi_4) \
           =& alpha 1/(2 sqrt(2)) ket(000) + alpha 1/(2 sqrt(2)) ket(100) + alpha 1/(2 sqrt(2)) ket(010) + alpha 1/(2 sqrt(2)) ket(110) \
           +& alpha 1/(2 sqrt(2)) ket(001) + alpha 1/(2 sqrt(2)) ket(101) + alpha 1/(2 sqrt(2)) ket(011) + alpha 1/(2 sqrt(2)) ket(111) \
           +& beta  1/(2 sqrt(2)) ket(000) - beta  1/(2 sqrt(2)) ket(100) - beta  1/(2 sqrt(2)) ket(010) + beta  1/(2 sqrt(2)) ket(110) \
           -& beta  1/(2 sqrt(2)) ket(001) + beta  1/(2 sqrt(2)) ket(101) + beta  1/(2 sqrt(2)) ket(011) - beta  1/(2 sqrt(2)) ket(111) \
           =& alpha ket(+++) + beta ket(---)
$


#note[$
H_0 &ket(000) &= &ket(00+) \
H_0 &ket(111) &= &ket(11-) \
H_1 &ket(00+) &= &ket(0++) \
H_1 &ket(11-) &= &ket(1--) \
H_2 &ket(0++) &= &ket(+++) \
H_2 &ket(1--) &= &ket(---)
$]


#note[$
H_i ( alpha ket(000) + beta ket(111) ) = alpha H_i ket(000) + beta H_i ket(111)
$]

$
H_2 &H_1 H_0 (alpha ket(000) + beta ket(111)) \
    &= alpha H_2 H_1 H_0 ket(000) + beta H_2 H_1 H_0 ket(111) \
    &= alpha ket(+++) + beta ket(---)
$

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(1), ctrl(2), $op("H")$, rstick($alpha ket(+++) + beta ket(---)$, n: 3), [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("H")$,                                                 [\ ],
lstick($ket(0)$)                    , 1      , targ() , $op("H")$,                                                     )
), placement: none, caption: [Encoding for phase flip code.])


=== Phase Flip Error Example

$
ket(psi_5) = alpha ket(+++) + beta ket(---)
$

$
ket(psi_6) = Z_1 ket(psi_6) = alpha ket(+-+) + beta ket(-+-)
$

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), $op("H")$, ctrl(1), ctrl(2), $op("H")$, 1        , rstick($alpha ket(+-+) + beta ket(-+-)$, n: 3), [\ ],
lstick($ket(0)$)                    , 1        , targ() , 1      , $op("H")$, $op("Z")$,                                                 [\ ],
lstick($ket(0)$)                    , 1        , 1      , targ() , $op("H")$, 1        ,                                                     )
), placement: none, caption: [Phase flip error example.])


=== Setup

#note[$
ket(+-+) &= 1/(2 sqrt(2)) (ket(000) + ket(001) - ket(010) - ket(011) \
         & #h(12mm) + ket(100) + ket(101) - ket(110) - ket(111) ) \
ket(-+-) &= 1/(2 sqrt(2)) (ket(000) - ket(001) + ket(010) - ket(011) \
         & #h(12mm) - ket(100) + ket(101) - ket(110) + ket(111) )
$]


#note[$
H_0 &ket(+-+) &= &ket(+-0) \
H_1 &ket(+-0) &= &ket(+10) \
H_2 &ket(+10) &= &ket(010) \
H_0 &ket(-+-) &= &ket(-+1) \
H_1 &ket(-+1) &= &ket(-01) \
H_2 &ket(-01) &= &ket(101)
$]

$
ket(psi_6)    &= alpha ket(+-+) + beta ket(-+-) \
ket(psi_7)    &= alpha ket(00+-+) + beta ket(00-+-) \§
ket(psi_8)    &= H_0 ket(psi_7) \
              &=  alpha H_0 ket(00+-+) + beta H_0 ket(00-+-) \
              &= alpha ket(00+-0) + beta ket(00-+1) \
ket(psi_9)    &= H_1 ket(psi_8) \
              &= alpha ket(00+10) + beta ket(00-01) \
ket(psi_(10)) &= H_2 ket(psi_9) \
              &= alpha ket(00010) + beta ket(00101) \
ket(psi_(11)) &= op("CX")_(03) ket(psi_(9)) \
              &= op("CX")_(03) ( alpha ket(00010) + beta ket(00101) ) \
              &= alpha ket(00010) + beta ket(01101) \
ket(psi_(12)) &= op("CX")_(13) ket(psi_(10)) \
              &= op("CX")_(13) ( alpha ket(00010) + beta ket(01101) ) \
              &= alpha ket(01010) + beta ket(01101) \
ket(psi_(13)) &= op("CX")_(14) ket(psi_(11)) \
              &= op("CX")_(14) ( alpha ket(01010) + beta ket(01101) ) \
              &= alpha ket(11010) + beta ket(01101) \
ket(psi_(14)) &= op("CX")_(24) ket(psi_(12)) \
              &= op("CX")_(24) ( alpha ket(11010) + beta ket(01101) ) \
              &= alpha ket(11010) + beta ket(11101) \
ket(psi_(15)) &= H_0 ket(psi_(13)) \
              &= alpha H_0 ket(11010) + beta H_0 ket(11101) \
              &= alpha ket(1101+) + beta ket(1110-) \
ket(psi_(16)) &= H_1 ket(psi_(14)) \
              &= alpha H_1 ket(1101+) + beta H_1 ket(1110-) \
              &= alpha ket(110-+) + beta ket(111+-) \
ket(psi_(17)) &= H_2 ket(psi_(15)) \
              &= alpha H_2 ket(110-+) + beta H_2 ket(111+-) \
              &= alpha ket(11+-+) + beta ket(11-+-)
$

#figure(rect(
quantum-circuit(
1               , $op("H")$, ctrl(3), 1      , 1      , 1      , $op("H")$, 1      , 1         , [\ ],
1               , $op("H")$, 1      , ctrl(2), ctrl(3), 1      , $op("H")$, 1      , 1         , [\ ],
1               , $op("H")$, 1      , 1      , 1      , ctrl(2), $op("H")$, 1      , 1         , [\ ],
lstick($ket(0)$), 1        , targ() , targ() , 1      , 1      , 1        , meter(), setwire(0), [\ ],
lstick($ket(0)$), 1        , 1      , 1      , targ() , targ() , 1        , meter(), setwire(0)      )
), placement: none, caption: [Syndrome setup for phase flip code.])


=== Measure

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), $op("H")$, 1        , $op("H")$,                             ctrl(3), 1      , 1      , 1      , $op("H")$, 1                  , [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("H")$, $op("Z")$, $op("H")$,                             1      , ctrl(2), ctrl(3), 1      , $op("H")$, 1                  , [\ ],
lstick($ket(0)$)  , 1      , targ() , $op("H")$, 1        , $op("H")$,                             1      , 1      , 1      , ctrl(2), $op("H")$, 1                  , [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), targ() , targ() , 1      , 1      , 1        , meter(), setwire(0), [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), 1      , 1      , targ() , targ() , 1        , meter(), setwire(0)      )
), placement: none, caption: [Measurement for phase flip code.])

Both 1 $=>$ qubit involved in both checks is different.


=== Correct

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), $op("H")$, 1        , $op("H")$,                             ctrl(3), 1      , 1      , 1      , $op("H")$, 1        ,             1, [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("H")$, $op("Z")$, $op("H")$,                             1      , ctrl(2), ctrl(3), 1      , $op("H")$, $op("Z")$,             1, [\ ],
lstick($ket(0)$)  , 1      , targ() , $op("H")$, 1        , $op("H")$,                             1      , 1      , 1      , ctrl(2), $op("H")$, 1        ,             1, [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), targ() , targ() , 1      , 1      , 1        , meter()  , setwire(0), 1, [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), 1      , 1      , targ() , targ() , 1        , meter()  , setwire(0), 1      )
), placement: none, caption: [Correcting phase flip error example.])


=== Disentangle

#figure(rect(
quantum-circuit(
lstick($ket(psi)$), ctrl(1), ctrl(2), $op("H")$, 1        , $op("H")$,                             ctrl(3), 1      , 1      , 1      , $op("H")$, 1        ,             ctrl(1), ctrl(2), rstick($ket(psi)$), [\ ],
lstick($ket(0)$)  , targ() , 1      , $op("H")$, $op("Z")$, $op("H")$,                             1      , ctrl(2), ctrl(3), 1      , $op("H")$, $op("Z")$,             targ() , 1      , rstick($ket(0)$)  , [\ ],
lstick($ket(0)$)  , 1      , targ() , $op("H")$, 1        , $op("H")$,                             1      , 1      , 1      , ctrl(2), $op("H")$, 1        ,             1      , targ() , rstick($ket(0)$)  , [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), targ() , targ() , 1      , 1      , 1        , meter()  , setwire(0), 1      , 1                          , [\ ],
setwire(0)        , 1      , 1      , 1        , 1        , 1        , lstick(ket(0)), setwire(1), 1      , 1      , targ() , targ() , 1        , meter()  , setwire(0), 1      , 1                          ,     )
), placement: none, caption: [Disentangle phase flip code.])


=== Simplified Syndrome Setup

#figure(rect(
quantum-circuit(
1,                                        $op("H")$, ctrl(3), 1      , 1      , 1      , $op("H")$, 1,       [\ ],
1,                                        $op("H")$, 1      , ctrl(2), ctrl(3), 1      , $op("H")$, 1,       [\ ],
1,                                        $op("H")$, 1      , 1      , 1      , ctrl(2), $op("H")$, 1,       [\ ],
setwire(0), lstick($ket(0)$), setwire(1), 1        , targ() , targ() , 1      , 1      , 1        , meter(), [\ ],
setwire(0), lstick($ket(0)$), setwire(1), 1        , 1      , 1      , targ() , targ() , 1        , meter(),     )
), placement: none, caption: [Original.])

#figure(rect(
quantum-circuit(
1               , 1        , targ()  , 1       , 1       , 1       , 1        , 1      , [\ ],
1               , 1        , 1       , targ()  , targ()  , 1       , 1        , 1      , [\ ],
1               , 1        , 1       , 1       , 1       , targ()  , 1        , 1      , [\ ],
lstick($ket(0)$), $op("H")$, ctrl(-3), ctrl(-2), 1       , 1       , $op("H")$, meter(), [\ ],
lstick($ket(0)$), $op("H")$, 1       , 1       , ctrl(-3), ctrl(-2), $op("H")$, meter(),     )
), placement: none, caption: [Simplified.])


#note("Phase Kickback")[$
op("CX")_(10) ket(++) &= op("CX")_(10)
                    1/2 (ket(00) + ket(01) + ket(10) + ket(11)) \
                 &= 1/2 (ket(00) + ket(01) + ket(11) + ket(10)) \
                 &= 1/2 (ket(00) + ket(01) + ket(10) + ket(11)) \
                 &= ket(++) \
op("CX")_(10) ket(-+) &= op("CX")_(10) 1/2 ( ket(00) + ket(01) -  ket(10) -  ket(11) ) \
                 &= 1/2 ( ket(00) + ket(01) -  ket(11) -  ket(10) ) \
                 &= 1/2 ( ket(00) + ket(01) -  ket(10) -  ket(11) ) \
                 &= ket(-+) \
op("CX")_(10) ket(+-) &= op("CX")_(10) ( ket(00) -  ket(01) + ket(10) -  ket(11) ) \
                 &= 1/2 ( ket(00) -  ket(01) + ket(11) -  ket(10) ) \
                 &= 1/2 ( ket(00) -  ket(01) -  ket(10) + ket(11) ) \
                 &= ket(--) \
op("CX")_(10) ket(--) &= op("CX")_(10) ( ket(00) -  ket(01) -  ket(10) + ket(11) ) \
                 &= 1/2 ( ket(00) -  ket(01) -  ket(11) + ket(10) ) \
                 &= 1/2 ( ket(00) -  ket(01) + ket(10) -  ket(11) ) \
                 &= ket(+-)
$]


==== No Error

#let pl = math.class("normal", $+$)
#let mi = math.class("normal", $-$)

$
ket(psi_0) &= alpha ket(#pl#pl#pl) + beta ket(#mi#mi#mi) \
ket(psi_1) &= alpha ket(00#pl#pl#pl) + beta ket(00#mi#mi#mi) \
ket(psi_2) &= H_3 ( alpha ket(00#pl#pl#pl) + beta ket(00#mi#mi#mi) ) \
           &= alpha ket(0#pl#pl#pl#pl) + beta ket(0#pl#mi#mi#mi) \
ket(psi_3) &= H_4 ( alpha ket(0#pl#pl#pl#pl) + beta ket(0#pl#mi#mi#mi) ) \
           &= alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) \
ket(psi_4) &= op("CX")_(32) ket(psi_3) \
           &= op("CX")_(32) ( alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) )  \
           &=                alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#mi#mi#mi#mi) \
ket(psi_5) &= op("CX")_(31) ket(psi_4) \
           &= op("CX")_(31) ( alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#mi#mi#mi#mi) )  \
           &=                alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) \
ket(psi_6) &= op("CX")_(41) ket(psi_5) \
           &= op("CX")_(41) ( alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) )  \
           &=                alpha ket(#pl#pl#pl#pl#pl) + beta ket(-#pl#mi#mi#mi) \
ket(psi_7) &= op("CX")_(40) ket(psi_6) \
           &= op("CX")_(40) ( alpha ket(#pl#pl#pl#pl#pl) + beta ket(#mi#pl#mi#mi#mi) )  \
           &=                alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) \
ket(psi_8) &= H_3 ( alpha ket(#pl#pl#pl#pl#pl) + beta ket(#pl#pl#mi#mi#mi) ) \
           &= alpha ket(#pl 0#pl#pl#pl) + beta ket(#pl 0#mi#mi#mi) \
ket(psi_9) &= H_4 ( alpha ket(#pl 0#pl#pl#pl) + beta ket(#pl 0#mi#mi#mi) ) \
           &= alpha ket(00#pl#pl#pl) + beta ket(00#mi#mi#mi)
$

Syndrome $00$: all qubits equal.


==== One error

$
ket(psi_0) &= alpha ket(#pl#mi#pl) + beta ket(#mi#pl#mi) \
ket(psi_1) &= alpha ket(00#pl#mi#pl) + beta ket(00#mi#pl#mi) \
ket(psi_2) &= H_3 ( alpha ket(00#pl#mi#pl) + beta ket(00#mi#pl#mi) ) \
           &= alpha ket(0#pl#pl#mi#pl) + beta ket(0#pl#mi#pl#mi) \
ket(psi_3) &= H_4 ( alpha ket(0#pl#pl#mi#pl) + beta ket(0#pl#mi#pl#mi) ) \
           &= alpha ket(#pl#pl#pl#mi#pl) + beta ket(#pl#pl#mi#pl#mi) \
ket(psi_4) &= op("CX")_(32) ket(psi_3) \
           &= op("CX")_(32) ( alpha ket(#pl#pl#pl#mi#pl) + beta ket(#pl#pl#mi#pl#mi) )  \
           &=                alpha ket(#pl#pl#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) \
ket(psi_5) &= op("CX")_(31) ket(psi_4) \
           &= op("CX")_(31) ( alpha ket(#pl#pl#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) )  \
           &=                alpha ket(#pl#mi#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) \
ket(psi_6) &= op("CX")_(41) ket(psi_5) \
           &= op("CX")_(41) ( alpha ket(#pl#mi#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) )  \
           &=                alpha ket(#mi#mi#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) \
ket(psi_7) &= op("CX")_(40) ket(psi_6) \
           &= op("CX")_(40) ( alpha ket(#mi#mi#pl#mi#pl) + beta ket(#pl#mi#mi#pl#mi) )  \
           &=                alpha ket(#mi#mi#pl#mi#pl) + beta ket(#mi#mi#mi#pl#mi) \
ket(psi_8) &= H_3 ( alpha ket(#mi#mi#pl#mi#pl) + beta ket(#mi#mi#mi#pl#mi) ) \
           &= alpha ket(#mi 1#pl#mi#pl) + beta ket(#mi 1#mi#pl#mi) \
ket(psi_9) &= H_4 ( alpha ket(#mi 1#pl#mi#pl) + beta ket(#mi 1#mi#pl#mi) ) \
           &= alpha ket(11#pl#mi#pl) + beta ket(11#mi#pl#mi)
$

Syndrome $11$: overlap qubit $1$ is different from others.


== Shor's Code

#note[$
op("CX")_(01) ket(0#pl) = op("CX")_(01) 1/sqrt(2) (ket(00) + ket(01)) \
                 = 1/sqrt(2) (ket(00) + ket(11)) \
op("CX")_(01) ket(0#mi) = op("CX")_(01) 1/sqrt(2) (ket(00) - ket(01)) \
                 = 1/sqrt(2) (ket(00) - ket(11)) \

$]


=== Encode

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(3), ctrl(6), $op("H")$,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1, [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("H")$,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1, [\ ],
lstick($ket(0)$)                    , 1      , targ() , $op("H")$,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1,     )
), placement: none, caption: [Encoding for bit flip code.])

#v(8mm)

$
ket(psi_0) &= alpha ket(0) + beta ket(1) \
ket(psi_1) &= alpha ket(000000000) + beta ket(000000001) \
ket(psi_2) &= op("CX")_(03) ket(psi_1) \
           &= op("CX")_(03) (alpha ket(000000000) + beta ket(000000001)) \
           &= alpha ket(000000000) + beta ket(000001001) \
ket(psi_3) &= op("CX")_(06) ket(psi_2) \
           & = op("CX")_(06) (alpha ket(000000000) + beta ket(000001001)) \
           &= alpha ket(000000000) + beta ket(001001001) \
ket(psi_4) &= H_0 ket(psi_3) \
           &= H_0 ( alpha ket(000000000) + beta ket(001001001) ) \
           &= alpha ket(00000000#pl) + beta ket(00100100#mi) \
ket(psi_5) &= H_3 ket(psi_4) \
           &= H_3 (alpha ket(00000000#pl) + beta ket(00100100#mi)) \
           &= alpha ket(00000#pl 00#pl) + beta ket(00100#mi 00#mi) \
ket(psi_6) &= H_6 ket(psi_5) \
           &= H_6 (alpha ket(00000#pl 00#pl) + beta ket(00100#mi 00#mi)) \
           &= alpha ket(00#pl 00#pl 00#pl) + beta ket(00#mi 00#mi 00#mi)
$
$
ket(psi_7) &= op("CX")_(01) ket(psi_6) \
           &= op("CX")_(01) ( alpha ket(00#pl 00#pl 00#pl ) + beta ket(00#mi 00#mi 00#mi) ) \
           &= op("CX")_(01) 1/sqrt(2) ( alpha ket(00#pl 00#pl 000) + alpha ket(00#pl 00#pl 001)  \
           &#h(11mm) +  beta  ket(00#mi 00#mi 000) - beta  ket(00#mi 00#mi 001) ) \
           &=  1/sqrt(2) ( alpha ket(00#pl 00#pl 000) + alpha ket(00#pl 00#pl 011)  \
           &#h(11mm) +  beta  ket(00#mi 00#mi 000) - beta  ket(00#mi 00#mi 011)  )\ 
ket(psi_8) &= op("CX")_(02) ket(psi_7) \
           &= op("CX")_(02) 1/sqrt(2) ( alpha ket(00#pl 00#pl 000) + alpha ket(00#pl 00#pl 011)  \
           &#h(11mm) +  beta  ket(00#mi 00#mi 000) - beta  ket(00#mi 00#mi 011)  ) \
           &= 1/sqrt(2) ( alpha ket(00#pl 00#pl 000) + alpha ket(00#pl 00#pl 111)  \
           &#h(11mm) +  beta  ket(00#mi 00#mi 000) - beta  ket(00#mi 00#mi 111)  ) \
ket(psi_9) &= op("CX")_(34) ket(psi_8) \
            &= op("CX")_(34) 1/sqrt(2) ( alpha ket(00#pl 00#pl 000) + alpha ket(00#pl 00#pl 111)  \
            &#h(11mm) +  beta  ket(00#mi 00#mi 000) - beta  ket(00#mi 00#mi 111)  ) \
            &= op("CX")_(34) 1/2 ( alpha ket(00#pl 000000) +alpha ket(00#pl 001000)  \
            &#h(11mm) + alpha ket(00#pl 000111) + alpha ket(00#pl 001111) \
            &#h(11mm) + beta  ket(00#mi 000000) - beta  ket(00#mi 001000) \
            &#h(11mm) - beta  ket(00#mi 000111) + beta  ket(00#mi 001111)  ) \
            &= 1/2 ( alpha ket(00#pl 000000) + alpha ket(00#pl 011000)  \
            &#h(11mm) + alpha ket(00#pl 000111) + alpha ket(00#pl 011111) \
            &#h(11mm) + beta  ket(00#mi 000000) - beta  ket(00#mi 011000) \
            &#h(11mm) - beta  ket(00#mi 000111) + beta  ket(00#mi 011111)  ) \
ket(psi_(10)) &= op("CX")_(35) ket(psi_9) \
               &= op("CX")_(35) 1/2 ( alpha ket(00#pl 000000) +alpha ket(00#pl 011000)  \
               &#h(11mm) + alpha ket(00#pl 000111) + alpha ket(00#pl 011111) \
               &#h(11mm) + beta  ket(00#mi 000000) - beta  ket(00#mi 011000) \
               &#h(11mm) - beta  ket(00#mi 000111) + beta  ket(00#mi 011111)  ) \
               &= 1/2 ( alpha ket(00#pl 000000) + alpha ket(00#pl 111000)  \
               &#h(11mm) + alpha ket(00#pl 000111) + alpha ket(00#pl 111111) \
               &#h(11mm) + beta  ket(00#mi 000000) - beta  ket(00#mi 111000) \
               &#h(11mm) - beta  ket(00#mi 000111) + beta  ket(00#mi 111111)  )
$
$
ket(psi_(11)) &= op("CX")_(67) ket(psi_(10)) \
              &= op("CX")_(67) 1/2 ( alpha ket(00#pl 000000) + alpha ket(00#pl 111000)  \
              &#h(11mm) + alpha ket(00#pl 000111) + alpha ket(00#pl 111111) \
              &#h(11mm) + beta  ket(00#mi 000000) - beta  ket(00#mi 111000) \
              &#h(11mm) - beta  ket(00#mi 000111) + beta  ket(00#mi 111111)  ) \
              &= op("CX")_(67) 1/(2 sqrt(2)) ( alpha ket(000000000) + alpha ket(001000000)  \
              &#h(11mm) + alpha ket(000111000) + alpha ket(001111000) \
              &#h(11mm) + alpha ket(000000111) + alpha ket(001000111) \
              &#h(11mm) + alpha ket(000111111) + alpha ket(001111111) \
              &#h(11mm) + beta  ket(000000000) - beta  ket(001000000) \
              &#h(11mm) - beta  ket(000111000) + beta  ket(001111000) \
              &#h(11mm) - beta  ket(000000111) + beta  ket(001000111) \
              &#h(11mm) + beta  ket(000111111) - beta  ket(001111111)  ) \
              &= 1/(2 sqrt(2)) ( alpha ket(000000000) + alpha ket(011000000)  \
              &#h(11mm) + alpha ket(000111000) + alpha ket(011111000) \
              &#h(11mm) + alpha ket(000000111) + alpha ket(011000111) \
              &#h(11mm) + alpha ket(000111111) + alpha ket(011111111) \
              &#h(11mm) + beta  ket(000000000) - beta  ket(011000000) \
              &#h(11mm) - beta  ket(000111000) + beta  ket(011111000) \
              &#h(11mm) - beta  ket(000000111) + beta  ket(011000111) \
              &#h(11mm) + beta  ket(000111111) - beta  ket(011111111)  )\
ket(psi_(12)) &= op("CX")_(68) ket(psi_(11)) \
              &= op("CX")_(68) 1/(2 sqrt(2)) ( alpha ket(000000000) + alpha ket(011000000)  \
              &#h(11mm) + alpha ket(000111000) + alpha ket(011111000) \
              &#h(11mm) + alpha ket(000000111) + alpha ket(011000111) \
              &#h(11mm) + alpha ket(000111111) + alpha ket(011111111) \
              &#h(11mm) + beta  ket(000000000) - beta  ket(011000000) \
              &#h(11mm) - beta  ket(000111000) + beta  ket(011111000) \
              &#h(11mm) - beta  ket(000000111) + beta  ket(011000111) \
              &#h(11mm) + beta  ket(000111111) - beta  ket(011111111)  ) \
              &= 1/(2 sqrt(2)) ( alpha ket(000000000) + alpha ket(111000000)  \
              &#h(11mm) + alpha ket(000111000) + alpha ket(111111000) \
              &#h(11mm) + alpha ket(000000111) + alpha ket(111000111) \
              &#h(11mm) + alpha ket(000111111) + alpha ket(111111111) \
              &#h(11mm) + beta  ket(000000000) - beta  ket(111000000) \
              &#h(11mm) - beta  ket(000111000) + beta  ket(111111000) \
              &#h(11mm) - beta  ket(000000111) + beta  ket(111000111) \
              &#h(11mm) + beta  ket(000111111) - beta  ket(111111111)  )
$


==== Simplify

$
&ket(0) -> 1/(2 sqrt(2)) (ket(000) + ket(111)) #kron (ket(000) + ket(111)) #kron (ket(000) + ket(111)) \
&ket(1) -> 1/(2 sqrt(2)) (ket(000) - ket(111)) #kron (ket(000) - ket(111)) #kron (ket(000) - ket(111)) \
&=> ket(phi) = alpha ket(0) + beta ket(1) -> \
&alpha / (2 sqrt(2)) (ket(000) + ket(111)) #kron (ket(000) + ket(111)) #kron (ket(000) + ket(111)) \
&#h(8mm) +  beta / (2 sqrt(2)) (ket(000) - ket(111)) #kron (ket(000) - ket(111)) #kron (ket(000) - ket(111))
$


=== Errors
#figure(rect(inset: 4mm,
  grid(
    columns: 3, rows: 5, align: center + horizon,
    column-gutter: 10mm, row-gutter: (8mm, 8mm, 0mm),
    quantum-circuit(
    1, $op("X")$, ctrl(1), 1, [\ ],
    1, 1        , targ()  , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), $op("X")$, 1, [\ ],
    1, targ() , $op("X")$, 1,    ),
    quantum-circuit(
    1, $op("X")$, ctrl(1), 1, [\ ],
    1, $op("X")$, targ() , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), $op("X")$, 1, [\ ],
    1, targ() , 1        , 1,    ),
    quantum-circuit(
    1, 1        , ctrl(1), 1, [\ ],
    1, $op("X")$, targ() , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), 1        , 1, [\ ],
    1, targ() , $op("X")$, 1,    ),
  )
), placement: none, caption: [Relationship between $op("X")$ and $op("CX")$ gates.])

#figure(rect(inset: 4mm,
  grid(
    columns: 3, rows: 5, align: center + horizon,
    column-gutter: 10mm, row-gutter: (8mm, 8mm, 0mm),
    quantum-circuit(
    1, $op("Z")$, ctrl(1), 1, [\ ],
    1, 1        , targ() , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), $op("Z")$, 1, [\ ],
    1, targ() , 1        , 1,    ),
    quantum-circuit(
    1, $op("Z")$, ctrl(1), 1, [\ ],
    1, $op("Z")$, targ() , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), 1        , 1, [\ ],
    1, targ() , $op("Z")$, 1,    ),
    quantum-circuit(
    1, 1        , ctrl(1), 1, [\ ],
    1, $op("Z")$, targ() , 1,    ),
    $equiv$,
    quantum-circuit(
    1, ctrl(1), $op("Z")$, 1, [\ ],
    1, targ() , $op("Z")$, 1,    ),
  )
), placement: none, caption: [Relationship between $op("Z")$ and $op("CX")$ gates.])


=== Bit Flip

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(3), ctrl(6), $op("H")$,                               1, ctrl(1), ctrl(2), 1         , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, targ() , 1      , 1         , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, 1      , targ() , 1         , 1, [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("H")$,                               1, ctrl(1), ctrl(2), 1         , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, targ() , 1      , $op("X")$ , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, 1      , targ() , 1         , 1, [\ ],
lstick($ket(0)$)                    , 1      , targ() , $op("H")$,                               1, ctrl(1), ctrl(2), 1         , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, targ() , 1      , 1         , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1, 1      , targ() , 1         , 1,     )
), placement: none, caption: [Bit flip error.])

Fix by treating inner codes an usual.


=== Phase Flip

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(3), ctrl(6), $op("H")$,                               ctrl(1), ctrl(2), 1        , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , 1        , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1        , 1, [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("H")$,                               ctrl(1), ctrl(2), 1        , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , $op("Z")$, 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1        , 1, [\ ],
lstick($ket(0)$)                    , 1      , targ() , $op("H")$,                               ctrl(1), ctrl(2), 1        , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), targ() , 1      , 1        , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , lstick($ket(0)$), setwire(1), 1      , targ() , 1        , 1,     )
), placement: none, caption: [Phase flip error.])

This circuit is indistinguishable to the following one, based on the identity above.
Note that $op("Z") ket(0) = ket(0)$.

#figure(rect(
quantum-circuit(
lstick($alpha ket(0) + beta ket(1)$), ctrl(3), ctrl(6), $op("H")$, 1        , 1,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), 1      , targ() , 1, [\ ],
lstick($ket(0)$)                    , targ() , 1      , $op("H")$, $op("Z")$, 1,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), 1      , targ() , 1, [\ ],
lstick($ket(0)$)                    , 1      , targ() , $op("H")$, 1        , 1,                               ctrl(1), ctrl(2), 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), targ() , 1      , 1, [\ ],
setwire(0)                          , 1      , 1      , 1        , 1        , 1, lstick($ket(0)$), setwire(1), 1      , targ() , 1,     )
), placement: none, caption: [Phase flip error equivalence.])



=== Probability of Error with Shor Code

#figure(
cetz.canvas({
  cetz.draw.set-style(
    axes: (stroke: .5pt, tick: (stroke: .5pt)), legend: (stroke: .25pt))

  plot.plot(size: (12, 8),
    x-tick-step: 0.1,
    x-min: 0.0, x-max: 1.0,
    y-tick-step: 0.1, y-min: 0.0, y-max: 1.0,
    legend: (9.1, 1.7),
    {
      plot.add(x => 1 - calc.pow(1 - x, 9) - 9 * x * calc.pow(1-x, 8), domain: (0.0, 1.0), label: "Shor Code")
      plot.add(x => x, domain: (0.0, 1.0), label: "No code")
    })
}),
caption: [$op("P")("error") = 1 - op("P")("< 2") = 1 - (1-p)^9 + 9 p (1-p)^8$],
placement: none)




== Pauli Matrices

$
  op("I") = mat(1, 0; 0, 1) #h(4mm) op("X") = mat(0, 1; 1, 0) #h(4mm) op("Y") = mat(0, -i; i, 0) #h(4mm) op("Z") = mat(1, 0; 0, -1)
$

$
  op("X") op("Y") = mat(0, 1; 1, 0) mat(0, -i; i, 0) = mat(i, 0; 0, -i) = i op("Z") \  
  op("Y") op("X") = mat(0, -i; i, 0) mat(0, 1; 1, 0) = mat(-i, 0; 0, i) = -i op("Z") \
  op("X") op("Y") = -op("Y") op("X") \
$

$
  op("X") op("Z") = mat(0, 1; 1, 0) mat(1, 0; 0, -1) = mat(0, -1; 1, 0) = -i op("Y") \  
  op("Z") op("X") = mat(1, 0; 0, -1) mat(0, 1; 1, 0) = mat(0, 1; -1, 0) = i op("Y") \
  op("X") op("Z") = -op("Z") op("X") \
$

$
  op("Y") op("Z") = mat(0, -i; i, 0) mat(1, 0; 0, -1) = mat(0, i; i, 0) = i op("X") \  
  op("Z") op("Y") = mat(1, 0; 0, -1) mat(0, -i; i, 0) = mat(0, -i; -i, 0) = - i op("X") \
  op("Y") op("Z") = -op("Z") op("Y") \
$

$
  op("X") op("X") = mat(0, 1; 1, 0) mat(0, 1; 1, 0) = mat(1, 0; 0, 1) = op("I") \
  op("Y") op("Y") = mat(0, -i; i, 0) mat(0, -i; i, 0) = mat(1, 0; 0, 1) = op("I")  \
  op("Z") op("Z") = mat(1, 0; 0, -1) mat(1, 0; 0, -1) = mat(1, 0; 0, 1) = op("I")  \
$

$
  op("X") op("Y") = mat(0, 1; 1, 0) mat(0, -i; i, 0) = mat(i, 0; 0, -i) = i mat(1, 0; 0 -1) = i op("Z") \
  op("Y") op("Z") = mat(0, -i; i, 0) mat(1, 0; 0, -1) = mat(0, i; i, 0) = i mat(0, 1; 1, 0) = i op("X") \
  op("Z") op("X") = mat(1, 0; 0, -1) mat(0, 1; 1, 0) = mat(0, 1; -1, 0) = i mat(0, -i; i, 0) = i op("Y") \
$

$
  op("Y") op("X") = -op("X") op("Y") = -i op("Z") \
  op("Z") op("Y") = -op("Y") op("Z") = -i op("X") \
  op("X") op("Z") = -op("Z") op("X") = -i op("Y") \
$



== Discrete Errors

$
  op("U") &= alpha op("I") + beta op("X") + gamma op("Y") + delta op("Z") \
          &= alpha op("I") + beta op("X") + gamma i op("X") op("Z") + delta op("Z")
$

$
  |alpha|^2 + |beta|^2 + |gamma|^2 + |delta|^2 = 1
$

=== Errors with Multiple Qubits

$
  op("I") #kron op("I") #kron op("X") #kron op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("I") = op("X")_6 \
  op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("Z") #kron op("X") #kron op("I") = op("Z")_2
$

=== Shor Code Discretization of Errors

$
  op("U")_k &= alpha op("I")_k + beta op("X")_k + gamma op("Y")_k + delta op("Z")_k \
          &= alpha op("I")_k + beta op("X")_k + gamma i op("X")_k op("Z")_k + delta op("Z")_k \
$

$
  op("U")_k = &alpha ket(op("I")_k "syndrome") #kron op("I")_k ket(psi) \
            + &beta ket(op("X")_k "syndrome") #kron op("X")_k ket(psi) \
            + &gamma i ket(op("X")_k op("Y")_k "syndrome") #kron op("X")_k op("Z")_k ket(psi) \
            + &delta ket(op("Z")_k "syndrome") #kron op("Z")_k ket(psi) \
$

== Pauli Group

$
  angle.l op("X"), op("Y"), op("Z") angle.r = {alpha op("P") | alpha in {1, -1, i, -i}, op("P") in {op("I"), op("X"), op("Y"), op("Z")}}
$

==== Example Subgroup

$
  angle.l op("X"), op("Z") angle.r = {op("I"), op("X"), op("Z"), -i op("Y"), i op("Y"), -op("Z"), -op("X"), -op("I")}
$

==== Example Subgroup where $n= 2$

$
  angle.l op("X") #kron op("X"), op("Z") #kron op("Z") angle.r = {op("I") #kron op("I"), op("X") #kron op("X"), op("Z") #kron op("Z"), -op("Y") #kron op("Y")}
$

$
(op("X") #kron op("X"))(op("Z") #kron op("Z"))
$

=== $n$ Bit Pauli Operations

#let colo(x, color: rgb("#F92A82")) = text(fill: color)[#x]
#let kron = $#kron$

$
  op("I") #kron op("I") #kron op("I") #kron op("I") &#colo([$<- n = 4, w t = 0$]) \ 
  op("I") #kron op("X") #kron op("I") #kron op("I") &#colo([$<- n = 4, w t = 1$]) \ 
  op("I") #kron op("X") #kron op("Z") #kron op("X") &#colo([$<- n = 4, w t = 3$]) \ 
  op("I") #kron op("I") #kron op("I") #kron op("I") #kron op("X") #kron op("X") &#colo([$<- n = 6, w t = 2$]) \ 
$


== Repetition Code as a Stabilizer Code

$
  alpha ket(0) + beta ket(1) &= alpha ket(000) + beta ket(111) \
$

=== Checks

$
  (op("Z") #kron op("Z") #kron op("I")) ket(psi) &eq.quest ket(psi) \
  (op("I") #kron op("Z") #kron op("Z")) ket(psi) &eq.quest ket(psi)
$


=== Stabilizer

$
  angle.l op("Z") #kron op("Z") #kron op("I"), op("I") #kron op("Z") #kron op("Z") angle.r = {op("I") #kron op("I") #kron op("I"), op("Z") #kron op("Z") #kron op("I"), op("I") #kron op("Z") #kron op("Z"), op("Z") #kron op("I") #kron op("Z")}
$

==== Minimal Generating Set

$
  {op("Z") #kron op("Z") #kron op("I"), op("I") #kron op("Z") #kron op("Z")}
$

==== Bit Flip Example

$
  ket(psi) -> (op("X") #kron op("I") #kron op("I")) ket(psi)
$

$
    &(op("Z") #kron op("Z") #kron op("I"))(op("X") #kron op("I") #kron op("I")) ket(psi) \
  = & -(op("X") #kron op("I") #kron op("I"))(op("Z") #kron op("Z") #kron op("I")) ket(psi) \
  = & -(op("X") #kron op("I") #kron op("I")) ket(psi) \
$
