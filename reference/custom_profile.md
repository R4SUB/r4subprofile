# Build a Submission Profile from Caller-Supplied Values

Constructs a `submission_profile` from values you supply, rather than
from a built-in regulatory authority. Every regulatory quantity (pillar
weights, decision bands, required indicators and asset types, minimum
coverage, RPN bands, detectability) is a required argument with no
default: this function invents no weights or thresholds of its own. It
is the escape hatch for a sponsor who must score against an internal,
regional, or not-yet-shipped ruleset whose numbers come from their own
authoritative source.

## Usage

``` r
custom_profile(
  authority,
  submission_type,
  pillar_weights,
  bands,
  required_indicators,
  required_asset_types,
  minimum_coverage,
  rpn_bands,
  default_detectability,
  full_name = authority,
  country = NA_character_,
  study_phase = NULL
)
```

## Arguments

- authority:

  Character. A name for the authority or ruleset (used in printed
  output; it need not be one of the built-in authorities).

- submission_type:

  Character. A name for the submission type.

- pillar_weights:

  Named numeric vector with names `"quality"`, `"trace"`, `"risk"`, and
  `"usability"` (in any order), each in `[0, 1]` and summing to 1.

- bands:

  Named list of decision bands with names `"ready"`, `"minor_gaps"`,
  `"conditional"`, and `"high_risk"`, each a length-2 numeric
  `c(low, high)`. The bands must be integer-contiguous and together
  cover 0-100.

- required_indicators:

  Non-empty character vector of required `indicator_id` values (no `NA`,
  no duplicates).

- required_asset_types:

  Non-empty character vector of required asset types (no `NA`, no
  duplicates).

- minimum_coverage:

  Single numeric in `[0, 1]`: the fraction of required indicators that
  must be present.

- rpn_bands:

  Named list of RPN bands with names `"critical"`, `"high"`, `"medium"`,
  and `"low"`, each a length-2 numeric `c(low, high)`. The bands must be
  integer-contiguous and together cover 1-125.

- default_detectability:

  Single whole number in `1:5`.

- full_name:

  Character. Full name of the authority. Defaults to `authority`.

- country:

  Character or `NA`. Country or region. Defaults to `NA`.

- study_phase:

  Character or `NULL`. Optional study phase, stored as-is.

## Value

A list of class `"submission_profile"`, identical in shape to the output
of
[`submission_profile()`](https://r4sub.github.io/r4subprofile/reference/submission_profile.md).

## Details

The supplied structure is validated the same way the shipped profiles
are: pillar weights must sum to 1, decision bands must be
integer-contiguous and cover 0-100, and RPN bands must be
integer-contiguous and cover 1-125. The result is an ordinary
`submission_profile`, so every function in this package that takes one –
[`profile_summary()`](https://r4sub.github.io/r4subprofile/reference/profile_summary.md),
[`validate_against_profile()`](https://r4sub.github.io/r4subprofile/reference/validate_against_profile.md),
[`profile_sci_config()`](https://r4sub.github.io/r4subprofile/reference/profile_sci_config.md),
[`profile_risk_config()`](https://r4sub.github.io/r4subprofile/reference/profile_risk_config.md),
[`profile_required_indicators()`](https://r4sub.github.io/r4subprofile/reference/profile_required_indicators.md)
– works on it unchanged.

## See also

[`submission_profile()`](https://r4sub.github.io/r4subprofile/reference/submission_profile.md)
for the built-in authorities.

## Examples

``` r
prof <- custom_profile(
  authority = "Internal",
  submission_type = "Gate2",
  pillar_weights = c(quality = 0.4, trace = 0.2, risk = 0.3, usability = 0.1),
  bands = list(
    ready = c(85, 100), minor_gaps = c(70, 84),
    conditional = c(50, 69), high_risk = c(0, 49)
  ),
  required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL", "R-HIGH-RPN"),
  required_asset_types = c("dataset", "define"),
  minimum_coverage = 0.8,
  rpn_bands = list(
    critical = c(80, 125), high = c(40, 79),
    medium = c(15, 39), low = c(1, 14)
  ),
  default_detectability = 3L
)
profile_summary(prof)
#> ℹ Submission Profile: Internal Gate2
#>   Authority:    Internal (NA)
#> 
#>   Pillar Weights:
#>     quality     0.40
#>     trace       0.20
#>     risk        0.30
#>     usability   0.10
#> 
#>   Decision Bands:
#>     ready         [85, 100]
#>     minor_gaps    [70, 84]
#>     conditional   [50, 69]
#>     high_risk     [0, 49]
#> 
#>   Required Indicators (3):
#>     - Q-MISS-VAR
#>     - T-TRACE-LEVEL
#>     - R-HIGH-RPN
#> 
#>   Required Asset Types: dataset, define
#>   Minimum Coverage:     80%
#>   Default Detectability: 3
```
