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

# ---- Structural invariants, each failing in isolation -----------------------

test_that("each pillar weight value must lie in [0, 1]", {
  # Sums to 1, but one weight is negative: a value-range failure, not a sum one.
  expect_error(
    mk(pillar_weights = c(quality = -0.1, trace = 0.5, risk = 0.5, usability = 0.1)),
    "values must be numbers"
  )
})

test_that("decision bands must start at 0", {
  expect_error(
    mk(bands = list(
      ready = c(85, 100), minor_gaps = c(70, 84),
      conditional = c(50, 69), high_risk = c(10, 49)
    )),
    "start at"
  )
})

test_that("decision bands must reach 100", {
  expect_error(
    mk(bands = list(
      ready = c(85, 99), minor_gaps = c(70, 84),
      conditional = c(50, 69), high_risk = c(0, 49)
    )),
    "reach"
  )
})

test_that("overlapping decision bands are rejected", {
  expect_error(
    mk(bands = list(
      ready = c(85, 100), minor_gaps = c(70, 86),
      conditional = c(50, 69), high_risk = c(0, 49)
    )),
    "contiguous"
  )
})

test_that("rpn bands must start at 1", {
  expect_error(
    mk(rpn_bands = list(
      critical = c(80, 125), high = c(40, 79),
      medium = c(15, 39), low = c(5, 14)
    )),
    "RPN bands"
  )
})

test_that("rpn bands must be contiguous", {
  expect_error(
    mk(rpn_bands = list(
      critical = c(80, 125), high = c(40, 79),
      medium = c(15, 38), low = c(1, 14)
    )),
    "RPN bands are not contiguous"
  )
})

test_that("overlapping rpn bands are rejected", {
  expect_error(
    mk(rpn_bands = list(
      critical = c(80, 125), high = c(40, 80),
      medium = c(15, 39), low = c(1, 14)
    )),
    "contiguous"
  )
})

# ---- Required arguments have no silent default ------------------------------

test_that("omitting any required argument errors rather than defaulting", {
  required <- c("authority", "submission_type", "pillar_weights", "bands",
                "required_indicators", "required_asset_types", "minimum_coverage",
                "rpn_bands", "default_detectability")
  for (nm in required) {
    args <- valid_args()
    args[[nm]] <- NULL
    expect_error(
      do.call(custom_profile, args), "missing",
      info = sprintf("omitting `%s` should error", nm)
    )
  }
})

# ---- Verbatim storage and order-normalisation of caller values --------------

test_that("caller-supplied regulatory values are stored verbatim", {
  pw <- c(quality = 0.25, trace = 0.25, risk = 0.25, usability = 0.25)
  bd <- list(
    ready = c(90, 100), minor_gaps = c(60, 89),
    conditional = c(30, 59), high_risk = c(0, 29)
  )
  rb <- list(
    critical = c(100, 125), high = c(50, 99),
    medium = c(10, 49), low = c(1, 9)
  )
  prof <- mk(
    authority = "ACME-REG", full_name = "ACME Regional Board",
    country = "Atlantis", study_phase = "PhaseX",
    pillar_weights = pw, bands = bd, rpn_bands = rb,
    required_indicators = c("X-ONE", "X-TWO"),
    required_asset_types = c("alpha", "beta", "gamma"),
    minimum_coverage = 0.5, default_detectability = 5L
  )
  expect_equal(prof$pillar_weights, pw)
  expect_equal(prof$bands, bd)
  expect_equal(prof$rpn_bands, rb)
  expect_equal(prof$required_indicators, c("X-ONE", "X-TWO"))
  expect_equal(prof$required_asset_types, c("alpha", "beta", "gamma"))
  expect_equal(prof$full_name, "ACME Regional Board")
  expect_equal(prof$country, "Atlantis")
  expect_equal(prof$study_phase, "PhaseX")
  expect_equal(prof$minimum_coverage, 0.5)
  expect_identical(prof$default_detectability, 5L)
})

test_that("input order changes field order only, never value associations", {
  pw_in <- c(usability = 0.1, risk = 0.3, quality = 0.4, trace = 0.2)
  rb_in <- list(
    low = c(1, 14), critical = c(80, 125),
    medium = c(15, 39), high = c(40, 79)
  )
  prof <- mk(pillar_weights = pw_in, rpn_bands = rb_in)
  expect_equal(
    prof$pillar_weights,
    c(quality = 0.4, trace = 0.2, risk = 0.3, usability = 0.1)
  )
  expect_equal(names(prof$rpn_bands), c("critical", "high", "medium", "low"))
  expect_equal(prof$rpn_bands$critical, c(80, 125))
  expect_equal(prof$rpn_bands$low, c(1, 14))
})

# ---- The returned profile flows through every consumer ----------------------

test_that("profile_summary(tibble) carries caller values, one row per field", {
  prof <- mk()
  tb <- profile_summary(prof, format = "tibble")
  expect_named(tb, c("field", "value"))
  # 5 scalar fields + 4 pillars + 4 bands + 4 rpn bands + 4 trailing fields.
  expect_equal(nrow(tb), 21L)
  val <- function(f) tb$value[tb$field == f]
  expect_equal(val("minimum_coverage"), "0.8")
  expect_equal(val("pillar_weight_quality"), "0.4")
  expect_equal(val("band_ready"), "85-100")
  expect_equal(val("rpn_band_critical"), "80-125")
  expect_equal(val("default_detectability"), "3")
  expect_equal(val("required_indicators"),
               "Q-MISS-VAR, T-TRACE-LEVEL, R-HIGH-RPN")
})

test_that("sci and risk configs expose caller values verbatim", {
  prof <- mk()
  sci <- profile_sci_config(prof)
  expect_identical(sci$pillar_weights, prof$pillar_weights)
  expect_identical(sci$bands, prof$bands)
  risk <- profile_risk_config(prof)
  expect_identical(risk$rpn_bands, prof$rpn_bands)
  expect_identical(risk$default_detectability, prof$default_detectability)
})

test_that("validate_against_profile honours caller indicators, assets, coverage", {
  prof <- mk(minimum_coverage = 1)

  ev_full <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators,
    asset_types = prof$required_asset_types
  )
  res_full <- validate_against_profile(ev_full, prof)
  expect_true(res_full$is_compliant)
  expect_equal(res_full$coverage, 1)
  expect_length(res_full$missing_indicators, 0)
  expect_length(res_full$missing_asset_types, 0)
  expect_equal(
    nrow(res_full$details),
    length(prof$required_indicators) + length(prof$required_asset_types) + 1L
  )

  # Drop a required indicator: coverage falls below the caller's minimum.
  dropped <- prof$required_indicators[1]
  ev_gap <- make_profile_test_evidence(
    indicator_ids = prof$required_indicators[-1],
    asset_types = prof$required_asset_types
  )
  res_gap <- validate_against_profile(ev_gap, prof)
  expect_false(res_gap$is_compliant)
  expect_true(dropped %in% res_gap$missing_indicators)
  expect_false(res_gap$coverage_met)
  expect_lt(res_gap$coverage, 1)
})

test_that("console summary prints caller authority and values", {
  prof <- mk(authority = "ACME-REG", study_phase = "PhaseX")
  out <- paste(capture.output(ret <- profile_summary(prof)), collapse = "\n")
  expect_match(out, "ACME-REG")
  expect_match(out, "PhaseX")
  expect_identical(ret, prof)
})

# ---- Multiple problems collected and reported at once -----------------------

test_that("several structural invariants are reported in one error", {
  err <- tryCatch(
    mk(
      pillar_weights = c(quality = 0.3, trace = 0.2, risk = 0.3, usability = 0.1),
      bands = list(
        ready = c(85, 99), minor_gaps = c(70, 84),
        conditional = c(50, 69), high_risk = c(0, 49)
      ),
      rpn_bands = list(
        critical = c(80, 120), high = c(40, 79),
        medium = c(15, 39), low = c(1, 14)
      )
    ),
    error = function(e) e
  )
  expect_s3_class(err, "error")
  msg <- conditionMessage(err)
  expect_match(msg, "sum to")
  expect_match(msg, "decision bands")
  expect_match(msg, "RPN bands")
})

test_that("several shape problems are reported in one error", {
  err <- tryCatch(
    mk(
      minimum_coverage = 2,
      default_detectability = 9,
      required_indicators = c("A", "A")
    ),
    error = function(e) e
  )
  expect_s3_class(err, "error")
  msg <- conditionMessage(err)
  expect_match(msg, "minimum_coverage")
  expect_match(msg, "default_detectability")
  expect_match(msg, "duplicates")
})
