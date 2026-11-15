# Serialize a Submission Profile to Portable JSON

Writes a `submission_profile` – whether a built-in authority profile
from
[`submission_profile()`](https://r4sub.github.io/r4subprofile/reference/submission_profile.md)
or a caller-built one from
[`custom_profile()`](https://r4sub.github.io/r4subprofile/reference/custom_profile.md)
– to a portable JSON document that can be stored, version-controlled, or
shared and later read back with
[`read_profile()`](https://r4sub.github.io/r4subprofile/reference/read_profile.md)
into an equivalent, validated profile.

## Usage

``` r
write_profile(profile, file = NULL, pretty = TRUE)
```

## Arguments

- profile:

  A `submission_profile` object.

- file:

  Optional path to write the JSON to. When `NULL` (default) the JSON
  string is returned; when a path is given the JSON is written there and
  the path is returned invisibly.

- pretty:

  Logical; whether to pretty-print the JSON with indentation. Defaults
  to `TRUE`. The choice does not affect the round-trip as long as it is
  the same on repeated writes.

## Value

When `file` is `NULL`, a single JSON string. When `file` is a path, the
path, invisibly.

## Details

The serialization carries only values that already exist on the profile;
it invents, defaults, or alters no weight, threshold, or other
configured value. The document is wrapped in a small envelope recording
a schema version so that
[`read_profile()`](https://r4sub.github.io/r4subprofile/reference/read_profile.md)
can recognize and check it.

The export is a faithful, stable round-trip: reading a written profile
and writing it again produces byte-identical JSON (export, import,
export is stable).

## See also

[`read_profile()`](https://r4sub.github.io/r4subprofile/reference/read_profile.md)
to read the result back,
[`diff_profiles()`](https://r4sub.github.io/r4subprofile/reference/diff_profiles.md)
to compare a profile against a built-in authority.

## Examples

``` r
prof <- submission_profile("FDA", "NDA")
json <- write_profile(prof)
cat(json)
#> {
#>   "r4subprofile_schema": 1,
#>   "profile": {
#>     "authority": "FDA",
#>     "full_name": "U.S. Food and Drug Administration",
#>     "country": "United States",
#>     "submission_type": "NDA",
#>     "study_phase": null,
#>     "pillar_weights": {
#>       "quality": 0.35,
#>       "trace": 0.25,
#>       "risk": 0.25,
#>       "usability": 0.15
#>     },
#>     "bands": {
#>       "ready": [85, 100],
#>       "minor_gaps": [70, 84],
#>       "conditional": [50, 69],
#>       "high_risk": [0, 49]
#>     },
#>     "required_indicators": ["Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN", "Q-DUP-RECORDS", "Q-FORMAT-ERR", "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP", "T-DERIVATION-DOC", "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP", "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"],
#>     "required_asset_types": ["dataset", "define", "program", "validation", "spec"],
#>     "minimum_coverage": 0.9,
#>     "rpn_bands": {
#>       "critical": [80, 125],
#>       "high": [40, 79],
#>       "medium": [15, 39],
#>       "low": [1, 14]
#>     },
#>     "default_detectability": 3
#>   }
#> }

# Round-trip back into an equivalent profile:
prof2 <- read_profile(json)
identical(write_profile(prof2), json)
#> [1] TRUE
```
