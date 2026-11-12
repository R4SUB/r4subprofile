valid_args <- function(...) {
  args <- list(
    authority = "Internal",
    submission_type = "Gate2",
    pillar_weights = c(quality = 0.4, trace = 0.2, risk = 0.3, usability = 0.1),
    bands = list(
      ready = c(85, 100), minor_gaps = c(70, 84),
      conditional = c(50, 69), high_risk = c(0, 49)
    ),
    required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL", "R-HIGH-RPN"),
    required_asset_types = c("dataset", "define"),
    minimum_coverage = 0.8,
    rpn_bands = list(
      critical = c(80, 125), high = c(40, 79),
      medium = c(15, 39), low = c(1, 14)
    ),
    default_detectability = 3L
  )
  utils::modifyList(args, list(...))
}

mk <- function(...) do.call(custom_profile, valid_args(...))

test_that("custom_profile returns a submission_profile with the expected shape", {
  prof <- mk()
  expect_s3_class(prof, "submission_profile")
  expected <- c("authority", "full_name", "country", "submission_type",
                "study_phase", "pillar_weights", "bands",
                "required_indicators", "required_asset_types",
                "minimum_coverage", "rpn_bands", "default_detectability")
  expect_true(all(expected %in% names(prof)))
})

test_that("supplied values are stored verbatim", {
  prof <- mk(study_phase = "Phase3", country = "Nowhere")
  expect_equal(prof$authority, "Internal")
  expect_equal(prof$submission_type, "Gate2")
  expect_equal(prof$study_phase, "Phase3")
  expect_equal(prof$country, "Nowhere")
  expect_equal(prof$required_indicators, c("Q-MISS-VAR", "T-TRACE-LEVEL", "R-HIGH-RPN"))
  expect_equal(prof$minimum_coverage, 0.8)
  expect_identical(prof$default_detectability, 3L)
})

test_that("full_name defaults to authority and country to NA", {
  prof <- mk()
  expect_equal(prof$full_name, "Internal")
  expect_true(is.na(prof$country))
})

test_that("fields are normalised to canonical order regardless of input order", {
  prof <- mk(
    pillar_weights = c(risk = 0.3, quality = 0.4, usability = 0.1, trace = 0.2),
    bands = list(
      high_risk = c(0, 49), ready = c(85, 100),
      conditional = c(50, 69), minor_gaps = c(70, 84)
    )
  )
  expect_equal(names(prof$pillar_weights),
               c("quality", "trace", "risk", "usability"))
  expect_equal(names(prof$bands),
               c("ready", "minor_gaps", "conditional", "high_risk"))
  expect_equal(names(prof$rpn_bands),
               c("critical", "high", "medium", "low"))
})

test_that("the result works with every profile consumer", {
  prof <- mk()
  expect_identical(profile_summary(prof), prof)
  expect_equal(profile_required_indicators(prof), prof$required_indicators)
  expect_s3_class(profile_sci_config(prof), "sci_config")
  expect_s3_class(profile_risk_config(prof), "risk_config")
  tb <- profile_summary(prof, format = "tibble")
  expect_s3_class(tb, "tbl_df")

  ev <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = prof$required_asset_types
  )
  res <- validate_against_profile(ev, prof)
  expect_s3_class(res, "profile_validation")
  expect_true(res$is_compliant)
})

test_that("pillar weights must sum to 1", {
  expect_error(
    mk(pillar_weights = c(quality = 0.5, trace = 0.2, risk = 0.3, usability = 0.1)),
    "sum to"
  )
})

test_that("pillar weights must carry exactly the four pillar names", {
  expect_error(
    mk(pillar_weights = c(quality = 0.5, trace = 0.3, risk = 0.2)),
    "named exactly"
  )
})

test_that("decision bands must cover 0-100 and be contiguous", {
  expect_error(
    mk(bands = list(
      ready = c(85, 100), minor_gaps = c(70, 83),
      conditional = c(50, 69), high_risk = c(0, 49)
    )),
    "contiguous"
  )
})

test_that("rpn bands must reach 125", {
  expect_error(
    mk(rpn_bands = list(
      critical = c(80, 120), high = c(40, 79),
      medium = c(15, 39), low = c(1, 14)
    )),
    "RPN bands"
  )
})

test_that("required_indicators must be a non-empty character vector", {
  expect_error(mk(required_indicators = character(0)), "non-empty character")
  expect_error(mk(required_indicators = c("A", "A")), "duplicates")
})

test_that("minimum_coverage must be a single number in [0, 1]", {
  expect_error(mk(minimum_coverage = 1.5), "minimum_coverage")
  expect_error(mk(minimum_coverage = "high"), "minimum_coverage")
})

test_that("default_detectability must be a whole number in 1:5", {
  expect_error(mk(default_detectability = 7), "default_detectability")
  expect_error(mk(default_detectability = 2.5), "default_detectability")
})

test_that("multiple problems are reported together", {
  expect_error(
    mk(minimum_coverage = 2, default_detectability = 9),
    "minimum_coverage"
  )
})
