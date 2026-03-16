# List Submission Types for an Authority

Returns the valid submission types for a given regulatory authority.

## Usage

``` r
list_submission_types(authority)
```

## Arguments

- authority:

  Character. A supported authority name.

## Value

A character vector of valid submission types.

## Examples

``` r
list_submission_types("FDA")
#> [1] "IND"   "NDA"   "BLA"   "ANDA"  "505b2"
list_submission_types("EMA")
#> [1] "CTA"       "MAA"       "variation"
```
