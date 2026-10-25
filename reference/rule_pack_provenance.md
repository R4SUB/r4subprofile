# Provenance of a Rule Pack

Returns the identifying fields of a rule pack as a named character
vector, to record on a scored result so the score can always be traced
to the exact ruleset and version that produced it.

## Usage

``` r
rule_pack_provenance(pack)
```

## Arguments

- pack:

  A `rule_pack` from
  [`rule_pack()`](https://r4sub.github.io/r4subprofile/reference/rule_pack.md).

## Value

A named character vector: `rule_pack`, `rule_pack_version`,
`effective_date`.

## See also

[`rule_pack()`](https://r4sub.github.io/r4subprofile/reference/rule_pack.md).

## Examples

``` r
rule_pack_provenance(rule_pack("fda-2026.1"))
#>         rule_pack rule_pack_version    effective_date 
#>      "fda-2026.1"          "2026.1"      "2026-01-01" 
```
