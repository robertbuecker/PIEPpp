**Unit cell parameters determination from a set of independent electron diffraction zonal patterns**

*Tatiana E. Gorelik<sup>a</sup>,* *Gerhard Miehe<sup>b</sup>, Robert
Bücker<sup>c</sup>, Kaname Yoshida<sup>d</sup>*

<sup>a</sup> Helmholtz Centre for Infection Research, Department
Structure and Function of Proteins, Inhoffenstraße 7, 38124,
Braunschweig, Germany.

<sup>b</sup> Darmstadt Technical University, Germany.

<sup>c</sup> Rigaku Corporation, 3-9-12 Matsubara-cho, Akishima-shi,
Tokyo 196-8666, Japan; Rigaku Europe SE, Hugenottenallee 167,
Neu-Isenburg 63263, Germany.

<sup>d</sup> Nanostructures Research Laboratory, Japan Fine Ceramics
Centre, 2-4-11 Mustuno, Atsuta-ku, Nagoya, 456-8587 Japan.

# Abstract

Due to the short de-Broglie wavelength of electrons compared to X-rays,
the curvature of their Ewald sphere is low, and individual electron
diffraction patterns are nearly flat in reciprocal space. As a result, a
reliable unit cell determination from a set of randomly oriented
electron diffraction patterns, being an essential step in serial
electron diffraction, becomes a non-trivial task. Here we describe an
algorithm for unit cell determination from a set of independent electron
diffraction patterns as implemented in the program ***PIEP***
(**<u>P</u>**rogram for **<u>I</u>**nterpreting **<u>E</u>**lectron
diffraction **<u>P</u>**atterns), written in early nineties. We evaluate
the performance of the algorithm by unit cell determination of two known
structures – copper perchloro phthalocyanine (CuPcCl<sub>16</sub>) and
lysozyme, challenging the algorithm by high-index zone patterns and long
crystallographic axes. Finally, we apply the procedure to a new,
structurally not characterized five amino acids peptide.

# Synopsis

We present an algorithm for unit cell determination from a set of
randomly oriented electron diffraction patters and demonstrate its
performance for two known structures - copper perchloro phthalocyanine
and lysozyme, and one structurally not yet characterized material.

# Keywords

Electron crystallography, 3D ED, MicroED, SerialED, unit cell parameters
determination

# Introduction

All crystallographic analyses rely on the knowledge of unit cell
parameters. For single-crystal X-ray data, unit cell determination
usually requires one or more diffraction patterns and a geometrical
description of the experimental conditions, such as radiation
wavelength, camera length, etc. The wavelength of X-rays is of the order
of typical diffraction data resolution, such that the radius of the
Ewald sphere is comparable to the size of the entire reciprocal lattice
accessible in an experiment. As a result, each recorded pattern is a
strongly curved slice through reciprocal space, giving rise to a
three-dimensional geometry of scattering vectors encoded in measured
spot positions. Then, either using 3D difference vectors, or Fourier
transformation, the primitive lattice basis vectors can be extracted
(Powell et al., 2012).

The situation is different for electron diffraction (ED). While the
exact de Broglie-wavelength of electrons depends on the acceleration
voltage, with typical values between 0.0335 Å (120 kV) and 0.0197 Å (300
kV) in transmission electron microscopes (TEMs), those are two orders of
magnitude smaller than wavelengths used in an X-ray experiment. As a
result, the part of the Ewald sphere accessible via diffraction spots
recorded in a single ED pattern at typical resolution is effectively
flat, and essentially no 3D lattice information can be extracted. While
reflections from higher order Laue zones can be seen and used for the 3D
lattice determination (Morniroli & Steeds, 1992; Shi, 2022), weakly
scattering organic materials rarely show those reflections, making unit
cell determination from a single zonal pattern impossible.

In 1960s Vainshtein (Vainshtein, 1964) proposed a simple 2-dimensional
lattice reconstruction method based on a tilt series of ED patterns.
These patterns were collected through a crystal tilt around a selected
crystallographic axis, usually low-index or main axis. For the lattice
reconstruction it was essential to know the angular relationship between
separated ED patters. The method was effectively used for the unit cell
determination from ED patterns of many nanocrystalline materials (Wu &
Spence, 2003; Kolb & Matveeva, 2003; Dorset et al., 2005; Gorelik et
al., 2009; Sun et al., 2010). One of the highlights of the method was
the discovery of quasicrystals in 1980s (Shechtman et al., 1984).

Following this approach, a so-called Vainshtein plot could be
constructed in three dimensions, mapping out a sufficient section of the
3D reciprocal space for lattice parameter determination. The procedure
included two steps – (i) the reduction of experimental ED patterns into
sets of reflection coordinates, and (ii) the reconstruction of 3D
coordinates of these reflections based on the known angular relationship
between the patterns. This was a relatively simple geometrical task,
several home-written packages were used for this purpose, and even a
commercial software (TRICE) was created (Zou et al., 2004).

The idea of using a defined angular relationship between patterns was
initially the basis for the development of 3D ED (also known as MicroED)
techniques pioneered by the Mainz group (Kolb et al., 2007; Kolb et al.,
2008). Later, the idea of zone pattern collection was abandoned in
favour of a method involving the rotation of crystals around an
*arbitrary* crystallographic axis in small, regular goniometer tilt
steps or during continuous rotation (Nederlof et al., 2013; Nannenga et
al., 2014), resulting in the collection of off-axis patterns, in analogy
to a typical single-crystal X-ray diffraction experiment. By projecting
the reflection positions onto 3D reciprocal space and analysing their
coordinates, the 3D lattice vectors can be extracted. The 3D ED/MicroED
method has fast gained popularity and is now an established technique of
structure analysis, applied to diverse materials (Gemmi et al., 2019)
using both electron microscopes and dedicated diffractometers (Ito et
al., 2021; Simoncic et al., 2023).

Application of 3D ED to extremely electron beam sensitive materials is
still a challenging task. For relatively large crystals, so called
“helical” data collection can be used – with a small electron beam
moving along the crystal as it is being tilted (Brazda et al., 2019). In
this way, all patterns are collected from a fresh, previously unexposed
area of the sample, while retaining a known relative orientation. Still,
in certain cases, the beam sensitivity of a crystal does not allow
collection of even a short tilt sequence, which would allow to obtain
the lattice basis vectors. Furthermore, large thin crystals are often
bent, or deform under irradiation. As a result, the 3D diffraction
volume is highly distorted and difficult to analyse.

The problem of small beam-sensitive crystals is well known in protein
X-ray crystallography and lead to the development of the serial
crystallography approach (Chapman et al., 2011), where single
diffraction snapshots of a large number of randomly oriented crystals
are collected, using X-ray free-electron lasers (XFELs) or microfocus
synchrotron beamlines (Stellato et al., 2014). For XFELs, the
irradiation time on the femtosecond scale is deemed shorter than
relevant damage processes, whereas at synchrotrons radiation doses per
snapshots are matched to the damage threshold of the crystal. A single
diffraction pattern is collected from an individual crystal, effectively
distributing radiation damage over many crystals. Indexing of each
diffraction pattern and subsequent merging of data from all crystals
creates high-quality datasets, able to provide a reliable structure
solution. Mature packages for snapshot processing are now available
(White et al., 2012; Brewster et al., 2018; Kabsch 2014).

The attractive idea of automatic single diffraction patterns collection
from individual nanocrystals was readily overtaken by electron
crystallographers (Smeets et al., 2018; Bücker at al., 2020,
Hogan-Lamarre et al., 2024). The application of serial electron
diffraction was successfully demonstrated for different zeolites (Smeets
et al., 2018), hen egg white lysozyme and crystalline granulovirus
shells (Bücker at al., 2020). Reflection indexing in separate ED
patterns was done based on the pre-knowledge of the lattice parameters.

The need of the pre-knowledge of the unit cell metric enormously
restricts the use of serial electron diffraction. As mentioned above, ED
patterns are essentially “flat” and do not contain 3D information.
However, a suitable mathematical treatment of a combined set of ED
patterns should provide information on all three lattice vectors.

An algorithm for unit-cell determination from randomly oriented ED
patterns was proposed by Jiang (Jiang et al., 2009). In the first step,
similarly to Vainshtein’s method, information in diffraction patterns
was reduced to the coordinates of Bragg reflections. In each pattern two
shortest pattern basis vectors were defined. Autocorrelation of the
whole diffraction pattern was used to assist the vector determination.
From these pairs of vectors, triangular facets were constructed,
characterized by the lengths of the two vectors and the angle between
them. Assuming the Ewald sphere being essentially flat, the following
holds: intersection of a 3D reciprocal lattice with a diffraction plane
generates a 2D lattice (zone pattern), thereby defining a facet. In the
second step, a list of potential 3D unit cells was generated by a grid
search, and principal facets were calculated for each cell. The match of
experimental and simulated facets was characterised by a figure of merit
(FOM). The lowest FOM provided the correct unit cell. This algorithm was
implemented in the software package EDIFF (Jiang et al., 2011) and was
validated by unit cell determination of mayenite, potassium penicillin
G, sodium oxacillin, and the orthogonal morphology nanocrystals of hen
egg-white lysozyme (Jiang et al., 2009).

A few decades earlier a similar program was developed by Gerhard Miehe
(Miehe, 1997), which contains a set of simple and powerful algorithms,
that hitherto were unpublished. The program was named PIEP
(**<u>P</u>**rogram for **<u>I</u>**nterpreting **<u>E</u>**lectron
diffraction **<u>P</u>**atterns) and included many possibilities for ED
data processing, among other options, determination of the unit cell
basis vectors from a set of randomly oriented ED patterns, successfully
used in many structural studies (Horvath‐Bordon et al., 2007; Schmitt et
al., 2010; Liu et al., 2016).

With the recent developments in the field of serial electron diffraction
(Bücker et al., 2020), we foresee the need for a robust algorithm for
unit cell determination from a set of diffraction patterns with
uncorrelated orientations. Therefore, we decided to test the GM
algorithm as implemented in *PIEP* for cell metric determination for
several materials. Three different materials were used for the study –
two with known structures (chlorinated copper phthalocyanine and
lysozyme), and a crystalline peptide GRGDS, which is not structurally
characterized yet. The molecular structures of the chlorinated copper
phthalocyanine and GRGDS peptide are shown in Figure 1.

In this work we describe the algorithm for unit-cell parameter
determination used in PIEP, discuss its strength and limitations, and
demonstrate the use of PIEP for unit cell determination from a set of
experimental randomly oriented ED zonal patterns for three different
compounds - two materials with known structures and one unknown.

<figure>
<img src=".\pub_figures/media/image1.png"/>
<figcaption><p>Figure 1 Molecular schemes of the studied compounds:
chlorinated copper phthalocyanine and peptide GRGDS.</p></figcaption>
</figure>

# Methods

## Test samples and test data

### Copper perchloro-phthalocyanine 

The copper perchloro phthalocyanine (CuPcCl<sub>16</sub>) nanocrystals
were prepared directly on a TEM grid as described in (Gorelik et al.,
2021).

Bright-field scanning transmission electron microscopy (STEM) images
were taken with a ThermoFisher Scientific TALOS TEM.

The obtained crystals were platelets with a very distinct morphology
(Figure 2) with the lateral size of 0.5 µm approximately. Occasionally,
needle-like crystals were found. Despite the difference in morphology,
the needle-like crystals had the same crystalline structure as the
platelets. Platelets had wedge-like shape; their thickness was varying
from a few to 30 nm (Yoshida, 2015).

<figure>
<img src=".\pub_figures/media/image2.png"/>
<figcaption><p>Figure 2 Bright-field STEM
images of CuPcCl<sub>16</sub> crystals recorded at different
magnification.</p></figcaption>
</figure>

<figure>
<img src=".\pub_figures/media/image3.png"/>
<figcaption><p>Figure 3 Typical dark-field STEM image of vitrified lysozyme crystals.
A) Grid region from which serial electron diffraction data are collected
within a single run, by sequentially moving the beam on the crystals
after automatic selection using image processing (red dots). B) Close-up
into a sub-region with single sub-micron lysozyme crystals.</p></figcaption>
</figure>

### Lysozyme data

Lysozyme is a single-chain polypeptide of 129 amino acids with the
molecular weight of 14,307 Da (Jolles, 1969). Different polymorphs of
lysozyme were reported in PDB (Bernstein et al., 1977), here electron
diffraction data of a tetragonal form, crystallizing in the space group
*P4<sub>3</sub>2<sub>1</sub>2* was used (Weiss et al., 2000). The data
analysis carried out in this work uses the serial electron
crystallography data as presented by Bücker et al. (Bücker et al.,
2020). In brief, lysozyme crystals were crushed by vortexing to obtain
sub-micron sized crystallites and plunge-frozen on a TEM grid in liquid
ethane. In Figure 3, a typical dark-field STEM image of a grid region is
shown. After automatic identification of crystals in the images, ≈ 1300
diffraction patterns were collected from a few dozens of regions.

To solve the protein structure, data was pre-processed using the package
*diffractem* (Bücker et al., 2021) assuming lattice constants of
a = b = 79.1 Å, c = 38 Å, which led to successful indexing of ≈ 1050
patterns using the *pinkIndexer* grid-search algorithm (Gevorkov et al.,
2020). The raw diffraction data and data processing results are
available from the Max Planck Digital Library EDMOND data repository at
<https://dx.doi.org/10.17617/3.53>; the resultant protein structure is
available from wwPDB using the code 6S2N.

### GRGDS

GRGDS is a 5 amino acids peptide. The crystal structure of the material
is unknown. GRGDS peptide was purchased from GenScript Biotech (Leiden,
Netherlands). After several attempts to obtain nanocrystals suitable for
ED structure analysis, crystals of GRGDS were eventually grown from
methanol directly on TEM grids using the following procedure: a drop of
the solution was placed onto a carbon-coated copper TEM grid and slowly
dried in a vessel with a volume less than 1 cm<sup>3</sup>, closed by a
piece of preparative glass. These crystals were then used for the unit
cell determination. GRGDS crystals grew as agglomerates of needles with
the width of less than 0.5 µm, and the length of around 10 µm (Figure
4).

The molecular volume estimated from the molecular structure (Hofmann,
2002) is 585 A<sup>3</sup>.

<figure>
<img src=".\pub_figures/media/image4.png" />
<figcaption><p>Figure 4 TEM image of GRGDS crystals.</p></figcaption>
</figure>

## Electron diffraction data collection

For CuPcCl<sub>16</sub> and GRGDS samples the TEM experiments were
performed using a ThermoFisher Titan transmission electron microscope
operated at 300 kV equipped with an objective Cs corrector. The data
were collected using a Fischione Advanced Tomo Holder 2020 at room
temperature. In TEM mode the beam-forming optics were set to
nanodiffraction mode with the C2 aperture of 50 µm. Diffraction patterns
were recorded with an effective beam diameter on the sample varied
between 100 and 500nm. The samples were randomly tilted in order to
access mostly different zone axes. Diffraction data were recorded with a
2k Gatan UltraScan CCD.

For Lysozyme, data was collected on a Philips Tecnai F20 S/TEM equipped
with a X-Spectrum Lambda 750k pixel array detector in defocused
nanoprobe STEM mode with a C2 aperture of 5 µm, resulting in a
collimated beam of approximately 110 nm. Crystals previously found in
dark-field STEM images of grid regions were addressed by the beam using
direct control of the STEM deflectors, synchronized to detector
read-out.

## Characteristic electron dose

For CuPcCl<sub>16</sub> and GRGDS, series of ED patterns were
sequentially collected from the same part of the crystals to quantify
the electron radiation stability of the sample. The data were measured
at room temperature. The characteristic electron dose is defined as the
point at which the intensities of electron diffraction peaks are reduced
to 1/e of its initial value (Kolb et al., 2010). Reflections within
different resolution shells showed slightly different decay profiles. An
average value was used for the characteristic dose calculation. The
characteristic electron dose at 300 kV and room temperature for
CuPcCl<sub>16</sub> was measured to be 7.6∙10<sup>3</sup>
e/Å<sup>2</sup>, for GRGDS 0.5 e/Å<sup>2</sup>. For lysozyme, as
discussed in (Bücker et al., 2020), dose-fractionated diffraction
exposures were used; optimum data quality was obtained for a dose of 2.6
e/Å<sup>2</sup> per crystal.

## Zone basis vectors extraction

From a pool of ED patterns, some particularly prominent ones, that is,
with the shortest interplanar distances and with the highest symmetry,
were selected by visual inspection. For these patterns, the basis
vectors were calculated using two different approaches: based on manual
selection of lattice basis vectors with subsequent least-squares
refinement (ESI, section 1.1), and autocorrelation of diffraction
patterns (ESI, section 1.2). For each pattern, the most confident
solution was used.

## The GM algorithm

In the following, the algorithm (here referred to as GM-algorithm, for
the developer - Gerhard Miehe) that underlies the determination of unit
cell parameters from a set of independent electron diffraction zonal
patterns by PIEP will be presented. Like the algorithm of Jiang et al.
(2009, 2011), the GM algorithm applies a trial-and-error approach. The
applied strategy, however, is different. It has briefly been described
in (Miehe, 1997) and will be detailed here.

The initial step in the data processing involves the reduction of a 2D
experimental ED pattern down to a set of two basis vectors. The vectors
can either be defined by the scalar lengths of two vectors,
|***r<sub>1</sub>***| and |***r<sub>2</sub>***|, and an angle between
them ***φ***, or as the scalar lengths of three vectors
(|***r<sub>1</sub>***|, |***r<sub>2</sub>***|, vector
|***r<sub>1</sub>***-***r<sub>2</sub>***|, optionally
|***r<sub>1</sub>***+***r<sub>2</sub>***|).

Direct and reciprocal lattice vectors are related by well-known
equations. Six cell parameters (lengths *a*, *b*, *c* and angles *α*,
*β*, *γ*, or their reciprocal counterparts’ lengths *a\**, *b\**, *c\**
and angles *α\**, *β\**, *γ\**) define a primitive unit cell. The key
premise of the GM algorithm is the fact that *each of the N given ED
patterns is suited to define zone \[001\] of one setting of the
associated unit cell*. Hence, three of the six reciprocal cell
parameters of that cell can be considered as known – say, *a\**, *b\**
and *γ\**. The missing three cell parameters are found by scanning
vector ***c\****, defined by its three components *x, y, z* on an
appropriate grid, using an appropriate step-width within a
three-dimensional vector space spanned by the orthogonal system:

***a<sub>0</sub>***\* = ***a***\*, ***c**<sub>0</sub>*\*= ***a***\* ×
***b***\*, ***b**<sub>0</sub>*\*= (***c**<sub>0</sub>*\* ×
***a**<sub>0</sub>*\*) / |***a<sub>0</sub>\****|

The grid scan is parametrized using scalar coordinates *x, y, V\**,
where *x* and *y* are defined as components of ***c\**** along the
***a<sub>0</sub>*\*** and ***b<sub>0</sub>**\** axes, respectively. To
inherently optimize the domain and step size of the grid search for the
problem at hand, the third scan coordinate is given by the reciprocal
lattice volume *V\**, implicitly defining the component of ***c\****
along the ***c<sub>0</sub>*\***-axis. The 3D scan is performed in layers
of constant *V\**:

–½|***a**<sub>0</sub>\**| &lt; x ≤ ½|***a**<sub>0</sub>\**|, 0 ≤ y ≤
½|***b**<sub>0</sub>\**|, *V\**<sub>min</sub> &lt; *V\** &lt;
*V\**<sub>max</sub>.

This range (Figure 5a) delineates the primitive unit cell for the most
general case, which will have *p1* symmetry. For the symmetry notation,
we use the plane group of the pattern, disregarding the intensity of
reflections.

Within this scan range, candidate cells are generated from each unique
value of ***c\**** and used to attempt indexing of the remaining *N-1*
patterns. If indexing fails for any of those, the current value of
***c\**** is discarded, and the procedure is repeated using the next
candidate. If all patterns can be indexed within given tolerances, the
cell is stored together with a reliability index **R**, which is derived
from the individual indexing tolerances of the *N-1* patterns. These
individual indexing tolerances, in turn, are formed from the sum of the
weighted mismatches of (1) the ratio of basis vectors in the diffraction
pattern |***r<sub>1</sub>***|/|***r<sub>2</sub>***|, (2) the angle
between the vectors in the pattern ***φ***, and (3) the overall pattern
scaling factor (camera constant ***C***, see ESI). The weighting
parameters, *w<sub>1</sub>*, *w<sub>2</sub>*, and *w<sub>3</sub>*, are
defined in the ASCII parameters file *piep.par* and can be modified as
needed. The specific set of values: *w<sub>1</sub>*=0.008 (equivalent to
0.8% contribution from the mean
|***r<sub>1</sub>***|/|***r<sub>2</sub>*** | mismatch), *w<sub>2</sub>*
= 0.006 (0.6% contribution from the ***φ*** mismatch), and
*w<sub>3</sub>* = 0.003 (0.3% contribution from the pattern scaling
mismatch) was empirically determined to produce stable runs and was used
in all calculations.

$$R = w\_{1}\sum\_{i = 1}^{N - 1}{|\frac{r\_{1i\\exp}}{r\_{2i\\exp}} - \frac{r\_{1i\\calc}}{r\_{2i\\calc}}|} + \\w\_{2}\sum\_{i = 1}^{N - 1}{|\varphi\_{i\\exp} - \varphi\_{i\\calc}|} + w\_{3}\sum\_{i = 1}^{N - 1}{|C\_{i\\exp} - C\_{i\\calc}|}$$

<figure>
<img src=".\pub_figures/media/image5.png"/>
<figcaption><p>Figure 5 Schematic representation of the scan
dimensionality for different symmetries: a) a general case, initial
pattern has p1 symmetry, 3D cell search. Left side: the (hk0) plane
showing the a<sub>0</sub> and b<sub>0</sub> vectors definition and the
base of the unit cell for the cell search; right side: a scheme for the
grid search in the reciprocal space. The z-axis represents V*. Scans are
performed in layers of constant V*, varying the x and y components of
the vector <strong>c</strong>. b) The initial pattern has a pmm
symmetry, reducing the search to a 2D search along four mirror planes;
c) initial pattern with cmm symmetry – 2D search along three mirror
planes; d) initial pattern corresponding to a mirror plane (e. g.
monoclinic crystal system, initial pattern [010] zone) and higher
symmetries – 1D scan.</p></figcaption>
</figure>

If possible, higher Laue zones should be evaluated to determine rough
limits for the expected volume of the reduced cell and to recognize
possible mirror planes (see below) in the structure (Shi & Li, 2021).

After the last layer (*V\*= V\**<sub>max</sub>) has been processed, the
reduced settings of the stored cells are displayed, sorted by the
R-indices. The correct cell should be found at the very beginning of the
list. Optionally, a Delaunay reduction (Patterson & Love, 1957) is
performed to determine the conventional settings of cells. For this
purpose, the slightly modified code of the program DELOS (Zimmermann et
al., 1985) is integrated in PIEP.

For this most general strategy, the handling of triclinic symmetry is
intrinsic. The accuracy of results depends mainly on the accuracy of
input data. In test runs with a set of simulated diffraction patterns,
assuming perfect measurement, the accuracy of the found unit cell
depends solely on the step size of the scan, which can be minimized at
will.

If a diffraction pattern displays a ‘true’ mirror plane (see below),
either *pmm* or *cmm*, the symmetry of the associated cell will be
higher than triclinic. Such patterns are particularly suited for
defining the initial zone \[001\].

A mirror plane within the plane *hk0* is ‘*true*’ (not accidental) if it
acts also on plane *hk1*, the trace of which is the first-order Laue
zone (FOLZ). If FOLZ-reflections are visible, this condition can be
verified. If extinctions due to a screw axis are present, it is surely
fulfilled. Any reflection in plane *hk1* may serve as a reflection 001.
Therefore, the search can be confined to the 4 potential mirror planes:
x=0, x=½|a<sub>0</sub>\*|, y=0 and y=½|b<sub>0</sub>\*| (for the *pmm*
case). The asymmetric units within these mirror planes are given below.
This way, the scan becomes two-dimensional (Figure 5b).

<table style="width:68%;">
<colgroup>
<col style="width: 2%" />
<col style="width: 13%" />
<col style="width: 16%" />
<col style="width: 18%" />
<col style="width: 17%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;"></th>
<th style="text-align: left;">x = 0</th>
<th style="text-align: left;">0 ≤ y ≤
½|<em><strong>b<sub>0</sub>*</strong></em>|</th>
<th style="text-align: left;"><em>V*</em><sub>min</sub> ≤ <em>V</em> ≤
<em>V*</em><sub>max</sub></th>
<th style="text-align: left;"></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;">x =
½|<em><strong>a<sub>0</sub>*</strong></em>|</td>
<td style="text-align: left;">0 ≤ y ≤
½|<em><strong>b<sub>0</sub>*</strong></em>|</td>
<td style="text-align: left;"><em>V*</em><sub>min</sub> ≤ <em>V</em> ≤
<em>V*</em><sub>max</sub></td>
<td style="text-align: left;"></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;">y = 0</td>
<td style="text-align: left;">0 &lt; x &lt;
½|<em><strong>a<sub>0</sub>*</strong></em>|</td>
<td style="text-align: left;"><em>V*</em><sub>min</sub> ≤ <em>V</em> ≤
<em>V*</em><sub>max</sub></td>
<td style="text-align: left;"></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;">y =
½|<em><strong>b<sub>0</sub>*</strong></em>|</td>
<td style="text-align: left;">0 &lt; x &lt;
½|<em><strong>a<sub>0</sub>*</strong></em>|</td>
<td style="text-align: left;"><em>V*</em><sub>min</sub> ≤ <em>V</em> ≤
<em>V*</em><sub>max</sub></td>
<td style="text-align: left;">(for <em>pmm</em> only)</td>
</tr>
</tbody>
</table>

This condition can be easily explained for a monoclinic structure. If a
zone pattern displays *2mm* symmetry, the unique monoclinic axis must be
one of the orthogonal basis vectors of this zone – either
***a<sub>0</sub>\**** or ***b<sub>0</sub>\****. The other basis vector
will correspond to one of the h0l reflections. The third, unknown basis
vector of the lattice, ***c\****, must be orthogonal to unique
monoclinic axis and thus must lie in a vertical plane, either orthogonal
to ***a<sub>0</sub>\**** or to ***b<sub>0</sub>\****. Consequently, the
possible c\* vectors span these vertical planes (Figure 5b), with the
***a\****-***b\****-defining plane being any of \[h0l\]. For a
monoclinic-centered lattice, the situation is somewhat different. The
*cmm* pattern can have any \[h0l\] index with l≠0. This condition
further restricts the number of solutions (Figure 5c).

The distribution of solutions can be visualized by plotting an ‘*inverse
FOM*’ *F*<sub>inv</sub> = *1/***R** (maximum for best fit) in these 4
planes: *F*<sub>inv</sub> = *F*<sub>inv</sub> (y, V\*) and
*F*<sub>inv</sub> = *F*<sub>inv</sub>(x, V\*).

For special cases of *pmm* and *cmm*, namely *p4* and *p6*,
respectively, the range to be scanned can further be restricted; two
linear scans of V\* will be sufficient (Figure 5d). If the initial zone
\[001\] displays symmetry *p4m*, the unit cell ought to be tetragonal.
V\* is scanned between *V\*<sub>min</sub>* and *V\*<sub>max</sub>*, the
reliability indexes becoming lines **R**(0,0,V\*) and **R**(½,½,V\*).
For the symmetry *p6m* the corresponding 1D-scans are **R**(0,0,V\*) and
**R**(⅓,⅓,V\*), defined within the basis system ***a<sub>0</sub>\****,
***b<sub>0</sub>\****, ***c<sub>0</sub>\****.

The number of solutions depends strongly on (i) the error limits defined
for the input data, (ii) the number of patterns, and (iii) the
prominence of zones recorded (how low the zone indices are).

Typical numbers of patterns used for the unit cell determination are:
4-6 for 3D scan, 3-5 for 2D and 2-3 for 1D search. During a run, these
numbers may dynamically be increased, and suspicious patterns may be
excluded.

Typical issues arising in usage of the GM algorithm and how to handle
them are as follows:

1.) Alien pattern(s) from e.g. contaminants or different polymorphs
hidden among regular patterns, which will erroneously trigger rejection
of correct solutions; suspicious patterns hence need to be removed.

2.) Inaccurate geometry of the vectors in the diffraction patterns, e.g.
due elliptical distortion. In this case, increase the error margins on
the diffraction pattern vectors or apply corrections for known
distortions (Bücker et al., 2021; Brázda et al., 2022).

3.) Incorrect search range (*z* search) of the unit cell volume. If no
satisfactory unit cell is found, increase the search range in volume.

4.) Symmetry of the zone \[0 0 1\] is overestimated due to a
pseudo-mirror plane, triggering the 1D- or 2D-scan strategies. If this
is suspected, enforce the general 3D-scan strategy via a dedicated
option, or choose a different pattern to define the initial \[0 0 1\]
zone.

# Results

## CuPcCl<sub>16</sub>

Copper phthalocyanine is a highly polymorphic compound (Herbst & Hunger,
2004), yet only one crystalline phase has been observed for its chlorine
derivative – copper perchloro-phthalocyanine CuPcCl<sub>16</sub>
(Gorelik et al., 2021). The unit cell is C-centred monoclinic (*C2/m*,
Z=8) with the lattice parameters a=17.685(4) Å, b=25.918(5) Å,
c=3.8330(8) Å, β= 95.05(3)°, unit cell volume is 1750.1 Å<sup>3</sup>.
The unit cell contains two molecules, the asymmetric unit includes ¼ of
the molecule, thus the volume of a single molecule is 875.05
Å<sup>3</sup> (a half of the unit cell volume).

The primitive reduced cell corresponding to the structure has a metric
of a=3.833 Å, b=15.688 Å, c=15.688 Å, α=111.39°, β=92.84°, γ=92.84°, and
can be transferred back to the centred monoclinic cell using the
transformation (0 1 1; 0 -1, 1; 1 0 0).

The crystal structure of CuPcCl<sub>16</sub> contains layers of flat
molecules, stacked along an inclined axis (Figure 6). When viewed along
the ***c*** axis, the shape of the molecule is seen slightly contracted
along ***a*** due to the projection. In the sample preparation procedure
used, the molecules are aligned flat on the supporting film. The angle
between the molecular normal and the crystallographic ***c*** axis can
be calculated from the crystal structure and is 26.5°. The main
crystallographic axis \[001\] hence lays only 26.5° away from normal
incidence on the TEM grid and can easily be reached by sample tilting.
Note, that this is a rather unusual scenario for
electron-crystallographic investigation. More commonly, the crystal
direction associated with the longest crystallographic axis is the least
developed, meaning the least amount of crystal growth occurs in this
direction. As a result, this axis often aligns with the beam incidence,
and due to the limited rotation range of TEM grids, it is rarely
observed experimentally (unless a specialized sample preparation
protocols are used, e. g. Wennmacher et al., 2019). In the case of
CuPcCl<sub>16</sub>, the crystals adopt this rather unusual morphology
and orientation due to the epitaxy on a KCl crystal.

<figure>
<img src=".\pub_figures/media/image6.png"/>
<figcaption><p>Figure 6 Crystalline structure of CuPcCl<sub>16</sub>
viewed along <strong>c</strong> (left) and <strong>b</strong> (right).
In the <strong>b</strong>-projection some molecules within the unit cell
were omitted for clarity.</p></figcaption>
</figure>

Seven zone patterns (Figure 7) were evaluated for unit cell
determination (Table 1). In each of these zonal patterns, the lengths of
two basis vectors and angles between them were extracted and used as
input for PIEP. A step-by-step guide with detailed explanations of the
procedure is presented in the ESI, section 3.2.

<table style="width:100%;">
<caption><p>Table 1 Electron diffraction zonal data of
CuPcCl<sub>16</sub> used for the lattice parameters determination
procedure</p></caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 15%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;"><em><strong>d<sub>1</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>d<sub>2</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>φ, °</strong></em></th>
<th style="text-align: center;">symmetry</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>1</sub></strong></em>)</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>2</sub></strong></em>)</th>
<th style="text-align: center;">Zone index</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">7.59</td>
<td style="text-align: center;">3.75</td>
<td style="text-align: center;">93.3</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">1 3 0</td>
<td style="text-align: center;">1 -1 -1</td>
<td style="text-align: center;">[-3 1 -4]</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">7.59</td>
<td style="text-align: center;">3.55</td>
<td style="text-align: center;">74.5</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">1 -3 0</td>
<td style="text-align: center;">1 -1 1</td>
<td style="text-align: center;">[-3 -1 2]</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">8.51</td>
<td style="text-align: center;">2.62</td>
<td style="text-align: center;">95.6</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">2 0 0</td>
<td style="text-align: center;">-1 -7 1</td>
<td style="text-align: center;">[0 1 7]</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">12.76</td>
<td style="text-align: center;">2.97</td>
<td style="text-align: center;">89.4</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 2 0</td>
<td style="text-align: center;">4 0 -1</td>
<td style="text-align: center;">[1 0 4]</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">12.75</td>
<td style="text-align: center;">2.65</td>
<td style="text-align: center;">96.5</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">0 2 0</td>
<td style="text-align: center;">-5 -1 1</td>
<td style="text-align: center;">[1 0 5]</td>
</tr>
<tr>
<td style="text-align: center;">6</td>
<td style="text-align: center;">12.75</td>
<td style="text-align: center;">2.15</td>
<td style="text-align: center;">85.9</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">0 2 0</td>
<td style="text-align: center;">-7 1 1</td>
<td style="text-align: center;">[1 0 7]</td>
</tr>
<tr>
<td style="text-align: center;">7</td>
<td style="text-align: center;">14.15</td>
<td style="text-align: center;">14.45</td>
<td style="text-align: center;">68.0</td>
<td style="text-align: center;"><em>cmm</em></td>
<td style="text-align: center;">1 -1 0</td>
<td style="text-align: center;">1 1 0</td>
<td style="text-align: center;">[0 0 1]</td>
</tr>
</tbody>
</table>

Pattern 7 displays the highest symmetry *cmm* and was therefore chosen
by the program to represent the initial \[001\] zone. No reflection
intensity values are provided to the program, the symmetry is
automatically estimated solely from the metric of the provided basis
vectors and the angle between them with the input tolerance. This
situation corresponds to the case presented in Figure 5c, where a 2D
search within three planes is necessary in order to find the unit cell
metric. For the search range and resolution, *V*<sub>max</sub> = 1000
Å<sup>3</sup> and a fractional increment *f* of 0.025 have been
specified, the program reports that 786 cells will be generated in 12
volume-layers between *V*<sub>min</sub> = 763 Å<sup>3</sup> and
*V*<sub>max </sub>= 1000 Å<sup>3</sup>. *V*<sub>min</sub> is calculated
as the smallest unit cell possible for a given \[0 0 1\] zone.
Essentially, it is the area of the base of the unit cell for the cell
search (Figure 5c). *PIEP* uses a non-equidistant set of *V* values,
with a constant fractional increment *f*, so that
$\frac{V\_{i + 1}}{V\_{i}} = 1 + f$. The combination of the
*V*<sub>max</sub> = 1000 Å<sup>3</sup> and a fractional increment of
0.025 gives twelve values for unit cell volume: (763.0, 782.1, 801.6,
821.7, 842.2, 863.3, 884. 8, 907.0, 929.6, 952.9, 976.7, 1001.1).

The unit cell search took less than 1 second (processor 2.1GHz Dual
Core), 23 solutions were returned (reduced setting of unit cells),
sorted by figure of merit R. The five solutions with the best R factors
are shown in Table 2.

<table style="width:97%;">
<caption><p>Table 2 Best solutions for the lattice parameters
determination of CuPcCl<sub>16</sub></p></caption>
<colgroup>
<col style="width: 4%" />
<col style="width: 9%" />
<col style="width: 9%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;">R</th>
<th style="text-align: center;">a, Å</th>
<th style="text-align: center;">b, Å</th>
<th style="text-align: center;">c, Å</th>
<th style="text-align: center;">α, °</th>
<th style="text-align: center;">β, °</th>
<th style="text-align: center;">γ, °</th>
<th style="text-align: center;">V, Å<sup>3</sup></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0.85</td>
<td style="text-align: center;">3.82</td>
<td style="text-align: center;">15.28</td>
<td style="text-align: center;">15.60</td>
<td style="text-align: center;">111.7</td>
<td style="text-align: center;">93.1</td>
<td style="text-align: center;">92.9</td>
<td style="text-align: center;">841.8</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">1.03</td>
<td style="text-align: center;">4.01</td>
<td style="text-align: center;">15.27</td>
<td style="text-align: center;">15.58</td>
<td style="text-align: center;">112.0</td>
<td style="text-align: center;">90.7</td>
<td style="text-align: center;">91.5</td>
<td style="text-align: center;">884.2</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">1.08</td>
<td style="text-align: center;">3.91</td>
<td style="text-align: center;">15.31</td>
<td style="text-align: center;">15.58</td>
<td style="text-align: center;">68.1</td>
<td style="text-align: center;">89.8</td>
<td style="text-align: center;">85.6</td>
<td style="text-align: center;">862.7</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">1.32</td>
<td style="text-align: center;">3.92</td>
<td style="text-align: center;">15.34</td>
<td style="text-align: center;">15.58</td>
<td style="text-align: center;">111.8</td>
<td style="text-align: center;">90.7</td>
<td style="text-align: center;">95.7</td>
<td style="text-align: center;">841.8</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">1.46</td>
<td style="text-align: center;">4.54</td>
<td style="text-align: center;">15.26</td>
<td style="text-align: center;">15.62</td>
<td style="text-align: center;">111.9</td>
<td style="text-align: center;">94.2</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">1,000.0</td>
</tr>
</tbody>
</table>

The solution with the lowest figure of merit **R** (0.85) has a cell
volume of 828.5 Å<sup>3</sup>, which is close to the volume of a single
molecule of 875.05 Å<sup>3</sup> (see above). These values match well
the metric of the known reduced primitive cell of *a* = 3.833 Å,
*b* = 15.688 Å, *c* = 15.688 Å, α = 111.39°, β = 92.84°, γ = 92.84°.
Delaunay reduction implemented in PIEP suggested an A-centred monoclinic
cell with the parameters *a* = 3.817 Å, *b* = 25.567 Å, *c* = 17.329 Å,
α = 88.70°, β = 95.35°, γ = 90.20°. A transformation with the matrix (0
0 1; 0 -1 0; 1 0 0) yields a C-centred monoclinic cell with the
parameters *a* = 17.329 Å, *b* = 25.567 Å, *c* = 3.817 Å, α = 89.80°,
β = 95.35°, γ = 91.30°, *V* = 1683.5 Å<sup>3</sup>, matching well the
expected values.

<figure>
<img src=".\pub_figures/media/image7.png"/>
<figcaption><p>Figure 7 seven zonal patterns of CuPcCl<sub>16</sub> used
for lattice parameters determination. The zone pattern 7 displays cmm
symmetry with two mirror planes – vertical and horizontal. Vertical
mirror planes are indicated in patterns 4, 5, 6, and 7.</p></figcaption>
</figure>

The obtained unit cell parameters were used to index all diffraction
patterns in the data set (Table 1). Remarkably, zones 4, 5, and 6
effectively represent a tilt series around the *b*\* axis. If the
angular relationship between these zones would have been known, the unit
cell could have been determined using the Vainshtein method (Vainshtein,
1964). However, without the knowledge on the zones’ mutual orientation,
additional cuts of the reciprocal space (zones in different
orientations) are needed to fix the cell. In this case, this is achieved
by the first three zones and the zone number 7.

The zone index vectors of the patterns forming a Vainshtein tilt series
are coplanar. Therefore, a unit cell generally cannot be determined from
a set of zone patterns forming a Vainshtein tilt series (unless
information on the mutual orientation of the zones is provided). For
this reason, when dealing with an unknown unit cell, a series of
patterns with a similar basis vector should be avoided.

<figure>
<img src=".\pub_figures/media/image8.png"/>
<figcaption><p>Figure 8 ‘Inverse FOM’ surface (1/R values) within the
(y, V) plane for x=0.5 for 2D scan (a) and (b) 3D search routines. The
sharp peak at the volume of 830 Å<sup>3</sup> corresponding to the best
solution found is marked by red arrows. More solution swill emerge with
increase volume. The correct solution should have a high prominence at
reasonably low volume values.</p></figcaption>
</figure>

The incorporation of the low index \[0 0 1\] zone (number 7) with high
symmetry (*cmm*), and correspondingly the reduction of the search space
to two dimensions (Figure 5c) significantly helps the algorithm to find
the correct solution. A plane in the 2D solution space is shown in
Figure 8a. Here, ‘inverse FOM’ *F*<sub>inv</sub> = 1/**R** values are
plotted in the (*y, V*) plane for *x* = 0.5. The sharp peak at the
volume of 830 Å<sup>3</sup> corresponds to the best solution found.

Practically, main zones with long axes are rarely present in a dataset
due to reasons outlined above. We therefore repeated the unit cell
determination, with the \[0 0 1\] zone being excluded. In the absence of
the zone number 7, zone number 4 with *2mm* symmetry was chosen by the
program to serve as the initial zone, still running a 2D search. The
clipped dataset of six patterns produced the best solution (R=0.55) with
a primitive unit cell with the parameters a = 3.76 Å, b = 15.23 Å,
c = 15.50 Å, α = 112.3°, β = 93.3°, γ = 93.5°, V = 816.1 Å<sup>3</sup>.
The Delaunay-reduced A-centred cell had the parameters of a = 3.76 Å,
b = 25.52 Å, c = 17.12 Å, α = 88.89°, β = 96.10°, γ = 89.93°. The
subsequent transformation (as discussed above) resulted in the C-centred
cell with a = 19.41 Å, b = 25.52 Å, c = 3.76 Å, β = 96.10°, matching the
expected values. Thus, also the dataset without the main zone produced a
correct unit-cell basis.

To enforce a 3D search, we further reduced the dataset and removed
pattern number 4 previously picked as initial zone. The obtained dataset
only contained five high-index zones. The best solution (R = 0.50) had a
primitive unit cell, with parameters of a = 3.77 Å, b = 15.23 Å,
c = 15.47 Å, α = 112.4°, β = 93.3°, γ = 93.7° still matching the
expected values.

The task of finding the correct lattice parameters set is essentially
represented by the task of finding a proper maximum of the surface of
1/R. The figure of merit plane containing the best solution is shown in
Figure 8b. With the expelling of the low-index and high-symmetry zones,
the dimensionality of the search becomes higher, and the surface becomes
noisy. These factors determine the success of the search routine.

## Lysozyme

We then moved on to a serial crystallography dataset of lysozyme. These
data presented a particular challenge due to several reasons. (i) The
experimental setup produced patterns with elliptical distortion of 2.3%,
with the long axis at an angle of 85° with respect to the horizontal
axis (Bücker et al., 2021; Brázda et al., 2022). However, this
distortion is constant and hence could be corrected for by approximately
assuming a camera length increased by 2% along the vertical axis. (ii)
The long unit cell axes of the protein crystals, in conjunction with
peak broadening due to mosaicity, finite beam coherence, and a large
detector pixel size (9-pixel peak distance along ***a\**** and
***b\****) yields a low sampling of the diffraction patterns, limiting
the accuracy of vector length measurements, and therefore the
performance of the GM algorithm.

<table style="width:100%;">
<caption><p>Table 3 Electron diffraction zonal data used for the lattice
parameters determination of lysozyme</p></caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 15%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;"><em><strong>d<sub>1</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>d<sub>2</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>φ, °</strong></em></th>
<th style="text-align: center;">symmetry</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>1</sub></strong></em>)</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>2</sub></strong></em>)</th>
<th style="text-align: center;">Zone index</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>4</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">1 0 0</td>
<td style="text-align: center;">[0 0 1]</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">77.48</td>
<td style="text-align: center;">6.46</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">6 0 5</td>
<td style="text-align: center;">[5 0 -6]</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">78.99</td>
<td style="text-align: center;">14.68</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">5 0 1</td>
<td style="text-align: center;">[1 0 -5]</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">77.12</td>
<td style="text-align: center;">9.53</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">7 0 2</td>
<td style="text-align: center;">[2 0 -7]</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">78.20</td>
<td style="text-align: center;">8.52</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">9 0 1</td>
<td style="text-align: center;">[1 0 -9]</td>
</tr>
<tr>
<td style="text-align: center;">6</td>
<td style="text-align: center;">79.64</td>
<td style="text-align: center;">12.09</td>
<td style="text-align: center;">90</td>
<td style="text-align: center;"><em>2mm</em></td>
<td style="text-align: center;">0 1 0</td>
<td style="text-align: center;">2 0 3</td>
<td style="text-align: center;">[3 0 -2]</td>
</tr>
</tbody>
</table>

<table style="width:97%;">
<caption><p>Table 4 Best solutions for the lattice parameters
determination of lysozyme, 1D search</p></caption>
<colgroup>
<col style="width: 4%" />
<col style="width: 9%" />
<col style="width: 9%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;">R</th>
<th style="text-align: center;">a, Å</th>
<th style="text-align: center;">b, Å</th>
<th style="text-align: center;">c, Å</th>
<th style="text-align: center;">α, °</th>
<th style="text-align: center;">β, °</th>
<th style="text-align: center;">γ, °</th>
<th style="text-align: center;">V, Å<sup>3</sup></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0.80</td>
<td style="text-align: center;">38.22</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">238,898.3</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">0.91</td>
<td style="text-align: center;">28.93</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">180,852.8</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">0.94</td>
<td style="text-align: center;">44.48</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">278,068.6</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">0.99</td>
<td style="text-align: center;">47.99</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">300,000.0</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">1.02</td>
<td style="text-align: center;">30.43</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">79.06</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">190,241.3</td>
</tr>
</tbody>
</table>

<figure>
<img src=".\pub_figures/media/image9.png"/>
<figcaption><p>Figure 9 Random orientation zone patterns of lysozyme
used for lattice parameters determination. Background subtraction as
described in (Bücker et al., 2021) has been applied. Vertical mirror
planes are indicated in all patterns.</p></figcaption>
</figure>

We initially selected 6 prominent zones with high apparent symmetry
(Table 3, Figure 9). One of these zones was the \[001\] pattern, with
4-fold symmetry. The other patterns (numbers 2-6, Table 3) contained a
main axis with evident extinctions, and all had *2mm* symmetry. Although
the experimentally measured angles deviated from 90° (87.796° in pattern
number 1), we fixed them to 90°, as it is dictated by the symmetry, to
boost the performance of the algorithm.

Selection of these zones would be a typical strategy for patterns
selection in a situation without any prior knowledge on the cell metric.
Patterns 2-6 are likely to represent a tilt series around the main axis,
therefore, these alone cannot fix a lattice. Here, the main \[001\] zone
is essential for the unit cell determination.

The incorporation of the \[001\] zone initiated a 1D search, thanks to
its four-fold symmetry. The solutions are given in Table 4. The best
solution had a tetragonal metric with *a* = 79.06 Å, *c* = 38.22 Å,
matching the expected parameters very well. With these parameters, first
the initial set of patterns could be indexed (patterns 1-6). The first
pattern was indexed as \[001\], as expected, the other patters all
contain the 0 1 0 axis as a common axis and form a tilt series (Table
3). These lattice parameters were used to index additional 12 patterns
with *p1* symmetry, which were selected from the pattern pool, but not
used for the lattice parameters determination. The results of the
indexing procedure are shown in Figure 10.

During the first run, we imposed tetragonal symmetry on the main zone
and thus initiated 1D search. We then decided to increase the
dimensionality of the search. A simple exclusion of the main \[001\]
zone would leave us with five zone patterns forming a tilt series
(patterns 2-6). To fix the lattice, we added the \[111\] zone (no. 9,
Figure 10). This set of zone patterns initiated a 2D scan. The best
solution with a figure of merit of 0.6 had unit cell parameters of 38.48
Å, 78.65 Å, 78.99 Å, 90.0°, 90.0°, 91.4° and the volume of 238,994.4
Å<sup>3</sup>, again close to the expected tetragonal metric.

Alternatively, we retained the main \[001\] in the dataset, set the
angle between the vectors to the measured value of 87.796°, and then
performed cell determination using the six patterns (1-6). The symmetry
of the main zone was classified as *cmm*, with |a| = |b|, initiating a
2D search (Figure 5c). The best solution, with a figure of merit of
1.01, produced a somewhat distorted unit cell but with a still
recognizable metric: 34.52 Å, 79.24 Å, 79.24 Å, 92.0°, 93.1°, 93.1°.

<figure>
<img src=".\pub_figures/media/image10.png" />
<figcaption><p>Figure 10 Additional electron diffraction zone patterns
of lysozyme, indexed based on the found unit cell
metric.</p></figcaption>
</figure>

## GRGDS

We then moved on to a material with unknown crystal structure to see
whether our procedure could give a reasonable suggestion for a unit cell
metric. Five patterns with a clear periodic pattern were selected as
input for *PIEP* (Figure 11). One of the patterns had *cmm* symmetry,
all other *p1*, no extinctions were seen in the patterns. Vectors
determined from all five patterns (Table 5) were input into PIEP. A
protocol of the interactive session in the program is listed in ESI
section 5.2.

<table style="width:100%;">
<caption><p>Table 5 Electron diffraction zonal data used for the lattice
parameters determination of GRGDS</p></caption>
<colgroup>
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 15%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;"><em><strong>d<sub>1</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>d<sub>2</sub>,
Å</strong></em></th>
<th style="text-align: center;"><em><strong>φ, °</strong></em></th>
<th style="text-align: center;">symmetry</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>1</sub></strong></em>)</th>
<th
style="text-align: center;">hkl(<em><strong>d<sub>2</sub></strong></em>)</th>
<th style="text-align: center;">Zone index</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">13.82</td>
<td style="text-align: center;">4.39</td>
<td style="text-align: center;">80.9</td>
<td style="text-align: center;"><em>cmm</em></td>
<td style="text-align: center;">2 0 0</td>
<td style="text-align: center;">1 1 0</td>
<td style="text-align: center;">[0 0 1]</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">12.94</td>
<td style="text-align: center;">3.91</td>
<td style="text-align: center;">85.6</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">2 0 -1</td>
<td style="text-align: center;">1 1 2</td>
<td style="text-align: center;">[1 -5 2]</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">7.10</td>
<td style="text-align: center;">4.42</td>
<td style="text-align: center;">80.8</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">-4 0 1</td>
<td style="text-align: center;">-1 1 0</td>
<td style="text-align: center;">[1 1 4]</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">4.76</td>
<td style="text-align: center;">4.40</td>
<td style="text-align: center;">80.5</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">-6 0 1</td>
<td style="text-align: center;">-1 1 0</td>
<td style="text-align: center;">[1 1 6]</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">12.99</td>
<td style="text-align: center;">1.47</td>
<td style="text-align: center;">89.1</td>
<td style="text-align: center;"><em>p1</em></td>
<td style="text-align: center;">-2 0 1</td>
<td style="text-align: center;">1 -3 2</td>
<td style="text-align: center;">[3 5 6]</td>
</tr>
</tbody>
</table>

<table style="width:97%;">
<caption><p>Table 6 Best solutions for the lattice parameters
determination of GRGDS</p></caption>
<colgroup>
<col style="width: 4%" />
<col style="width: 9%" />
<col style="width: 9%" />
<col style="width: 11%" />
<col style="width: 11%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">#</th>
<th style="text-align: center;">R</th>
<th style="text-align: center;">a, Å</th>
<th style="text-align: center;">b, Å</th>
<th style="text-align: center;">c, Å</th>
<th style="text-align: center;">α, °</th>
<th style="text-align: center;">β, °</th>
<th style="text-align: center;">γ, °</th>
<th style="text-align: center;">V, Å<sup>3</sup></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">0.84</td>
<td style="text-align: center;">4.44</td>
<td style="text-align: center;">14.51</td>
<td style="text-align: center;">19.47</td>
<td style="text-align: center;">105.3</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">98.8</td>
<td style="text-align: center;">1195.6</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">0.99</td>
<td style="text-align: center;">4.44</td>
<td style="text-align: center;">14.49</td>
<td style="text-align: center;">20.47</td>
<td style="text-align: center;">105.0</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">98.8</td>
<td style="text-align: center;">1257.4</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">1.14</td>
<td style="text-align: center;">4.44</td>
<td style="text-align: center;">14.42</td>
<td style="text-align: center;">21.53</td>
<td style="text-align: center;">76.1</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">81.2</td>
<td style="text-align: center;">1322.4</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">1.16</td>
<td style="text-align: center;">7.82</td>
<td style="text-align: center;">13.21</td>
<td style="text-align: center;">14.36</td>
<td style="text-align: center;">86.5</td>
<td style="text-align: center;">74.2</td>
<td style="text-align: center;">76.9</td>
<td style="text-align: center;">1390.8</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">1.17</td>
<td style="text-align: center;">4.44</td>
<td style="text-align: center;">14.52</td>
<td style="text-align: center;">18.98</td>
<td style="text-align: center;">74.6</td>
<td style="text-align: center;">90.0</td>
<td style="text-align: center;">81.2</td>
<td style="text-align: center;">1165.8</td>
</tr>
</tbody>
</table>

The volume search range was set to \[0 1500\], the maximal limit being
slightly larger than the doubled molecular volume. The pattern with
*cmm* symmetry was selected as ***a\****-***b\****-defining plane,
initiating 2D search. The best five solutions are presented in Table 6.
Solution with the best figure of merit had a cell volume of 1195.6
Å<sup>3</sup>, matching the expected volume of two GRGDS molecules (2 x
585 = 1170 Å<sup>3</sup>). Delaunay reduction suggested a monoclinic
A-centred unit cell with the lattice parameters of 19.466 Å, 4.4446 Å,
28.6756 Å, 90.02°, 105.47°, 90.00°, which was transformed to standard
settings using the transformation matrix (0 0 1; 0 -1 0; 1 0 0). The
final unit cell is monoclinic C-centred with the lattice parameters of
28.6756 Å, 4.4446 Å, 19.466 Å, 90.00°, 105.47°, 90.02°, and a volume of
2391.1 Å<sup>3</sup>. The unit cell should then contain four molecules
of GRGDS. As GRGDS is a chiral molecule, the only possible space group
would be Sohncke *C2* group (no. 5) with *Z*=4, *Z’*=1.

The obtained unit cell could be used to index the five zones. The
indices of the reflections are given in Table 5. The first pattern was
indexed as the main \[0 0 1\] zone, with the vectors having 200 and 110
indices, reflections 100 and 010 being absent due to C-centring
reflections condition: h + k = 2n. All other zones had relatively high
indices. We tried to exclude the *cmm* zone from the dataset and run a
3D search, which however did not produce any reasonable solution.

<figure>
<img src=".\pub_figures/media/image11.png" />
<figcaption><p>Figure 11 Electron diffraction zone patterns of GRGDS
peptide used for the lattice parameters determination. Vertical mirror
planes are indicated in the first pattern.</p></figcaption>
</figure>

Finally, we would like to mention that we recently determined the
crystal structure of GRGDS from 3D ED data. The structure was revealed
to be a co-crystal of GRGDS with trifluoroacetic acid (TFA),
crystallizing in the *C2* space group with lattice parameters: a =
29.231 Å, b = 4.546 Å, c = 19.640 Å, and β = 106.70°, which match well
with the parameters determined using PIEP. The original diffraction data
for the GRGDS-TFA co-crystal can be accessed at DOI:
10.5281/zenodo.13938422, and the CSD deposition code for the structure
is 2391399. Further details regarding the structure determination will
be published elsewhere.

# Discussion

The GM algorithm requires a few zonal patterns with the highest symmetry
and the shortest vectors between the reflections as input. In this
study, we manually selected patterns matching these criteria. Obviously,
manually searching through a dataset containing thousands of patterns is
impractical, but this procedure can be easily automated.

The initial step in serial data reduction involves extracting the
coordinates of the peaks from the patterns. One possible approach to
selecting the most prominent zonal patterns involves autocorrelation of
the peak positions, extracting the two shortest linearly independent
vectors, constructing a 2D net from these basis vectors, and comparing
the positions of the nodes of the created lattice with the initial peak
positions on the pattern. If these match, it is likely that a regular 2D
net of reflections is present. However, if many unmatched positions
exist, the pattern may represent a high-index cut of reciprocal space.
The low-index pattern can then be further sorted based on the length of
the vectors it contains.

Alternatively, given the large number of patterns and the ease of
generating electron diffraction patterns from a given structure, machine
learning approaches could likely be applied to the task of selecting the
most prominent zonal patterns.

The convincing performance of the GM algorithm is given by the
intelligent incorporation of the symmetry detected in electron
diffraction patterns. The presence of high symmetry decreases the
dimensionality of the scan, reducing the solution space, and,
consequently, the time needed.

Finding the correct solution is essentially a task of finding a
prominent maximum within the solution space or plane (Figure 8).
Naturally, a noisy search space (surface) will destabilize the
procedure. Therefore, the errors in the data caused by diverse physical
factors, such as distortion in diffraction patterns or slight off-tilt
of zone orientations are critical for the performance.

Table 7 lists all expected and determined unit cell parameters. For both
monoclinic centred structures—CuPcCl<sub>16</sub> and GRGDS—the
corresponding primitive unit cell is provided. For GRGDS, the primitive
unit cell was calculated from the experimentally obtained C-centered
lattice using the transformation (0 -1 0; 0.5 0.5 0; 0 0 1).

For both small-molecule compounds, the average error in the angles of
the determined unit cell is below 1°, with a maximum of 1.2° for γ of
GRGDS. For the lysozyme structure, which has large lattice parameters
and lower accuracy in experimentally measured angles (not precisely
in-zone patterns), the error in the angle is significantly higher,
reaching up to 3°.

Estimating the accuracy of the length parameters is more challenging.
The absolute lengths of the unit cell vectors are often influenced by
camera constant errors. For this reason, *PIEP* separates the camera
constant and the ratios of vector lengths when calculating the figure of
merit for a solution. We have chosen to adopt the same approach. To
assess the accuracy of the obtained unit cell metrics relative to
expected values, while factoring out camera constant errors, we use the
following figure of merit:

$$\frac{1}{R\_{gof}} = \left| \frac{a}{b} - \frac{a\_{\exp}}{b\_{\exp}} \right| + \left| \frac{b}{c} - \frac{b\_{\exp}}{c\_{\exp}} \right| + \left| \frac{c}{a} - \frac{c\_{\exp}}{a\_{\exp}} \right| + \left| \alpha - \alpha\_{\exp} \right| + \left| \beta - \beta\_{\exp} \right| + \left| \gamma - \gamma\_{\exp} \right|$$

It is possible to develop a weighting scheme for length and angular
errors and to develop a qualitative criterion for
*R*<sub>*g**o**f*</sub> to correspond to a “correct” unit cell. However,
for simplicity, we decided to give equal weight to both parts, leaving
this important aspect for further studies.

<table style="width:68%;">
<caption><p>Table 7 List of expected and determined unit cell
parameters</p></caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 7%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 9%" />
<col style="width: 7%" />
<col style="width: 7%" />
<col style="width: 6%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;"></th>
<th style="text-align: left;">a Å</th>
<th style="text-align: left;">b Å</th>
<th style="text-align: left;">c Å</th>
<th style="text-align: left;">α, °</th>
<th style="text-align: left;">β, °</th>
<th style="text-align: left;">γ, °</th>
<th style="text-align: left;"><span
class="math display"><em>R</em><sub><em>g</em><em>o</em><em>f</em></sub></span></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;"><strong>CuPcCl<sub>16</sub></strong></td>
<td style="text-align: left;"><strong>3.833</strong></td>
<td style="text-align: left;"><strong>15.688</strong></td>
<td style="text-align: left;"><strong>15.688</strong></td>
<td style="text-align: left;"><strong>111.39</strong></td>
<td style="text-align: left;"><strong>92.84</strong></td>
<td style="text-align: left;"><strong>92.84</strong></td>
<td style="text-align: left;"></td>
</tr>
<tr>
<td style="text-align: left;">2D, <em>cmm</em></td>
<td style="text-align: left;">3.82</td>
<td style="text-align: left;">15.28</td>
<td style="text-align: left;">15.60</td>
<td style="text-align: left;">111.7</td>
<td style="text-align: left;">93.1</td>
<td style="text-align: left;">92.9</td>
<td style="text-align: left;">1.50</td>
</tr>
<tr>
<td style="text-align: left;">2D, <em>2mm</em></td>
<td style="text-align: left;">3.76</td>
<td style="text-align: left;">15.23</td>
<td style="text-align: left;">15.50</td>
<td style="text-align: left;">112.3</td>
<td style="text-align: left;">93.3</td>
<td style="text-align: left;">93.5</td>
<td style="text-align: left;">0.48</td>
</tr>
<tr>
<td style="text-align: left;">3D</td>
<td style="text-align: left;">3.77</td>
<td style="text-align: left;">15.23</td>
<td style="text-align: left;">15.47</td>
<td style="text-align: left;">112.4</td>
<td style="text-align: left;">93.3</td>
<td style="text-align: left;">93.7</td>
<td style="text-align: left;">0.42</td>
</tr>
<tr>
<td style="text-align: left;"><strong>Lysozyme</strong></td>
<td style="text-align: left;"><strong>77.51</strong></td>
<td style="text-align: left;"><strong>77.51</strong></td>
<td style="text-align: left;"><strong>37.42</strong></td>
<td style="text-align: left;"><strong>90</strong></td>
<td style="text-align: left;"><strong>90</strong></td>
<td style="text-align: left;"><strong>90</strong></td>
<td style="text-align: left;"></td>
</tr>
<tr>
<td style="text-align: left;">1D</td>
<td style="text-align: left;">79.06</td>
<td style="text-align: left;">79.06</td>
<td style="text-align: left;">38.22</td>
<td style="text-align: left;">90</td>
<td style="text-align: left;">90</td>
<td style="text-align: left;">90</td>
<td style="text-align: left;">289</td>
</tr>
<tr>
<td style="text-align: left;">2D, <em>2mm</em></td>
<td style="text-align: left;">38.48</td>
<td style="text-align: left;">78.65</td>
<td style="text-align: left;">78.99</td>
<td style="text-align: left;">90.0</td>
<td style="text-align: left;">90.0</td>
<td style="text-align: left;">91.4</td>
<td style="text-align: left;">0.23</td>
</tr>
<tr>
<td style="text-align: left;">2D, <em>cmm</em></td>
<td style="text-align: left;">34.52</td>
<td style="text-align: left;">79.24</td>
<td style="text-align: left;">79.24</td>
<td style="text-align: left;">92.0</td>
<td style="text-align: left;">93.1</td>
<td style="text-align: left;">93.1</td>
<td style="text-align: left;">0.09</td>
</tr>
<tr>
<td style="text-align: left;"><strong>GRGDS</strong></td>
<td style="text-align: left;"><strong>4.546</strong></td>
<td style="text-align: left;"><strong>14.791</strong></td>
<td style="text-align: left;"><strong>19.640</strong></td>
<td style="text-align: left;"><strong>106.496</strong></td>
<td style="text-align: left;"><strong>90</strong></td>
<td style="text-align: left;"><strong>98.84</strong></td>
<td style="text-align: left;"></td>
</tr>
<tr>
<td style="text-align: left;">2D, <em>cmm</em></td>
<td style="text-align: left;">4.44</td>
<td style="text-align: left;">14.51</td>
<td style="text-align: left;">19.47</td>
<td style="text-align: left;">105.3</td>
<td style="text-align: left;">90.0</td>
<td style="text-align: left;">98.8</td>
<td style="text-align: left;">0.76</td>
</tr>
</tbody>
</table>

The *PIEP* program is written in legacy Fortran, which provides
excellent performance and is still used in core components of many
crystallographic programs and general scientific packages and provides a
friendly text-based interactive interface. *PIEP* can be compiled
without specific efforts on modern computing hardware running Windows,
macOS, or Linux, using *GCC* or Microsoft Fortran compilers. While the
use of Fortran declining may be somewhat of a hurdle for integration
with more contemporary computing environments, successful integrations
of this type are not uncommon, such as *CCSL*
(https://www.ill.eu/sites/ccsl/html/ccsldoc.html) integrated in *DASH*
(David et al., 2006). Besides an interfacing layer based on keystroke
emulation (as e.g. implemented for indexing sub-programs in *CrystFEL*
(White et al., 2012), using wrapper codes such as *F2PY*
(https://numpy.org/doc/stable/f2py/) to interface to Python could be a
potential topic for upcoming work on deeper integration into serial
electron crystallography packages like *diffractem* (Bücker et al.,
2021) or *Instamatic* (Smeets et al., 2018). Alternatively, and this is
likely a more straightforward approach, the GM algorithm can be
reimplemented within another software framework.

# Conclusion

Here we present an old program ***PIEP*** (**<u>P</u>**rogram for
**<u>I</u>**nterpreting **<u>E</u>**lectron diffraction
**<u>P</u>**atterns) written by one of the authors, Gerhard Miehe, in
the early 1990s. The program has a robust and well-designed algorithm
(the GM algorithm) for unit cell parameters determination from a set of
randomly oriented zonal electron diffraction patterns, a problem which
gains renewed actuality in the context of the development of serial
electron crystallography (SerialED).

We demonstrate the performance of *PIEP* for lattice parameters
determination of a known material with moderate lengths of
crystallographic axes – copper perchloro phthalocyanine
(CuPcCl<sub>16</sub>) and for lysozyme protein crystals, challenging the
algorithm by long lattice vectors. We run the program in low dimensional
search mode, corresponding to the symmetry of the material and increased
the dimensionality of the search by expulsion of the high-symmetry zone
patterns. In all situations, *PIEP* was able to find reliably the
correct solution and index all provided zone patterns. Finally, we
applied the procedure to unit cell determination of the GRGDS peptide
with unknown structure. Also here, the algorithm gave a reasonable
suggestion for the unit cell metric, so that even the space group could
be suggested.

Determining unit cell parameters from a set of randomly oriented
electron diffraction patterns is a bottleneck in the analysis of serial
electron diffraction data. The GM algorithm could hence represent a
working solution for this crucial step of the analysis pipeline.

# Program availability

The program is written in FORTRAN IV, can be compiled under Microsoft
Windows, macOS, and Linux, and runs in a terminal window with ca. 130
commands available. The program as well as a list of commands is
available at ZENODO: <https://doi.org/10.5281/zenodo.7859090> .

# Acknowledgement

We are grateful to Ute Kaiser (Ulm University, Germany) for providing
TEM facilities for electron diffraction data collection.

# Literature

Bernstein, F. C., Koetzle, T. F., Williams, G. J. B., Meyer, E. F. Jr,
Brice, M. D., Rodgers, J. R., Kennard, O., Shimanouchi, T., Tasumi, M.
(1977). J. Mol. Biol. 112, 535–542.

Brázda, P., Klementová, M., Krysiak, Y. & Palatinus, L. (2022). *IUCrJ*
9, 735–755.

Brázda, P., Palatinus, L., Babor, M. (2019). Science, 364,667-669.

Brewster, A. S., Waterman, D. G., Parkhurst, J. M., Gildea, R. J.,
Young, I. D., O'Riordan, L. J., Yano, J., Winter, G., Evans, G. &
Sauter, N. K. (2018). Acta Cryst. D74, 877-894.

Bücker, R., Hogan-Lamarre, P., Mehrabi, P., Schulz, E. C., Bultema, L.
A., Gevorkov, Y., Brehm, W., Yefanov, O., Oberthür, D., Kassier, G. H.,
Miller, R. J. D. (2020). Nat Commun., 11, 996.

Bücker, R., Hogan-Lamarre, P. & Miller, R. J. D. (2021). *Front. Mol.
Biosci.* 8, 624264.

Chapman, H. N., Fromme, P., Barty, A. White, T. A., Kirian, R. A.,
Aquila, A., Hunter, M. S., Schulz, J., DePonte, D. P., Weierstall, U.,
Doak, R. B., Maia, F. R. N. C., Martin, A. V., Schlichting, I., Lomb,
L., Coppola, N., Shoeman, R. L., Epp, S. W., Hartmann, R., Rolles, D.,
Rudenko, A., Foucar, L., Kimmel, N., Weidenspointner, G., Spence, J. C.
H. (2011). Nature, 470, 73–77.

David, W. I. F., Shankland, K., van de Streek, J., Pidcock, E.,
Motherwell, W. D. S., Cole, J. C. (2006). J. Appl. Cryst. 39, 910-915.

Dorset, D. L., Roth, W. J., Gilmore, C. J. (2005). Acta Cryst. A61,
516–527.

Gemmi, M., Mugnaioli, E., Gorelik, T. E., Kolb, U., Palatinus, L.,
Boullay, P., Hovmöller, S., Abrahams, J. P. (2019). ACS Cent. Sci. 5,
1315–1329.

Gevorkov, Y., Barty, A., Brehm, W., White, T. A., Tolstikova, A.,
Wiedorn, M. O., Meents, A., Grigat, R.-R., Chapman, H. N. & Yefanov, O.
(2020). Acta Cryst. A76, 121-131.

Gorelik, T., Schmidt, M. U., Brüning, J., Bekö, S., Kolb, U. (2009).
Crystal Growth and Design, 9, 3898–3903.

Gorelik, T. E., Habermehl, S., Shubin, A. A., Gruene, T. Yoshida, K.,
Oleynikov, P., Kaiser, U., Schmidt, M. U. (2021). Acta Cryst. B77,
662–675.

Herbst, W. & Hunger, K. (2004). Industrial Organic Pigments: Production,
Properties, Applications. Wiley-VCH.

Hogan-Lamarre, P., Luo, Y., Buecker, R., Miller, R. J. D., Zou, X.
(2024). IUCrJ 11, 62–72.

Hofmann, D. W. M. (2002). Acta Cryst. B57, 489-493.

Horvath-Bordon, E., Riedel, R., McMillan, P. F., Kroll, P., Miehe, G.,
van Aken, P. A., Zerr, A., Hoppe, P., Shebanova, O., McLaren, I.,
Lauterbach, S., Kroke, E., Boehler, R. (2007). Angew. Chem. Int. Ed. 46,
1476–1480.

Ito, S., White, F. J., Okunishi, E., Aoyama, Y., Yamano, A., Sato, H.,
Ferrara, J. D., Jasnowski, M. Meyer, M. (2021). *CrystEngComm* 23
8622-8630.

Jiang, L., Georgieva, D., Zandbergen, H. W. & Abrahams, J. P. (2009).
Acta Cryst. D65, 625–632.

Jiang, L., Georgieva, D. & Abrahams, J. P. (2011). J. Appl. Cryst. 44,
1132–1136.

Jolles, P., Angewandte Chemie, International Edition, 8, 227-239 (1969).

Kabsch, W. (2014). *Acta Cryst* D70, 2204-2216.

Kolb U. & Matveeva, G. N. (2003). Z. Kristallogr. 218, 259–268.

Kolb, U., Gorelik, T., Kübel, C., Otten, M. T., Hubert, D. (2007).
Ultramicroscopy, 107, 507-513.

Kolb, U., Gorelik, T., Otten, M. T. (2008). Ultramicroscopy, 108,
763-772.

Kolb, U., Gorelik, T. E., Mugnaioli, E., Stewart, A., (2010). Polymer
Reviews, 50, 385–409.

Liu, L., Knapp, M., Ehrenberg, H., Fang, L., Schmitt, L., A., Fuess, H.,
Hoelzeld, M. and Hinterstein, M. (2016). J. Appl. Cryst. 49, 574–584.

Miehe, G. (1997). Berichte der Deutschen Mineralogischen Gesellschaft,
Beih. z. Eur. J. Mineral. 9, 250.

Morniroli, J. P. & Steeds, J. W. (1992). Ultramicroscopy, 45, 219-239.

Nannenga, B. L., Shi, D., Hattne, J., Reyes, F. E., Gonen, T.(2014)
eLife 3:e03600, <https://doi.org/10.7554/eLife.03600>

Nederlof, I., van Genderen, E., Li, Y.-W., Abrahams, J. P (2013). Acta
Cryst. D69, 1223–1230.

Patterson, A. L. & Love, W. E. (1957). Acta Cryst., 10, 111-116.

Powell, H. R., Johnson, O., Leslie, A. G. W. (2013). Acta Cryst. D69,
1195–1203.

Schmitt, L. A., Hinterstein, M., Kleebe, H.-J. and Fuess, H. (2010). J.
Appl. Cryst. 43, 805–810.

Shechtman, D., Blech, I., Gratias, D., Cahn, J.W. (1984). Phys. Rev.
Lett. 53, 1951-1954.

Shi, H. (2022). J. Appl. Cryst. 55, 669-676.

Shi, H. & Li, Z. (2021). IUCrJ 8, 805–813.

Simoncic, P., Romeijn, E., Hovestreydt, E., Steinfeld, G.,
Santiso-Quiñones, G., Merkelbach, J. (2023). *Acta Cryst*. E79, 410-422.

Smeets, S., Zou, X., Wan, W. (2018). J. Appl. Cryst. 51, 1262–1273.

Stellato, F., Oberthür, D., Liang, M., Bean, R., Gati, C., Yefanov, O.,
Barty, A., Burkhardt, A., Fischer, P., Galli, L., Kirian, R. A., Meyer,
J., Panneerselvam, S., Yoon, C. H., Chervinskii, F., Speller, E., White,
T. A., Betzel, C., Meents, A., Chapman, H. N. (2014). IUCrJ, 4, 204-212.

Sun, J., He, Z., Hovmöller, S., Zou, X., Gramm, F., Baerlocher, C.,
McCusker, L. B. (2010). Z. Kristallogr. 225, 77–85.

Vainshtein, B. K. (1964). Structure Analysis by Electron Diffraction,
Pergamon.

Weiss, M. S., Palm, G. J., Hilgenfeld, R. (2000). Acta Cryst. D56,
952-958.

Wennmacher, J.T.C., Zaubitzer, C., Li, T., Bahk, Y. K., Wang, J., van
Bokhoven, J. A., Gruene, T. (2019). Nat Commun 10, 3316.

White, T. A., Kirian, R. A., Martin, A. V., Aquila, A., Nass, K., Barty,
A., Chapman, H. N. (2012). *J. Appl. Cryst*. 45, 335–341.

Wu, J. S. & Spence, J. C. H. (2003). Acta Cryst. A59, 495-505.

Yoshida, K., Biskupek, J., Kurata, H., Kaiser, U., (2015).
Ultramicroscopy, 159, 73-80.

Zimmerman, H. (1985). Biom. J. 27, 349-352.

Zou, X., Hovmöller, A., Hovmöller, S. (2004). Ultramicroscopy, 98,
187–193.
