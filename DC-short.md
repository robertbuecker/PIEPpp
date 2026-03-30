> **Cell parameter determination, a typical sequence of commands**
>
> 1.: Set modi
>
> **BR**
>
> (TE)
>
> 2.: Prepare loading of patterns (clean memory A)
>
> **AD** or **AX** (former: AE): delete or exclude "foreign" patterns
>
> (ND)
>
> 3a. Get patterns
>
> if read from file P: **PG**
>
> 3b. Load patterns
>
> (DS : if ND is to be applied)
>
> **AP**
>
> loop 3a – 3b
>
> 4: Prepare cell parameter determination
>
> **PC**
>
> 5\. Run cell parameter determination
>
> **DC**
>
> 6\. Inspection of solutions
>
> **CW**
>
> 6a. Analysis (Delaunay reduction) of solutions.
>
> Depending on the situation: **CG, DE, SD**
>
> 6b. If SD was applied:
>
> **CG, DE**
>
> 7: Enforce conditions prescribed by the crystal class
>
> **IS**
