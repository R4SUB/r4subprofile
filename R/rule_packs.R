# Built-in rule pack metadata. A rule pack pins an authority's requirements to a
# version and an effective date, so a score can be reproduced and compared over
# time as guidance changes. Versions are dated (year.release) rather than
# semantic, to track the guidance cycle they correspond to.
.rule_pack_meta <- list(
  "fda-2026.1" = list(authority = "FDA", version = "2026.1",
                      effective_date = "2026-01-01"),
  "ema-2026.1" = list(authority = "EMA", version = "2026.1",
                      effective_date = "2026-01-01")
)

# The indicators an authority cares about: the union of the required indicators
# across all of its submission types. Internal.
authority_indicators <- function(authority) {
  auth <- .authority_db[[authority]]
  inds <- unlist(
    lapply(auth$submission_types, function(st) st$required_indicators),
    use.names = FALSE
  )
  sort(unique(inds))
}

#' Available Rule Packs
#'
#' Lists the built-in rule packs. A rule pack is an identified, versioned set of
#' the indicators an authority requires, so a submission can be scored against a
#' named, dated ruleset and the result reproduced later.
#'
#' @return A tibble with one row per pack: `id`, `authority`, `version`,
#'   `effective_date`, and `n_indicators`.
#'
#' @seealso [rule_pack()].
#'
#' @examples
#' rule_packs()
#'
#' @export
rule_packs <- function() {
  ids <- names(.rule_pack_meta)
  tibble::tibble(
    id             = ids,
    authority      = vapply(.rule_pack_meta, `[[`, character(1), "authority"),
    version        = vapply(.rule_pack_meta, `[[`, character(1), "version"),
    effective_date = vapply(.rule_pack_meta, `[[`, character(1), "effective_date"),
    n_indicators   = vapply(ids, function(id)
      length(authority_indicators(.rule_pack_meta[[id]]$authority)), integer(1))
  )
}

#' Select a Rule Pack
#'
#' Returns a rule pack by id (which encodes the authority and version, for
#' example `"fda-2026.1"`). Each indicator in the pack carries a `source` field
#' for the authoritative citation that motivates it.
#'
#' The built-in packs ship with `source` set to `NA`: the citations are pending
#' entry by someone with the regulatory references to hand, deliberately rather
#' than filled with unverified section numbers. Supply them with the `sources`
#' argument, or fill them from your own controlled reference list. This keeps the
#' pack mechanism, the versioning, and the provenance usable now, with the
#' citations added when they can be stated accurately.
#'
#' @param id A pack id from [rule_packs()], for example `"fda-2026.1"`.
#' @param sources Optional named character vector mapping `indicator_id` to a
#'   citation, used to fill the `source` field. Names not in the pack are
#'   ignored with a warning.
#'
#' @return An object of class `"rule_pack"` with `id`, `authority`, `version`,
#'   `effective_date`, and an `indicators` tibble (`indicator_id`, `source`).
#'
#' @seealso [rule_packs()], [rule_pack_provenance()].
#'
#' @examples
#' pack <- rule_pack("fda-2026.1")
#' pack
#' rule_pack_indicators(pack)
#'
#' # Supply citations for a controlled reference list:
#' pack <- rule_pack("fda-2026.1",
#'   sources = c("Q-MISS-VAR" = "FDA Study Data Technical Conformance Guide"))
#'
#' @export
rule_pack <- function(id, sources = NULL) {
  if (!is.character(id) || length(id) != 1L || !id %in% names(.rule_pack_meta)) {
    cli::cli_abort(c(
      "Unknown rule pack {.val {id}}.",
      "i" = "Available packs: {.val {names(.rule_pack_meta)}}."
    ))
  }
  meta <- .rule_pack_meta[[id]]
  inds <- authority_indicators(meta$authority)
  src <- stats::setNames(rep(NA_character_, length(inds)), inds)

  if (!is.null(sources)) {
    if (is.null(names(sources))) {
      cli::cli_abort("{.arg sources} must be a named vector (indicator id to citation).")
    }
    known <- intersect(names(sources), inds)
    src[known] <- as.character(sources[known])
    unknown <- setdiff(names(sources), inds)
    if (length(unknown) > 0L) {
      cli::cli_warn("Ignoring source(s) for indicators not in this pack: {.val {unknown}}.")
    }
  }

  structure(
    list(
      id             = id,
      authority      = meta$authority,
      version        = meta$version,
      effective_date = meta$effective_date,
      indicators     = tibble::tibble(
        indicator_id = inds,
        source       = unname(src[inds])
      )
    ),
    class = "rule_pack"
  )
}

#' @param x A `rule_pack`.
#' @param ... Ignored.
#' @rdname rule_pack
#' @export
print.rule_pack <- function(x, ...) {
  cli::cli_alert_info(
    "Rule pack {.val {x$id}}: {x$authority}, version {x$version}, effective {x$effective_date}"
  )
  n <- nrow(x$indicators)
  n_cited <- sum(!is.na(x$indicators$source))
  cli::cli_alert_info("  {n} indicator{?s}, {n_cited} with a source citation")
  invisible(x)
}

#' Indicators in a Rule Pack
#'
#' @param pack A `rule_pack` from [rule_pack()].
#' @return The pack's indicators tibble (`indicator_id`, `source`).
#' @seealso [rule_pack()].
#' @examples
#' rule_pack_indicators(rule_pack("ema-2026.1"))
#' @export
rule_pack_indicators <- function(pack) {
  if (!inherits(pack, "rule_pack")) {
    cli::cli_abort("{.arg pack} must be a {.cls rule_pack} object.")
  }
  pack$indicators
}

#' Provenance of a Rule Pack
#'
#' Returns the identifying fields of a rule pack as a named character vector, to
#' record on a scored result so the score can always be traced to the exact
#' ruleset and version that produced it.
#'
#' @param pack A `rule_pack` from [rule_pack()].
#' @return A named character vector: `rule_pack`, `rule_pack_version`,
#'   `effective_date`.
#' @seealso [rule_pack()].
#' @examples
#' rule_pack_provenance(rule_pack("fda-2026.1"))
#' @export
rule_pack_provenance <- function(pack) {
  if (!inherits(pack, "rule_pack")) {
    cli::cli_abort("{.arg pack} must be a {.cls rule_pack} object.")
  }
  c(
    rule_pack         = pack$id,
    rule_pack_version = pack$version,
    effective_date    = pack$effective_date
  )
}
