#' Validate Evidence Against a Submission Profile
#'
#' Checks whether an evidence table meets the requirements specified by a
#' regulatory submission profile: required indicators present, required asset
#' types covered, and minimum indicator coverage met.
#'
#' @param evidence A validated evidence data.frame conforming to the
#'   r4subcore evidence schema.
#' @param profile A `submission_profile` object.
#'
#' @return A list of class `"profile_validation"` with elements:
#'   - `is_compliant`: logical; `TRUE` if all requirements are met
#'   - `missing_indicators`: character vector of missing required indicator IDs
#'   - `missing_asset_types`: character vector of missing required asset types
#'   - `coverage`: numeric; fraction of required indicators present (0-1)
#'   - `coverage_met`: logical; whether coverage meets the minimum threshold
#'   - `details`: tibble with per-requirement status
#'
#' @examples
#' \dontrun{
#' prof <- submission_profile("FDA", "NDA")
#' result <- validate_against_profile(evidence, prof)
#' result$is_compliant
#' result$missing_indicators
#' }
#'
#' @export
validate_against_profile <- function(evidence, profile) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  r4subcore::validate_evidence(evidence)

  # Check required indicators
  present_indicators <- unique(evidence$indicator_id)
  required <- profile$required_indicators
  missing_ind <- setdiff(required, present_indicators)

  # Check required asset types
  present_assets <- unique(evidence$asset_type)
  missing_assets <- setdiff(profile$required_asset_types, present_assets)

  # Compute coverage
  n_required <- length(required)
  n_present <- sum(required %in% present_indicators)
  coverage <- if (n_required == 0L) 1.0 else n_present / n_required
  coverage_met <- coverage >= profile$minimum_coverage

  # Build details tibble
  ind_status <- if (n_required > 0L) {
    tibble::tibble(
      requirement = paste0("indicator:", required),
      status = ifelse(required %in% present_indicators, "present", "missing")
    )
  } else {
    tibble::tibble(requirement = character(0), status = character(0))
  }

  asset_status <- tibble::tibble(
    requirement = paste0("asset_type:", profile$required_asset_types),
    status = ifelse(
      profile$required_asset_types %in% present_assets, "present", "missing"
    )
  )

  coverage_status <- tibble::tibble(
    requirement = "minimum_coverage",
    status = if (coverage_met) "met" else "not_met"
  )

  details <- rbind(ind_status, asset_status, coverage_status)

  is_compliant <- length(missing_ind) == 0L &&
    length(missing_assets) == 0L &&
    coverage_met

  structure(
    list(
      is_compliant        = is_compliant,
      missing_indicators  = missing_ind,
      missing_asset_types = missing_assets,
      coverage            = round(coverage, 4),
      coverage_met        = coverage_met,
      details             = details
    ),
    class = "profile_validation"
  )
}

#' @export
print.profile_validation <- function(x, ...) {
  status <- if (x$is_compliant) "COMPLIANT" else "NOT COMPLIANT"
  cat(sprintf("Profile Validation: %s\n", status))
  cat(sprintf("  Coverage: %.1f%%\n", x$coverage * 100))
  if (length(x$missing_indicators) > 0L) {
    cat(sprintf("  Missing Indicators: %s\n",
                paste(x$missing_indicators, collapse = ", ")))
  }
  if (length(x$missing_asset_types) > 0L) {
    cat(sprintf("  Missing Asset Types: %s\n",
                paste(x$missing_asset_types, collapse = ", ")))
  }
  invisible(x)
}
