# Compare a Profile Against a Built-in Authority

Reports the fields in which a profile – typically a
[`custom_profile()`](https://r4sub.github.io/r4subprofile/reference/custom_profile.md)
or a profile imported with
[`read_profile()`](https://r4sub.github.io/r4subprofile/reference/read_profile.md)
– differs from a built-in reference profile. It is a read-only
comparison of values that already exist on both profiles: nothing is
changed, and no weight or threshold is invented.

## Usage

``` r
diff_profiles(profile, reference, submission_type = NULL)
```

## Arguments

- profile:

  A `submission_profile` object (the one under inspection).

- reference:

  Either a `submission_profile` object to compare against, or a single
  string naming a built-in authority (for example `"FDA"`), in which
  case a built-in profile is built with
  [`submission_profile()`](https://r4sub.github.io/r4subprofile/reference/submission_profile.md).

- submission_type:

  Optional submission type to use when `reference` names an authority.
  `NULL` (default) uses that authority's first type. Ignored when
  `reference` is already a profile object.

## Value

A tibble with one row per differing field and columns `field`, `value`
(from `profile`), and `reference_value` (from `reference`). A zero-row
tibble means the two profiles agree on every field.

## Details

Both profiles are reduced to their one-row-per-field tibble form (the
same representation as `profile_summary(format = "tibble")`) and
compared field by field; only the differing fields are returned.

## See also

[`profile_summary()`](https://r4sub.github.io/r4subprofile/reference/profile_summary.md),
[`write_profile()`](https://r4sub.github.io/r4subprofile/reference/write_profile.md),
[`read_profile()`](https://r4sub.github.io/r4subprofile/reference/read_profile.md).

## Examples

``` r
mine <- custom_profile(
  authority = "FDA", submission_type = "NDA",
  pillar_weights = c(quality = 0.40, trace = 0.25, risk = 0.25, usability = 0.10),
  bands = list(
    ready = c(85, 100), minor_gaps = c(70, 84),
    conditional = c(50, 69), high_risk = c(0, 49)
  ),
  required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL"),
  required_asset_types = c("dataset", "define"),
  minimum_coverage = 0.90,
  rpn_bands = list(
    critical = c(80, 125), high = c(40, 79),
    medium = c(15, 39), low = c(1, 14)
  ),
  default_detectability = 3L
)
diff_profiles(mine, "FDA", submission_type = "NDA")
#> # A tibble: 6 × 3
#>   field                   value                     reference_value             
#>   <chr>                   <chr>                     <chr>                       
#> 1 full_name               FDA                       U.S. Food and Drug Administ…
#> 2 country                 NA                        United States               
#> 3 pillar_weight_quality   0.4                       0.35                        
#> 4 pillar_weight_usability 0.1                       0.15                        
#> 5 required_indicators     Q-MISS-VAR, T-TRACE-LEVEL Q-MISS-VAR, Q-TYPE-MISMATCH…
#> 6 required_asset_types    dataset, define           dataset, define, program, v…
```
