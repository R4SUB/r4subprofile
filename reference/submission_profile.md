# Create a Submission Profile

Constructs a regulatory submission profile with authority-specific
pillar weights, decision bands, required indicators, and risk
configuration.

## Usage

``` r
submission_profile(authority, submission_type, study_phase = NULL)
```

## Arguments

- authority:

  Character. Regulatory authority name (e.g., `"FDA"`, `"EMA"`). See
  [`list_authorities()`](https://r4sub.github.io/r4subprofile/reference/list_authorities.md)
  for all supported values.

- submission_type:

  Character. Submission type for the authority (e.g., `"NDA"`, `"MAA"`).
  See
  [`list_submission_types()`](https://r4sub.github.io/r4subprofile/reference/list_submission_types.md)
  for valid values.

- study_phase:

  Character or `NULL`. Optional study phase (e.g., `"Phase1"`,
  `"Phase2"`, `"Phase3"`, `"Phase4"`). Currently informational.

## Value

A list of class `"submission_profile"` with elements: `authority`,
`full_name`, `country`, `submission_type`, `study_phase`,
`pillar_weights`, `bands`, `required_indicators`,
`required_asset_types`, `minimum_coverage`, `rpn_bands`,
`default_detectability`.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
prof$pillar_weights
#>   quality     trace      risk usability 
#>      0.35      0.25      0.25      0.15 
prof$required_indicators
#>  [1] "Q-MISS-VAR"        "Q-TYPE-MISMATCH"   "Q-LABEL-LEN"      
#>  [4] "Q-DUP-RECORDS"     "Q-FORMAT-ERR"      "T-ORPHAN-VAR"     
#>  [7] "T-TRACE-LEVEL"     "T-AMBIGUOUS-MAP"   "T-DERIVATION-DOC" 
#> [10] "R-HIGH-RPN"        "R-OPEN-RISK"       "R-MITIGATION-GAP" 
#> [13] "U-DEFINE-COMPLETE" "U-REVIEWER-NOTE"   "U-LABEL-QUALITY"  

prof_ema <- submission_profile("EMA", "MAA", study_phase = "Phase3")
prof_ema$bands
#> $ready
#> [1]  85 100
#> 
#> $minor_gaps
#> [1] 70 84
#> 
#> $conditional
#> [1] 50 69
#> 
#> $high_risk
#> [1]  0 49
#> 
```
