#' Summarize a Submission Profile
#'
#' Summarizes a regulatory submission profile. The default `"console"` format
#' prints a human-readable summary (authority details, pillar weights, decision
#' bands, and requirements) and returns the profile invisibly. The `"tibble"`
#' format instead returns a tidy, one-row-per-field tibble of the same
#' information, so a summary can be filtered, joined, or written out
#' programmatically.
#'
#' @param profile A `submission_profile` object.
#' @param format One of `"console"` (default) or `"tibble"`. `"console"` keeps
#'   the printed-and-invisible behavior; `"tibble"` returns a tidy tibble.
#'
#' @return For `format = "console"`, the profile object, invisibly. For
#'   `format = "tibble"`, a tibble with one row per profile field and columns
#'   `field` and `value` (character).
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#'
#' # Printed summary (returns the profile invisibly):
#' profile_summary(prof)
#'
#' # Tidy tibble for programmatic use:
#' profile_summary(prof, format = "tibble")
#'
#' @export
profile_summary <- function(profile, format = c("console", "tibble")) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  format <- match.arg(format)

  if (identical(format, "tibble")) {
    return(.profile_summary_tibble(profile))
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

# Build the tidy one-row-per-field summary tibble.
# @noRd
.profile_summary_tibble <- function(profile) {
  rng <- function(x) sprintf("%g-%g", x[[1]], x[[2]])

  pw <- profile$pillar_weights
  bd <- profile$bands
  rb <- profile$rpn_bands

  field <- c(
    "authority", "full_name", "country", "submission_type", "study_phase",
    paste0("pillar_weight_", names(pw)),
    paste0("band_", names(bd)),
    paste0("rpn_band_", names(rb)),
    "required_indicators", "required_asset_types",
    "minimum_coverage", "default_detectability"
  )

  value <- c(
    profile$authority,
    profile$full_name,
    profile$country,
    profile$submission_type,
    if (is.null(profile$study_phase)) NA_character_ else as.character(profile$study_phase),
    as.character(unname(pw)),
    vapply(bd, rng, character(1)),
    vapply(rb, rng, character(1)),
    paste(profile$required_indicators, collapse = ", "),
    paste(profile$required_asset_types, collapse = ", "),
    as.character(profile$minimum_coverage),
    as.character(profile$default_detectability)
  )

  tibble::tibble(field = field, value = unname(value))
}
