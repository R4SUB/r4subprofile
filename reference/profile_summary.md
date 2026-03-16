# Summarize a Submission Profile

Prints a formatted summary of a regulatory submission profile including
authority details, pillar weights, decision bands, and requirements.

## Usage

``` r
profile_summary(profile)
```

## Arguments

- profile:

  A `submission_profile` object.

## Value

The profile object, invisibly.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
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
```
