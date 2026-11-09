# Tests for compare_authorities() (R/compare_authorities.R)

test_that("default compares every supported authority", {
  cmp <- compare_authorities()
  expect_s3_class(cmp, "tbl_df")
  expect_setequal(cmp$authority, list_authorities()$authority)
  expect_true(all(c(
    "authority", "full_name", "country", "submission_type",
    "w_quality", "w_trace", "w_risk", "w_usability",
    "ready_min", "minimum_coverage", "n_required_indicators",
    "default_detectability", "required_asset_types"
  ) %in% names(cmp)))
})

test_that("a subset uses each authority's first submission type", {
  cmp <- compare_authorities(c("FDA", "EMA", "PMDA"))
  expect_equal(nrow(cmp), 3L)
  expect_equal(cmp$submission_type[cmp$authority == "FDA"], "IND")
  expect_equal(cmp$submission_type[cmp$authority == "EMA"], "CTA")
  expect_equal(cmp$submission_type[cmp$authority == "PMDA"], "CTN")
})

test_that("authority names are matched case-insensitively", {
  cmp <- compare_authorities(c("fda", "ema"))
  expect_equal(cmp$authority, c("FDA", "EMA"))
})

test_that("pillar weights sum to one for each authority", {
  cmp <- compare_authorities()
  s <- cmp$w_quality + cmp$w_trace + cmp$w_risk + cmp$w_usability
  expect_true(all(abs(s - 1) < 1e-8))
})

test_that("a named submission_types vector selects per authority", {
  cmp <- compare_authorities(c("FDA", "EMA"),
                             submission_types = c(FDA = "NDA", EMA = "MAA"))
  expect_equal(cmp$submission_type[cmp$authority == "FDA"], "NDA")
  expect_equal(cmp$submission_type[cmp$authority == "EMA"], "MAA")
})

test_that("an unnamed authority falls back to its first type", {
  cmp <- compare_authorities(c("FDA", "EMA"), submission_types = c(FDA = "BLA"))
  expect_equal(cmp$submission_type[cmp$authority == "FDA"], "BLA")
  expect_equal(cmp$submission_type[cmp$authority == "EMA"], "CTA")  # fallback
})

test_that("a single submission type is applied to all, erroring where absent", {
  # NDA exists for FDA but not for EMA
  expect_error(compare_authorities(c("FDA", "EMA"), submission_types = "NDA"),
               "not offered")
})

test_that("unknown authorities are rejected", {
  expect_error(compare_authorities(c("FDA", "NASA")), "Unknown")
})

test_that("an unnamed multi-value submission_types is rejected", {
  expect_error(
    compare_authorities(c("FDA", "EMA"), submission_types = c("NDA", "MAA")),
    "must be named"
  )
})

test_that("ready_min and coverage come through as numbers", {
  cmp <- compare_authorities("PMDA")
  expect_equal(cmp$ready_min, 82)
  expect_equal(cmp$minimum_coverage, 0.75)
  expect_equal(cmp$n_required_indicators, 6L)
})

test_that("rank_by = NULL leaves the default output unchanged", {
  base_cols <- c(
    "authority", "full_name", "country", "submission_type",
    "w_quality", "w_trace", "w_risk", "w_usability",
    "ready_min", "minimum_coverage", "n_required_indicators",
    "default_detectability", "required_asset_types"
  )
  cmp <- compare_authorities()
  # Default call carries exactly the original columns, in order, and no rank
  # columns leak in.
  expect_identical(names(cmp), base_cols)
  expect_false("strictness_rank" %in% names(cmp))
  # Explicit NULL is identical to the implicit default.
  expect_identical(compare_authorities(rank_by = NULL), cmp)
})

test_that("rank_by orders authorities strictest first and adds columns", {
  cmp <- compare_authorities(rank_by = "minimum_coverage")
  # Rows are ordered by the measure, descending.
  expect_true(all(diff(cmp$minimum_coverage) <= 0))
  # Additive columns are present.
  expect_true(all(c("strictness_rank", "minor_gaps_min", "conditional_min") %in%
                    names(cmp)))
  # Strictest authority ranks first.
  expect_equal(cmp$strictness_rank[1], 1L)
  expect_equal(cmp$minimum_coverage[1], max(cmp$minimum_coverage))
})

test_that("ranking reorders rows but changes no existing value", {
  base_cols <- c(
    "authority", "full_name", "country", "submission_type",
    "w_quality", "w_trace", "w_risk", "w_usability",
    "ready_min", "minimum_coverage", "n_required_indicators",
    "default_detectability", "required_asset_types"
  )
  base <- compare_authorities(c("FDA", "EMA", "PMDA"))
  ranked <- compare_authorities(c("FDA", "EMA", "PMDA"),
                                rank_by = "n_required_indicators")
  # Same set of authorities, same shared columns, values preserved after a
  # reordering join.
  expect_setequal(ranked$authority, base$authority)
  reord <- ranked[match(base$authority, ranked$authority), base_cols]
  expect_equal(as.data.frame(reord), as.data.frame(base[, base_cols]))
})

test_that("ties in the ranking measure share a rank and keep original order", {
  # FDA (IND) and EMA (CTA) both require coverage 0.70.
  cmp <- compare_authorities(c("FDA", "EMA"), rank_by = "minimum_coverage")
  expect_equal(cmp$minimum_coverage, c(0.70, 0.70))
  expect_equal(cmp$strictness_rank, c(1L, 1L))
  expect_equal(cmp$authority, c("FDA", "EMA"))
})

test_that("an unknown rank_by value is rejected", {
  expect_error(compare_authorities(rank_by = "not_a_measure"), "Unknown")
  expect_error(compare_authorities(rank_by = c("ready_min", "minimum_coverage")),
               "single string")
})
