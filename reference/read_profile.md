# Read a Submission Profile from Portable JSON

Reads a JSON document produced by
[`write_profile()`](https://r4sub.github.io/r4subprofile/reference/write_profile.md)
back into a `submission_profile`. The structure is checked the same way
a caller-built profile is: the reconstruction is routed through
[`custom_profile()`](https://r4sub.github.io/r4subprofile/reference/custom_profile.md),
so the imported profile must satisfy exactly the structural invariants
applied to the shipped profiles (pillar weights sum to 1, decision bands
integer- contiguous over 0-100, RPN bands integer-contiguous over
1-125). A document that fails them is rejected rather than silently
repaired.

## Usage

``` r
read_profile(file)
```

## Arguments

- file:

  A single string: either a path to a JSON file written by
  [`write_profile()`](https://r4sub.github.io/r4subprofile/reference/write_profile.md),
  or the JSON string itself.

## Value

A `submission_profile` object equivalent to the one that was written.

## Details

Only values present in the document are used; no weight, threshold, or
other value is invented or defaulted in.

## See also

[`write_profile()`](https://r4sub.github.io/r4subprofile/reference/write_profile.md).

## Examples

``` r
prof <- submission_profile("EMA", "MAA")
json <- write_profile(prof)
prof2 <- read_profile(json)
identical(prof, prof2)
#> [1] TRUE
```
