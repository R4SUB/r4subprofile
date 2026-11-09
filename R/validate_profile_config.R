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
  check_bands <- function(bands, lo, hi, label) {
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

  problems <- character(0)

  for (auth in names(db)) {
    types <- db[[auth]]$submission_types
    for (ty in names(types)) {
      td <- types[[ty]]
      tag <- sprintf("%s/%s", auth, ty)

      w <- sum(td$pillar_weights)
      if (abs(w - 1) > tol) {
        problems <- c(problems, sprintf("%s: pillar weights sum to %g, not 1", tag, w))
      }

      problems <- c(
        problems,
        check_bands(td$bands, 0, 100, sprintf("%s: decision bands", tag)),
        check_bands(td$rpn_bands, 1, 125, sprintf("%s: RPN bands", tag))
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
