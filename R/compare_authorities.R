#' Compare Submission Profiles Across Authorities
#'
#' Puts several regulatory authorities side by side so a sponsor filing in more
#' than one region can see how the readiness bar differs: pillar weights, the
#' score needed to be ready, the minimum traceability coverage, how many
#' indicators are required, and the detectability default that feeds risk
#' scoring. It answers "what changes if we also file with the EMA" without
#' building and eyeballing each profile by hand.
#'
#' Pass `rank_by` to order the authorities from strictest to most lenient on a
#' chosen measure. Ranking only reorders rows and adds columns; it never changes
#' any weight, threshold, or other configured value.
#'
#' @param authorities Character vector of authority names, matched
#'   case-insensitively (for example `c("fda", "ema", "pmda")`). Defaults to
#'   every supported authority from [list_authorities()].
#' @param submission_types How to pick a submission type per authority. `NULL`
#'   (default) uses each authority's first type. A single string uses that type
#'   for every authority (and errors if one does not offer it). A named vector
#'   (`c(FDA = "NDA", EMA = "MAA")`) selects per authority, falling back to the
#'   first type for any authority not named.
#' @param rank_by Optional single string naming a strictness measure to order
#'   the result by, from highest (strictest) to lowest. `NULL` (default) leaves
#'   the output and its ordering exactly as they are without this argument. One
#'   of `"minimum_coverage"`, `"ready_min"`, or `"n_required_indicators"`. When
#'   set, rows are reordered by that measure (ties keep their original order) and
#'   the result gains the additive columns described below.
#'
#' @return A tibble with one row per authority and columns `authority`,
#'   `full_name`, `country`, `submission_type`, the four pillar weights
#'   (`w_quality`, `w_trace`, `w_risk`, `w_usability`), `ready_min` (lowest SCI
#'   in the ready band), `minimum_coverage`, `n_required_indicators`,
#'   `default_detectability`, and `required_asset_types`.
#'
#'   When `rank_by` is supplied the same columns are returned, reordered by the
#'   chosen measure, plus these additive columns: `strictness_rank` (1 for the
#'   strictest authority on the measure, with tied values sharing a rank) and the
#'   remaining decision-band floors `minor_gaps_min` and `conditional_min`, which
#'   complete the band picture alongside `ready_min`. No existing value changes.
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
#' # Rank authorities from strictest to most lenient on required coverage:
#' compare_authorities(rank_by = "minimum_coverage")
#'
#' # Or by how many indicators each requires:
#' compare_authorities(c("FDA", "EMA", "PMDA"), rank_by = "n_required_indicators")
#'
#' @export
compare_authorities <- function(authorities = NULL, submission_types = NULL,
                                 rank_by = NULL) {
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

  # Validate the rank_by argument once, up front.
  rank_choices <- c("minimum_coverage", "ready_min", "n_required_indicators")
  if (!is.null(rank_by)) {
    if (!is.character(rank_by) || length(rank_by) != 1L) {
      cli::cli_abort("{.arg rank_by} must be a single string or {.code NULL}.")
    }
    if (!rank_by %in% rank_choices) {
      cli::cli_abort(c(
        "Unknown {.arg rank_by} value {.val {rank_by}}.",
        "i" = "Choose one of: {.val {rank_choices}}."
      ))
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

  profs <- lapply(authorities, function(a) submission_profile(a, resolve_type(a)))

  rows <- lapply(profs, function(p) {
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

  out <- tibble::as_tibble(do.call(rbind, rows))

  if (is.null(rank_by)) {
    return(out)
  }

  # Additive strictness ranking: reorder by the chosen measure (strictest
  # first) and add columns. No existing value is touched.
  measure <- out[[rank_by]]
  ord <- order(-measure)
  out <- out[ord, , drop = FALSE]
  profs <- profs[ord]

  out$strictness_rank <- rank(-out[[rank_by]], ties.method = "min")
  out$minor_gaps_min  <- vapply(profs, function(p) p$bands$minor_gaps[1], numeric(1))
  out$conditional_min <- vapply(profs, function(p) p$bands$conditional[1], numeric(1))

  tibble::as_tibble(out)
}
