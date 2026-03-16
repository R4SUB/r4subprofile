# Validate Evidence Against a Submission Profile

Checks whether an evidence table meets the requirements specified by a
regulatory submission profile: required indicators present, required
asset types covered, and minimum indicator coverage met.

## Usage

``` r
validate_against_profile(evidence, profile)
```

## Arguments

- evidence:

  A validated evidence data.frame conforming to the r4subcore evidence
  schema.

- profile:

  A `submission_profile` object.

## Value

A list of class `"profile_validation"` with elements:

- `is_compliant`: logical; `TRUE` if all requirements are met

- `missing_indicators`: character vector of missing required indicator
  IDs

- `missing_asset_types`: character vector of missing required asset
  types

- `coverage`: numeric; fraction of required indicators present (0-1)

- `coverage_met`: logical; whether coverage meets the minimum threshold

- `details`: tibble with per-requirement status

## Examples

``` r
if (FALSE) { # \dontrun{
prof <- submission_profile("FDA", "NDA")
result <- validate_against_profile(evidence, prof)
result$is_compliant
result$missing_indicators
} # }
```
