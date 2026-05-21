# =============================================================================
# PROJECT 7 — Coercive Portfolio Characterization
# Secretaría de Hacienda Distrital — Bogotá, Colombia
# =============================================================================
# SCRIPT 02 — DESCRIPTIVE ANALYSIS
# Author: Carol Ladino
# Date:   March 2026
# =============================================================================

df <- readRDS("CARTERA_MAR_26_LIMPIA.rds")
dir.create("outputs", showWarnings = FALSE)

cat("======================================================\n")
cat("  DESCRIPTIVE ANALYSIS — CARTERA_MAR_26\n")
cat("======================================================\n\n")


# =============================================================================
# BLOCK A — PORTFOLIO VALUE BY TAX TYPE
# =============================================================================
cat("======================================================\n")
cat("  BLOCK A: PORTFOLIO VALUE BY TAX TYPE\n")
cat("======================================================\n\n")

# A1. Total value and count by tax
imp_count <- aggregate(ID_CARTERA ~ NOMBRE_IMPUESTO, data = df, FUN = length)
imp_valor <- aggregate(DEUDA_TOTAL ~ NOMBRE_IMPUESTO, data = df, FUN = sum)
names(imp_count)[2] <- "N_RECORDS"
impuesto_resumen <- merge(imp_count, imp_valor, by = "NOMBRE_IMPUESTO")
impuesto_resumen$PCT_CASES <- round(impuesto_resumen$N_RECORDS /
                                      sum(impuesto_resumen$N_RECORDS) * 100, 2)
impuesto_resumen$PCT_VALUE <- round(impuesto_resumen$DEUDA_TOTAL /
                                      sum(impuesto_resumen$DEUDA_TOTAL) * 100, 2)
impuesto_resumen$AVG_DEBT  <- round(impuesto_resumen$DEUDA_TOTAL /
                                      impuesto_resumen$N_RECORDS, 0)
impuesto_resumen <- impuesto_resumen[order(-impuesto_resumen$DEUDA_TOTAL), ]

cat("A1. Portfolio by tax type:\n")
print(impuesto_resumen, row.names = FALSE)

# A2. Pareto analysis
cat("\nA2. Pareto — debtors concentrating 80% of value:\n")
deudor_total <- aggregate(DEUDA_TOTAL ~ NRO_ID_ANON, data = df, FUN = sum)
deudor_total <- deudor_total[order(-deudor_total$DEUDA_TOTAL), ]
deudor_total$ACUM_PCT <- cumsum(deudor_total$DEUDA_TOTAL) /
                           sum(deudor_total$DEUDA_TOTAL) * 100

total_deudores  <- nrow(deudor_total)
deudores_80     <- sum(deudor_total$ACUM_PCT <= 80)
pct_deudores_80 <- round(deudores_80 / total_deudores * 100, 2)

cat(sprintf("  Total unique debtors:         %s\n", format(total_deudores, big.mark=",")))
cat(sprintf("  Debtors = 80%% of value:      %s (%.2f%%)\n", format(deudores_80, big.mark=","), pct_deudores_80))
cat(sprintf("  Remaining debtors (20%% val): %s (%.2f%%)\n\n",
            format(total_deudores - deudores_80, big.mark=","), 100 - pct_deudores_80))

# A3. By debtor type
tipo_count <- aggregate(ID_CARTERA ~ TIPO_DEUDOR, data = df, FUN = length)
tipo_valor <- aggregate(DEUDA_TOTAL ~ TIPO_DEUDOR, data = df, FUN = sum)
names(tipo_count)[2] <- "N_RECORDS"
tipo_resumen <- merge(tipo_count, tipo_valor, by = "TIPO_DEUDOR")
tipo_resumen$PCT_CASES <- round(tipo_resumen$N_RECORDS / sum(tipo_resumen$N_RECORDS) * 100, 2)
tipo_resumen$PCT_VALUE <- round(tipo_resumen$DEUDA_TOTAL / sum(tipo_resumen$DEUDA_TOTAL) * 100, 2)
cat("A3. Portfolio by debtor type:\n")
print(tipo_resumen, row.names = FALSE)

# A4. By debt tranche
tramo_count <- as.data.frame(table(df$TRAMO_DEUDA))
tramo_valor <- aggregate(DEUDA_TOTAL ~ TRAMO_DEUDA, data = df, FUN = sum)
names(tramo_count) <- c("TRAMO_DEUDA", "N_RECORDS")
tramo_resumen <- merge(tramo_count, tramo_valor, by = "TRAMO_DEUDA")
tramo_resumen$PCT_CASES <- round(tramo_resumen$N_RECORDS / sum(tramo_resumen$N_RECORDS) * 100, 2)
tramo_resumen$PCT_VALUE <- round(tramo_resumen$DEUDA_TOTAL / sum(tramo_resumen$DEUDA_TOTAL) * 100, 2)
cat("\nA4. Portfolio by debt tranche:\n")
print(tramo_resumen, row.names = FALSE)

# Save Block A
write.csv(impuesto_resumen, "outputs/A1_portfolio_by_tax.csv",         row.names = FALSE)
write.csv(tipo_resumen,     "outputs/A3_portfolio_by_debtor_type.csv", row.names = FALSE)
write.csv(tramo_resumen,    "outputs/A4_debt_tranches.csv",            row.names = FALSE)
cat("\n✔ Block A saved\n")


# =============================================================================
# BLOCK B — PORTFOLIO AGE & PRESCRIPTION RISK
# =============================================================================
cat("\n======================================================\n")
cat("  BLOCK B: PORTFOLIO AGE & PRESCRIPTION RISK\n")
cat("======================================================\n\n")

# B1. By vintage year
vig_count <- aggregate(ID_CARTERA ~ VIGENCIA, data = df, FUN = length)
vig_valor <- aggregate(DEUDA_TOTAL ~ VIGENCIA, data = df, FUN = sum)
names(vig_count)[2] <- "N_RECORDS"
vigencia_resumen <- merge(vig_count, vig_valor, by = "VIGENCIA")
vigencia_resumen$PCT_VALUE <- round(vigencia_resumen$DEUDA_TOTAL /
                                      sum(vigencia_resumen$DEUDA_TOTAL) * 100, 2)
vigencia_resumen <- vigencia_resumen[order(vigencia_resumen$VIGENCIA), ]
cat("B1. Portfolio by vintage year:\n")
print(vigencia_resumen, row.names = FALSE)

# B2. Age buckets
bucket_count <- as.data.frame(table(df$BUCKET_EDAD))
bucket_valor <- aggregate(DEUDA_TOTAL ~ BUCKET_EDAD, data = df, FUN = sum)
names(bucket_count) <- c("BUCKET_EDAD", "N_RECORDS")
bucket_resumen <- merge(bucket_count, bucket_valor, by = "BUCKET_EDAD")
bucket_resumen$PCT_CASES <- round(bucket_resumen$N_RECORDS / sum(bucket_resumen$N_RECORDS) * 100, 2)
bucket_resumen$PCT_VALUE <- round(bucket_resumen$DEUDA_TOTAL / sum(bucket_resumen$DEUDA_TOTAL) * 100, 2)
cat("\nB2. Portfolio by age bucket:\n")
print(bucket_resumen, row.names = FALSE)

# B3. Prescription risk (next 12 months)
fecha_hoy    <- as.Date("2026-03-01")
fecha_limite <- fecha_hoy + 365
prescripcion_proxima <- df[
  !is.na(df$FECHA_PRESCRIPCION) &
  df$FECHA_PRESCRIPCION >= fecha_hoy &
  df$FECHA_PRESCRIPCION <= fecha_limite, ]

cat(sprintf("\nB3. Cases expiring within 12 months: %s\n",
            format(nrow(prescripcion_proxima), big.mark = ",")))
cat(sprintf("    Total value at risk: $ %s COP\n",
            format(round(sum(prescripcion_proxima$DEUDA_TOTAL, na.rm=TRUE)), big.mark=",")))

if (nrow(prescripcion_proxima) > 0) {
  presc_count <- aggregate(ID_CARTERA ~ NOMBRE_IMPUESTO, data = prescripcion_proxima, FUN = length)
  presc_valor <- aggregate(DEUDA_TOTAL ~ NOMBRE_IMPUESTO, data = prescripcion_proxima, FUN = sum)
  names(presc_count)[2] <- "N_CASES"
  presc_resumen <- merge(presc_count, presc_valor, by = "NOMBRE_IMPUESTO")
  presc_resumen <- presc_resumen[order(-presc_resumen$DEUDA_TOTAL), ]
  cat("\n    Breakdown by tax:\n")
  print(presc_resumen, row.names = FALSE)
}

write.csv(vigencia_resumen,      "outputs/B1_portfolio_by_vintage.csv",  row.names = FALSE)
write.csv(bucket_resumen,        "outputs/B2_age_buckets.csv",           row.names = FALSE)
if (nrow(prescripcion_proxima) > 0)
  write.csv(prescripcion_proxima,"outputs/B3_prescription_risk.csv",     row.names = FALSE)
cat("\n✔ Block B saved\n")


# =============================================================================
# BLOCK C — LEGAL PROCESS STATUS
# =============================================================================
cat("\n======================================================\n")
cat("  BLOCK C: LEGAL PROCESS STATUS\n")
cat("======================================================\n\n")

total   <- nrow(df)
con_mp  <- sum(df$TIENE_MP  == 1, na.rm = TRUE)
sin_mp  <- sum(df$TIENE_MP  == 0, na.rm = TRUE)
con_fp  <- sum(df$TIENE_FP  == 1, na.rm = TRUE)
con_ifp <- sum(df$TIENE_IFP == 1, na.rm = TRUE)

# C1. Process stage overview
etapas <- data.frame(
  Stage   = c("Total portfolio", "With payment order (MP)",
               "Without payment order (MP)", "With first ruling (FP)",
               "With second ruling (IFP)"),
  N_Cases = c(total, con_mp, sin_mp, con_fp, con_ifp),
  PCT     = round(c(total, con_mp, sin_mp, con_fp, con_ifp) / total * 100, 2)
)
cat("C1. Process stage overview:\n")
print(etapas, row.names = FALSE)

# C2. Value by stage
val_sin_mp  <- sum(df$DEUDA_TOTAL[df$TIENE_MP  == 0], na.rm = TRUE)
val_con_mp  <- sum(df$DEUDA_TOTAL[df$TIENE_MP  == 1], na.rm = TRUE)
val_con_fp  <- sum(df$DEUDA_TOTAL[df$TIENE_FP  == 1], na.rm = TRUE)
val_con_ifp <- sum(df$DEUDA_TOTAL[df$TIENE_IFP == 1], na.rm = TRUE)
total_val   <- sum(df$DEUDA_TOTAL, na.rm = TRUE)

etapas_valor <- data.frame(
  Stage       = c("Without MP", "With MP", "With FP", "With IFP"),
  Total_Value = c(val_sin_mp, val_con_mp, val_con_fp, val_con_ifp),
  PCT_Value   = round(c(val_sin_mp, val_con_mp, val_con_fp, val_con_ifp) /
                        total_val * 100, 2)
)
cat("\nC2. Portfolio value by process stage:\n")
print(etapas_valor, row.names = FALSE)

# C3. MP rate by tax type
mp_count  <- aggregate(TIENE_MP ~ NOMBRE_IMPUESTO, data = df, FUN = sum)
tot_count <- aggregate(ID_CARTERA ~ NOMBRE_IMPUESTO, data = df, FUN = length)
names(mp_count)[2]  <- "CON_MP"
names(tot_count)[2] <- "TOTAL"
mp_resumen <- merge(mp_count, tot_count, by = "NOMBRE_IMPUESTO")
mp_resumen$PCT_WITH_MP <- round(mp_resumen$CON_MP / mp_resumen$TOTAL * 100, 2)
mp_resumen <- mp_resumen[order(-mp_resumen$PCT_WITH_MP), ]
cat("\nC3. Payment order rate by tax type:\n")
print(mp_resumen, row.names = FALSE)

write.csv(etapas,       "outputs/C1_process_stage_overview.csv", row.names = FALSE)
write.csv(etapas_valor, "outputs/C2_value_by_stage.csv",         row.names = FALSE)
write.csv(mp_resumen,   "outputs/C3_mp_rate_by_tax.csv",         row.names = FALSE)
cat("\n✔ Block C saved\n")


# =============================================================================
# EXECUTIVE SUMMARY
# =============================================================================
cat("\n======================================================\n")
cat("  EXECUTIVE SUMMARY\n")
cat("======================================================\n\n")

cat(sprintf("  Total portfolio value:          $ %s COP\n", format(round(total_val), big.mark=",")))
cat(sprintf("  Clean records:                    %s\n",     format(nrow(df), big.mark=",")))
cat(sprintf("  Unique debtors:                   %s\n",     format(total_deudores, big.mark=",")))
cat(sprintf("  Debtors = 80%% of value:          %s (%.1f%%)\n", format(deudores_80, big.mark=","), pct_deudores_80))
cat(sprintf("  With payment order (MP):          %s (%.1f%%)\n", format(con_mp, big.mark=","), con_mp/total*100))
cat(sprintf("  WITHOUT payment order (MP):       %s (%.1f%%)\n", format(sin_mp, big.mark=","), sin_mp/total*100))
cat(sprintf("  With first ruling (FP):           %s (%.1f%%)\n", format(con_fp, big.mark=","), con_fp/total*100))
cat(sprintf("  With second ruling (IFP):         %s (%.1f%%)\n", format(con_ifp, big.mark=","), con_ifp/total*100))
cat(sprintf("  Cases at prescription risk:       %s\n",     format(nrow(prescripcion_proxima), big.mark=",")))

cat("\n======================================================\n")
cat("  SCRIPT 02 COMPLETE\n")
cat("  Next: Script 03 — Visualizations\n")
cat("======================================================\n")
