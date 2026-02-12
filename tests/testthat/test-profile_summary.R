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
