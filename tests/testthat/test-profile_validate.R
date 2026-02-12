test_that("validate_against_profile returns profile_validation class", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "IND")
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expect_s3_class(result, "profile_validation")
})

test_that("returns is_compliant=TRUE when all requirements met", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "IND")
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expect_true(result$is_compliant)
})

test_that("identifies missing indicators", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "IND")
  # Only provide first indicator, missing the rest
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators[1],
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expect_true(length(result$missing_indicators) > 0L)
})

test_that("identifies missing asset types", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "NDA")
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = "dataset"  # missing define, program, etc.
  )
  result <- validate_against_profile(ev, prof)
  expect_true(length(result$missing_asset_types) > 0L)
})

test_that("coverage computation is correct", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "IND")
  req <- prof$required_indicators
  # Provide half the required indicators
  half <- req[seq_len(ceiling(length(req) / 2))]
  ev <- make_profile_test_evidence(
    indicator_ids = half,
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expected_coverage <- length(half) / length(req)
  expect_equal(result$coverage, round(expected_coverage, 4))
})

test_that("coverage_met reflects minimum_coverage threshold", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "NDA")
  # Provide only 1 indicator -- coverage should be below threshold
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators[1],
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expect_false(result$coverage_met)
})

test_that("validate_against_profile rejects non-profile input", {
  expect_error(validate_against_profile(data.frame(), list()), "submission_profile")
})

test_that("print.profile_validation does not error", {
  skip_if_not_installed("r4subcore")
  prof <- submission_profile("FDA", "IND")
  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = prof$required_asset_types
  )
  result <- validate_against_profile(ev, prof)
  expect_output(print(result), "Profile Validation")
})
