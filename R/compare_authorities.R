#' Compare Submission Profiles Across Authorities
#'
#' Puts several regulatory authorities side by side so a sponsor filing in more
#' than one region can see how the readiness bar differs: pillar weights, the
#' score needed to be ready, the minimum traceability coverage, how many
#' indicators are required, and the detectability default that feeds risk
#' scoring. It answers "what changes if we also file with the EMA" without
#' building and eyeballing each profile by hand.
#'
#' @param authorities Character vector of authority names, matched
#'   case-insensitively (for example `c("fda", "ema", "pmda")`). Defaults to
#'   every supported authority from [list_authorities()].
#' @param submission_types How to pick a submission type per authority. `NULL`
#'   (default) uses each authority's first type. A single string uses that type
#'   for every authority (and errors if one does not offer it). A named vector
#'   (`c(FDA = "NDA", EMA = "MAA")`) selects per authority, falling back to the
#'   first type for any authority not named.
#'
#' @return A tibble with one row per authority and columns `authority`,
#'   `full_name`, `country`, `submission_type`, the four pillar weights
#'   (`w_quality`, `w_trace`, `w_risk`, `w_usability`), `ready_min` (lowest SCI
#'   in the ready band), `minimum_coverage`, `n_required_indicators`,
#'   `default_detectability`, and `required_asset_types`.
#'
#' @examples
#' compare_authorities(c("FDA", "EMA", "PMDA"))
#'
#' # A specific submission type where all three offer it is not guaranteed, so
#' # select per authority:
#' compare_authorities(
#'   c("FDA", "EMA"),
#'   submission_types = c(FDA = "NDA", EMA = "MAA")
#' )
#'
#' @export
compare_authorities <- function(authorities = NULL, submission_types = NULL) {
  all_auth <- list_authorities()$authority

  if (is.null(authorities)) {
    authorities <- all_auth
  } else {
    if (!is.character(authorities) || length(authorities) == 0L) {
      cli::cli_abort("{.arg authorities} must be a non-empty character vector.")
    }
    idx <- match(toupper(authorities), toupper(all_auth))
    if (any(is.na(idx))) {
      bad <- authorities[is.na(idx)]
      cli::cli_abort(c(
        "Unknown authorit{?y/ies}: {.val {bad}}.",
        "i" = "Supported: {.val {all_auth}}."
      ))
    }
    authorities <- all_auth[idx]
  }

  # Validate the submission_types argument shape once.
  if (!is.null(submission_types)) {
    if (!is.character(submission_types)) {
      cli::cli_abort("{.arg submission_types} must be character (a string or named vector).")
    }
    if (length(submission_types) > 1L && is.null(names(submission_types))) {
      cli::cli_abort(
        "A multi-value {.arg submission_types} must be named by authority, e.g. {.code c(FDA = \"NDA\")}."
      )
    }
  }

  resolve_type <- function(a) {
    types <- list_submission_types(a)
    if (is.null(submission_types)) return(types[1])

    if (!is.null(names(submission_types))) {
      j <- match(toupper(a), toupper(names(submission_types)))
      t <- if (is.na(j)) types[1] else submission_types[[j]]
    } else {
      t <- submission_types[1]
    }
    if (!t %in% types) {
      cli::cli_abort(c(
        "Submission type {.val {t}} is not offered by {.val {a}}.",
        "i" = "Available: {.val {types}}."
      ))
    }
    t
  }

  rows <- lapply(authorities, function(a) {
    p <- submission_profile(a, resolve_type(a))
    w <- p$pillar_weights
    data.frame(
      authority             = p$authority,
      full_name             = p$full_name,
      country               = p$country,
      submission_type       = p$submission_type,
      w_quality             = unname(w[["quality"]]),
      w_trace               = unname(w[["trace"]]),
      w_risk                = unname(w[["risk"]]),
      w_usability           = unname(w[["usability"]]),
      ready_min             = p$bands$ready[1],
      minimum_coverage      = p$minimum_coverage,
      n_required_indicators = length(p$required_indicators),
      default_detectability = p$default_detectability,
      required_asset_types  = paste(p$required_asset_types, collapse = ", "),
      stringsAsFactors      = FALSE
    )
  })

  tibble::as_tibble(do.call(rbind, rows))
}
