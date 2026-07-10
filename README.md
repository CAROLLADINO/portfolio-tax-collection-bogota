# 📊 Coercive Tax Collection Portfolio — Characterization Analysis
**Secretaría de Hacienda Distrital — Bogotá, Colombia**

![R](https://img.shields.io/badge/Language-R-276DC3?style=flat&logo=r)
![Status](https://img.shields.io/badge/Status-Complete-27ae60?style=flat)
![Data](https://img.shields.io/badge/Records-4.4M-1a5276?style=flat)
![Portfolio](https://img.shields.io/badge/Portfolio-$12.97T COP-e74c3c?style=flat)

---

## 📌 Project Overview

This project performs a full end-to-end characterization of the **coercive tax collection portfolio** of the Secretaría de Hacienda Distrital (Bogotá's District Treasury). The dataset contains **4.4 million records** across 9 tax types, covering debts from 1990 to 2026.

The goal is to understand the structure of the portfolio — who owes, how much, for which taxes, and how far along the legal collection process each case has progressed — in order to support **prioritization decisions** in the specialized collection area.

---

## 🗂️ Repository Structure

```
├── data/                        # Not included (confidential — anonymized internally)
├── scripts/
│   ├── 00_diagnostico_CARTERA_MAR_26.R       # Phase 0A: Initial diagnosis
│   ├── 01_limpieza_anonimizacion.R            # Phase 0B: Cleaning & anonymization
│   ├── 01b_parche_fechas.R                    # Patch: date format correction
│   ├── 02_descriptive_analysis.R              # Phase 1: Descriptive analysis
│   └── 03_visualizations.R                    # Phase 2: Visualizations
├── plots/
│   ├── 01_portfolio_by_tax.png
│   ├── 02_cases_vs_value_by_tax.png
│   ├── 03_pareto_debtors_value.png
│   ├── 04_portfolio_by_vintage.png
│   ├── 05_portfolio_age_buckets.png
│   ├── 06_process_funnel.png
│   ├── 07_natural_vs_juridico.png
│   └── 08_debt_tranches.png
├── outputs/
│   ├── A1_portfolio_by_tax.csv
│   ├── A4_portfolio_by_debtor_type.csv
│   ├── A5_debt_tranches.csv
│   ├── B1_portfolio_by_vintage.csv
│   ├── B2_portfolio_age_buckets.csv
│   ├── B3_prescription_risk_cases.csv
│   ├── C1_process_stage_overview.csv
│   ├── C2_value_by_stage.csv
│   └── C3_mp_rate_by_tax.csv
└── README.md
```

---

## 🔒 Data Privacy & Anonymization

The original dataset contains sensitive taxpayer information. Before any analysis:
- `NOMBRE_CONTRIBUYENTE` (taxpayer name) was **permanently deleted**
- `NRO_ID` (ID number) was **replaced with an anonymous hash** (`NRO_ID_ANON`)
- No personal identifiers are present in any output, CSV, or plot

All scripts are designed to run on the anonymized version only.

---

## 🧹 Data Pipeline

### Phase 0A — Diagnosis
- Assessed 4,463,851 rows × 42 columns
- Identified duplicates, nulls, invalid categories, and date format issues
- No column exceeded 11% null rate (well-structured dataset)

### Phase 0B — Cleaning & Anonymization
| Step | Action | Records affected |
|------|--------|-----------------|
| Anonymization | Hashed NRO_ID, deleted name | All 4.4M |
| Duplicate IDs | Removed all ID_CARTERA duplicates | 33 |
| Invalid tax ID | Removed corrupt ID_IMPUESTO values | 41 |
| Invalid TIPO_ID | Removed empty/zero type codes | 4 |
| Date correction | Fixed format from `%Y-%m-%d` → `%d/%m/%Y` | 11 date columns |
| **Final dataset** | **Clean records ready for analysis** | **4,463,773** |

### Phase 1 — Descriptive Analysis
Three analytical blocks:
- **Block A:** Portfolio value by tax type, Pareto analysis, debtor segmentation
- **Block B:** Portfolio age, vintage distribution, prescription risk
- **Block C:** Legal process stage funnel (payment order → rulings)

### Phase 2 — Visualizations
8 publication-ready plots generated in base R (no external packages).

---

## 📊 Key Findings

### 💰 Portfolio Scale
| Metric | Value |
|--------|-------|
| Total portfolio value | **~$12.97 trillion COP** |
| Clean records | 4,463,773 |
| Unique debtors | 1,157,686 |

---

### 🏦 Finding 1 — Vehicles dominates in volume, but composition matters
Vehicles (ID 2) accounts for **59.3% of records** but Predial (property tax) likely concentrates more value per case given the nature of real estate debts. The lollipop chart (Plot 2) reveals the cases vs value gap across all 9 tax types.

---

### 📐 Finding 2 — Extreme Pareto concentration
> **3.1% of debtors (35,595 out of 1,157,686) concentrate 80% of the total portfolio value.**

This has a direct operational implication: prioritizing collection efforts on this group maximizes recovery per unit of effort. The remaining 96.9% of debtors represent only 20% of the value.

---

### 🕰️ Finding 3 — Portfolio heavily skewed toward post-pandemic vintages
```
2020–2025 vintages → 72.3% of all records
2025 alone         → 23.9% of records (most recent)
Pre-2000           → < 0.1% (historical, preserved for reference)
```
The surge in 2020–2021 vintages reflects the economic impact of COVID-19 on taxpayer compliance.

---

### ⚠️ Finding 4 — 405,287 cases at prescription risk
Nearly **9% of the portfolio** has a prescription date within the next 12 months. If no legal action is taken, this value is permanently lost. Breakdown by tax type available in `B3_prescription_risk_cases.csv`.

---

### ⚖️ Finding 5 — The legal funnel is severely bottlenecked
```
4,463,773   Total portfolio cases         (100%)
  912,580   With payment order issued      (20.4%)
    6,474   With first ruling              ( 0.1%)
    2,534   With second ruling             ( 0.1%)
```
**79.6% of cases have not yet received a payment order (mandamiento de pago)** — representing the largest untapped opportunity for collection action. The funnel narrows dramatically at each legal stage.

---

### 👥 Finding 6 — Natural persons dominate in volume; legal entities likely in value
```
Natural persons:  3,715,353 cases (83.2%)
Legal entities:     748,420 cases (16.8%)
```
While natural persons represent 83% of cases, legal entities (NIT) are expected to concentrate a disproportionate share of the total value — a key segmentation for specialized collection.

---

## 🛠️ Technical Notes

- **Language:** R (base only — no external packages required)
- **Environment:** Restricted corporate network (no package installation)
- **Data format:** Raw `.txt` files by tax type → unified R dataframe → `.rds`
- **Records:** 4,463,851 raw → 4,463,773 after cleaning (0.002% removed)
- **Date handling:** All 11 date columns converted from `dd/mm/yyyy` character to R `Date` class
- **Monetary values:** Colombian Pesos (COP) — no currency conversion applied

---

## 🔜 Next Steps

- [ ] **Project 8:** Scoring model for specialized collection prioritization (ML)
- [ ] **Project 9:** Process efficiency analysis — time between legal stages
- [ ] Power BI dashboard connecting to clean `.rds` output
- [ ] Incorporate additional months for longitudinal comparison

---

## 👤 Author

**[Your Name]**
Data Analyst — Secretaría de Hacienda Distrital, Bogotá
[LinkedIn] · [GitHub]

---

*Data is anonymized. No personal information is present in this repository.*
*Analysis performed on March 2026 snapshot (CARTERA_MAR_26).*

## Completed
- [x] Time series decomposition of monthly collection (36 months) — identified 
      July seasonality driven by property/vehicle tax deadlines, and confirmed 
      a positive underlying trend in collection performance (collection rate 
      increased from 60.32% to 81.72%, December 2022 vs. December 2024).

## Next Steps
- [ ] Project 8: Scoring model for specialized collection prioritization (ML)
- [ ] Project 9: Process efficiency analysis — time between legal stages
- [ ] Power BI dashboard connecting to clean output (`cartera_procesada.csv`)
- [ ] Incorporate additional months for longitudinal comparison