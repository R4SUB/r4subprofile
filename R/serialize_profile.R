# Schema version written into every serialized profile, and the set of schema
# versions this package can read back. Bump the writer version only when the
# serialized shape changes; keep older readable versions in the supported set.
# @noRd
.profile_schema_version            <- 1L
.profile_schema_versions_supported <- 1L

#' Serialize a Submission Profile to Portable JSON
#'
#' Writes a `submission_profile` -- whether a built-in authority profile from
#' [submission_profile()] or a caller-built one from [custom_profile()] -- to a
#' portable JSON document that can be stored, version-controlled, or shared and
#' later read back with [read_profile()] into an equivalent, validated profile.
#'
#' The serialization carries only values that already exist on the profile; it
#' invents, defaults, or alters no weight, threshold, or other configured value.
#' The document is wrapped in a small envelope recording a schema version so
#' that [read_profile()] can recognize and check it.
#'
#' The export is a faithful, stable round-trip: reading a written profile and
#' writing it again produces byte-identical JSON (export, import, export is
#' stable).
#'
#' @param profile A `submission_profile` object.
#' @param file Optional path to write the JSON to. When `NULL` (default) the
#'   JSON string is returned; when a path is given the JSON is written there and
#'   the path is returned invisibly.
#' @param pretty Logical; whether to pretty-print the JSON with indentation.
#'   Defaults to `TRUE`. The choice does not affect the round-trip as long as it
#'   is the same on repeated writes.
#'
#' @return When `file` is `NULL`, a single JSON string. When `file` is a path,
#'   the path, invisibly.
#'
#' @seealso [read_profile()] to read the result back, [diff_profiles()] to
#'   compare a profile against a built-in authority.
#'
#' @examples
#' prof <- submission_profile("FDA", "NDA")
#' json <- write_profile(prof)
#' cat(json)
#'
#' # Round-trip back into an equivalent profile:
#' prof2 <- read_profile(json)
#' identical(write_profile(prof2), json)
#'
#' @export
write_profile <- function(profile, file = NULL, pretty = TRUE) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }
  if (!is.logical(pretty) || length(pretty) != 1L || is.na(pretty)) {
    cli::cli_abort("{.arg pretty} must be a single {.code TRUE} or {.code FALSE}.")
  }
  if (!is.null(file) &&
      !(is.character(file) && length(file) == 1L && !is.na(file) && nzchar(file))) {
    cli::cli_abort("{.arg file} must be `NULL` or a single non-empty file path.")
  }

  country_val <- if (length(profile$country) != 1L || is.na(profile$country)) {
    NA_character_
  } else {
    as.character(profile$country)
  }
  phase_val <- if (is.null(profile$study_phase)) {
    NA_character_
  } else {
    as.character(profile$study_phase)
  }

  body <- list(
    authority             = jsonlite::unbox(as.character(profile$authority)),
    full_name             = jsonlite::unbox(as.character(profile$full_name)),
    country               = jsonlite::unbox(country_val),
    submission_type       = jsonlite::unbox(as.character(profile$submission_type)),
    study_phase           = jsonlite::unbox(phase_val),
    pillar_weights        = lapply(as.list(profile$pillar_weights),
                                   function(v) jsonlite::unbox(as.numeric(v))),
    bands                 = lapply(profile$bands, as.numeric),
    required_indicators   = as.character(profile$required_indicators),
    required_asset_types  = as.character(profile$required_asset_types),
    minimum_coverage      = jsonlite::unbox(as.numeric(profile$minimum_coverage)),
    rpn_bands             = lapply(profile$rpn_bands, as.numeric),
    default_detectability = jsonlite::unbox(as.integer(profile$default_detectability))
  )

  envelope <- list(
    r4subprofile_schema = jsonlite::unbox(.profile_schema_version),
    profile             = body
  )

  json <- jsonlite::toJSON(
    envelope,
    auto_unbox = FALSE,
    null       = "null",
    na         = "null",
    digits     = 10,
    pretty     = pretty
  )
  json <- as.character(json)

  if (is.null(file)) {
    return(json)
  }
  writeLines(json, file)
  invisible(file)
}

#' Read a Submission Profile from Portable JSON
#'
#' Reads a JSON document produced by [write_profile()] back into a
#' `submission_profile`. The structure is checked the same way a caller-built
#' profile is: the reconstruction is routed through [custom_profile()], so the
#' imported profile must satisfy exactly the structural invariants applied to
#' the shipped profiles (pillar weights sum to 1, decision bands integer-
#' contiguous over 0-100, RPN bands integer-contiguous over 1-125). A document
#' that fails them is rejected rather than silently repaired.
#'
#' Only values present in the document are used; no weight, threshold, or other
#' value is invented or defaulted in.
#'
#' @param file A single string: either a path to a JSON file written by
#'   [write_profile()], or the JSON string itself.
#'
#' @return A `submission_profile` object equivalent to the one that was written.
#'
#' @seealso [write_profile()].
#'
#' @examples
#' prof <- submission_profile("EMA", "MAA")
#' json <- write_profile(prof)
#' prof2 <- read_profile(json)
#' identical(prof, prof2)
#'
#' @export
read_profile <- function(file) {
  if (!is.character(file) || length(file) != 1L || is.na(file) || !nzchar(file)) {
    cli::cli_abort(
      "{.arg file} must be a single string: a path to a JSON file or JSON text."
    )
  }

  is_path    <- file.exists(file)
  looks_json <- grepl("\\{", file)
  if (!is_path && !looks_json) {
    cli::cli_abort(c(
      "Cannot read a profile from {.arg file}.",
      "i" = "It is neither an existing file nor JSON text."
    ))
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(file, simplifyVector = TRUE, simplifyDataFrame = FALSE),
    error = function(e) {
      cli::cli_abort(c(
        "Could not parse the profile JSON.",
        "x" = conditionMessage(e)
      ))
    }
  )

  .profile_from_parsed(parsed)
}

# Reconstruct a submission_profile from a parsed JSON envelope. Shared by
# read_profile(). Validates the envelope and routes the regulatory values
# through custom_profile() so an imported profile is checked by exactly the
# same contract as a caller-built one. It passes values straight through and
# invents nothing.
# @noRd
.profile_from_parsed <- function(parsed) {
  if (!is.list(parsed) || is.null(parsed$r4subprofile_schema) ||
      is.null(parsed$profile)) {
    cli::cli_abort(c(
      "This does not look like a profile written by {.fn write_profile}.",
      "i" = "The expected {.field r4subprofile_schema} / {.field profile} envelope is missing."
    ))
  }

  schema    <- parsed$r4subprofile_schema
  supported <- .profile_schema_versions_supported
  if (!is.numeric(schema) || length(schema) != 1L || !schema %in% supported) {
    cli::cli_abort(c(
      "Unsupported profile schema version {.val {schema}}.",
      "i" = "This version of the package reads schema {.val {supported}}."
    ))
  }

  p <- parsed$profile

  # Named weight object comes back as a named list; flatten to a named numeric
  # vector (coercing to double, preserving the names).
  pw <- p$pillar_weights
  if (is.list(pw)) {
    pw <- unlist(pw, use.names = TRUE)
  }
  pw_names <- names(pw)
  pw <- as.numeric(pw)
  names(pw) <- pw_names

  # Whole-number bands parse back as integer vectors; the profile stores them
  # as doubles, so coerce to keep the round-trip type-exact.
  bands     <- lapply(p$bands, as.numeric)
  rpn_bands <- lapply(p$rpn_bands, as.numeric)

  country <- if (is.null(p$country) || (length(p$country) == 1L && is.na(p$country))) {
    NA_character_
  } else {
    as.character(p$country)
  }
  study_phase <- if (is.null(p$study_phase) ||
                     (length(p$study_phase) == 1L && is.na(p$study_phase))) {
    NULL
  } else {
    as.character(p$study_phase)
  }

  custom_profile(
    authority             = p$authority,
    submission_type       = p$submission_type,
    pillar_weights        = pw,
    bands                 = bands,
    required_indicators   = as.character(p$required_indicators),
    required_asset_types  = as.character(p$required_asset_types),
    minimum_coverage      = p$minimum_coverage,
    rpn_bands             = rpn_bands,
    default_detectability = p$default_detectability,
    full_name             = if (is.null(p$full_name)) p$authority else p$full_name,
    country               = country,
    study_phase           = study_phase
  )
}

#' Compare a Profile Against a Built-in Authority
#'
#' Reports the fields in which a profile -- typically a [custom_profile()] or a
#' profile imported with [read_profile()] -- differs from a built-in reference
#' profile. It is a read-only comparison of values that already exist on both
#' profiles: nothing is changed, and no weight or threshold is invented.
#'
#' Both profiles are reduced to their one-row-per-field tibble form (the same
#' representation as `profile_summary(format = "tibble")`) and compared field by
#' field; only the differing fields are returned.
#'
#' @param profile A `submission_profile` object (the one under inspection).
#' @param reference Either a `submission_profile` object to compare against, or
#'   a single string naming a built-in authority (for example `"FDA"`), in which
#'   case a built-in profile is built with [submission_profile()].
#' @param submission_type Optional submission type to use when `reference` names
#'   an authority. `NULL` (default) uses that authority's first type. Ignored
#'   when `reference` is already a profile object.
#'
#' @return A tibble with one row per differing field and columns `field`,
#'   `value` (from `profile`), and `reference_value` (from `reference`). A
#'   zero-row tibble means the two profiles agree on every field.
#'
#' @seealso [profile_summary()], [write_profile()], [read_profile()].
#'
#' @examples
#' mine <- custom_profile(
#'   authority = "FDA", submission_type = "NDA",
#'   pillar_weights = c(quality = 0.40, trace = 0.25, risk = 0.25, usability = 0.10),
#'   bands = list(
#'     ready = c(85, 100), minor_gaps = c(70, 84),
#'     conditional = c(50, 69), high_risk = c(0, 49)
#'   ),
#'   required_indicators = c("Q-MISS-VAR", "T-TRACE-LEVEL"),
#'   required_asset_types = c("dataset", "define"),
#'   minimum_coverage = 0.90,
#'   rpn_bands = list(
#'     critical = c(80, 125), high = c(40, 79),
#'     medium = c(15, 39), low = c(1, 14)
#'   ),
#'   default_detectability = 3L
#' )
#' diff_profiles(mine, "FDA", submission_type = "NDA")
#'
#' @export
diff_profiles <- function(profile, reference, submission_type = NULL) {
  if (!inherits(profile, "submission_profile")) {
    cli::cli_abort("{.arg profile} must be a {.cls submission_profile} object.")
  }

  if (inherits(reference, "submission_profile")) {
    ref <- reference
  } else if (is.character(reference) && length(reference) == 1L && !is.na(reference)) {
    ty <- if (is.null(submission_type)) {
      list_submission_types(reference)[1]
    } else {
      submission_type
    }
    ref <- submission_profile(reference, ty)
  } else {
    cli::cli_abort(
      "{.arg reference} must be a {.cls submission_profile} or a single authority name."
    )
  }

  a <- profile_summary(profile, format = "tibble")
  b <- profile_summary(ref, format = "tibble")

  idx <- match(a$field, b$field)
  b_val <- b$value[idx]

  differs <- !mapply(
    function(x, y) isTRUE(x == y) || (is.na(x) && is.na(y)),
    a$value, b_val
  )

  tibble::tibble(
    field           = a$field[differs],
    value           = a$value[differs],
    reference_value = b_val[differs]
  )
}
