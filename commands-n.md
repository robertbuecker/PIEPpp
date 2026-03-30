#####  Commands

The command line contains nothing but the command. In this description
the maximum number of expected input values is given in brackets. If the
command generates more than one question (i.e. input lines) the maximum
numbers of parameters per question are separated by "+" , e.g. (3 + 1 +
y/n). ("y/n" = yes/no)

**7.1 The most important commands**

**H** : list a short description of all commands (**h**elp) (0)

**HH** : **h**elp for a specified topic (1)

\# of the topic

**EN, EX, QU**: **en**d, **ex**it, **qu**it, all equivalent; (y/n) :
confirmation

**Preliminary note on paragraph 7.2: Conventions for cell parameter
input**

Remember **6.1.2.4:** Cell parameters <u>must</u> be given in Å !

The program determines the crystal class from the cell parameters. For
tetragonal and hexagonal (trigonal) cells the unique axes **must** be
the c-axis, for monoclinic cells the b-axis ("second setting").
Otherwise instead of tetragonal symmetry orthorhombic symmetry and
instead of hexagonal and monoclinic symmetry triclinic symmetry is
assumed. Settings which do not match these conventions can simply be
transformed using the command DE (Delaunay reduction).

The setting a = b = c, α = β = γ ≠ 90° of a rhombohedral cell is
automatically transformed to the hexa­go­nal R-centered setting.

Except for R-centering, trigonal symmetry is not distinguished from
hexagonal symmetry since intensities are not considered.

If the lengths of two axes of a cell parameter set which is close to
tetragonal, hexagonal or cubic differ by less than 0.001% they are
automatically equalized. Angles which differ by less than 0.005° from
90° or 120° are set to the corresponding rounded value. If higher
deviations from the ideal ratio or angle are to be adapted the command
"IS" can be used to **<u>i</u>**dealize the **<u>s</u>**ymmetry.

If centering is incompatible with the crystal system the program writes
an error message as soon as the cell parameters are to be used for
calculations, e.g. to index a pattern. For permitted centerings see
section 2.4.3. If e.g. an *A*-centered orthorhombic structure with a = b
is to be used, either slightly distort the equality a = b (e.g.
a=7.1234, b=7.1235) or inter­change b and c. The latter setting is not
recognized as being tetragonal.

A convenient and generally applicable way to enforce the triclinic
handling of a cell (e.g. to obtain all symme­trically equivalent
solutions of an indexing problem) is to replace α = 90° by α = 90.01°
(command AL).

**7.2: Cell parameters:**

**CP** : **c**ell **p**arameters (Å and °) and centering (6+1)

1st line: cell parameters

a&gt;0 : cell parameters

missing values are replaced by dummies (1 Å for axes, 90° for angles)

a&lt;0 : reciprocal cell parameters

**a=0 (blank line) <u>enables the assignment of additional cell
parameter files</u>**

2nd line: centering (def.: P, cf. "CN")

**A , B , C , AL , BE , GA** (1)

cell parameters, separately

&lt;0 : reciprocal

**CN** : **c**e**n**tering (col.1), upper or lower case (1), def.: P (or
p)

may be extended to space group symbol: text up to col. 11 is echoed.

**LG** : **g**et **l**attice constants from file L (1)

asks for the 4-character identifier of the set

blank reads the next set

**LW** : display (**w**rite) **l**attice **constant** file L (1)

0 : identifier, title, cell parameters and centering symbol (space
group) (3 lines)

≠0: identifier and title line only (one line per set)

**DE** : **De**launay reduction (3)

number of the transformation to be loaded (0: none, "1" is always the
reduced cell)

indicator for matrix output (0 : no, ≠0 : yes)

indicator for minimum or (&lt;0) exclusive symmetry to be output:

0: tricl., 1: monocl., 2: orthorh., 3: tetrag., 4: hexag.(trigonal), 5:
cubic

blank line: all transformations listed (to get the numbers to which
"number to be

loaded" refers) without matrix, cell parameters in work area are
retained.

See also sd

**IS :** **i**dealize **s**ymmetry (2 + y/n) : adapts cell parameters
which are close to a crystal

class of higher symmetry.

Input: accepted deviations from the "ideal" values for a/b etc.(%) and
angle (°)

if different from default values.

y/n : confirmation for loading to the work area

**L** : **l**ist content of the work area (cell parameters and SAD data)
(0)

**RN** : self‑acting **r**ewind of cell parameter file before LG, S1 and
SA: **n**o (0)

**RY** : — " — : **y**es (default) (0)

**RW** : **r**e**w**ind cell parameter file (0), important for "LG",
"SA" and "S1" on condition "RN"

**BG** : **g**et cell data from **B**‑memory (1): current number

**BP** : **p**ut cell parameters to **B**‑memory (1): Asks for a comment
to be assigned to the set.

After saving of the set (BS) col.1-4 of the comment act as identifier.

**BD** : **d**elete cell data from **B**‑memory (1)

&gt;0: specified number, &lt;0: all, 0: escape

**BW** : display (**w**rite) **B**-memory (0)

**BS** : **s**ave cell parameters from **B**‑memory on scratch file S
(1)

&gt;0: specified number, &lt;0: all, 0 (or blank): escape

**7.3 SAD data**

**TI** : **ti**tle of the SAD pattern (1)

**CC** : **c**amera **c**onstant or camera length with sigma (2 (+1))

&gt;0: camera constant (Åmm)

&lt;0: camera length (mm), then HV will be asked for

0: SAD data from file

**HV** : **h**igh **v**oltage or wavelength (1)

&gt;0: high voltage in V (not kV!)

&lt;0: wave length in Å

**R1** : **1**st **r**adius (or d-value), divisor (if a multiple has
been measured), sigma (3)

1st value &gt;0: distance (mm), &lt;0: d-value (Å)

e.g.: 22.4 7 means: 22.4mm, measured over 7 reflections = 3.2mm ,

-2.5 3 means: 2.5Å, measured over 3 reflections = 7.5 Å

In both cases missing 3<sup>rd</sup> value: default sigma (e.g. 3%).

Note: The sequence of divisor and sigma may be reversed by a switch in
the parameter file.

**R2** : **2**nd **r**adius (or d-value) (3)

as R1 for the second radius

**R3** : **3**rd **r**adius (or d-value) (6 + y/n)

length of vector r1‑r2 (as R1) (3) and optionally of r1+r2; (3) (same
line).

If the second triple is given, the angle is calculated from both
vectors. Both

results and their mean value are displayed. After confirmation the
latter

is accepted. Sigma is max(default sigma, difference of the two
calculated angles).

**AN** : **an**gle between r1 and r2 (°), sigma (2)

≠0: angle (automatically transformed to 0 ≤ angle ≤ 180°) and sigma

=0: branches to R3

**E1, E2, E3, EA, EC**: estimated errors for r1, r2, r3, angle, camera
const. (1)

**L0** : radius **L**aue zone **0**, sigma (2)

≥0: radius as given

&lt;0: tilt angle (°) with respect to the adjusted zone

**L1** : difference (radius **L**aue zone **1** ‑ Laue zone 0), sigma,
indicator lower limit (3)

&gt;0: difference of radii, if 3<sup>rd</sup> value ≠0: value is lower
limit

=0: indicates: no information

&lt;0: input is CC/ L1 ("d-value" (e.g. got from the measuring
function))

**C0** : **c**alculate radius of Laue zone **0** from the tilt angle of
the zone

*continued next page*

**  **

**SAD data, *continued***

**ND** : **n**ew **d**efault sigmas for radii, angle, camera const., L0,
L1 (5)

**DS** : replace sigmas of an SAD pattern (r, angle, camera const.)

by **d**efault **s**igmas (y/n)

**IR** : **i**nterchange r1 and r2 (0)

**RO** : **ro**tate r1, r2, r3: r1 → r2, r2 → r3, r3 → r1 (y/n)

**UN** : reduce ('**un**ify') an SAD pattern (y/n)

(minimize r1 + r2 + r3, make r1 the shortest, r3 the longest distance)

**GS** : definition of goniometer type, clear goniometer data,

calculate angle between **g**oniometer **s**ettings (1+4)

1st question: goniometer type: (1)

0: default type

1: double tilt

2: rotation tilt (not active)

3: double tilt, β = β<sub>0</sub> + factor · β<sub>obs</sub> (e.g. CM12)

&lt;0: clear existing data ( “no information“) **(important!)**

2nd question: depending on goniometer type: β<sub>0</sub> ,
α<sub>0</sub> or β<sub>0</sub> and factor

3rd question: angles (2 per orientation) (4),

repeated until blank is submitted

**GR** : (**r**ead) **g**oniometer angles associated with an SAD-pattern
(2)

**NP** : **n**ew **p**attern (y/n); starts automatic input sequence for
an SAD pattern

**LD** : **l**oa**d** calculated data (y/n + 1) (immediately after exit
from CR)

1st question: confirmation (y/n); if "y":

2nd question: title of the pattern

**L** : **l**ist of current parameters (work area), cell parameters
included (0)

**OR** : **o**utput: **r**adii (as measured, default) (0)

**OD** : **o**utput: **d**‑values (0) (additionally some other
quantities are converted:

camera constant to camera length, radius of zero order Laue zone to

tilt angle, radius of 1st order Laue zone to 1/d\*)

**Obsolete commands**

**EV** : **e**rror for **v**olume (relevant for I and SC if VY is set)
(1)

**D0**, **D1** : estimated errors (**d**elta) for L**0** and L**1** (1)

**  
7.4 : Data handling (move, delete, display, see diagrams 1 and 2):**

***cell parameter file (L or S) ⇒ work area:***

**LG** : **g**et **l**attice constants from file L (1)

**LW** : display (**w**rite) **l**attice constant file L (1)

**RW** : **r**e**w**ind cell parameter file L (0)

***cell parameters (work area) ⇔ B‑memory***:

**BP** : **p**ut cell parameters into **B**‑memory (1)

asks for a name to be assigned to the parameter set.

When saved by BS col. 1 – 4 are used as identifier.

**BG** : **g**et cell data from **B**‑memory, current number (1)

**BD** : **d**elete cell data from **B**‑memory, current numbers are
updated (1)

**BW** : display (**w**rite) **B**-memory (0)

***B-memory (cell parameters) ⇒ scratch file S***

**BS** : **s**ave cell param. from **B**‑memory on scratch file S (1)

&gt;0: specified number, &lt;0: all, 0: escape

***C-memory (cell parameters) ⇒ work area***

**CG** : **g**et cell parameters from **C**-memory (1)

**CW** : display (**w**rite) sorted cell parameter list from
**C**-memory

sorted by *R*, integral or volume (1)

***A‑memory(SAD data) ⇒ work area***

**AP** : **p**ut SAD data into **A**-memory (1)

**AG** : **g**et SAD data from **A**-memory (1)

**AD** : **d**elete SAD data from **A**‑memory (1)

**AW** : display (**w**rite) **A**-memory (0)

**LA** : **l**ist **A**-memory, short output: d-values (format f 9.4)
etc. (0)

***file P ( SAD-data)* ⇔ *work area :***

**PS** : **s**ave SAD data to file **P** (y/n)

appends current SAD data to file P

**PG** : **g**et a pattern from file **P** (1)

**PW** : display (**w**rite) file **P** (2)

**7.5 Indexing**

**I** : **I**ndex the pattern stored in the work area

using the cell parameters stored in the work area (0)

***conditions:***

**RL** : **r**igid **l**imits for r1, r2 and camera const. ) (1)

0=yes (default)

1=no (sigmas of (r1,r2) and camera constant are convoluted)

**MU** : maximum **mu**ltiplicity for indexing and maximum multiplicity
used by "DC" (2)

1st value: 0: 2 (default)

&gt;0: as given

&lt;0: infinite

2nd value (used by DC); default:2, max.:2

**WT** : **w**eigh**t**s for R-value (3)

blank line (or *<u>all</u>* 0): default values

otherwise: weights for deviations: angle(°), r1/r2(%), camera const. (%)

***output***

**L** : **l**ist of current parameters (work area) (0)

**OR** : **o**utput: **r**adii (as measured, default) (0)

**OD** : **o**utput: **d**‑values (0) (additionally some other
quantities are converted

for output, e.g. camera constant to camera length, radius of zero order

Laue zone to tilting angle, radius 2<sup>nd</sup> order Laue zone to
1/d\*

**ZA** : output **z**one **a**xes (h1 × h2) together with indexing
(on/off) (0)

**NR** : maximum **n**umbe**r** of solutions to be listed (1)

**CM** : **c**o**m**prehensiveness of output on protocol file 2 (1) (not
maintained)

0: maximal

1: medium

&gt;1: minimal

**PO** : **p**arallel **o**utput on protocol file 1 (on/off) (0)

**7.6 Search for cell parameters by scans through the cell parameter
file**

**SA** : **s**can through cell parameter file using SAD data from memory
**A** (2+1)

1st question: range for the reduced cell volume

2nd question: max. number of solutions per pattern to be echoed

**S1** : **s**can through cell parameter file using **1** SAD pattern
(the one in the work area) (2+1)

questions as with command SA

**7.7: Cell parameter determination:**

**PC** : **p**repare **c**ell parameter determination (2+2+2)

1.: \# of the **a**\*,**b**\*-defining SAD pattern (if different from
the proposed one),

2<sup>nd</sup>: 0: strategy is determined by the program

&lt;0: enforce full (3-dimensional) grid

&gt;0: "wall thickness" (2-dimensional case)

repeated until a blank line is submitted

2.: volume range (min. and max. volume) (2)

3.: step width param. for a\*-b\*-plane and for 1/c (2)

if only one value is given it is valid for both.

0: default values

&gt;0: factor by which default values are multiplied

&lt;0: absolute: step width parameter

**DC** : **d**etermine **c**ell parameters (3 (+ y/n (+ 1)))

1.: number of solutions to be echoed after each layer

2.: exclude zone \[001\] from determination of c\*: 0 = no, &gt;0 = yes

3.: write input file for GNUPLOT-representation? 0 = no, &gt;0 = yes

(3 is currently not available)

If memory C is not empty:

2nd question: handling of old solutions: 0=delete, 1=keep

If a GNUPLOT-file is demanded (currently not active):

2nd or 3rd question: filename (def.: "a.a")

**BR** : **br**eak conditions for SA, S1, DC (1)

0 : break after each match for SA and S1

1 : as 0 for SA and S1, after each match for DC

≥ 2 : none (default for DC)

**EQ** : limits for **eq**uivalence of cell parameter sets to be stored
in memory C (2)

**AX** : e**x**clude or include data set \#|n| in memory **A** from SA-
and DC-runs (1)

n&gt;0 : exclude the corresponding set (label ‘e’ in listing); n&lt;0
include again;

|n|&gt;15: exclude or include all data, respectively

**AI** : **i**nvert all "exclude"-marks in memory **A**; (blank → e, e →
blank)

**TE** : **t**emporary **e**rrors for SAD data during cell parameter
determination (y/n+3)

**CW** : display (**w**rite) sorted cell parameter list from
**C**-memory (1)

0: sorted by *R*, 1: sorted by integral, 2 or &gt;2: sorted by volume

**CG** : **g**et cell parameters from **C**-memory (1)

**DE** : **De**launay reduction, cf. section D2 "cell parameters"

**SD** : **s**can through C-memory, perform **D**elaunay reduction for
each entry (2)

1st question: start number (def.: 1 )

2nd question: minimal or exclusive symmetry of transformations to be
output:

0: tricl., 1: monocl., 2: orh., 3: tetr., 4: hex., 5: cub.

&gt;=0: minimum, &lt;0: exclusive

(**RF** : **r**e**f**ine cell parameters (currently not implemented))

*continued next page*

**Cell parameter determination, *continued***

**SS** : determine cell parameters from a **s**ingle **S**AD pattern

or from two patterns containing a common vector (2+3)

1st question: two numbers in A-memory (2)

r1 of both SAD data sets must coincide within 2%.

If none of the two patterns displays a mirror plane perpendicular r1

two cell parameter sets are calculated for each volume unless

1st number &lt;0: first set only

2nd number &lt;0: second set only

2nd question: Delaunay reduction of the reduced cells (1)

0 : no, output only reduced cells

1 – 5 : yes, the number stands for the the

lowest symmetry to be output:

1: mcl., 2: orh., 3: tetr., 4: hex., 5:cub.

-1 – (-5) : similar to 1 – 5,

however: <u>just</u> the specified symmetry

3nd question: volume or angular range: begin, end, step (3)

begin &gt;0: volume range

&lt;0: angular range

end =0 (⇒ step=0): calculation for V(begin) only

step =0: default value used

&gt;0: as given

&lt;0 (for volume scans only): &lt;%&gt; (100 ⋅
(V<sub>n+1</sub>-V<sub>n</sub>)/V<sub>n</sub> )

**  **

**7.8:** **Calculations:**

**CD** : **c**alculations in **d**irect space (angles, distances, vector
product), *x*,*y*,*z* input (9)

(*x,y,z*)<sub>1</sub>, (*x,y,z*)<sub>2</sub> , \[(*x,y,z*)<sub>0</sub>\]

repeated until blank is submitted

**CR** : **c**alculations in **r**eciprocal space, *hkl* input (7 (or
10) + y/n)

\#1-3: (*hkl*)<sub>1</sub>, \#4-6: (*hkl*)<sub>2</sub>, \#7: radius 0.
Laue zone or (&lt;0) tilt angle

If (*hkl*)<sub>2</sub> is omitted or set to 0,0,0, (*hkl*)<sub>1</sub>
is interpreted as zone axis in addition.

If \# 4 - 6 are given as 0,0,0, \#7 is interpreted as above,

and the three integers (*hkl*)<sub>3</sub> given as \# 8 – 10 are
transformed to the

coordinate system defined by the two reflections defining

zone \[*uvw*\] = (*hkl*)<sub>1</sub> x (*hkl*)<sub>2</sub> (a\* and b\*)
and an output FOLZ reflection as c\*.

The 2nd question asks whether the graphic representation is to be
omitted (y/n).

The sequence is repeated until a blank line is submitted

**LD** : **l**oa**d** calculated pattern (y/n + 1)

1st question: confirmation (y/n)

2nd question: title of the pattern

**GC**: **c**alculate angles between orientations from **g**oniometer
settings

of SAD-patterns in memory A (2) : numbers of the two patterns

**GS** : definition of goniometer type, clear goniometer data,

calculate angle between **g**oniometer **s**ettings (1+1+4)

1st question: goniometer type: (1)

0: no changes, 1: double tilt, 2: rotation tilt, 3: as 1, β=c\*x+
β<sub>0</sub> (cf. 7.3)

&lt;0: clears existing goniometer data (work area) (important!)

2nd question: α<sub>0</sub> (double tilt) or β<sub>0</sub> (rotation
tilt) (1) : offset angle of goniometer

or c and β<sub>0</sub> (2) (if type = 3)

note: this angle is used for navigation (OZ and AB)

3rd question: angles (2 per setting) (4), repeated, until blank is
submitted

**CZ** : find **c**losest **z**one (7) : input: indices of two zones and
maximum angle.

Calculates angles between the first zone and all zones which are related
by

symmetry to the 2nd zone, up to the maximum angle. Sorted by increasing
angle.

**MV** : 3x3-**m**atrix and **v**ector operations. **(tight conventions
for numeric input !)**

The command opens a subset of commands (lower case or upper case) :

**I1** : **i**nvert matrix **1** **L** : **l**ist vector, matrices and
cell

**I2** : **i**nvert matrix **2** **H** : **h**elp **M1**: input new
**m**atrix **1** **V** : input **v**ector

**M2**: input new **m**atrix **2** **MV**: product **m**atrix ·
**v**ector

**MM**: product **m**atrix · **m**atrix **VV**: **v**ector product of
two **v**ectors

**MI**: **i**nterchange **m**atrices 1 and 2 **VS**: **s**calar product
of two **v**ectors

**MA**: **a**pply **m**atrix 1 to the current **VM**: product **v**ector
· **m**atrix

cell parameters, optionally **EN** **en**d, exit mv

load the transformed cell

**MR**: **r**eset **m**atrix 1 to 1

Matrices 1 and 2 and one vector are held in memory.

**7.9:** **Measuring, calibration:**

**JE** : Input of SAED data in terms of projective lens deflector
currents (e..g. **Je**ol, page ??) (8)

x<sub>0</sub> , y<sub>0</sub> , x<sub>1</sub> , y<sub>1</sub> ,
n<sub>1</sub> , x<sub>2</sub> , y<sub>2</sub> , n<sub>2</sub> :
coordinates for zero point and for two reflections

with multiplicity

**JH** : as je , but hexadecimal (**J**eol, hexadecimal (prtest m2) )
1+1+1+1+1+1+1+1

x<sub>0</sub> , y<sub>0</sub> , x<sub>1</sub> , y<sub>1</sub> ,
n<sub>1</sub> , x<sub>2</sub> , y<sub>2</sub> , n<sub>2</sub> : as JE,
but hexadecimal and one line per value

**NC** : **n**ew **c**alibration: read calibration factors for je and jh
(1+1+2)

1st question: JH(0) or JE(1)

2nd: calibration for x (1) or y (2) or both (0)

3rd: calibration factor(s)

**HD** : convert **h**exadecimal integers to **d**ecimal (1+1)

1st question: hexadecimal number to be converted (a-f: lower case)

2nd: number of the stack register to which the result is to be
transferred

**7.10 :** **Navigation:**

**OZ** : read data of an **o**rientation determining **z**one (1+y/n+4
or 1+y/n+5)

1st question: number of the zone (1, 2 or 3; 3 only after 1 <u>and</u> 2
have been input)

2nd: goniometer angles from memory A? (y/n)

3rd: *u, v, w,* \# of the pattern in memory A ((4) if 2nd answer = yes)

or *u, v, w,* α, β ((5) if 2nd answer = no)

"0" or blank deletes the data of the specified zone

**AB** : calculate **a**lpha and **b**eta for a desired zone (4)

*u, v, w* , (maximal angle for α and β (double tilt) or α (rotation
tilt))

repeated until a blank line is submitted

**CZ** : angles between zones \[u1 v1 w1\] and \[u2 v2 w2\] (and its
equivalents): see **7.8**

**GC** : angles between zones in memory A from goniometer angles: see
**7.8**

**GU** : **G**oniometer angles for all zones accessible within a given
**u**pper limit for β and α.

Maximum value of |*u| ,|v|,|w|* is asked for.

**7.11 : Screen layout:**

**YX** : parameters for graphics (scale, ratio **y**/**x**) (3)

scale factor, ratio height/width of a character for screen, ratio for
line printer

**NL** : **n**umber of **l**ines per screen (1)

**7.12: Pocket calculator (RPN = reversed polish notation)**

The four stack registers and the memory register are displayed as soon
as an operation is performed. To merely display the registers (without
performing an operation), use command "." followed by any letter in
col.1 of the next line.

**.** : load a number to the *x*-register of the stack (register 1) and
shift the stack

(the content of register 4 is lost)

| 1 | 2 | 3 | 4 | → | *x* | 1 | 2 | 3 |

**..** : shift the stack and keep register 1 (the content of register 4
is lost)

| 1 | 2 | 3 | 4 | → | 1 | 1 | 2 | 3 |

**+** , **−** , **\*** , **/** , **\*\*** : operation between contents
of reg.2 and 1,

e.g. "/" means: reg.2 / reg.1

With 'r' = result, the effect on the stack is as follows:

| 1 | 2 | 3 | 4 | → | r | 3 | 4 | 4 |

**LX** : **l**ast ***x***. The effect after the above operations is:

| r | 3 | 4 | 4 | → | 1 | r | 3 | 4 |

**RE** : 1/*x* (**re**ciprocal)

**CS** : -*x* (**c**hange **s**ign)

**SQ** : *x*<sup>2</sup> (**sq**uare)

**RT** : √ *x* (square **r**oo**t**)

**SI** : **si**n *x*

**AS** : **as**in *x*

**CO** : **co**s *x*

**AC** : **ac**os *x*

**TG** : **t**an(**g**ens) *x*

**AT** : **at**an *x*

**E\*** : exp(*x*) (**e\***\**x*, e*<sup>x</sup>* )

**LO** : **lo**garithm (base e) (ln *x*)

After these commands (result "r") the stack is modified as follows :

| 1 | 2 | 3 | 4 | → | r | 2 | 3 | 4 |

Except for cs and re the effect of lx is

| r | 2 | 3 | 4 | → | 1 | r | 2 | 3 |

Stack manipulations:

**&lt;** | 1 | 2 | 3 | 4 | → | 2 | 3 | 4 | 1 |

**&gt;** | 1 | 2 | 3 | 4 | → | 4 | 1 | 2 | 3 |

**&lt; &gt;** | 1 | 2 | 3 | 4 | → | 2 | 1 | 3 | 4 |

**MP** : **p**ut content of reg.1 to **m**emory (stack is not affected)

**MG** : **g**et content of **m**emory (M):

| 1 | 2 | 3 | 4 | → | M | 1 | 2 | 3 |

*continued next page*

**Pocket calculator (RPN), *continued***

direct loading ***to*** a specified register:

**.1** : | 1 | 2 | 3 | 4 || m | → | *x* | 2 | 3 | 4 || m |

**.2** : | 1 | 2 | 3 | 4 || m | → | 1 | *x* | 3 | 4 || m |

**.3** : | 1 | 2 | 3 | 4 || m | → | 1 | 2 | *x* | 4 || m |

**.4** : | 1 | 2 | 3 | 4 || m | → | 1 | 2 | 3 | *x* || m |

**.M** : | 1 | 2 | 3 | 4 || m | → | 1 | 2 | 3 | 4 || *x* |

loading ***from*** a specified register to the input line

**!1** or **!!** : from reg.1

**!2** : from reg.2

**!3** : from reg.3

**!4** : from reg.4

**!M** : from memory register (M)
