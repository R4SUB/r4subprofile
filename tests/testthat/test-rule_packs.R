# Tests for versioned rule packs (R/rule_packs.R)

test_that("the registry lists the built-in packs", {
  reg <- rule_packs()
  expect_s3_class(reg, "data.frame")
  expect_true(all(c("fda-2026.1", "ema-2026.1") %in% reg$id))
  expect_true(all(c("id", "authority", "version", "effective_date",
                    "n_indicators") %in% names(reg)))
  expect_true(all(reg$n_indicators > 0))
})

test_that("a pack can be selected by id and carries version and effective date", {
  pack <- rule_pack("fda-2026.1")
  expect_s3_class(pack, "rule_pack")
  expect_equal(pack$authority, "FDA")
  expect_equal(pack$version, "2026.1")
  expect_equal(pack$effective_date, "2026-01-01")
  expect_true(nrow(pack$indicators) > 0)
  expect_true(all(c("indicator_id", "source") %in% names(pack$indicators)))
})

test_that("an unknown pack id is an error", {
  expect_error(rule_pack("nope-9.9"), "Unknown rule pack")
})

test_that("built-in pack indicators start with no citation", {
  pack <- rule_pack("ema-2026.1")
  expect_true(all(is.na(pack$indicators$source)))
})

test_that("citations can be supplied and land on the right indicators", {
  inds <- rule_pack("fda-2026.1")$indicators$indicator_id
  target <- inds[1]
  pack <- rule_pack("fda-2026.1",
                    sources = stats::setNames("FDA guidance X", target))
  got <- pack$indicators$source[pack$indicators$indicator_id == target]
  expect_equal(got, "FDA guidance X")
  # untouched indicators stay NA
  expect_true(any(is.na(pack$indicators$source)))
})

test_that("sources for unknown indicators are ignored with a warning", {
  expect_warning(
    rule_pack("fda-2026.1", sources = c("NOT-AN-INDICATOR" = "x")),
    "not in this pack"
  )
})

test_that("sources must be named", {
  expect_error(rule_pack("fda-2026.1", sources = "x"), "named vector")
})

test_that("provenance carries the pack id and version", {
  prov <- rule_pack_provenance(rule_pack("fda-2026.1"))
  expect_equal(unname(prov["rule_pack"]), "fda-2026.1")
  expect_equal(unname(prov["rule_pack_version"]), "2026.1")
})

test_that("rule_pack_indicators requires a rule_pack", {
  expect_error(rule_pack_indicators(list()), "rule_pack")
})
