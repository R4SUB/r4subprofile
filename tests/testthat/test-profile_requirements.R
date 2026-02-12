test_that("profile_required_indicators returns a character vector", {
  prof <- submission_profile("FDA", "NDA")
  result <- profile_required_indicators(prof)
  expect_true(is.character(result))
})

test_that("FDA NDA has more required indicators than FDA IND", {
  nda <- submission_profile("FDA", "NDA")
  ind <- submission_profile("FDA", "IND")
  expect_true(
    length(profile_required_indicators(nda)) >
      length(profile_required_indicators(ind))
  )
})

test_that("all required indicators are non-empty strings", {
  prof <- submission_profile("FDA", "NDA")
  inds <- profile_required_indicators(prof)
  expect_true(all(nchar(inds) > 0L))
})

test_that("profile_required_indicators rejects non-profile input", {
  expect_error(profile_required_indicators(list()), "submission_profile")
})
