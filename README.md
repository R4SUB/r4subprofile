# r4subprofile

**r4subprofile** defines regulatory submission profiles for the R4SUB clinical submission readiness ecosystem.

Each profile bundles authority-specific pillar weights, decision thresholds, required indicators, and risk configuration for a given regulatory authority and submission type.

## Installation

```r
pak::pak("R4SUB/r4subprofile")
```

## Supported Authorities

| Authority | Country | Submission Types |
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

# Browse authorities
list_authorities()
list_submission_types("FDA")

# Create a profile
prof <- submission_profile("FDA", "NDA")
prof$pillar_weights
prof$required_indicators

# Extract configs compatible with r4subscore / r4subrisk
sci_cfg  <- profile_sci_config(prof)
risk_cfg <- profile_risk_config(prof)

# Validate evidence against profile requirements
result <- validate_against_profile(evidence, prof)
result$is_compliant
result$missing_indicators
```

## Integration with R4SUB Packages

```r
library(r4subscore)
library(r4subprofile)

prof <- submission_profile("FDA", "NDA")

# Use profile weights for SCI computation
pillar_scores <- compute_pillar_scores(evidence, config = profile_sci_config(prof))
sci <- compute_sci(pillar_scores, config = profile_sci_config(prof))
```

## Exported Functions

| Function | Purpose |
|---|---|
| `submission_profile()` | Create a regulatory submission profile |
| `list_authorities()` | List all supported regulatory authorities |
| `list_submission_types()` | List valid submission types for an authority |
| `profile_sci_config()` | Extract SCI configuration (r4subscore compatible) |
| `profile_risk_config()` | Extract risk configuration (r4subrisk compatible) |
| `profile_required_indicators()` | Get mandatory indicators for a profile |
| `validate_against_profile()` | Check evidence completeness vs profile |
| `profile_summary()` | Print formatted profile summary |

## License

MIT
