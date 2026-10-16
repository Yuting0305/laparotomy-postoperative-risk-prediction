# ------------------------------------------------------------------
# Shared helpers for AUROC / DeLong analyses
# Run all scripts from the repository root (the folder containing this file).
# ------------------------------------------------------------------
library(pROC)

DATA_DIR   <- "data"      # input: model probability CSVs (not included in repo)
OUTPUT_DIR <- "results"   # output: summary tables

# File-name suffix of the ML-model probability file:
#   <DATA_DIR>/<outcome>_All_Model_Probabilities_<suffix>.csv
ML_FILE_SUFFIX <- "del_4_feature"

# Which probability column is used from each comparator file.
# Both comparators (ASA and SURPAS) use the logistic-regression probabilities.
ASA_MODEL_COL    <- "Logistic.regression"
SURPAS_MODEL_COL <- "Logistic.regression"

dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

# Format p-values: 3 decimals, "<0.001" for very small values
format_p <- function(p) ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))

# Format AUC and 95% CI as "0.xxx (0.xxx-0.xxx)"
format_auc_ci <- function(lower, auc, upper) {
  sprintf("%.3f (%.3f-%.3f)", auc, lower, upper)
}

# Returns c(lower, auc, upper), rounded to 3 decimals
auc_ci <- function(actual, predicted) {
  r <- roc(actual, predicted, quiet = TRUE)
  round(as.numeric(ci.auc(r, conf.level = 0.95)), 3)
}

# Read "<outcome>_All_Model_Probabilities_<suffix>.csv" from `dir`
read_probs <- function(outcome, suffix, dir = DATA_DIR) {
  path <- file.path(dir, paste0(outcome, "_All_Model_Probabilities_", suffix, ".csv"))
  if (!file.exists(path)) stop("Input file not found: ", path)
  read.csv(path, header = TRUE)
}

# ------------------------------------------------------------------
# Compare the ML models against ASA and SURPAS for one outcome.
#   outcome     : prefix used in the input file names
#   output_tag  : label used in the output file names (default = outcome)
# Expected columns: Actual, lightGBM, XGBoost in the ML file;
#                   Actual and the column named in ASA_MODEL_COL / SURPAS_MODEL_COL
#                   (default: Logistic.regression) in the ASA and SURPAS files.
# ------------------------------------------------------------------
run_outcome_analysis <- function(outcome, output_tag = outcome) {
  d_ml     <- read_probs(outcome, ML_FILE_SUFFIX)
  d_surpas <- read_probs(outcome, "SURPAS")
  d_asa    <- read_probs(outcome, "ASA")

  if (!ASA_MODEL_COL %in% names(d_asa))
    stop("Column '", ASA_MODEL_COL, "' not found in the ASA file for ", outcome)
  if (!SURPAS_MODEL_COL %in% names(d_surpas))
    stop("Column '", SURPAS_MODEL_COL, "' not found in the SURPAS file for ", outcome)

  # Paired DeLong tests assume the same patients in the same order
  stopifnot(
    "Actual labels differ between input files" =
      identical(d_ml$Actual, d_surpas$Actual) && identical(d_ml$Actual, d_asa$Actual)
  )
  outcome_y <- d_ml$Actual

  # ---- AUROC with 95% CI ----
  ci <- rbind(
    LGB    = auc_ci(outcome_y, d_ml$lightGBM),
    XGB    = auc_ci(outcome_y, d_ml$XGBoost),
    ASA    = auc_ci(outcome_y, d_asa[[ASA_MODEL_COL]]),
    SURPAS = auc_ci(outcome_y, d_surpas[[SURPAS_MODEL_COL]])
  )
  colnames(ci) <- c("Lower", "AUC", "Upper")
  auc_table <- data.frame(
    `AUC (95% CI)` = format_auc_ci(ci[, "Lower"], ci[, "AUC"], ci[, "Upper"]),
    row.names = rownames(ci),
    check.names = FALSE
  )
  print(auc_table)
  write.csv(auc_table, file.path(OUTPUT_DIR, paste0("ROC_AUC_95CI_", output_tag, ".csv")))

  # ---- Pairwise DeLong tests ----
  probs_list <- list(
    AI_model = d_ml$XGBoost,
    ASA_m    = d_asa[[ASA_MODEL_COL]],
    SURPAS_m = d_surpas[[SURPAS_MODEL_COL]]
  )
  pairs <- combn(names(probs_list), 2)

  pvals <- numeric(ncol(pairs))
  comp_names <- character(ncol(pairs))
  for (i in seq_len(ncol(pairs))) {
    m1 <- pairs[1, i]; m2 <- pairs[2, i]
    test <- roc.test(
      roc(outcome_y, probs_list[[m1]], quiet = TRUE),
      roc(outcome_y, probs_list[[m2]], quiet = TRUE),
      method = "delong"
    )
    pvals[i] <- test$p.value
    comp_names[i] <- paste(m1, "vs", m2)
  }

  results <- data.frame(
    Comparison = comp_names,
    p_value    = format_p(pvals),
    adj_p_Bonf = format_p(p.adjust(pvals, method = "bonferroni"))
  )
  print(results, row.names = FALSE)
  write.csv(results, file.path(OUTPUT_DIR, paste0("DeLong_Test_", output_tag, ".csv")),
            row.names = FALSE, fileEncoding = "UTF-8")

  invisible(list(auc = auc_table, delong = results))
}
