# Indicators in a Rule Pack

Indicators in a Rule Pack

## Usage

``` r
rule_pack_indicators(pack)
```

## Arguments

- pack:

  A `rule_pack` from
  [`rule_pack()`](https://r4sub.github.io/r4subprofile/reference/rule_pack.md).

## Value

The pack's indicators tibble (`indicator_id`, `source`).

## See also

[`rule_pack()`](https://r4sub.github.io/r4subprofile/reference/rule_pack.md).

## Examples

``` r
rule_pack_indicators(rule_pack("ema-2026.1"))
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
```
