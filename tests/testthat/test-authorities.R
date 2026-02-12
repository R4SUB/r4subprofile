test_that("list_authorities returns a tibble", {
  result <- list_authorities()
  expect_s3_class(result, "tbl_df")
})

test_that("list_authorities has all 6 authorities", {
  result <- list_authorities()
  expect_equal(nrow(result), 6L)
  expect_true("FDA" %in% result$authority)
  expect_true("EMA" %in% result$authority)
  expect_true("PMDA" %in% result$authority)
  expect_true("Health_Canada" %in% result$authority)
  expect_true("TGA" %in% result$authority)
  expect_true("MHRA" %in% result$authority)
})

test_that("list_authorities has expected columns", {
  result <- list_authorities()
  expect_true(all(c("authority", "full_name", "country", "n_submission_types") %in%
                    names(result)))
})

test_that("list_submission_types returns valid types for FDA", {
  types <- list_submission_types("FDA")
  expect_true(is.character(types))
  expect_true(length(types) >= 3L)
  expect_true("NDA" %in% types)
})

test_that("list_submission_types errors on invalid authority", {
  expect_error(list_submission_types("FAKE"), "Unknown authority")
})

test_that("every listed submission type creates a valid profile", {
  auths <- list_authorities()
  for (a in auths$authority) {
    types <- list_submission_types(a)
    for (st in types) {
      prof <- submission_profile(a, st)
      expect_s3_class(prof, "submission_profile")
    }
  }
})
