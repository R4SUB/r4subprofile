# Extract Risk Configuration from a Profile

Returns a list with structure compatible with
[`r4subrisk::risk_config_default()`](https://rdrr.io/pkg/r4subrisk/man/risk_config_default.html).
Can be passed directly to risk assessment functions.

## Usage

``` r
profile_risk_config(profile)
```

## Arguments

- profile:

  A `submission_profile` object.

## Value

A list of class `"risk_config"` with `rpn_bands`,
`evidence_severity_to_probability`, `evidence_severity_to_impact`, and
`default_detectability`.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
cfg <- profile_risk_config(prof)
cfg$rpn_bands
#> $critical
#> [1]  80 125
#> 
#> $high
#> [1] 40 79
#> 
#> $medium
#> [1] 15 39
#> 
#> $low
#> [1]  1 14
#> 
```
