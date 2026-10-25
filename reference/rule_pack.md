# Select a Rule Pack

Returns a rule pack by id (which encodes the authority and version, for
example `"fda-2026.1"`). Each indicator in the pack carries a `source`
field for the authoritative citation that motivates it.

## Usage

``` r
rule_pack(id, sources = NULL)

# S3 method for class 'rule_pack'
print(x, ...)
```

## Arguments

- id:

  A pack id from
  [`rule_packs()`](https://r4sub.github.io/r4subprofile/reference/rule_packs.md),
  for example `"fda-2026.1"`.

- sources:

  Optional named character vector mapping `indicator_id` to a citation,
  used to fill the `source` field. Names not in the pack are ignored
  with a warning.

- x:

  A `rule_pack`.

- ...:

  Ignored.

## Value

An object of class `"rule_pack"` with `id`, `authority`, `version`,
`effective_date`, and an `indicators` tibble (`indicator_id`, `source`).

## Details

The built-in packs ship with `source` set to `NA`: the citations are
pending entry by someone with the regulatory references to hand,
deliberately rather than filled with unverified section numbers. Supply
them with the `sources` argument, or fill them from your own controlled
reference list. This keeps the pack mechanism, the versioning, and the
provenance usable now, with the citations added when they can be stated
accurately.

## See also

[`rule_packs()`](https://r4sub.github.io/r4subprofile/reference/rule_packs.md),
[`rule_pack_provenance()`](https://r4sub.github.io/r4subprofile/reference/rule_pack_provenance.md).

## Examples

``` r
pack <- rule_pack("fda-2026.1")
pack
#> ℹ Rule pack "fda-2026.1": FDA, version 2026.1, effective 2026-01-01
#> ℹ   15 indicators, 0 with a source citation
rule_pack_indicators(pack)
#> # A tibble: 15 × 2
#>    indicator_id      source
#>    <chr>             <chr> 
#>  1 Q-DUP-RECORDS     NA    
#>  2 Q-FORMAT-ERR      NA    
#>  3 Q-LABEL-LEN       NA    
#>  4 Q-MISS-VAR        NA    
#>  5 Q-TYPE-MISMATCH   NA    
#>  6 R-HIGH-RPN        NA    
#>  7 R-MITIGATION-GAP  NA    
#>  8 R-OPEN-RISK       NA    
#>  9 T-AMBIGUOUS-MAP   NA    
#> 10 T-DERIVATION-DOC  NA    
#> 11 T-ORPHAN-VAR      NA    
#> 12 T-TRACE-LEVEL     NA    
#> 13 U-DEFINE-COMPLETE NA    
#> 14 U-LABEL-QUALITY   NA    
#> 15 U-REVIEWER-NOTE   NA    

# Supply citations for a controlled reference list:
pack <- rule_pack("fda-2026.1",
  sources = c("Q-MISS-VAR" = "FDA Study Data Technical Conformance Guide"))
```
