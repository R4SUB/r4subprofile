# Get Required Indicators for a Profile

Returns the list of indicator IDs that are mandatory for the given
submission profile.

## Usage

``` r
profile_required_indicators(profile)
```

## Arguments

- profile:

  A `submission_profile` object.

## Value

A character vector of required `indicator_id` values.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
profile_required_indicators(prof)
#>  [1] "Q-MISS-VAR"        "Q-TYPE-MISMATCH"   "Q-LABEL-LEN"      
#>  [4] "Q-DUP-RECORDS"     "Q-FORMAT-ERR"      "T-ORPHAN-VAR"     
#>  [7] "T-TRACE-LEVEL"     "T-AMBIGUOUS-MAP"   "T-DERIVATION-DOC" 
#> [10] "R-HIGH-RPN"        "R-OPEN-RISK"       "R-MITIGATION-GAP" 
#> [13] "U-DEFINE-COMPLETE" "U-REVIEWER-NOTE"   "U-LABEL-QUALITY"  

prof_ind <- submission_profile("FDA", "IND")
profile_required_indicators(prof_ind)
#> [1] "Q-MISS-VAR"        "Q-TYPE-MISMATCH"   "T-TRACE-LEVEL"    
#> [4] "R-HIGH-RPN"        "U-DEFINE-COMPLETE"
```
