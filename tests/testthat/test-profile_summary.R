test_that("profile_summary does not error", {
  prof <- submission_profile("FDA", "NDA")
  expect_output(profile_summary(prof))
})

test_that("profile_summary includes authority name", {
  prof <- submission_profile("EMA", "MAA")
  output <- capture.output(profile_summary(prof))
  msgs <- capture.output(profile_summary(prof), type = "message")
  full_output <- paste(c(output, msgs), collapse = " ")
  expect_true(grepl("EMA", full_output))
  expect_true(grepl("MAA", full_output))
})

test_that("profile_summary rejects non-profile input", {
  expect_error(profile_summary(list()), "submission_profile")
})

test_that("profile_summary(format = 'tibble') returns a tidy tibble", {
  prof <- submission_profile("FDA", "NDA")
  tb <- profile_summary(prof, format = "tibble")

  expect_s3_class(tb, "tbl_df")
  expect_identical(names(tb), c("field", "value"))
  expect_true(is.character(tb$field))
  expect_true(is.character(tb$value))
  expect_true(nrow(tb) > 0)

  # No printed output in tibble mode.
  expect_silent(profile_summary(prof, format = "tibble"))

  # Core fields are present with the expected values.
  lookup <- function(f) tb$value[match(f, tb$field)]
  expect_equal(lookup("authority"), "FDA")
  expect_equal(lookup("submission_type"), "NDA")
  expect_equal(lookup("country"), prof$country)
  expect_equal(
    lookup("pillar_weight_quality"),
    as.character(unname(prof$pillar_weights[["quality"]]))
  )
  expect_equal(
    lookup("band_ready"),
    sprintf("%g-%g", prof$bands$ready[1], prof$bands$ready[2])
  )
})

test_that("profile_summary(format = 'tibble') records an absent study phase as NA", {
  prof <- submission_profile("FDA", "NDA")
  tb <- profile_summary(prof, format = "tibble")
  expect_true(is.na(tb$value[match("study_phase", tb$field)]))

  prof2 <- submission_profile("EMA", "MAA", study_phase = "Phase3")
  tb2 <- profile_summary(prof2, format = "tibble")
  expect_equal(tb2$value[match("study_phase", tb2$field)], "Phase3")
})

test_that("profile_summary rejects an unknown format", {
  prof <- submission_profile("FDA", "NDA")
  expect_error(profile_summary(prof, format = "json"))
})
