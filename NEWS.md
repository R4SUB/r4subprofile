# r4subprofile 0.3.0

- Add `compare_authorities()`, a side-by-side comparison of submission profiles
  across regulatory authorities: pillar weights, the SCI needed to be ready,
  minimum coverage, the number of required indicators, and the detectability
  default. A sponsor filing in more than one region can see how the readiness
  bar changes between, say, the FDA and the EMA without building and reading
  each profile by hand. Authority names match case-insensitively and the
  submission type can be chosen per authority.

# r4subprofile 0.2.0

- Add versioned rule packs: `rule_packs()` lists the available packs,
  `rule_pack()` selects one by id (for example `"fda-2026.1"`) with an authority,
  a version, and an effective date, `rule_pack_indicators()` returns its
  indicators, and `rule_pack_provenance()` returns the identifying fields to
  record on a scored result so a score can be traced to the exact ruleset that
  produced it. Each indicator carries a `source` field for its authoritative
  citation; the built-in packs ship these as `NA` (pending entry from a
  controlled reference list rather than filled with unverified section numbers)
  and they can be supplied through the `sources` argument.

# r4subprofile 0.1.1

- Add vignette: "Regulatory Authority Profiles" covering `submission_profile()`,
  `profile_summary()`, `validate_against_profile()`, and authority weight comparisons.

# r4subprofile 0.1.0

- Initial CRAN release.
