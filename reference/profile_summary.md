# Summarize a Submission Profile

Summarizes a regulatory submission profile. The default `"console"`
format prints a human-readable summary (authority details, pillar
weights, decision bands, and requirements) and returns the profile
invisibly. The `"tibble"` format instead returns a tidy,
one-row-per-field tibble of the same information, so a summary can be
filtered, joined, or written out programmatically.

## Usage

``` r
profile_summary(profile, format = c("console", "tibble"))
```

## Arguments

- profile:

  A `submission_profile` object.

- format:

  One of `"console"` (default) or `"tibble"`. `"console"` keeps the
  printed-and-invisible behavior; `"tibble"` returns a tidy tibble.

## Value

For `format = "console"`, the profile object, invisibly. For
`format = "tibble"`, a tibble with one row per profile field and columns
`field` and `value` (character).

## Examples

``` r
prof <- submission_profile("FDA", "NDA")

# Printed summary (returns the profile invisibly):
profile_summary(prof)
#> ℹ Submission Profile: FDA NDA
#>   Authority:    U.S. Food and Drug Administration (United States)
#> 
#>   Pillar Weights:
#>     quality     0.35
#>     trace       0.25
#>     risk        0.25
#>     usability   0.15
#> 
#>   Decision Bands:
#>     ready         [85, 100]
#>     minor_gaps    [70, 84]
#>     conditional   [50, 69]
#>     high_risk     [0, 49]
#> 
#>   Required Indicators (15):
#>     - Q-MISS-VAR
#>     - Q-TYPE-MISMATCH
#>     - Q-LABEL-LEN
#>     - Q-DUP-RECORDS
#>     - Q-FORMAT-ERR
#>     - T-ORPHAN-VAR
#>     - T-TRACE-LEVEL
#>     - T-AMBIGUOUS-MAP
#>     - T-DERIVATION-DOC
#>     - R-HIGH-RPN
#>     - R-OPEN-RISK
#>     - R-MITIGATION-GAP
#>     - U-DEFINE-COMPLETE
#>     - U-REVIEWER-NOTE
#>     - U-LABEL-QUALITY
#> 
#>   Required Asset Types: dataset, define, program, validation, spec
#>   Minimum Coverage:     90%
#>   Default Detectability: 3

# Tidy tibble for programmatic use:
profile_summary(prof, format = "tibble")
#> # A tibble: 21 × 2
#>    field                   value                            
#>    <chr>                   <chr>                            
#>  1 authority               FDA                              
#>  2 full_name               U.S. Food and Drug Administration
#>  3 country                 United States                    
#>  4 submission_type         NDA                              
#>  5 study_phase             NA                               
#>  6 pillar_weight_quality   0.35                             
#>  7 pillar_weight_trace     0.25                             
#>  8 pillar_weight_risk      0.25                             
#>  9 pillar_weight_usability 0.15                             
#> 10 band_ready              85-100                           
#> # ℹ 11 more rows
```
