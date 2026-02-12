#' Create a Submission Profile
#'
#' Constructs a regulatory submission profile with authority-specific pillar
#' weights, decision bands, required indicators, and risk configuration.
#'
#' @param authority Character. Regulatory authority name (e.g., `"FDA"`, `"EMA"`).
#'   See [list_authorities()] for all supported values.
#' @param submission_type Character. Submission type for the authority
#'   (e.g., `"NDA"`, `"MAA"`). See [list_submission_types()] for valid values.
#' @param study_phase Character or `NULL`. Optional study phase (e.g.,
#'   `"Phase1"`, `"Phase2"`, `"Phase3"`, `"Phase4"`). Currently informational.
#'
#' @return A list of class `"submission_profile"` with elements:
#'   `authority`, `full_name`, `country`, `submission_type`, `study_phase`,
#'   `pillar_weights`, `bands`, `required_indicators`, `required_asset_types`,
#'   `minimum_coverage`, `rpn_bands`, `default_detectability`.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' prof$pillar_weights
#' prof$required_indicators
#'
#' prof_ema <- submission_profile("EMA", "MAA", study_phase = "Phase3")
#' prof_ema$bands
#'
#' @export
submission_profile <- function(authority, submission_type, study_phase = NULL) {
  if (!is.character(authority) || length(authority) != 1L) {
    cli::cli_abort("{.arg authority} must be a single character string.")
  }
  if (!authority %in% names(.authority_db)) {
    valid <- paste(names(.authority_db), collapse = ", ")
    cli::cli_abort(
      "Unknown authority {.val {authority}}. Valid: {valid}."
    )
  }

  auth_data <- .authority_db[[authority]]

  if (!is.character(submission_type) || length(submission_type) != 1L) {
    cli::cli_abort("{.arg submission_type} must be a single character string.")
  }
  if (!submission_type %in% names(auth_data$submission_types)) {
    valid <- paste(names(auth_data$submission_types), collapse = ", ")
    cli::cli_abort(
      c(
        "Unknown submission type {.val {submission_type}} for {.val {authority}}.",
        "i" = "Valid types: {valid}."
      )
    )
  }

  type_data <- auth_data$submission_types[[submission_type]]

  structure(
    list(
      authority             = authority,
      full_name             = auth_data$full_name,
      country               = auth_data$country,
      submission_type       = submission_type,
      study_phase           = study_phase,
      pillar_weights        = type_data$pillar_weights,
      bands                 = type_data$bands,
      required_indicators   = type_data$required_indicators,
      required_asset_types  = type_data$required_asset_types,
      minimum_coverage      = type_data$minimum_coverage,
      rpn_bands             = type_data$rpn_bands,
      default_detectability = type_data$default_detectability
    ),
    class = "submission_profile"
  )
}

#' @export
print.submission_profile <- function(x, ...) {
  cat(sprintf("Submission Profile: %s %s\n", x$authority, x$submission_type))
  cat(sprintf("  Authority: %s (%s)\n", x$full_name, x$country))
  if (!is.null(x$study_phase)) {
    cat(sprintf("  Study Phase: %s\n", x$study_phase))
  }
  cat(sprintf("  Pillar Weights: quality=%.2f, trace=%.2f, risk=%.2f, usability=%.2f\n",
              x$pillar_weights["quality"], x$pillar_weights["trace"],
              x$pillar_weights["risk"], x$pillar_weights["usability"]))
  cat(sprintf("  Ready Band: [%g, %g]\n", x$bands$ready[1], x$bands$ready[2]))
  cat(sprintf("  Required Indicators: %d\n", length(x$required_indicators)))
  cat(sprintf("  Required Asset Types: %s\n",
              paste(x$required_asset_types, collapse = ", ")))
  cat(sprintf("  Minimum Coverage: %.0f%%\n", x$minimum_coverage * 100))
  invisible(x)
}
