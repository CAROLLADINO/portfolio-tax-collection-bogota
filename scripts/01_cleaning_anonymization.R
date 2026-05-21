# =============================================================================
# PROJECT 7 — Coercive Portfolio Characterization
# Secretaría de Hacienda Distrital — Bogotá, Colombia
# =============================================================================
# SCRIPT 01 — CLEANING & ANONYMIZATION
# Author: Carol Ladino
# Date:   March 2026
# =============================================================================
# TAX CATALOG
#   1  = PREDIAL
#   2  = VEHICULOS
#   03 = ICA
#   04 = RETEICA
#   5  = SOBRETASA
#   6  = DELINEACION
#   7  = PUBLICIDAD
#   9  = SIN_CUENTA_CORRIENTE
#   10 = AZAR
# =============================================================================

cat("======================================================\n")
cat("  CLEANING & ANONYMIZATION — CARTERA_MAR_26\n")
cat("======================================================\n\n")

# STEP 0 — Working copy (never modify the original)
df <- CARTERA_MAR_26
cat("✔ Working copy created: df\n")
cat("  Initial rows:", nrow(df), "\n\n")


# -----------------------------------------------------------------------------
# STEP 1 — ANONYMIZATION
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 1: ANONYMIZATION\n")
cat("------------------------------------------------------\n")

anonimizar <- function(x) {
  ifelse(
    is.na(x),
    NA_character_,
    paste0("ID_", sprintf("%010d", as.integer(factor(x))))
  )
}

df$NRO_ID_ANON          <- anonimizar(df$NRO_ID)
df$NOMBRE_CONTRIBUYENTE <- NULL
df$NRO_ID               <- NULL

cat("✔ NRO_ID replaced by NRO_ID_ANON (anonymous hash)\n")
cat("✔ NOMBRE_CONTRIBUYENTE deleted\n\n")


# -----------------------------------------------------------------------------
# STEP 2 — TAX LABELS
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 2: TAX LABELS\n")
cat("------------------------------------------------------\n")

catalogo_impuesto <- c(
  "1"  = "PREDIAL",
  "2"  = "VEHICULOS",
  "03" = "ICA",
  "04" = "RETEICA",
  "5"  = "SOBRETASA",
  "6"  = "DELINEACION",
  "7"  = "PUBLICIDAD",
  "9"  = "SIN_CUENTA_CORRIENTE",
  "10" = "AZAR"
)

df$NOMBRE_IMPUESTO <- catalogo_impuesto[df$ID_IMPUESTO]
cat("✔ NOMBRE_IMPUESTO created\n")
cat("  Records without valid tax ID:", sum(is.na(df$NOMBRE_IMPUESTO)), "\n\n")


# -----------------------------------------------------------------------------
# STEP 3 — REMOVE INVALID RECORDS
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 3: REMOVE INVALID RECORDS\n")
cat("------------------------------------------------------\n")

n_antes <- nrow(df)

# 3a. ID_CARTERA duplicates — remove all
dup_ids <- df$ID_CARTERA[duplicated(df$ID_CARTERA) | duplicated(df$ID_CARTERA, fromLast = TRUE)]
dup_ids <- unique(dup_ids[!is.na(dup_ids)])
df <- df[!(df$ID_CARTERA %in% dup_ids), ]
cat("✔ ID_CARTERA duplicates removed:  ", n_antes - nrow(df), "\n")

# 3b. Invalid ID_IMPUESTO
n_antes2 <- nrow(df)
df <- df[!is.na(df$NOMBRE_IMPUESTO), ]
cat("✔ Invalid ID_IMPUESTO removed:    ", n_antes2 - nrow(df), "\n")

# 3c. Invalid TIPO_ID
n_antes3 <- nrow(df)
df <- df[!(df$TIPO_ID %in% c("", "0", NA)) & !is.na(df$TIPO_ID), ]
cat("✔ Invalid TIPO_ID removed:        ", n_antes3 - nrow(df), "\n")

cat(sprintf("\n  Before: %d | After: %d | Removed: %d (%.3f%%)\n\n",
    n_antes, nrow(df), n_antes - nrow(df),
    (n_antes - nrow(df)) / n_antes * 100))


# -----------------------------------------------------------------------------
# STEP 4 — DATE CONVERSION (correct format: dd/mm/yyyy)
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 4: DATE CONVERSION\n")
cat("------------------------------------------------------\n")

cols_fecha <- c(
  "FECHA_DOCUMENTO", "FECHA_NOTIFICACION", "FECHA_EXIGIBILIDAD",
  "FECHA_PRESCRIPCION", "FECHA_EXIGIBILIDAD_ORIGINAL",
  "FECHA_MP", "FECHA_NOTIFICACION_MP",
  "FECHA_FP", "FECHA_NOTIFICACION_FP",
  "FECHA_IFP", "FECHA_NOTIFICACION_IFP"
)

for (col in cols_fecha) {
  if (col %in% names(df)) {
    df[[col]] <- as.Date(df[[col]], format = "%d/%m/%Y")
  }
}

# Verify
cat("✔ Date columns converted (format: dd/mm/yyyy):\n")
for (col in cols_fecha) {
  if (col %in% names(df)) {
    n_na <- sum(is.na(df[[col]]))
    cat(sprintf("  %-35s NAs: %d\n", col, n_na))
  }
}
cat("\n")


# -----------------------------------------------------------------------------
# STEP 5 — PROCESS FLAGS (corrected: empty strings = no process)
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 5: PROCESS FLAGS\n")
cat("------------------------------------------------------\n")

df$TIENE_MP <- ifelse(
  is.na(df$NRO_ACTO_MP) | trimws(df$NRO_ACTO_MP) == "", 0L, 1L)

df$TIENE_FP <- ifelse(
  is.na(df$NRO_ACTO_FP) | trimws(df$NRO_ACTO_FP) == "" |
  trimws(df$NRO_ACTO_FP) == ".", 0L, 1L)

df$TIENE_IFP <- ifelse(
  is.na(df$NRO_ACTO_IFP) | trimws(df$NRO_ACTO_IFP) == "" |
  trimws(df$NRO_ACTO_IFP) == ".", 0L, 1L)

cat(sprintf("✔ TIENE_MP  — With: %s | Without: %s\n",
    format(sum(df$TIENE_MP == 1),  big.mark = ","),
    format(sum(df$TIENE_MP == 0),  big.mark = ",")))
cat(sprintf("✔ TIENE_FP  — With: %s\n",
    format(sum(df$TIENE_FP == 1),  big.mark = ",")))
cat(sprintf("✔ TIENE_IFP — With: %s\n\n",
    format(sum(df$TIENE_IFP == 1), big.mark = ",")))


# -----------------------------------------------------------------------------
# STEP 6 — DERIVED VARIABLES
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 6: DERIVED VARIABLES\n")
cat("------------------------------------------------------\n")

df$DEUDA_TOTAL      <- rowSums(df[, c("IMPUESTOS", "SANCIONES", "INTERESES")], na.rm = TRUE)
df$TIPO_DEUDOR      <- ifelse(df$TIPO_ID == "NIT", "JURIDICO", "NATURAL")
df$ANTIGUEDAD_ANIOS <- ifelse(!is.na(df$VIGENCIA), 2026 - df$VIGENCIA, NA)

df$TRAMO_DEUDA <- cut(
  df$DEUDA_TOTAL,
  breaks = c(0, 100000, 500000, 2000000, 10000000, 50000000, Inf),
  labels = c("0-100K", "100K-500K", "500K-2M", "2M-10M", "10M-50M", "50M+"),
  include.lowest = TRUE, right = FALSE
)

df$BUCKET_EDAD <- cut(
  df$ANTIGUEDAD_ANIOS,
  breaks = c(-Inf, 1, 3, 5, 10, 15, Inf),
  labels = c("0-1y (Current)", "1-3y (Recent)", "3-5y (Medium)",
             "5-10y (Old)", "10-15y (Very old)", "15y+ (Critical)"),
  right = TRUE
)

cat("✔ DEUDA_TOTAL      = IMPUESTOS + SANCIONES + INTERESES\n")
cat("✔ TIPO_DEUDOR      = JURIDICO / NATURAL\n")
cat("✔ ANTIGUEDAD_ANIOS = 2026 - VIGENCIA\n")
cat("✔ TRAMO_DEUDA      = 6 value ranges\n")
cat("✔ BUCKET_EDAD      = 6 age ranges\n\n")


# -----------------------------------------------------------------------------
# STEP 7 — FINAL VERIFICATION
# -----------------------------------------------------------------------------
cat("------------------------------------------------------\n")
cat("  STEP 7: FINAL VERIFICATION\n")
cat("------------------------------------------------------\n")

cat("Final rows:   ", format(nrow(df), big.mark = ","), "\n")
cat("Final columns:", ncol(df), "\n\n")

cat("Distribution by NOMBRE_IMPUESTO:\n")
print(sort(table(df$NOMBRE_IMPUESTO), decreasing = TRUE))

cat("\nDistribution by TIPO_DEUDOR:\n")
print(table(df$TIPO_DEUDOR))

cat("\nTotal portfolio value (COP):\n")
cat("  $", format(sum(df$DEUDA_TOTAL, na.rm = TRUE), big.mark = ","), "\n\n")


# -----------------------------------------------------------------------------
# STEP 8 — SAVE CLEAN DATA
# -----------------------------------------------------------------------------
saveRDS(df, "CARTERA_MAR_26_LIMPIA.rds")
cat("✅ Clean data saved: CARTERA_MAR_26_LIMPIA.rds\n")
cat("   To reload: df <- readRDS('CARTERA_MAR_26_LIMPIA.rds')\n\n")

cat("======================================================\n")
cat("  SCRIPT 01 COMPLETE\n")
cat("  Next: Script 02 — Descriptive Analysis\n")
cat("======================================================\n")
