# r4subprofile (development version)

- Add `custom_profile()`, a builder for a `submission_profile` from
  caller-supplied values. Every regulatory quantity (pillar weights, decision
  bands, required indicators and asset types, minimum coverage, RPN bands,
  detectability) is a required argument with no default, so the function invents
  no weights or thresholds of its own; it validates the supplied structure with
  the same invariants applied to the shipped profiles and returns an ordinary
  `submission_profile` that works with every existing accessor. This lets a
  sponsor score against an internal, regional, or not-yet-shipped ruleset whose
  numbers come from their own authoritative source.
- `compare_authorities()` gains an optional `rank_by` argument. The default
  `NULL` leaves the output and its ordering exactly as before. Set to
  `"minimum_coverage"`, `"ready_min"`, or `"n_required_indicators"` it orders the
  authorities from strictest to most lenient on that measure and adds the
  additive columns `strictness_rank`, `minor_gaps_min`, and `conditional_min`.
  Ranking only reorders rows and adds columns; no weight, threshold, or other
  configured value changes.
- `profile_summary()` gains a `format` argument. The default `"console"` keeps
  the printed, invisibly-returned behavior; `"tibble"` returns a tidy
  one-row-per-field tibble of the profile, so a summary can be filtered, joined,
  or written out programmatically.
- Add an internal structural check over the authority configuration, wired into
  the test suite: for every authority and submission type it asserts that pillar
  weights sum to 1, decision bands are contiguous and cover 0-100, and RPN bands
  cover 1-125. It validates structure only and changes no configured values.

# r4subprofile 0.3.1

- Fix the pkgdown reference index: drop stale print entries and add the rule-pack topics so the site builds.
- Docs: correct the description of `profile_summary()` in the vignette and the
  README; it prints a formatted summary and returns the profile invisibly, it
  does not return a tibble. Add `compare_authorities()` to the README function
  table.

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
