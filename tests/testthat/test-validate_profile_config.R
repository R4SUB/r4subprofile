test_that("the shipped authority configuration is valid", {
  expect_true(validate_profile_config())
  expect_silent(validate_profile_config())
})

test_that("every authority and submission type passes the invariants", {
  # Exercise each entry explicitly so a single bad entry is attributable.
  for (auth in names(.authority_db)) {
    for (ty in names(.authority_db[[auth]]$submission_types)) {
      td <- .authority_db[[auth]]$submission_types[[ty]]

      expect_equal(sum(td$pillar_weights), 1, tolerance = 1e-8,
                   info = sprintf("%s/%s pillar weights", auth, ty))

      d_lo <- vapply(td$bands, function(b) b[[1]], numeric(1))
      d_hi <- vapply(td$bands, function(b) b[[2]], numeric(1))
      expect_equal(min(d_lo), 0, info = sprintf("%s/%s decision floor", auth, ty))
      expect_equal(max(d_hi), 100, info = sprintf("%s/%s decision ceiling", auth, ty))

      r_lo <- vapply(td$rpn_bands, function(b) b[[1]], numeric(1))
      r_hi <- vapply(td$rpn_bands, function(b) b[[2]], numeric(1))
      expect_equal(min(r_lo), 1, info = sprintf("%s/%s RPN floor", auth, ty))
      expect_equal(max(r_hi), 125, info = sprintf("%s/%s RPN ceiling", auth, ty))
    }
  }
})

test_that("validate_profile_config catches broken configuration", {
  make_db <- function(type) {
    list(TEST = list(
      full_name = "Test Authority",
      country = "Nowhere",
      submission_types = list(X = type)
    ))
  }

  good_type <- .authority_db$FDA$submission_types$NDA

  # Weights that do not sum to 1.
  bad_weights <- good_type
  bad_weights$pillar_weights <- c(quality = 0.5, trace = 0.25, risk = 0.25, usability = 0.25)
  expect_error(validate_profile_config(make_db(bad_weights)), "sum to")

  # Decision bands that leave a gap (not contiguous).
  bad_bands <- good_type
  bad_bands$bands <- list(
    ready = c(85, 100), minor_gaps = c(70, 83),
    conditional = c(50, 69), high_risk = c(0, 49)
  )
  expect_error(validate_profile_config(make_db(bad_bands)), "contiguous")

  # RPN bands that do not reach 125.
  bad_rpn <- good_type
  bad_rpn$rpn_bands <- list(
    critical = c(80, 120), high = c(40, 79),
    medium = c(15, 39), low = c(1, 14)
  )
  expect_error(validate_profile_config(make_db(bad_rpn)), "RPN bands")
})
