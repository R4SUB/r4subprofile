#' List Supported Regulatory Authorities
#'
#' Returns a summary of all supported regulatory authorities with their
#' full names, countries, and number of available submission types.
#'
#' @return A tibble with columns: `authority`, `full_name`, `country`,
#'   `n_submission_types`.
#'
#' @examples
#' list_authorities()
#'
#' @export
list_authorities <- function() {
  auths <- names(.authority_db)
  tibble::tibble(
    authority = auths,
    full_name = vapply(auths, function(a) .authority_db[[a]]$full_name, character(1)),
    country = vapply(auths, function(a) .authority_db[[a]]$country, character(1)),
    n_submission_types = vapply(auths, function(a) {
      length(.authority_db[[a]]$submission_types)
    }, integer(1))
  )
}

#' List Submission Types for an Authority
#'
#' Returns the valid submission types for a given regulatory authority.
#'
#' @param authority Character. A supported authority name.
#'
#' @return A character vector of valid submission types.
#'
#' @examples
#' list_submission_types("FDA")
#' list_submission_types("EMA")
#'
#' @export
list_submission_types <- function(authority) {
  if (!is.character(authority) || length(authority) != 1L) {
    cli::cli_abort("{.arg authority} must be a single character string.")
  }
  if (!authority %in% names(.authority_db)) {
    valid <- paste(names(.authority_db), collapse = ", ")
    cli::cli_abort(
      "Unknown authority {.val {authority}}. Valid: {valid}."
    )
  }
  names(.authority_db[[authority]]$submission_types)
}
