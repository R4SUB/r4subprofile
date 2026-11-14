# A representative caller-built profile (NA country, NULL study phase by
# default) used across the round-trip tests.
make_custom <- function(...) {
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
  args[names(list(...))] <- list(...)
  do.call(custom_profile, args)
}

test_that("write_profile returns a JSON string with the schema envelope", {
  prof <- submission_profile("FDA", "NDA")
  json <- write_profile(prof)

  expect_type(json, "character")
  expect_length(json, 1L)
  expect_match(json, "r4subprofile_schema")
  expect_match(json, "\"profile\"")
})

test_that("read_profile(write_profile(x)) reproduces a built-in profile exactly", {
  # Cover several authorities and submission types.
  for (auth in list_authorities()$authority) {
    for (ty in list_submission_types(auth)) {
      prof <- submission_profile(auth, ty)
      prof2 <- read_profile(write_profile(prof))
      expect_identical(prof2, prof, info = sprintf("%s/%s", auth, ty))
    }
  }
})

test_that("the round-trip is stable: export, import, export is byte-identical", {
  prof <- submission_profile("EMA", "MAA")
  json1 <- write_profile(prof)
  json2 <- write_profile(read_profile(json1))
  expect_identical(json2, json1)

  # Also stable without pretty-printing.
  cj1 <- write_profile(prof, pretty = FALSE)
  cj2 <- write_profile(read_profile(cj1), pretty = FALSE)
  expect_identical(cj2, cj1)
})

test_that("a study phase round-trips when present", {
  prof <- submission_profile("FDA", "NDA", study_phase = "Phase3")
  prof2 <- read_profile(write_profile(prof))
  expect_identical(prof2$study_phase, "Phase3")
  expect_identical(prof2, prof)
})

test_that("a custom profile round-trips, including NA country and NULL phase", {
  prof <- make_custom()
  prof2 <- read_profile(write_profile(prof))
  expect_identical(prof2, prof)
  expect_true(is.na(prof2$country))
  expect_null(prof2$study_phase)

  # And with a non-default full_name / country / phase supplied.
  prof3 <- make_custom(full_name = "Internal Gate", country = "Nowhere",
                       study_phase = "Phase2")
  prof4 <- read_profile(write_profile(prof3))
  expect_identical(prof4, prof3)
})

test_that("a single-element required vector stays a vector across the round-trip", {
  prof <- make_custom(
    required_indicators = "Q-MISS-VAR",
    required_asset_types = "dataset"
  )
  prof2 <- read_profile(write_profile(prof))
  expect_identical(prof2$required_indicators, "Q-MISS-VAR")
  expect_identical(prof2$required_asset_types, "dataset")
})

test_that("write_profile and read_profile work through a file", {
  prof <- submission_profile("PMDA", list_submission_types("PMDA")[1])
  path <- tempfile(fileext = ".json")
  on.exit(unlink(path), add = TRUE)

  res <- write_profile(prof, file = path)
  expect_identical(res, path)
  expect_true(file.exists(path))

  prof2 <- read_profile(path)
  expect_identical(prof2, prof)
})

test_that("read_profile reuses the structural validator and rejects bad numbers", {
  json <- write_profile(submission_profile("FDA", "NDA"))
  # Break the pillar-weight sum (0.35 -> 0.95); the reused invariant must catch it.
  bad <- sub("0.35", "0.95", json, fixed = TRUE)
  expect_error(read_profile(bad), "sum to|structurally valid")
})

test_that("read_profile rejects a non-envelope or unsupported schema", {
  expect_error(read_profile('{"foo": 1}'), "write_profile|envelope")

  json <- write_profile(submission_profile("FDA", "NDA"))
  bad_schema <- sub('"r4subprofile_schema": 1', '"r4subprofile_schema": 99',
                    json, fixed = TRUE)
  expect_error(read_profile(bad_schema), "schema")
})

test_that("read_profile and write_profile validate their arguments", {
  expect_error(read_profile(42), "single string")
  expect_error(read_profile("not json and not a file"),
               "neither an existing file nor JSON")
  expect_error(write_profile(list(a = 1)), "submission_profile")
  expect_error(write_profile(submission_profile("FDA", "NDA"), pretty = "yes"),
               "pretty")
})

test_that("diff_profiles reports no differences for identical profiles", {
  d <- diff_profiles(submission_profile("FDA", "NDA"), "FDA",
                     submission_type = "NDA")
  expect_s3_class(d, "tbl_df")
  expect_identical(names(d), c("field", "value", "reference_value"))
  expect_equal(nrow(d), 0L)
})

test_that("diff_profiles reports exactly the fields that differ", {
  mine <- make_custom(
    authority = "FDA", submission_type = "NDA",
    pillar_weights = c(quality = 0.40, trace = 0.25, risk = 0.25, usability = 0.10),
    bands = list(
      ready = c(85, 100), minor_gaps = c(70, 84),
      conditional = c(50, 69), high_risk = c(0, 49)
    ),
    required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL"),
    required_asset_types = c("dataset", "define"),
    minimum_coverage = 0.80,
    rpn_bands = list(
      critical = c(80, 125), high = c(40, 79),
      medium = c(15, 39), low = c(1, 14)
    ),
    default_detectability = 3L
  )
  d <- diff_profiles(mine, "FDA", submission_type = "NDA")

  # Quality and usability weights differ; minimum_coverage differs (0.8 vs 0.9).
  expect_true("pillar_weight_quality" %in% d$field)
  expect_true("pillar_weight_usability" %in% d$field)
  expect_true("minimum_coverage" %in% d$field)
  # Trace and risk weights match, so they are absent.
  expect_false("pillar_weight_trace" %in% d$field)

  cov <- d[d$field == "minimum_coverage", ]
  expect_identical(cov$value, "0.8")
  expect_identical(cov$reference_value, "0.9")
})

test_that("diff_profiles accepts a profile object as the reference", {
  a <- submission_profile("FDA", "IND")
  b <- submission_profile("FDA", "NDA")
  d <- diff_profiles(a, b)
  expect_gt(nrow(d), 0L)
  # Symmetry of the field set: same fields differ either direction.
  d2 <- diff_profiles(b, a)
  expect_setequal(d$field, d2$field)
})

test_that("diff_profiles validates its arguments", {
  expect_error(diff_profiles(list(), "FDA"), "submission_profile")
  expect_error(diff_profiles(submission_profile("FDA", "NDA"), 42), "reference")
})
