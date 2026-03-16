# List Supported Regulatory Authorities

Returns a summary of all supported regulatory authorities with their
full names, countries, and number of available submission types.

## Usage

``` r
list_authorities()
```

## Value

A tibble with columns: `authority`, `full_name`, `country`,
`n_submission_types`.

## Examples

``` r
list_authorities()
#> # A tibble: 6 × 4
#>   authority     full_name                             country n_submission_types
#>   <chr>         <chr>                                 <chr>                <int>
#> 1 FDA           U.S. Food and Drug Administration     United…                  5
#> 2 EMA           European Medicines Agency             Europe…                  3
#> 3 PMDA          Pharmaceuticals and Medical Devices … Japan                    2
#> 4 Health_Canada Health Canada                         Canada                   2
#> 5 TGA           Therapeutic Goods Administration      Austra…                  2
#> 6 MHRA          Medicines and Healthcare products Re… United…                  2
```
