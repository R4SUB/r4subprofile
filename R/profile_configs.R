#' Extract SCI Configuration from a Profile
#'
#' Returns a list with structure compatible with `r4subscore::sci_config_default()`.
#' Can be passed directly to `compute_pillar_scores()` or `compute_sci()`.
#'
#' @param profile A `submission_profile` object.
#'
#' @return A list of class `"sci_config"` with `pillar_weights` and `bands`.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' cfg <- profile_sci_config(prof)
#' cfg$pillar_weights
#' cfg$bands
#'
#' @export
profile_sci_config <- function(profile) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  structure(
    list(
      pillar_weights = profile$pillar_weights,
      bands = profile$bands
    ),
    class = "sci_config"
  )
}

#' Extract Risk Configuration from a Profile
#'
#' Returns a list with structure compatible with `r4subrisk::risk_config_default()`.
#' Can be passed directly to risk assessment functions.
#'
#' @param profile A `submission_profile` object.
#'
#' @return A list of class `"risk_config"` with `rpn_bands`,
#'   `evidence_severity_to_probability`, `evidence_severity_to_impact`,
#'   and `default_detectability`.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' cfg <- profile_risk_config(prof)
#' cfg$rpn_bands
#'
#' @export
profile_risk_config <- function(profile) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  structure(
    list(
      rpn_bands = profile$rpn_bands,
      evidence_severity_to_probability = c(
        info = 1L, low = 2L, medium = 3L, high = 4L, critical = 5L
      ),
      evidence_severity_to_impact = c(
        info = 1L, low = 2L, medium = 3L, high = 4L, critical = 5L
      ),
      default_detectability = profile$default_detectability
    ),
    class = "risk_config"
  )
}
