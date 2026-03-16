# r4subprofile

<!-- badges: start -->
[![R-CMD-check](https://github.com/R4SUB/r4subprofile/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R4SUB/r4subprofile/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/r4subprofile)](https://CRAN.R-project.org/package=r4subprofile)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/r4subprofile)](https://CRAN.R-project.org/package=r4subprofile)
[![r-universe](https://r4sub.r-universe.dev/badges/r4subprofile)](https://r4sub.r-universe.dev/r4subprofile)
<!-- badges: end -->

**r4subprofile** defines regulatory submission profiles for the R4SUB clinical submission readiness ecosystem. Each profile bundles authority-specific pillar weights, decision thresholds, required indicators, and risk configuration for a given regulatory authority and submission type.

## Installation

```r
install.packages("r4subprofile")
```

Development version:

```r
pak::pak("R4SUB/r4subprofile")
```

## Supported Authorities

| Authority | Region | Submission Types |
|---|---|---|
| **FDA** | United States | IND, NDA, BLA, ANDA, 505b2 |
| **EMA** | European Union | CTA, MAA, variation |
| **PMDA** | Japan | CTN, NDA_JP |
| **Health_Canada** | Canada | CTA_CA, NDS |
| **TGA** | Australia | CTN_AU, registration |
| **MHRA** | United Kingdom | CTA_UK, MAA_UK |

## Quick Start

```r
library(r4subprofile)

# Browse supported authorities
list_authorities()
list_submission_types("FDA")

# Create a submission profile
prof <- submission_profile("FDA", "NDA")
prof$pillar_weights
prof$required_indicators

# Extract configs for downstream packages
sci_cfg  <- profile_sci_config(prof)
risk_cfg <- profile_risk_config(prof)

# Validate evidence against profile requirements
val <- validate_against_profile(evidence, prof)
val$is_compliant
val$missing_indicators
```

## Integration with r4subscore

```r
library(r4subscore)
library(r4subprofile)

prof <- submission_profile("EMA", "MAA", study_phase = "Phase3")

pillar_scores <- compute_pillar_scores(evidence, config = profile_sci_config(prof))
sci           <- compute_sci(pillar_scores, config = profile_sci_config(prof))
```

## Key Functions

| Function | Purpose |
|---|---|
| `submission_profile()` | Create a regulatory submission profile |
| `list_authorities()` | List all supported regulatory authorities |
| `list_submission_types()` | List valid submission types for an authority |
| `profile_sci_config()` | Extract SCI config (r4subscore compatible) |
| `profile_risk_config()` | Extract risk config (r4subrisk compatible) |
| `profile_required_indicators()` | Get mandatory indicators for a profile |
| `validate_against_profile()` | Check evidence completeness vs profile |
| `profile_summary()` | Tidy tibble summary of a profile |

## License

MIT
