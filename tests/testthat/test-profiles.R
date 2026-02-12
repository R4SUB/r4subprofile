test_that("submission_profile creates a valid object", {
  prof <- submission_profile("FDA", "NDA")
  expect_s3_class(prof, "submission_profile")
})

test_that("profile has all expected elements", {
  prof <- submission_profile("FDA", "NDA")
  expected <- c("authority", "full_name", "country", "submission_type",
                "study_phase", "pillar_weights", "bands",
                "required_indicators", "required_asset_types",
                "minimum_coverage", "rpn_bands", "default_detectability")
  expect_true(all(expected %in% names(prof)))
})

test_that("pillar_weights sum to 1", {
  prof <- submission_profile("FDA", "NDA")
  expect_equal(sum(prof$pillar_weights), 1.0)
})

test_that("pillar_weights have correct names", {
  prof <- submission_profile("FDA", "NDA")
  expect_equal(sort(names(prof$pillar_weights)),
               sort(c("quality", "trace", "risk", "usability")))
})

test_that("errors on unknown authority", {
  expect_error(submission_profile("FAKE", "NDA"), "Unknown authority")
})

test_that("errors on unknown submission type", {
  expect_error(submission_profile("FDA", "FAKE"), "Unknown submission type")
})

test_that("study_phase is stored correctly", {
  prof <- submission_profile("FDA", "NDA", study_phase = "Phase3")
  expect_equal(prof$study_phase, "Phase3")
})

test_that("all FDA submission types create valid profiles", {
  types <- c("IND", "NDA", "BLA", "ANDA", "505b2")
  for (st in types) {
    prof <- submission_profile("FDA", st)
    expect_s3_class(prof, "submission_profile")
    expect_equal(sum(prof$pillar_weights), 1.0)
  }
})

test_that("all EMA submission types create valid profiles", {
  types <- c("CTA", "MAA", "variation")
  for (st in types) {
    prof <- submission_profile("EMA", st)
    expect_s3_class(prof, "submission_profile")
    expect_equal(sum(prof$pillar_weights), 1.0)
  }
})

test_that("all 6 authorities create at least one valid profile", {
  auths <- c("FDA", "EMA", "PMDA", "Health_Canada", "TGA", "MHRA")
  for (a in auths) {
    types <- names(r4subprofile:::.authority_db[[a]]$submission_types)
    prof <- submission_profile(a, types[1])
    expect_s3_class(prof, "submission_profile")
  }
})

test_that("FDA NDA is stricter than FDA IND", {
  nda <- submission_profile("FDA", "NDA")
  ind <- submission_profile("FDA", "IND")
  expect_true(nda$minimum_coverage > ind$minimum_coverage)
  expect_true(length(nda$required_indicators) > length(ind$required_indicators))
})

test_that("print.submission_profile does not error", {
  prof <- submission_profile("FDA", "NDA")
  expect_output(print(prof), "Submission Profile")
})
