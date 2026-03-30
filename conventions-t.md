**6.1 Conventions for data input**

**6.1.1 Commands**

The user communicates with the program by a set of 136 commands. 30
of them are related to the built-in RPN-type pocket calculator. The
submission of a command generates a line telling the user which data
are expected - except for the 30 RPN- commands and for commands
which don't ask for data.

**6.1.1.1** Two-character commands <u>must</u> be typed in columns 1
and 2, one-character commands in col. 1. Columns 3 and higher are not
interpreted, i.e. the command line doesn't contain any data.

**6.1.1.2** Commands may be renamed in the parameter file (see
6.2.1?). Each command has two representations, which may be identical.
The default setting is the lower case and the upper case
representation of letters , e.g. 'cp' and 'CP' for **<u>c</u>**ell
**<u>p</u>**arameters. The pocket calculator accepts ' / ' and ' : '
for division.

**6.1.1.3** Commands which ask for *<u>numeric</u>* input may be
canceled if any character which is not recognized as part of numeric
input (including "+", except ";" and - in certain cases - "!"
(cf.6.1.2.2), e.g. any letter) is submitted <u>in column 1</u> instead
of the expected data. Also ^Z (Strg Z) followed by &lt;return&gt;
cancels a command.

The demand for *<u>alphanumeric</u>* input can be canceled by ^Z as
well. If indicated in the data demand line, "." or "," in col. 1
(col.2 to 4 blank) may be used to cancel the demand .

**6.1.1.4** Unknown commands are ignored.

**6.1.1.5** The commands 'H' (or 'h') and 'HH' (or 'hh') ('help') list
short descriptions of the commands.

**6.1.2 Numeric input**

**6.1.2.1** Input is in free format (col.1-70). E-format is not
permitted. **For the particular significance of column 1 see 6.1.1.3
and 6.1.2.2**. Real numbers outside the ranges ±10<sup>±27</sup>
(except 0) and integers (e.g. serial numbers) exceeding the range
±10<sup>7</sup> are not accepted. The standard decimal point is ".". A
switch in the parameter file enables the program to accept both, point
"." and comma ",". Integers as well as real numbers may be given with
or without decimal point.

**6.1.2.2** Stack and memory of the RPN "pocket calculator" may serve
as storage for numerical values. "!*n*" transfers the value stored in
register *n* (1 ≤ *n* ≤ 4) to the input line. The command "!m" or "!M"
transfers the content of the RPN memory.

**6.1.2.3** A blank line or &lt;return&gt; zeroes all expected values.
Tailing 0's need not be typed. Isolated "." and "-" (and "," if it is
accepted as decimal point) are interpreted as 0. Except for col.1 any
non- numeric character as defined in 6.1.1.3 is handled as space.

**6.1.2.4** When input "0" (or any character which is interpreted as
"0") ob­viously makes no sense, "0" is either replaced by a default
value which is usually dis­played in the data demand line, or the
command is canceled, or the program insists on a value ?0. If no value
is avail­able, an escape as described in 6.1.1.3 branches to a
meaning­ful point. This doesn't apply to the input sequence which is
initialized by the command "NP" (new pattern). Here the repeated input
of a number, e.g. "1", will help to escape.

**6.1.2.5** **Cell parameters, d-values and wavelength <u>must</u> be
given in Å, high voltage in V (not kV!).** SAD data, including camera
length, should be given in mm, hence the camera constant in Åmm.

**6.1.2.6** Usually an echo of input data or of calculated floating
point data which consists only of the figure "9", e.g. "9999.9",
indicates a format overflow. Internally the correct values are used.

**6.1.3 Alphanumeric input**

Besides commands, the data described in 6.1.3.1 to 6.1.3.5 are
alphanumeric:

**6.1.3.1** Title of the SAD pattern, col. 1-70, no restrictions

**6.1.3.2** Centering symbol in column 1, upper or lower case, default
is "P". All symbols except upper or lower case A,B,C,R,I,F, in
particular "P", "p" and " " (blank) are interpreted as "P". The
centering symbol may be extended to the space group symbol. The
content of columns 2 - 11 is echoed together with the centering symbol
but it is irrelevant for calculations.

**6.1.3.3** Identifiers of cell parameter sets (commands BP, LG).
Upper and lower case are not equivalent. The demand for a name can be
canceled by ^Z (Strg Z) or by one of the punctuation marks "." or ","
in column 1 (col.2-4 blank) (see 6.1.1.3).

**6.1.3.4** File names. The equivalence of upper and lower case
characters depends on the operating system. The program does not check
for conflicts caused by the assignment of files. Therefore
**<u>particular care is advised when specifying file names</u>**. The
demand for a file name can be canceled by ^Z or by one of the
punctuation marks "." or "," in column 1 (see 6.1.1.3).

**6.1.3.5** yes/no-answers to questions: **All answers except those
beginning with "N" or "n" in col.1 are interpreted as "yes". In
particular a blank line or &lt;return&gt; is "yes".**
