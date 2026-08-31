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
