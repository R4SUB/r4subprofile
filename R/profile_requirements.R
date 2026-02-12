#' Get Required Indicators for a Profile
#'
#' Returns the list of indicator IDs that are mandatory for the given
#' submission profile.
#'
#' @param profile A `submission_profile` object.
#'
#' @return A character vector of required `indicator_id` values.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' profile_required_indicators(prof)
#'
#' prof_ind <- submission_profile("FDA", "IND")
#' profile_required_indicators(prof_ind)
#'
#' @export
profile_required_indicators <- function(profile) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  profile$required_indicators
}
