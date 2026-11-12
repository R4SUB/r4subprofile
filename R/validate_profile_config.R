# Canonical field names shared by every submission profile.
# @noRd
.pillar_names <- c("quality", "trace", "risk", "usability")
.band_names   <- c("ready", "minor_gaps", "conditional", "high_risk")
.rpn_names    <- c("critical", "high", "medium", "low")

# Check that a set of [lo, hi] bands is integer-contiguous and covers [lo, hi].
# Returns a character vector of problem messages (empty when valid). Internal;
# shared by validate_profile_config() and custom_profile().
# @noRd
.check_band_coverage <- function(bands, lo, hi, label) {
  msgs <- character(0)
  los <- vapply(bands, function(b) b[[1]], numeric(1))
  his <- vapply(bands, function(b) b[[2]], numeric(1))
  ord <- order(los)
  los <- los[ord]
  his <- his[ord]

  if (min(los) != lo) {
    msgs <- c(msgs, sprintf("%s start at %g, not %g", label, min(los), lo))
  }
  if (max(his) != hi) {
    msgs <- c(msgs, sprintf("%s reach %g, not %g", label, max(his), hi))
  }
  if (length(los) > 1L) {
    steps <- los[-1] - (his[-length(his)] + 1)
    if (any(steps != 0)) {
      msgs <- c(msgs, sprintf("%s are not contiguous", label))
    }
  }
  msgs
}

# Collect the structural problems for one submission-type entry `td`. Shared by
# validate_profile_config() (over the shipped database) and custom_profile()
# (over a caller-built entry). It inspects structure only and never treats a
# configured weight, threshold, or band as an authoritative value.
# @noRd
.profile_structure_problems <- function(td, tag, tol = 1e-8) {
  problems <- character(0)

  w <- sum(td$pillar_weights)
  if (abs(w - 1) > tol) {
    problems <- c(problems, sprintf("%s: pillar weights sum to %g, not 1", tag, w))
  }

  problems <- c(
    problems,
    .check_band_coverage(td$bands, 0, 100, sprintf("%s: decision bands", tag)),
    .check_band_coverage(td$rpn_bands, 1, 125, sprintf("%s: RPN bands", tag))
  )
  problems
}

#' Validate the Internal Authority Configuration
#'
#' Internal structural check over the non-exported `.authority_db`. For every
#' authority and submission type it asserts that:
#'
#' * the pillar weights sum to 1,
#' * the decision bands are integer-contiguous and cover 0-100, and
#' * the RPN bands are integer-contiguous and cover 1-125.
#'
#' It inspects structure only; it never reads from or writes to the configured
#' weights, thresholds, or bands. It is wired into the test suite so that any
#' future edit to the authority data that breaks these invariants is caught.
#'
#' @param db The authority database to check. Defaults to `.authority_db`.
#' @param tol Numeric tolerance for the pillar-weight sum.
#'
#' @return `TRUE`, invisibly, when every entry is valid; otherwise it aborts
#'   with one message per problem found.
#'
#' @noRd
validate_profile_config <- function(db = .authority_db, tol = 1e-8) {
  problems <- character(0)

  for (auth in names(db)) {
    types <- db[[auth]]$submission_types
    for (ty in names(types)) {
      problems <- c(
        problems,
        .profile_structure_problems(types[[ty]], sprintf("%s/%s", auth, ty), tol)
      )
    }
  }

  if (length(problems) > 0L) {
    cli::cli_abort(c(
      "Invalid authority configuration.",
      stats::setNames(problems, rep("x", length(problems)))
    ))
  }

  invisible(TRUE)
}
