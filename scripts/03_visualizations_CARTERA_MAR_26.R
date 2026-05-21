# =============================================================================
# PROJECT 7 — Coercive Portfolio Characterization
# Secretaría de Hacienda Distrital — Bogotá, Colombia
# =============================================================================
# PHASE 2 — VISUALIZATIONS (Base R only)
# Script: 03_visualizations_CARTERA_MAR_26.R
# Author: [Your name]
# Date:   March 2026
# =============================================================================

df <- readRDS("CARTERA_MAR_26_LIMPIA.rds")

# Output folder for plots
dir.create("plots", showWarnings = FALSE)

# Shared color palette
COL_MAIN  <- "#1a5276"   # dark blue
COL_ACC   <- "#e74c3c"   # red accent
COL_WARN  <- "#f39c12"   # amber warning
COL_OK    <- "#27ae60"   # green
COL_LIGHT <- "#d6eaf8"   # light blue
PALETTE   <- c("#1a5276","#2980b9","#27ae60","#f39c12",
               "#e74c3c","#8e44ad","#16a085","#d35400","#2c3e50")

# Helper: format billions COP
bil <- function(x) paste0("$", round(x / 1e12, 2), "T")
mil <- function(x) paste0("$", round(x / 1e6, 1), "M")


# =============================================================================
# PLOT 1 — Portfolio value by tax type (horizontal bar)
# =============================================================================
imp_valor <- aggregate(DEUDA_TOTAL ~ NOMBRE_IMPUESTO, data = df, FUN = sum)
imp_valor <- imp_valor[order(imp_valor$DEUDA_TOTAL), ]
imp_valor$DEUDA_BILL <- imp_valor$DEUDA_TOTAL / 1e12

png("plots/01_portfolio_by_tax.png", width = 900, height = 550, res = 110)
par(mar = c(5, 9, 4, 3), bg = "white")
bars <- barplot(
  imp_valor$DEUDA_BILL,
  names.arg = imp_valor$NOMBRE_IMPUESTO,
  horiz     = TRUE,
  las       = 1,
  col       = colorRampPalette(c(COL_LIGHT, COL_MAIN))(nrow(imp_valor)),
  border    = NA,
  xlab      = "Total Debt (Trillion COP)",
  main      = "Portfolio Value by Tax Type",
  cex.names = 0.85,
  cex.axis  = 0.8
)
text(
  x   = imp_valor$DEUDA_BILL + max(imp_valor$DEUDA_BILL) * 0.01,
  y   = bars,
  labels = paste0("$", round(imp_valor$DEUDA_BILL, 2), "T"),
  cex = 0.75, adj = 0, col = "gray30"
)
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 4, cex = 0.65, col = "gray50")
dev.off()
cat("✔ Plot 1 saved: plots/01_portfolio_by_tax.png\n")


# =============================================================================
# PLOT 2 — Cases vs Value by tax (bubble / lollipop comparison)
# =============================================================================
imp_count <- aggregate(ID_CARTERA ~ NOMBRE_IMPUESTO, data = df, FUN = length)
names(imp_count)[2] <- "N"
imp_both  <- merge(imp_valor[, c("NOMBRE_IMPUESTO","DEUDA_TOTAL")], imp_count)
imp_both$PCT_CASOS <- imp_both$N / sum(imp_both$N) * 100
imp_both$PCT_VALOR <- imp_both$DEUDA_TOTAL / sum(imp_both$DEUDA_TOTAL) * 100
imp_both  <- imp_both[order(-imp_both$PCT_VALOR), ]

png("plots/02_cases_vs_value_by_tax.png", width = 950, height = 580, res = 110)
par(mar = c(6, 5, 4, 2), bg = "white")
x   <- seq_len(nrow(imp_both))
gap <- 0.25
plot(NULL, xlim = c(0.5, nrow(imp_both) + 0.5),
     ylim = c(0, max(imp_both$PCT_CASOS, imp_both$PCT_VALOR) * 1.15),
     xaxt = "n", xlab = "", ylab = "Share (%)",
     main = "Cases vs Value Share by Tax Type")
segments(x - gap, 0, x - gap, imp_both$PCT_CASOS, col = COL_MAIN,  lwd = 3)
segments(x + gap, 0, x + gap, imp_both$PCT_VALOR, col = COL_ACC,   lwd = 3)
points(x - gap, imp_both$PCT_CASOS, pch = 21, bg = COL_MAIN,  col = "white", cex = 1.8)
points(x + gap, imp_both$PCT_VALOR, pch = 21, bg = COL_ACC,   col = "white", cex = 1.8)
axis(1, at = x, labels = imp_both$NOMBRE_IMPUESTO, las = 2, cex.axis = 0.78)
legend("topright", legend = c("% Cases", "% Value"),
       col = c(COL_MAIN, COL_ACC), lwd = 3, pch = 21,
       pt.bg = c(COL_MAIN, COL_ACC), bty = "n", cex = 0.85)
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 5, cex = 0.65, col = "gray50")
dev.off()
cat("✔ Plot 2 saved: plots/02_cases_vs_value_by_tax.png\n")


# =============================================================================
# PLOT 3 — Pareto curve: debtors vs cumulative value
# =============================================================================
deudor_total <- aggregate(DEUDA_TOTAL ~ NRO_ID_ANON, data = df, FUN = sum)
deudor_total <- deudor_total[order(-deudor_total$DEUDA_TOTAL), ]
deudor_total$ACUM_PCT_VALOR    <- cumsum(deudor_total$DEUDA_TOTAL) /
                                    sum(deudor_total$DEUDA_TOTAL) * 100
deudor_total$ACUM_PCT_DEUDORES <- seq_len(nrow(deudor_total)) /
                                    nrow(deudor_total) * 100

# Sample for plotting (too many points)
idx    <- unique(c(seq(1, nrow(deudor_total), length.out = 2000),
                   nrow(deudor_total)))
pareto <- deudor_total[idx, ]

png("plots/03_pareto_debtors_value.png", width = 900, height = 560, res = 110)
par(mar = c(5, 5, 4, 2), bg = "white")
plot(pareto$ACUM_PCT_DEUDORES, pareto$ACUM_PCT_VALOR,
     type = "l", lwd = 2.5, col = COL_MAIN,
     xlab = "Cumulative % of Debtors",
     ylab = "Cumulative % of Portfolio Value",
     main = "Pareto Curve — Debtors vs Portfolio Value",
     xlim = c(0, 100), ylim = c(0, 100))
# 80/20 reference lines
abline(h = 80, lty = 2, col = COL_ACC,  lwd = 1.5)
abline(v = 3.1, lty = 2, col = COL_ACC, lwd = 1.5)
abline(a = 0, b = 1, lty = 3, col = "gray70")  # equality line
text(5,  83, "80% of value", col = COL_ACC, cex = 0.78, adj = 0)
text(3.5, 10, "3.1% of debtors\n(35,595)", col = COL_ACC, cex = 0.75, adj = 0)
legend("bottomright",
       legend = c("Lorenz curve", "80/20 reference", "Perfect equality"),
       col    = c(COL_MAIN, COL_ACC, "gray70"),
       lty    = c(1, 2, 3), lwd = c(2.5, 1.5, 1),
       bty    = "n", cex = 0.8)
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 4, cex = 0.65, col = "gray50")
dev.off()
cat("✔ Plot 3 saved: plots/03_pareto_debtors_value.png\n")


# =============================================================================
# PLOT 4 — Portfolio value by vintage year (area/bar)
# =============================================================================
vig_valor <- aggregate(DEUDA_TOTAL ~ VIGENCIA, data = df, FUN = sum)
vig_valor <- vig_valor[!is.na(vig_valor$VIGENCIA) & vig_valor$VIGENCIA >= 1990, ]
vig_valor <- vig_valor[order(vig_valor$VIGENCIA), ]
vig_valor$DEUDA_BILL <- vig_valor$DEUDA_TOTAL / 1e12

png("plots/04_portfolio_by_vintage.png", width = 1000, height = 560, res = 110)
par(mar = c(5, 5, 4, 2), bg = "white")
bar_cols <- ifelse(vig_valor$VIGENCIA >= 2020, COL_ACC, COL_MAIN)
barplot(
  vig_valor$DEUDA_BILL,
  names.arg = vig_valor$VIGENCIA,
  col       = bar_cols,
  border    = NA,
  las       = 2,
  cex.names = 0.7,
  xlab      = "Vintage Year",
  ylab      = "Total Debt (Trillion COP)",
  main      = "Portfolio Value by Vintage Year"
)
legend("topleft",
       legend = c("Before 2020", "2020 onwards (post-pandemic)"),
       fill   = c(COL_MAIN, COL_ACC), border = NA, bty = "n", cex = 0.82)
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 4, cex = 0.65, col = "gray50")
dev.off()
cat("✔ Plot 4 saved: plots/04_portfolio_by_vintage.png\n")


# =============================================================================
# PLOT 5 — Age buckets: cases and value
# =============================================================================
df$BUCKET_EDAD <- cut(
  df$ANTIGUEDAD_ANIOS,
  breaks = c(-Inf, 1, 3, 5, 10, 15, Inf),
  labels = c("0-1y\n(Current)", "1-3y\n(Recent)", "3-5y\n(Medium)",
             "5-10y\n(Old)", "10-15y\n(Very old)", "15y+\n(Critical)"),
  right  = TRUE
)
bucket_n <- table(df$BUCKET_EDAD)
bucket_v <- tapply(df$DEUDA_TOTAL, df$BUCKET_EDAD, sum, na.rm = TRUE)
bucket_pct_v <- bucket_v / sum(bucket_v) * 100

png("plots/05_portfolio_age_buckets.png", width = 950, height = 560, res = 110)
par(mfrow = c(1, 2), mar = c(6, 4, 3, 1), bg = "white")
# Left: cases
barplot(as.numeric(bucket_n) / 1000,
        names.arg = names(bucket_n),
        col       = colorRampPalette(c(COL_OK, COL_WARN, COL_ACC))(6),
        border    = NA, las = 1, cex.names = 0.72,
        ylab      = "Cases (thousands)",
        main      = "Cases by Age Bucket")
# Right: value
barplot(as.numeric(bucket_pct_v),
        names.arg = names(bucket_v),
        col       = colorRampPalette(c(COL_OK, COL_WARN, COL_ACC))(6),
        border    = NA, las = 1, cex.names = 0.72,
        ylab      = "Share of Total Value (%)",
        main      = "Value Share by Age Bucket")
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 5, cex = 0.62, col = "gray50", outer = TRUE)
dev.off()
cat("✔ Plot 5 saved: plots/05_portfolio_age_buckets.png\n")


# =============================================================================
# PLOT 6 — Process funnel (MP → FP → IFP)
# =============================================================================
total   <- nrow(df)
con_mp  <- sum(df$TIENE_MP  == 1, na.rm = TRUE)
sin_mp  <- sum(df$TIENE_MP  == 0, na.rm = TRUE)
con_fp  <- sum(df$TIENE_FP  == 1, na.rm = TRUE)
con_ifp <- sum(df$TIENE_IFP == 1, na.rm = TRUE)

etapas_n   <- c(total, con_mp, con_fp, con_ifp)
etapas_lbl <- c("Total\nPortfolio", "Payment\nOrder (MP)",
                "First\nRuling (FP)", "Second\nRuling (IFP)")
etapas_pct <- round(etapas_n / total * 100, 1)

png("plots/06_process_funnel.png", width = 900, height = 520, res = 110)
par(mar = c(5, 5, 4, 2), bg = "white")
cols_funnel <- c(COL_MAIN, COL_WARN, COL_ACC, "#8e44ad")
bp <- barplot(
  etapas_n / 1e6,
  names.arg = etapas_lbl,
  col       = cols_funnel,
  border    = NA,
  ylab      = "Cases (millions)",
  main      = "Coercive Collection Process Funnel",
  ylim      = c(0, max(etapas_n / 1e6) * 1.18),
  cex.names = 0.82
)
text(bp, etapas_n / 1e6 + max(etapas_n / 1e6) * 0.03,
     labels = paste0(format(etapas_n, big.mark = ","), "\n(", etapas_pct, "%)"),
     cex = 0.75, col = "gray25")
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 4, cex = 0.65, col = "gray50")
dev.off()
cat("✔ Plot 6 saved: plots/06_process_funnel.png\n")


# =============================================================================
# PLOT 7 — Natural vs Juridico: cases and value (donut-style pie)
# =============================================================================
tipo_n <- table(df$TIPO_DEUDOR)
tipo_v <- tapply(df$DEUDA_TOTAL, df$TIPO_DEUDOR, sum, na.rm = TRUE)

png("plots/07_natural_vs_juridico.png", width = 900, height = 480, res = 110)
par(mfrow = c(1, 2), mar = c(2, 2, 3, 2), bg = "white")
pie(tipo_n,
    labels = paste0(names(tipo_n), "\n",
                    format(as.integer(tipo_n), big.mark = ","), " cases\n(",
                    round(tipo_n / sum(tipo_n) * 100, 1), "%)"),
    col    = c(COL_MAIN, COL_ACC),
    border = "white",
    main   = "Cases by Debtor Type",
    cex    = 0.82)
pie(tipo_v,
    labels = paste0(names(tipo_v), "\n",
                    bil(tipo_v), "\n(",
                    round(tipo_v / sum(tipo_v) * 100, 1), "%)"),
    col    = c(COL_MAIN, COL_ACC),
    border = "white",
    main   = "Value by Debtor Type",
    cex    = 0.82)
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 0, cex = 0.65, col = "gray50", outer = TRUE)
dev.off()
cat("✔ Plot 7 saved: plots/07_natural_vs_juridico.png\n")


# =============================================================================
# PLOT 8 — Debt tranche distribution
# =============================================================================
tramo_n <- table(df$TRAMO_DEUDA)
tramo_v <- tapply(df$DEUDA_TOTAL, df$TRAMO_DEUDA, sum, na.rm = TRUE)
tramo_pct_v <- tramo_v / sum(tramo_v) * 100

png("plots/08_debt_tranches.png", width = 950, height = 560, res = 110)
par(mfrow = c(1, 2), mar = c(6, 4, 3, 1), bg = "white")
cols_tramo <- colorRampPalette(c(COL_LIGHT, COL_MAIN))(6)
barplot(as.numeric(tramo_n) / 1000,
        names.arg = names(tramo_n),
        col = cols_tramo, border = NA, las = 2, cex.names = 0.78,
        ylab = "Cases (thousands)", main = "Cases by Debt Tranche")
barplot(as.numeric(tramo_pct_v),
        names.arg = names(tramo_pct_v),
        col = cols_tramo, border = NA, las = 2, cex.names = 0.78,
        ylab = "Share of Total Value (%)", main = "Value Share by Debt Tranche")
mtext("Source: Secretaría de Hacienda Distrital — March 2026",
      side = 1, line = 5, cex = 0.62, col = "gray50", outer = TRUE)
dev.off()
cat("✔ Plot 8 saved: plots/08_debt_tranches.png\n")


# =============================================================================
# SUMMARY
# =============================================================================
cat("\n======================================================\n")
cat("  PHASE 2 COMPLETE — 8 plots saved in /plots\n")
cat("======================================================\n")
cat("  01_portfolio_by_tax.png\n")
cat("  02_cases_vs_value_by_tax.png\n")
cat("  03_pareto_debtors_value.png\n")
cat("  04_portfolio_by_vintage.png\n")
cat("  05_portfolio_age_buckets.png\n")
cat("  06_process_funnel.png\n")
cat("  07_natural_vs_juridico.png\n")
cat("  08_debt_tranches.png\n")
cat("\n  Next step: PHASE 3 — Dashboard (Power BI)\n")
cat("======================================================\n")
