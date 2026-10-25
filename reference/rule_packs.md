# Available Rule Packs

Lists the built-in rule packs. A rule pack is an identified, versioned
set of the indicators an authority requires, so a submission can be
scored against a named, dated ruleset and the result reproduced later.

## Usage

``` r
rule_packs()
```

## Value

A tibble with one row per pack: `id`, `authority`, `version`,
`effective_date`, and `n_indicators`.

## See also

[`rule_pack()`](https://r4sub.github.io/r4subprofile/reference/rule_pack.md).

## Examples

``` r
rule_packs()
#> # A tibble: 2 × 5
#>   id         authority version effective_date n_indicators
#>   <chr>      <chr>     <chr>   <chr>                 <int>
#> 1 fda-2026.1 FDA       2026.1  2026-01-01               15
#> 2 ema-2026.1 EMA       2026.1  2026-01-01               15
```
