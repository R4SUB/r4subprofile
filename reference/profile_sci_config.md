# Extract SCI Configuration from a Profile

Returns a list with structure compatible with
[`r4subscore::sci_config_default()`](https://rdrr.io/pkg/r4subscore/man/sci_config_default.html).
Can be passed directly to
[`compute_pillar_scores()`](https://rdrr.io/pkg/r4subscore/man/compute_pillar_scores.html)
or
[`compute_sci()`](https://rdrr.io/pkg/r4subscore/man/compute_sci.html).

## Usage

``` r
profile_sci_config(profile)
```

## Arguments

- profile:

  A `submission_profile` object.

## Value

A list of class `"sci_config"` with `pillar_weights` and `bands`.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
cfg <- profile_sci_config(prof)
cfg$pillar_weights
#>   quality     trace      risk usability 
#>      0.35      0.25      0.25      0.15 
cfg$bands
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
