# Compare Submission Profiles Across Authorities

Puts several regulatory authorities side by side so a sponsor filing in
more than one region can see how the readiness bar differs: pillar
weights, the score needed to be ready, the minimum traceability
coverage, how many indicators are required, and the detectability
default that feeds risk scoring. It answers "what changes if we also
file with the EMA" without building and eyeballing each profile by hand.

## Usage

``` r
compare_authorities(authorities = NULL, submission_types = NULL)
```

## Arguments

- authorities:

  Character vector of authority names, matched case-insensitively (for
  example `c("fda", "ema", "pmda")`). Defaults to every supported
  authority from
  [`list_authorities()`](https://r4sub.github.io/r4subprofile/reference/list_authorities.md).

- submission_types:

  How to pick a submission type per authority. `NULL` (default) uses
  each authority's first type. A single string uses that type for every
  authority (and errors if one does not offer it). A named vector
  (`c(FDA = "NDA", EMA = "MAA")`) selects per authority, falling back to
  the first type for any authority not named.

## Value

A tibble with one row per authority and columns `authority`,
`full_name`, `country`, `submission_type`, the four pillar weights
(`w_quality`, `w_trace`, `w_risk`, `w_usability`), `ready_min` (lowest
SCI in the ready band), `minimum_coverage`, `n_required_indicators`,
`default_detectability`, and `required_asset_types`.

## Examples

``` r
compare_authorities(c("FDA", "EMA", "PMDA"))
#> # A tibble: 3 × 13
#>   authority full_name           country submission_type w_quality w_trace w_risk
#>   <chr>     <chr>               <chr>   <chr>               <dbl>   <dbl>  <dbl>
#> 1 FDA       U.S. Food and Drug… United… IND                  0.3     0.25   0.3 
#> 2 EMA       European Medicines… Europe… CTA                  0.3     0.2    0.35
#> 3 PMDA      Pharmaceuticals an… Japan   CTN                  0.25    0.3    0.3 
#> # ℹ 6 more variables: w_usability <dbl>, ready_min <dbl>,
#> #   minimum_coverage <dbl>, n_required_indicators <int>,
#> #   default_detectability <int>, required_asset_types <chr>

# A specific submission type where all three offer it is not guaranteed, so
# select per authority:
compare_authorities(
  c("FDA", "EMA"),
  submission_types = c(FDA = "NDA", EMA = "MAA")
)
#> # A tibble: 2 × 13
#>   authority full_name           country submission_type w_quality w_trace w_risk
#>   <chr>     <chr>               <chr>   <chr>               <dbl>   <dbl>  <dbl>
#> 1 FDA       U.S. Food and Drug… United… NDA                  0.35    0.25   0.25
#> 2 EMA       European Medicines… Europe… MAA                  0.3     0.25   0.3 
#> # ℹ 6 more variables: w_usability <dbl>, ready_min <dbl>,
#> #   minimum_coverage <dbl>, n_required_indicators <int>,
#> #   default_detectability <int>, required_asset_types <chr>
```
