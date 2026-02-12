#' Summarize a Submission Profile
#'
#' Prints a formatted summary of a regulatory submission profile including
#' authority details, pillar weights, decision bands, and requirements.
#'
#' @param profile A `submission_profile` object.
#'
#' @return The profile object, invisibly.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' profile_summary(prof)
#'
#' @export
profile_summary <- function(profile) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }

  cli::cli_alert_info("Submission Profile: {profile$authority} {profile$submission_type}")
  cat(sprintf("  Authority:    %s (%s)\n", profile$full_name, profile$country))
  if (!is.null(profile$study_phase)) {
    cat(sprintf("  Study Phase:  %s\n", profile$study_phase))
  }
  cat("\n")

  cat("  Pillar Weights:\n")
  for (nm in names(profile$pillar_weights)) {
    cat(sprintf("    %-10s  %.2f\n", nm, profile$pillar_weights[nm]))
  }
  cat("\n")

  cat("  Decision Bands:\n")
  for (nm in names(profile$bands)) {
    cat(sprintf("    %-12s  [%g, %g]\n", nm,
                profile$bands[[nm]][1], profile$bands[[nm]][2]))
  }
  cat("\n")

  cat(sprintf("  Required Indicators (%d):\n", length(profile$required_indicators)))
  for (ind in profile$required_indicators) {
    cat(sprintf("    - %s\n", ind))
  }
  cat("\n")

  cat(sprintf("  Required Asset Types: %s\n",
              paste(profile$required_asset_types, collapse = ", ")))
  cat(sprintf("  Minimum Coverage:     %.0f%%\n", profile$minimum_coverage * 100))
  cat(sprintf("  Default Detectability: %d\n", profile$default_detectability))

  invisible(profile)
}
