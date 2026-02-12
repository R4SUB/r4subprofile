# Internal authority database
# Not exported; accessed through submission_profile(), list_authorities(), etc.
# @noRd

.authority_db <- list(

  FDA = list(
    full_name = "U.S. Food and Drug Administration",
    country = "United States",
    submission_types = list(
      IND = list(
        pillar_weights = c(quality = 0.30, trace = 0.25, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define", "program"),
        minimum_coverage = 0.70,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      NDA = list(
        pillar_weights = c(quality = 0.35, trace = 0.25, risk = 0.25, usability = 0.15),
        bands = list(
          ready = c(85, 100), minor_gaps = c(70, 84),
          conditional = c(50, 69), high_risk = c(0, 49)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.90,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      BLA = list(
        pillar_weights = c(quality = 0.35, trace = 0.25, risk = 0.25, usability = 0.15),
        bands = list(
          ready = c(85, 100), minor_gaps = c(70, 84),
          conditional = c(50, 69), high_risk = c(0, 49)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.90,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      ANDA = list(
        pillar_weights = c(quality = 0.35, trace = 0.20, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-FORMAT-ERR",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN", "R-OPEN-RISK",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define", "program"),
        minimum_coverage = 0.80,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      `505b2` = list(
        pillar_weights = c(quality = 0.35, trace = 0.25, risk = 0.25, usability = 0.15),
        bands = list(
          ready = c(82, 100), minor_gaps = c(68, 81),
          conditional = c(48, 67), high_risk = c(0, 47)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK",
          "U-DEFINE-COMPLETE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation"),
        minimum_coverage = 0.85,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  ),

  EMA = list(
    full_name = "European Medicines Agency",
    country = "European Union",
    submission_types = list(
      CTA = list(
        pillar_weights = c(quality = 0.30, trace = 0.20, risk = 0.35, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define"),
        minimum_coverage = 0.70,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      MAA = list(
        pillar_weights = c(quality = 0.30, trace = 0.25, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(85, 100), minor_gaps = c(70, 84),
          conditional = c(50, 69), high_risk = c(0, 49)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.90,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      variation = list(
        pillar_weights = c(quality = 0.35, trace = 0.20, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(78, 100), minor_gaps = c(62, 77),
          conditional = c(42, 61), high_risk = c(0, 41)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN", "R-OPEN-RISK",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define", "program"),
        minimum_coverage = 0.75,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  ),

  PMDA = list(
    full_name = "Pharmaceuticals and Medical Devices Agency",
    country = "Japan",
    submission_types = list(
      CTN = list(
        pillar_weights = c(quality = 0.25, trace = 0.30, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(82, 100), minor_gaps = c(68, 81),
          conditional = c(48, 67), high_risk = c(0, 47)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL", "T-ORPHAN-VAR",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define", "program"),
        minimum_coverage = 0.75,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      NDA_JP = list(
        pillar_weights = c(quality = 0.25, trace = 0.30, risk = 0.25, usability = 0.20),
        bands = list(
          ready = c(88, 100), minor_gaps = c(75, 87),
          conditional = c(55, 74), high_risk = c(0, 54)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.92,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  ),

  Health_Canada = list(
    full_name = "Health Canada",
    country = "Canada",
    submission_types = list(
      CTA_CA = list(
        pillar_weights = c(quality = 0.30, trace = 0.25, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define"),
        minimum_coverage = 0.70,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      NDS = list(
        pillar_weights = c(quality = 0.35, trace = 0.25, risk = 0.25, usability = 0.15),
        bands = list(
          ready = c(83, 100), minor_gaps = c(68, 82),
          conditional = c(48, 67), high_risk = c(0, 47)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation"),
        minimum_coverage = 0.85,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  ),

  TGA = list(
    full_name = "Therapeutic Goods Administration",
    country = "Australia",
    submission_types = list(
      CTN_AU = list(
        pillar_weights = c(quality = 0.30, trace = 0.20, risk = 0.35, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define"),
        minimum_coverage = 0.70,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      registration = list(
        pillar_weights = c(quality = 0.30, trace = 0.25, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(84, 100), minor_gaps = c(68, 83),
          conditional = c(48, 67), high_risk = c(0, 47)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.88,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  ),

  MHRA = list(
    full_name = "Medicines and Healthcare products Regulatory Agency",
    country = "United Kingdom",
    submission_types = list(
      CTA_UK = list(
        pillar_weights = c(quality = 0.30, trace = 0.20, risk = 0.35, usability = 0.15),
        bands = list(
          ready = c(80, 100), minor_gaps = c(65, 79),
          conditional = c(45, 64), high_risk = c(0, 44)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH",
          "T-TRACE-LEVEL",
          "R-HIGH-RPN",
          "U-DEFINE-COMPLETE"
        ),
        required_asset_types = c("dataset", "define"),
        minimum_coverage = 0.70,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      ),
      MAA_UK = list(
        pillar_weights = c(quality = 0.30, trace = 0.25, risk = 0.30, usability = 0.15),
        bands = list(
          ready = c(84, 100), minor_gaps = c(69, 83),
          conditional = c(49, 68), high_risk = c(0, 48)
        ),
        required_indicators = c(
          "Q-MISS-VAR", "Q-TYPE-MISMATCH", "Q-LABEL-LEN",
          "Q-DUP-RECORDS", "Q-FORMAT-ERR",
          "T-ORPHAN-VAR", "T-TRACE-LEVEL", "T-AMBIGUOUS-MAP",
          "T-DERIVATION-DOC",
          "R-HIGH-RPN", "R-OPEN-RISK", "R-MITIGATION-GAP",
          "U-DEFINE-COMPLETE", "U-REVIEWER-NOTE", "U-LABEL-QUALITY"
        ),
        required_asset_types = c("dataset", "define", "program", "validation", "spec"),
        minimum_coverage = 0.88,
        rpn_bands = list(
          critical = c(80, 125), high = c(40, 79),
          medium = c(15, 39), low = c(1, 14)
        ),
        default_detectability = 3L
      )
    )
  )
)
