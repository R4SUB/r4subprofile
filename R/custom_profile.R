#' Build a Submission Profile from Caller-Supplied Values
#'
#' Constructs a `submission_profile` from values you supply, rather than from a
#' built-in regulatory authority. Every regulatory quantity (pillar weights,
#' decision bands, required indicators and asset types, minimum coverage, RPN
#' bands, detectability) is a required argument with no default: this function
#' invents no weights or thresholds of its own. It is the escape hatch for a
#' sponsor who must score against an internal, regional, or not-yet-shipped
#' ruleset whose numbers come from their own authoritative source.
#'
#' The supplied structure is validated the same way the shipped profiles are:
#' pillar weights must sum to 1, decision bands must be integer-contiguous and
#' cover 0-100, and RPN bands must be integer-contiguous and cover 1-125. The
#' result is an ordinary `submission_profile`, so every function in this package
#' that takes one -- [profile_summary()], [validate_against_profile()],
#' [profile_sci_config()], [profile_risk_config()],
#' [profile_required_indicators()] -- works on it unchanged.
#'
#' @param authority Character. A name for the authority or ruleset (used in
#'   printed output; it need not be one of the built-in authorities).
#' @param submission_type Character. A name for the submission type.
#' @param pillar_weights Named numeric vector with names `"quality"`, `"trace"`,
#'   `"risk"`, and `"usability"` (in any order), each in `[0, 1]` and summing to
#'   1.
#' @param bands Named list of decision bands with names `"ready"`,
#'   `"minor_gaps"`, `"conditional"`, and `"high_risk"`, each a length-2 numeric
#'   `c(low, high)`. The bands must be integer-contiguous and together cover
#'   0-100.
#' @param required_indicators Non-empty character vector of required
#'   `indicator_id` values (no `NA`, no duplicates).
#' @param required_asset_types Non-empty character vector of required asset
#'   types (no `NA`, no duplicates).
#' @param minimum_coverage Single numeric in `[0, 1]`: the fraction of required
#'   indicators that must be present.
#' @param rpn_bands Named list of RPN bands with names `"critical"`, `"high"`,
#'   `"medium"`, and `"low"`, each a length-2 numeric `c(low, high)`. The bands
#'   must be integer-contiguous and together cover 1-125.
#' @param default_detectability Single whole number in `1:5`.
#' @param full_name Character. Full name of the authority. Defaults to
#'   `authority`.
#' @param country Character or `NA`. Country or region. Defaults to `NA`.
#' @param study_phase Character or `NULL`. Optional study phase, stored as-is.
#'
#' @return A list of class `"submission_profile"`, identical in shape to the
#'   output of [submission_profile()].
#'
#' @seealso [submission_profile()] for the built-in authorities.
#'
#' @examples
#' prof <- custom_profile(
#'   authority = "Internal",
#'   submission_type = "Gate2",
#'   pillar_weights = c(quality = 0.4, trace = 0.2, risk = 0.3, usability = 0.1),
#'   bands = list(
#'     ready = c(85, 100), minor_gaps = c(70, 84),
#'     conditional = c(50, 69), high_risk = c(0, 49)
#'   ),
#'   required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL", "R-HIGH-RPN"),
#'   required_asset_types = c("dataset", "define"),
#'   minimum_coverage = 0.8,
#'   rpn_bands = list(
#'     critical = c(80, 125), high = c(40, 79),
#'     medium = c(15, 39), low = c(1, 14)
#'   ),
#'   default_detectability = 3L
#' )
#' profile_summary(prof)
#'
#' @export
custom_profile <- function(authority,
                           submission_type,
                           pillar_weights,
                           bands,
                           required_indicators,
                           required_asset_types,
                           minimum_coverage,
                           rpn_bands,
                           default_detectability,
                           full_name = authority,
                           country = NA_character_,
                           study_phase = NULL) {
  shape <- character(0)

  check_string <- function(x, arg) {
    if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
      shape <<- c(shape, sprintf("`%s` must be a single non-empty string.", arg))
      FALSE
    } else {
      TRUE
    }
  }

  check_string(authority, "authority")
  check_string(submission_type, "submission_type")
  check_string(full_name, "full_name")

  if (!(is.character(country) && length(country) == 1L)) {
    shape <- c(shape, "`country` must be a single string or `NA`.")
  }
  if (!is.null(study_phase) &&
      !(is.character(study_phase) && length(study_phase) == 1L && !is.na(study_phase))) {
    shape <- c(shape, "`study_phase` must be `NULL` or a single non-empty string.")
  }

  # Named numeric set with an exact name set.
  check_named_set <- function(x, want, arg, numeric_vals) {
    if (is.null(names(x)) || !setequal(names(x), want)) {
      shape <<- c(shape, sprintf(
        "`%s` must be named exactly: %s.", arg, paste(want, collapse = ", ")
      ))
      return(FALSE)
    }
    if (anyDuplicated(names(x))) {
      shape <<- c(shape, sprintf("`%s` has duplicated names.", arg))
      return(FALSE)
    }
    TRUE
  }

  pw_ok <- is.numeric(pillar_weights) &&
    check_named_set(pillar_weights, .pillar_names, "pillar_weights")
  if (isTRUE(pw_ok)) {
    if (any(is.na(pillar_weights)) || any(pillar_weights < 0 | pillar_weights > 1)) {
      shape <- c(shape, "`pillar_weights` values must be numbers in [0, 1].")
      pw_ok <- FALSE
    }
  } else if (!is.numeric(pillar_weights)) {
    shape <- c(shape, "`pillar_weights` must be a named numeric vector.")
    pw_ok <- FALSE
  }

  # A named list of length-2 numeric bands, with an exact name set.
  check_band_list <- function(x, want, arg) {
    if (!is.list(x) || is.null(names(x)) || !setequal(names(x), want)) {
      shape <<- c(shape, sprintf(
        "`%s` must be a list named exactly: %s.", arg, paste(want, collapse = ", ")
      ))
      return(FALSE)
    }
    ok <- vapply(x, function(b) is.numeric(b) && length(b) == 2L && !anyNA(b),
                 logical(1))
    if (!all(ok)) {
      shape <<- c(shape, sprintf(
        "`%s` entries must each be a length-2 numeric c(low, high).", arg
      ))
      return(FALSE)
    }
    TRUE
  }

  bands_ok <- check_band_list(bands, .band_names, "bands")
  rpn_ok   <- check_band_list(rpn_bands, .rpn_names, "rpn_bands")

  check_id_vec <- function(x, arg) {
    if (!is.character(x) || length(x) == 0L || anyNA(x) || any(!nzchar(x))) {
      shape <<- c(shape, sprintf(
        "`%s` must be a non-empty character vector with no NA or empty values.", arg
      ))
      return(FALSE)
    }
    if (anyDuplicated(x)) {
      shape <<- c(shape, sprintf("`%s` must not contain duplicates.", arg))
      return(FALSE)
    }
    TRUE
  }

  check_id_vec(required_indicators, "required_indicators")
  check_id_vec(required_asset_types, "required_asset_types")

  if (!is.numeric(minimum_coverage) || length(minimum_coverage) != 1L ||
      is.na(minimum_coverage) || minimum_coverage < 0 || minimum_coverage > 1) {
    shape <- c(shape, "`minimum_coverage` must be a single number in [0, 1].")
  }

  det_ok <- is.numeric(default_detectability) &&
    length(default_detectability) == 1L && !is.na(default_detectability) &&
    default_detectability == round(default_detectability) &&
    default_detectability >= 1 && default_detectability <= 5
  if (!det_ok) {
    shape <- c(shape, "`default_detectability` must be a single whole number in 1:5.")
  }

  if (length(shape) > 0L) {
    cli::cli_abort(c(
      "Invalid {.fn custom_profile} arguments.",
      stats::setNames(shape, rep("x", length(shape)))
    ))
  }

  # Normalise to canonical order so downstream accessors behave like the
  # built-in profiles.
  pillar_weights <- pillar_weights[.pillar_names]
  bands          <- bands[.band_names]
  rpn_bands      <- rpn_bands[.rpn_names]

  # Reuse the exact structural invariants applied to the shipped profiles.
  problems <- .profile_structure_problems(
    list(pillar_weights = pillar_weights, bands = bands, rpn_bands = rpn_bands),
    sprintf("%s/%s", authority, submission_type)
  )
  if (length(problems) > 0L) {
    cli::cli_abort(c(
      "The supplied profile is not structurally valid.",
      stats::setNames(problems, rep("x", length(problems)))
    ))
  }

  structure(
    list(
      authority             = authority,
      full_name             = full_name,
      country               = country,
      submission_type       = submission_type,
      study_phase           = study_phase,
      pillar_weights        = pillar_weights,
      bands                 = bands,
      required_indicators   = required_indicators,
      required_asset_types  = required_asset_types,
      minimum_coverage      = minimum_coverage,
      rpn_bands             = rpn_bands,
      default_detectability = as.integer(default_detectability)
    ),
    class = "submission_profile"
  )
}
