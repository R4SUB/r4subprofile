test_that("profile_sci_config returns sci_config class", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_sci_config(prof)
  expect_s3_class(cfg, "sci_config")
})

test_that("sci_config has pillar_weights and bands", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_sci_config(prof)
  expect_true("pillar_weights" %in% names(cfg))
  expect_true("bands" %in% names(cfg))
})

test_that("sci_config pillar_weights sum to 1", {
  prof <- submission_profile("EMA", "MAA")
  cfg <- profile_sci_config(prof)
  expect_equal(sum(cfg$pillar_weights), 1.0)
})

test_that("sci_config bands are numeric vectors of length 2", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_sci_config(prof)
  for (band in cfg$bands) {
    expect_true(is.numeric(band))
    expect_equal(length(band), 2L)
  }
})

test_that("profile_risk_config returns risk_config class", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_risk_config(prof)
  expect_s3_class(cfg, "risk_config")
})

test_that("risk_config has rpn_bands and default_detectability", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_risk_config(prof)
  expect_true("rpn_bands" %in% names(cfg))
  expect_true("default_detectability" %in% names(cfg))
})

test_that("risk_config default_detectability is between 1 and 5", {
  prof <- submission_profile("FDA", "NDA")
  cfg <- profile_risk_config(prof)
  expect_true(cfg$default_detectability >= 1L && cfg$default_detectability <= 5L)
})

test_that("config extractors reject non-profile input", {
  expect_error(profile_sci_config(list()), "submission_profile")
  expect_error(profile_risk_config(list()), "submission_profile")
})
