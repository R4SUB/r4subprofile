# Shared test helper: build minimal valid evidence for profile validation tests
make_profile_test_evidence <- function(indicator_ids, asset_types) {
  n <- max(length(indicator_ids), length(asset_types))
  indicator_ids <- rep_len(indicator_ids, n)
  asset_types <- rep_len(asset_types, n)

  data.frame(
    run_id = rep("R4S-TEST", n),
    study_id = rep("TEST-001", n),
    asset_type = asset_types,
    asset_id = paste0("ASSET-", seq_len(n)),
    source_name = rep("test_source", n),
    source_version = rep("1.0", n),
    indicator_id = indicator_ids,
    indicator_name = paste0("Indicator ", seq_len(n)),
    indicator_domain = rep("quality", n),
    severity = rep("medium", n),
    result = rep("pass", n),
    metric_value = rep(1.0, n),
    metric_unit = rep("score", n),
    message = rep("test message", n),
    location = rep("TEST:VAR", n),
    evidence_payload = rep("{}", n),
    created_at = rep(Sys.time(), n),
    stringsAsFactors = FALSE
  )
}
