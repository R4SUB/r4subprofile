# Regulatory Authority Profiles

Different regulatory authorities weight the four R4SUB evidence pillars
(quality, trace, risk, usability) differently. The `r4subprofile`
package encodes these authority-specific requirements so that the SCI
can be calibrated accordingly.

``` r
library(r4subprofile)
```

## Supported authorities

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

## Submission types per authority

``` r
list_submission_types("FDA")
#> [1] "IND"   "NDA"   "BLA"   "ANDA"  "505b2"
list_submission_types("EMA")
#> [1] "CTA"       "MAA"       "variation"
```

## Creating a submission profile

[`submission_profile()`](https://r4sub.github.io/r4subprofile/reference/submission_profile.md)
returns a profile with authority-specific pillar weights, decision
bands, and required indicators:

``` r
fda_nda <- submission_profile("FDA", "NDA")
fda_nda$pillar_weights
#>   quality     trace      risk usability 
#>      0.35      0.25      0.25      0.15
fda_nda$minimum_coverage
#> [1] 0.9
```

``` r
ema_maa <- submission_profile("EMA", "MAA", study_phase = "Phase3")
ema_maa$pillar_weights
#>   quality     trace      risk usability 
#>      0.30      0.25      0.30      0.15
```

## Comparing authority weights

FDA NDA vs EMA MAA pillar weights:

``` r
weights_df <- data.frame(
  pillar    = c("quality", "trace", "risk", "usability"),
  FDA_NDA   = unname(fda_nda$pillar_weights),
  EMA_MAA   = unname(ema_maa$pillar_weights)
)
weights_df
#>      pillar FDA_NDA EMA_MAA
#> 1   quality    0.35    0.30
#> 2     trace    0.25    0.25
#> 3      risk    0.25    0.30
#> 4 usability    0.15    0.15
```

## Profile summary

[`profile_summary()`](https://r4sub.github.io/r4subprofile/reference/profile_summary.md)
returns a tidy tibble summarising the profile:

``` r
profile_summary(fda_nda)
#> ℹ Submission Profile: FDA NDA
#>   Authority:    U.S. Food and Drug Administration (United States)
#> 
#>   Pillar Weights:
#>     quality     0.35
#>     trace       0.25
#>     risk        0.25
#>     usability   0.15
#> 
#>   Decision Bands:
#>     ready         [85, 100]
#>     minor_gaps    [70, 84]
#>     conditional   [50, 69]
#>     high_risk     [0, 49]
#> 
#>   Required Indicators (15):
#>     - Q-MISS-VAR
#>     - Q-TYPE-MISMATCH
#>     - Q-LABEL-LEN
#>     - Q-DUP-RECORDS
#>     - Q-FORMAT-ERR
#>     - T-ORPHAN-VAR
#>     - T-TRACE-LEVEL
#>     - T-AMBIGUOUS-MAP
#>     - T-DERIVATION-DOC
#>     - R-HIGH-RPN
#>     - R-OPEN-RISK
#>     - R-MITIGATION-GAP
#>     - U-DEFINE-COMPLETE
#>     - U-REVIEWER-NOTE
#>     - U-LABEL-QUALITY
#> 
#>   Required Asset Types: dataset, define, program, validation, spec
#>   Minimum Coverage:     90%
#>   Default Detectability: 3
```

## Validating evidence against a profile

[`validate_against_profile()`](https://r4sub.github.io/r4subprofile/reference/validate_against_profile.md)
checks an evidence table against the profile’s required indicators and
asset types:

``` r
ev <- data.frame(
  run_id           = "run-001",
  study_id         = "STUDY01",
  asset_type       = c("dataset", "define", "program", "spec"),
  asset_id         = c("ADSL", "define.xml", "prod_adsl.R", "ADSL"),
  source_name      = "r4subcore",
  source_version   = "0.1.2",
  indicator_id     = c("Q-001", "Q-002", "R-001", "U-001"),
  indicator_name   = c("Quality Check", "Define Check",
                       "Program Validation", "Label Quality"),
  indicator_domain = c("quality", "quality", "risk", "usability"),
  severity         = "info",
  result           = "pass",
  metric_value     = 1,
  metric_unit      = "score",
  message          = "Check passed",
  location         = c("ADSL", "define.xml", "prod_adsl.R", "ADSL"),
  evidence_payload = "{}",
  created_at       = Sys.time(),
  stringsAsFactors = FALSE
)

val <- validate_against_profile(ev, fda_nda)
val$is_compliant
#> [1] FALSE
val$coverage
#> [1] 0
val$missing_indicators
#>  [1] "Q-MISS-VAR"        "Q-TYPE-MISMATCH"   "Q-LABEL-LEN"      
#>  [4] "Q-DUP-RECORDS"     "Q-FORMAT-ERR"      "T-ORPHAN-VAR"     
#>  [7] "T-TRACE-LEVEL"     "T-AMBIGUOUS-MAP"   "T-DERIVATION-DOC" 
#> [10] "R-HIGH-RPN"        "R-OPEN-RISK"       "R-MITIGATION-GAP" 
#> [13] "U-DEFINE-COMPLETE" "U-REVIEWER-NOTE"   "U-LABEL-QUALITY"
```

The `details` tibble shows per-requirement status:

``` r
head(val$details)
#> # A tibble: 6 × 2
#>   requirement               status 
#>   <chr>                     <chr>  
#> 1 indicator:Q-MISS-VAR      missing
#> 2 indicator:Q-TYPE-MISMATCH missing
#> 3 indicator:Q-LABEL-LEN     missing
#> 4 indicator:Q-DUP-RECORDS   missing
#> 5 indicator:Q-FORMAT-ERR    missing
#> 6 indicator:T-ORPHAN-VAR    missing
```

## Study phase

Some authorities adjust requirements based on study phase. Pass
`study_phase` to reflect phase-specific requirements:

``` r
pmda_nda_p3 <- submission_profile("PMDA", "NDA_JP", study_phase = "Phase3")
pmda_nda_p3$pillar_weights
#>   quality     trace      risk usability 
#>      0.25      0.30      0.25      0.20
```
