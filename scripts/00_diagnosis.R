load("~/2026/ABRIL/TXT/PLANO_CARTERA/CARTERA_MAR_26.RData")
# =============================================================================
# PROJECT 7 — Coercive Portfolio Characterization
# Secretaría de Hacienda Distrital — Bogotá, Colombia
# =============================================================================
# SCRIPT 00 — INITIAL DIAGNOSIS (read only, does not modify data)
# Author: Carol Ladino
# Date:   March 2026
# =============================================================================

cat("======================================================\n")
cat("  DIAGNOSIS — CARTERA_MAR_26\n")
cat("======================================================\n\n")

cat("Rows:   ", nrow(CARTERA_MAR_26), "\n")
cat("Columns:", ncol(CARTERA_MAR_26), "\n\n")

cat("Column names:\n")
print(names(CARTERA_MAR_26))

cat("\nColumn types:\n")
print(sapply(CARTERA_MAR_26, class))

# --- Duplicates in ID_CARTERA ---
cat("\n======================================================\n")
cat("  DUPLICATES IN ID_CARTERA\n")
cat("======================================================\n\n")

total_ids      <- nrow(CARTERA_MAR_26)
ids_unicos     <- length(unique(CARTERA_MAR_26$ID_CARTERA))
ids_duplicados <- total_ids - ids_unicos

cat("Total records:     ", total_ids, "\n")
cat("Unique IDs:        ", ids_unicos, "\n")
cat("Duplicate records: ", ids_duplicados,
    sprintf("(%.2f%%)\n", ids_duplicados / total_ids * 100))

cat("\nTop 10 most repeated ID_CARTERA:\n")
freq_id  <- sort(table(CARTERA_MAR_26$ID_CARTERA), decreasing = TRUE)
freq_dup <- freq_id[freq_id > 1]
print(head(freq_dup, 10))

# --- Nulls per column ---
cat("\n======================================================\n")
cat("  NULL VALUES PER COLUMN\n")
cat("======================================================\n\n")

nulos     <- sapply(CARTERA_MAR_26, function(x) sum(is.na(x)))
pct_nulos <- round(nulos / nrow(CARTERA_MAR_26) * 100, 2)

reporte_nulos <- data.frame(
  column    = names(nulos),
  nulls     = as.integer(nulos),
  pct_nulls = pct_nulos,
  row.names = NULL
)
reporte_nulos <- reporte_nulos[order(-reporte_nulos$nulls), ]
print(reporte_nulos, row.names = FALSE)

cat("\nColumns with more than 20% nulls:\n")
print(reporte_nulos[reporte_nulos$pct_nulls > 20, ], row.names = FALSE)

# --- Distribution by TIPO_ID ---
cat("\n======================================================\n")
cat("  DISTRIBUTION BY TIPO_ID\n")
cat("======================================================\n\n")

freq_tipo <- sort(table(CARTERA_MAR_26$TIPO_ID), decreasing = TRUE)
pct_tipo  <- round(prop.table(freq_tipo) * 100, 2)
dist_tipo <- data.frame(
  TIPO_ID   = names(freq_tipo),
  n         = as.integer(freq_tipo),
  pct       = as.numeric(pct_tipo),
  row.names = NULL
)
print(dist_tipo, row.names = FALSE)

# --- Distribution by ID_IMPUESTO ---
cat("\n======================================================\n")
cat("  DISTRIBUTION BY ID_IMPUESTO\n")
cat("======================================================\n\n")

freq_imp <- sort(table(CARTERA_MAR_26$ID_IMPUESTO), decreasing = TRUE)
pct_imp  <- round(prop.table(freq_imp) * 100, 2)
dist_imp <- data.frame(
  ID_IMPUESTO = names(freq_imp),
  n           = as.integer(freq_imp),
  pct         = as.numeric(pct_imp),
  row.names   = NULL
)
print(dist_imp, row.names = FALSE)

# --- Monetary variables ---
cat("\n======================================================\n")
cat("  MONETARY VARIABLES SUMMARY\n")
cat("======================================================\n\n")

for (v in c("IMPUESTOS", "SANCIONES", "INTERESES")) {
  x <- CARTERA_MAR_26[[v]]
  cat(sprintf("\n--- %s ---\n", v))
  cat("  Min:       ", min(x,    na.rm = TRUE), "\n")
  cat("  Max:       ", max(x,    na.rm = TRUE), "\n")
  cat("  Mean:      ", round(mean(x, na.rm = TRUE), 2), "\n")
  cat("  Median:    ", median(x, na.rm = TRUE), "\n")
  cat("  Nulls:     ", sum(is.na(x)), "\n")
  cat("  Negatives: ", sum(x < 0, na.rm = TRUE), "\n")
  cat("  Zeros:     ", sum(x == 0, na.rm = TRUE), "\n")
}

# --- Distribution by VIGENCIA ---
cat("\n======================================================\n")
cat("  DISTRIBUTION BY VIGENCIA\n")
cat("======================================================\n\n")

freq_vig <- sort(table(CARTERA_MAR_26$VIGENCIA), decreasing = FALSE)
pct_vig  <- round(prop.table(freq_vig) * 100, 2)
dist_vig <- data.frame(
  VIGENCIA  = names(freq_vig),
  n         = as.integer(freq_vig),
  pct       = as.numeric(pct_vig),
  row.names = NULL
)
print(dist_vig, row.names = FALSE)

# --- Save null report ---
write.csv(reporte_nulos, "00_null_report.csv", row.names = FALSE)
cat("\n✅ Saved: 00_null_report.csv\n")
cat("\n======================================================\n")
cat("  DIAGNOSIS COMPLETE\n")
cat("  Next: Script 01 — Cleaning & Anonymization\n")
cat("======================================================\n")
