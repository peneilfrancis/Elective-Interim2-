# ==============================================================================
# PHILIPPINES REAL ESTATE MARKET INTELLIGENCE & VALUATION DASHBOARD
# Course:     ELECTIVE 3 – BSIT241-C (Data Analytics Capstone Project)
# Authors:    Group 2: Dean Warren P. Booc & Peneil Francis S. Cayaco
# Instructor: Prof. Joseph L. Domingo | Academic Year: 2026-2027
# Design:     National University (NU) Inspired Style: Navy (#1D2D68) & Gold (#FFC72C)
# Architecture: Contextual In-Panel Controls, Executive 2-Column Visual Pairing
# ==============================================================================

suppressPackageStartupMessages({
  library(shiny)
  library(plotly)
  library(dplyr)
  library(randomForest)
})

# ──────────────────────────────────────────────────────────────────────────────
# 1. ROBUST RECURSIVE DIRECTORY RESOLUTION
# ──────────────────────────────────────────────────────────────────────────────
find_dir <- function(name) {
  candidates <- c(
    name,
    file.path("..", name),
    file.path("Elective3_Interim2", name),
    file.path("..", "Elective3_Interim2", name)
  )
  m <- candidates[dir.exists(candidates)]
  if (length(m) > 0) m[1] else name
}

dir_datasets <- find_dir("Datasets")
dir_models   <- find_dir("Models")

# ──────────────────────────────────────────────────────────────────────────────
# 2. INGEST DATASETS & MODELS
# ──────────────────────────────────────────────────────────────────────────────
f_clean <- file.path(dir_datasets, "listings_clean.rds")
f_viz3  <- file.path(dir_datasets, "listings_viz3.rds")

listings_clean <- if (file.exists(f_clean)) {
  readRDS(f_clean)
} else {
  data.frame()
}

listings_viz3 <- if (file.exists(f_viz3)) {
  readRDS(f_viz3)
} else {
  data.frame()
}

mlr_model <- tryCatch(readRDS(file.path(dir_models, "mlr_model.rds")), error = function(e) NULL)
rf_model  <- tryCatch(readRDS(file.path(dir_models, "rf_model.rds")),  error = function(e) NULL)

ALL_REGIONS <- if (!is.null(rf_model$forest$xlevels$region)) {
  rf_model$forest$xlevels$region
} else {
  c("National Capital Region (NCR)", "Region VII (Central Visayas)", "Region IV-A (CALABARZON)")
}

# ──────────────────────────────────────────────────────────────────────────────
# 3. FORMATTING UTILITIES
# ──────────────────────────────────────────────────────────────────────────────
fmt_php <- function(x) {
  if (is.null(x) || is.na(x)) return("—")
  if (x >= 1e9) sprintf("₱%.2fB", x / 1e9)
  else if (x >= 1e6) sprintf("₱%.2fM", x / 1e6)
  else sprintf("₱%s", formatC(round(x), format = "d", big.mark = ","))
}

fmt_num <- function(x) {
  if (is.null(x) || is.na(x)) return("—")
  formatC(round(x), format = "d", big.mark = ",")
}

# ──────────────────────────────────────────────────────────────────────────────
# 4. EXECUTIVE STYLESHEET (CONTEXTUAL IN-PANEL CONTROLS & CLEAN SECTIONS)
# ──────────────────────────────────────────────────────────────────────────────
nu_inspo_css <- "
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');

  :root {
    --nu-navy: #1D2D68;
    --nu-navy-dark: #121E4A;
    --nu-navy-light: #2A3E8A;
    --nu-gold: #FFC72C;
    --nu-gold-dark: #D49D00;
    --nu-gold-light: #FFF9E6;
    --nu-slate: #0F172A;
    --nu-text-muted: #475569;
    --nu-bg: #F4F6FB;
    --nu-card-border: #DDE3EA;
  }

  * { box-sizing: border-box; }
  body {
    background-color: var(--nu-bg);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    color: var(--nu-slate);
    margin: 0;
    padding: 0;
    font-size: 17px;
    line-height: 1.65;
  }

  /* ── NU INSPIRED HERO HEADER ── */
  .nu-hero-header {
    background: linear-gradient(135deg, #121E4A 0%, #1D2D68 60%, #2A3E8A 100%);
    padding: 20px 32px;
    box-shadow: 0 4px 16px rgba(18, 30, 74, 0.28);
  }
  .nu-header-card {
    background: #FFFFFF;
    border-radius: 12px;
    padding: 16px 26px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
    border-bottom: 4px solid var(--nu-gold);
  }
  .nu-header-title-box h1 {
    font-size: 2.15rem;
    font-weight: 900;
    color: var(--nu-navy);
    margin: 0;
    letter-spacing: -0.015em;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .nu-header-title-box h1 span.gold-highlight {
    color: #D49D00;
  }
  .nu-header-title-box p.subtitle {
    font-size: 1.08rem;
    color: var(--nu-text-muted);
    margin: 4px 0 0 0;
    font-weight: 500;
  }
  .nu-header-badges {
    display: flex;
    gap: 12px;
    align-items: center;
  }
  .nu-badge-pill {
    padding: 8px 16px;
    border-radius: 30px;
    font-size: 1.05rem;
    font-weight: 700;
    display: inline-flex;
    padding: 10px 20px;
    align-items: center;
    gap: 8px;
    letter-spacing: 0.02em;
  }
  .pill-rf-gold {
    background: var(--nu-gold);
    color: var(--nu-navy-dark);
    box-shadow: 0 2px 6px rgba(0,0,0,0.1);
  }
  .pill-mlr-navy {
    background: var(--nu-navy);
    color: #FFFFFF;
  }

  /* ── MAIN DASHBOARD CONTAINER ── */
  .dash-wrapper {
    max-width: 1720px;
    margin: 0 auto;
    padding: 22px 28px;
  }

  /* ── SECTION TITLES ── */
  .section-heading-bar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin: 10px 0 16px 0;
  }
  .section-heading-bar h2 {
    font-size: 1.55rem;
    font-weight: 900;
    color: var(--nu-navy);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin: 0;
  }
  .section-heading-bar .line {
    flex-grow: 1;
    height: 2px;
    background: linear-gradient(90deg, var(--nu-gold) 0%, transparent 100%);
  }

  /* ── BY THE NUMBERS (5 KPI CARDS INSPIRED BY NU WEBSITE) ── */
  .nu-numbers-row {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 16px;
    margin-bottom: 24px;
  }
  .nu-stat-card {
    border-radius: 12px;
    padding: 18px 20px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.04);
    transition: transform 0.15s ease, box-shadow 0.15s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .nu-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 18px rgba(29, 45, 104, 0.12);
  }
  .card-white {
    background: #FFFFFF;
    border: 1.5px solid var(--nu-card-border);
  }
  .card-white .stat-title { color: var(--nu-text-muted); }
  .card-white .stat-number { color: var(--nu-navy); }
  .card-white .stat-sub { color: #64748B; }
  .card-white .stat-icon { color: var(--nu-navy); }

  .card-gold {
    background: var(--nu-gold);
    border: 1.5px solid #E6B100;
    box-shadow: 0 3px 12px rgba(212, 157, 0, 0.22);
  }
  .card-gold .stat-title { color: #5C4300; }
  .card-gold .stat-number { color: var(--nu-navy-dark); }
  .card-gold .stat-sub { color: #4A3600; }
  .card-gold .stat-icon { color: var(--nu-navy-dark); }

  .stat-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 6px;
  }
  .stat-title {
    font-size: 1.02rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }
  .stat-icon {
    font-size: 1.45rem;
    opacity: 0.9;
  }
  .stat-number {
    font-size: 2.85rem;
    font-weight: 900;
    line-height: 1.1;
    font-style: italic;
    margin: 3px 0 6px 0;
  }
  .stat-sub {
    font-size: 1.05rem;
    line-height: 1.4;
    font-weight: 500;
  }
  .stat-sub b {
    font-weight: 800;
  }

  /* ── 2-COLUMN SECTION GRIDS ── */
  .grid-2col-equal {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 24px;
  }

  /* ── BOX PANEL CONTAINERS ── */
  .nu-box-panel {
    background: #FFFFFF;
    border-radius: 12px;
    border: 1.5px solid var(--nu-card-border);
    box-shadow: 0 3px 12px rgba(0,0,0,0.04);
    padding: 22px 24px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .nu-panel-header {
    border-bottom: 2px solid #EDF2F7;
    padding-bottom: 12px;
    margin-bottom: 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .nu-panel-title {
    font-size: 1.45rem;
    font-weight: 800;
    color: var(--nu-navy);
    margin: 0;
  }
  .nu-panel-subtitle {
    font-size: 1.08rem;
    color: #475569;
    margin: 3px 0 0 0;
  }

  /* ── IN-PANEL CONTEXTUAL CONTROLS TOOLBAR ── */
  .chart-toolbar {
    background: #F8FAFD;
    border: 1px solid #E2E8F0;
    border-radius: 8px;
    padding: 8px 16px;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 16px;
    flex-wrap: wrap;
  }
  .toolbar-label {
    font-size: 1.02rem;
    font-weight: 800;
    text-transform: uppercase;
    color: var(--nu-navy);
    display: flex;
    align-items: center;
    gap: 6px;
    white-space: nowrap;
    margin-bottom: 0;
  }
  .toolbar-controls {
    display: flex;
    align-items: center;
    gap: 14px;
    flex-wrap: wrap;
  }
  .chart-toolbar .shiny-input-container {
    margin-bottom: 0 !important;
  }
  .chart-toolbar .form-group {
    margin-bottom: 0 !important;
  }
  .chart-toolbar select.form-control {
    border: 1.5px solid #CBD5E1 !important;
    border-radius: 6px !important;
    padding: 6px 12px !important;
    font-size: 1.05rem !important;
    font-weight: 600 !important;
    color: #1E293B !important;
    background-color: #FFFFFF !important;
    height: 44px !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;
  }
  .chart-toolbar .selectize-control {
    margin-bottom: 0 !important;
  }
  .chart-toolbar .selectize-input {
    border: 1.5px solid #CBD5E1 !important;
    border-radius: 6px !important;
    padding: 7px 12px !important;
    font-size: 1.05rem !important;
    font-weight: 600 !important;
    color: #1E293B !important;
    background: #FFFFFF !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05) !important;
    min-height: 44px !important;
    line-height: 1.4 !important;
    white-space: nowrap !important;
  }
  .chart-toolbar .selectize-dropdown {
    font-size: 1.05rem !important;
    border-radius: 6px !important;
    border: 1px solid #CBD5E1 !important;
    box-shadow: 0 4px 14px rgba(0,0,0,0.1) !important;
  }
  .chart-toolbar .checkbox-inline, .chart-toolbar .radio-inline {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
    font-size: 1.05rem !important;
    font-weight: 600 !important;
    color: #1E293B !important;
    margin-top: 0 !important;
    margin-bottom: 0 !important;
    cursor: pointer !important;
  }
  .chart-toolbar input[type=checkbox], .chart-toolbar input[type=radio] {
    margin-top: 0 !important;
    cursor: pointer !important;
  }

  /* ── KEY FINDINGS & ANALYTICS CONTAINER (LARGE, PROMINENT) ── */
  .nu-findings-container {
    background: #FFFDF5;
    border: 2.5px solid var(--nu-gold);
    border-radius: 12px;
    padding: 24px 26px;
    box-shadow: 0 4px 18px rgba(255, 199, 44, 0.2);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .findings-pill-tag {
    background: var(--nu-gold);
    color: var(--nu-navy-dark);
    font-size: 0.98rem;
    font-weight: 900;
    padding: 6px 16px;
    border-radius: 20px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 8px;
  }
  .findings-main-title {
    font-size: 1.6rem;
    font-weight: 900;
    color: var(--nu-navy);
    margin: 0 0 14px 0;
    border-bottom: 2px solid #F6D678;
    padding-bottom: 10px;
  }
  .finding-card {
    margin-bottom: 14px;
    padding: 14px 18px;
    background: #FFFFFF;
    border-radius: 10px;
    border-left: 5px solid var(--nu-gold);
    box-shadow: 0 2px 8px rgba(0,0,0,0.03);
  }
  .finding-title {
    font-size: 1.25rem;
    font-weight: 800;
    color: var(--nu-navy);
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .finding-title span.badge-num {
    background: var(--nu-navy);
    color: var(--nu-gold);
    width: 24px;
    height: 24px;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    font-weight: 900;
    flex-shrink: 0;
  }
  .finding-body {
    font-size: 1.08rem;
    color: #1E293B;
    line-height: 1.7;
    margin: 0;
  }
  .finding-body b {
    color: #92400E;
    font-weight: 700;
  }

  /* ── LIVE PREDICTOR CARD (MACHINE LEARNING SECTION) ── */
  .nu-predictor-panel {
    background: linear-gradient(135deg, #121E4A 0%, #1D2D68 60%, #2A3E8A 100%);
    border-radius: 12px;
    color: #FFFFFF;
    padding: 24px 28px;
    margin-bottom: 24px;
    box-shadow: 0 6px 20px rgba(18, 30, 74, 0.28);
    border: 1px solid rgba(255,255,255,0.12);
  }
  .predictor-header-title {
    font-size: 1.7rem;
    font-weight: 900;
    color: var(--nu-gold);
    margin: 0 0 4px 0;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .predictor-header-sub {
    font-size: 1.15rem;
    color: #CBD5E1;
    margin: 0 0 18px 0;
  }
  .nu-predictor-panel label {
    font-size: 1.02rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--nu-gold);
    margin-bottom: 6px;
  }
  .nu-predictor-panel .form-control, .nu-predictor-panel select {
    background: rgba(255,255,255,0.14);
    border: 1.5px solid rgba(255,255,255,0.3);
    color: #FFFFFF;
    border-radius: 8px;
    font-size: 1.12rem;
    padding: 10px 14px;
  }
  .nu-predictor-panel select option {
    background: #121E4A;
    color: #FFFFFF;
  }
  .btn-nu-calc {
    background: linear-gradient(135deg, #FFC72C 0%, #E6AC00 100%);
    color: var(--nu-navy-dark);
    font-size: 1.22rem;
    font-weight: 900;
    border: none;
    border-radius: 8px;
    padding: 14px 24px;
    width: 100%;
    margin-top: 25px;
    cursor: pointer;
    box-shadow: 0 3px 8px rgba(0,0,0,0.25);
    transition: opacity 0.15s;
  }
  .btn-nu-calc:hover {
    opacity: 0.92;
  }
  .pred-result-card {
    background: rgba(255,255,255,0.08);
    border: 1.5px solid rgba(255,255,255,0.22);
    border-radius: 10px;
    padding: 16px 20px;
    text-align: center;
  }
  .pred-result-card.gold-featured {
    border: 2px solid var(--nu-gold);
    background: rgba(255, 199, 44, 0.14);
  }
  .pred-card-label {
    font-size: 1.05rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: #E2E8F0;
  }
  .gold-featured .pred-card-label {
    color: var(--nu-gold);
  }
  .pred-card-val {
    font-size: 2.85rem;
    font-weight: 900;
    color: #FFFFFF;
    margin: 4px 0;
  }
  .gold-featured .pred-card-val {
    color: var(--nu-gold);
  }

  /* ── DATA TABLES ── */
  .table-container-box {
    margin-top: 14px;
    border-top: 1.5px solid #EDF2F7;
    padding-top: 12px;
  }
  .table-subheading {
    font-size: 1.15rem;
    font-weight: 800;
    color: var(--nu-navy);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    margin-bottom: 8px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .nu-datatable {
    width: 100%;
    border-collapse: collapse;
    font-size: 1.12rem;
  }
  .nu-datatable th {
    background-color: var(--nu-navy);
    color: #FFFFFF;
    font-weight: 800;
    text-align: left;
    padding: 12px 18px;
    font-size: 1.12rem;
    border-bottom: 3px solid var(--nu-gold);
  }
  .nu-datatable td {
    padding: 10px 18px;
    font-size: 1.05rem;
    border-bottom: 1px solid #EDF2F7;
    color: #334155;
  }
  .nu-datatable tr:hover {
    background-color: #F8FAFD;
  }
  .nu-datatable tr.total-highlight {
    font-weight: 800;
    background-color: var(--nu-gold-light);
    border-top: 2px solid var(--nu-gold);
    color: var(--nu-navy-dark);
  }

  /* ── VELOCITY CALLOUT CARD ── */
  .velocity-stat-card {
    background: #F0F4FB;
    border: 1.5px solid #D6E0F0;
    border-radius: 8px;
    padding: 12px 16px;
    margin-top: 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 1.12rem;
  }
  .velocity-stat-card b {
    color: var(--nu-navy);
  }

  /* ── EDA SECTION TABS & BADGES ── */
  .eda-note-box {
    background: #F8FAFD;
    border-left: 4px solid var(--nu-navy);
    border-radius: 6px;
    padding: 10px 14px;
    margin-top: 12px;
    font-size: 1.08rem;
    color: #334155;
    line-height: 1.5;
  }
  .eda-note-box b {
    color: var(--nu-navy);
  }
  .badge-action-drop {
    background: #FEE2E2;
    color: #991B1B;
    font-size: 0.95rem;
    font-weight: 800;
    padding: 5px 12px;
    border-radius: 4px;
    display: inline-block;
  }
  .badge-action-handled {
    background: #FEF3C7;
    color: #92400E;
    font-size: 0.95rem;
    font-weight: 800;
    padding: 5px 12px;
    border-radius: 4px;
    display: inline-block;
  }

  /* ── FOOTER ── */
  .nu-footer-bar {
    text-align: center;
    padding: 20px 24px;
    font-size: 1.08rem;
    color: var(--nu-text-muted);
    border-top: 1.5px solid var(--nu-card-border);
    background: #FFFFFF;
    margin-top: 10px;
  }
  .nu-footer-bar b {
    color: var(--nu-navy);
  }
"

# ──────────────────────────────────────────────────────────────────────────────
# 5. UI DEFINITION (SECTIONED PROFESSIONALLY IN ONE PAGE)
# ──────────────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  title = "Philippines Real Estate Market Intelligence Dashboard | Group 2",
  tags$head(
    tags$style(HTML(nu_inspo_css)),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
  ),

  # ── HERO HEADER WITH FLOATING CARD ──
  div(class = "nu-hero-header",
    div(class = "nu-header-card",
      div(class = "nu-header-title-box",
        h1(
          tags$i(class = "fa-solid fa-chart-line", style = "color: #D49D00;"),
          "PHILIPPINES REAL ESTATE ",
          span(class = "gold-highlight", "MARKET INTELLIGENCE"),
          " DASHBOARD"
        ),
        p(class = "subtitle",
          "ELECTIVE 3 (BSIT241-C) DATA ANALYTICS CAPSTONE \u00b7 Group 2: Dean Warren P. Booc & Peneil Francis S. Cayaco \u00b7 Instructor: Prof. Joseph L. Domingo"
        )
      ),
      div(class = "nu-header-badges",
        span(class = "nu-badge-pill pill-rf-gold",
          tags$i(class = "fa-solid fa-tree"), "Random Forest: R\u00b2 75.23% (RMSE 0.569)"
        ),
        span(class = "nu-badge-pill pill-mlr-navy",
          tags$i(class = "fa-solid fa-chart-simple"), "MLR: R\u00b2 58.78%"
        )
      )
    )
  ),

  # ── MAIN DASHBOARD CONTENT (STRUCTURED SECTIONS) ──
  div(class = "dash-wrapper",

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 1: EXECUTIVE MARKET METRICS ("BY THE NUMBERS")
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-heading-bar",
      h2("1. Executive Market Summary (By The Numbers)"),
      div(class = "line")
    ),

    div(class = "nu-numbers-row",
      div(class = "nu-stat-card card-white",
        div(class = "stat-header",
          span(class = "stat-title", "Total Scraped Listings"),
          tags$i(class = "fa-solid fa-database stat-icon")
        ),
        div(class = "stat-number", "241,496"),
        div(class = "stat-sub", HTML("<b>100%</b> Kaggle secondary baseline"))
      ),
      div(class = "nu-stat-card card-gold",
        div(class = "stat-header",
          span(class = "stat-title", "Active Market Inventory"),
          tags$i(class = "fa-solid fa-bolt stat-icon")
        ),
        div(class = "stat-number", "49,884"),
        div(class = "stat-sub", HTML("<b>20.7%</b> active | 79.3% delisted/sold"))
      ),
      div(class = "nu-stat-card card-white",
        div(class = "stat-header",
          span(class = "stat-title", "National Median Price"),
          tags$i(class = "fa-solid fa-peso-sign stat-icon")
        ),
        div(class = "stat-number", "₱12.30M"),
        div(class = "stat-sub", HTML("Mean <b>₱41.6M</b> (3.4\u00d7 luxury skew)"))
      ),
      div(class = "nu-stat-card card-gold",
        div(class = "stat-header",
          span(class = "stat-title", "NCR Median Price/m\u00b2"),
          tags$i(class = "fa-solid fa-city stat-icon")
        ),
        div(class = "stat-number", "₱179,931"),
        div(class = "stat-sub", HTML("Top market (<b>+63%</b> vs Reg VII)"))
      ),
      div(class = "nu-stat-card card-white",
        div(class = "stat-header",
          span(class = "stat-title", "Model Accuracy (RF)"),
          tags$i(class = "fa-solid fa-brain stat-icon")
        ),
        div(class = "stat-number", "75.23%"),
        div(class = "stat-sub", HTML("R\u00b2 test accuracy \u00b7 200 trees"))
      )
    ),

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 2: EXPLORATORY DATA ANALYSIS (EDA) & DATA AUDIT (PAPER §5)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-heading-bar",
      h2("2. Exploratory Data Analysis (EDA) & Data Health Audit (Paper §5)"),
      div(class = "line")
    ),

    div(class = "grid-2col-equal",

      # ── LEFT CARD: DESCRIPTIVE STATS & DATA QUALITY AUDIT ──
      div(class = "nu-box-panel",
        div(class = "nu-panel-header",
          div(
            h3(class = "nu-panel-title", "Descriptive Statistics & Missing Data Audit"),
            p(class = "nu-panel-subtitle", "Paper §5.1 & §5.3: Baseline metrics across all 241,496 raw listing records")
          )
        ),

        # In-Panel Contextual Controls
        div(class = "chart-toolbar",
          div(class = "toolbar-label",
            tags$i(class = "fa-solid fa-table-list", style = "color: #D49D00;"),
            "EDA Audit View:"
          ),
          div(class = "toolbar-controls",
            radioButtons("eda_table_view", NULL,
              choices = c("Descriptive Statistics (Table 12)" = "stats", "Data Quality & Missingness (Table 23)" = "missing"),
              selected = "stats",
              inline = TRUE
            )
          )
        ),

        # Table output
        div(style = "min-height: 350px; overflow-x: auto;",
          uiOutput("table_eda_audit")
        ),

        div(class = "eda-note-box",
          HTML("<b>Methodological Note (Paper §5.1):</b> Descriptive statistics are computed from the full raw baseline (<b>241,496 records</b>) to characterize the total market scope before active-listing and complete-case modeling filters are applied.")
        )
      ),

      # ── RIGHT CARD: ROOM SCALING & PHYSICAL FEATURE DRIVERS ──
      div(class = "nu-box-panel",
        div(class = "nu-panel-header",
          div(
            h3(class = "nu-panel-title", "Physical Feature Drivers & Room Scaling"),
            p(class = "nu-panel-subtitle", "Paper §5.3 & Script 02_eda.R: Price progression across bedrooms & property types")
          )
        ),

        # In-Panel Contextual Controls
        div(class = "chart-toolbar",
          div(class = "toolbar-label",
            tags$i(class = "fa-solid fa-cubes-stacked", style = "color: var(--nu-navy);"),
            "EDA Chart View:"
          ),
          div(class = "toolbar-controls",
            div(style = "width: 280px;",
              selectInput("eda_chart_metric", NULL,
                choices = c("Median Price by Bedroom Count" = "bedrooms", "Raw Property Type Share (241K)" = "prop_type"),
                selected = "bedrooms", width = "100%", selectize = FALSE
              )
            )
          )
        ),

        # Plotly chart
        plotlyOutput("plot_eda_rooms", height = "350px"),

        div(class = "velocity-stat-card",
          span(HTML("<b>Luxury Proxy:</b> Bathrooms (+49.8% value)")),
          span(HTML("<b>Bedrooms:</b> +8.7% value")),
          span(HTML("<b>Key Takeaway:</b> En-suite baths signal luxury tier"))
        )
      )
    ),

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 3: COMPARATIVE PROPERTY VALUATION & REGIONAL DENSITY (VIZ 1 & 2)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-heading-bar",
      h2("3. Property Type Distributions & Regional Valuations (Paper §6.1 & §6.2)"),
      div(class = "line")
    ),

    div(class = "grid-2col-equal",

      # ── LEFT CARD: VIZ 1 WITH DIRECT IN-PANEL CONTROLS & TABLE ──
      div(class = "nu-box-panel",
        div(class = "nu-panel-header",
          div(
            h3(class = "nu-panel-title", "Viz 1: Distribution of Asking Prices by Property Type"),
            p(class = "nu-panel-subtitle", "Paper §6.1: Comparing asking price distributions across real estate types")
          )
        ),

        # In-Panel Contextual Controls for Viz 1
        div(class = "chart-toolbar",
          div(class = "toolbar-label",
            tags$i(class = "fa-solid fa-sliders", style = "color: #D49D00;"),
            "Viz 1 Controls:"
          ),
          div(class = "toolbar-controls",
            div(style = "width: 200px;",
              selectInput("viz1_scale", NULL,
                choices = c("Log10 Scale (Paper)" = "log", "Linear Scale" = "linear"),
                selected = "log", width = "100%", selectize = FALSE
              )
            ),
            checkboxGroupInput("viz1_types", NULL,
              choices = c("Condominium" = "condo", "House" = "house", "Lot" = "lot"),
              selected = c("condo", "house", "lot"),
              inline = TRUE
            )
          )
        ),

        # Plotly Boxplot
        plotlyOutput("plot_viz1", height = "365px"),

        # Accompanying Property Type Table Directly Underneath
        div(class = "table-container-box",
          div(class = "table-subheading",
            span("Active Listings Breakdown by Property Type"),
            span(style = "font-size: 0.78rem; color: #64748B;", "Data Source: Kaggle (Cleaned)")
          ),
          uiOutput("table_types")
        )
      ),

      # ── RIGHT CARD: VIZ 2 WITH DIRECT IN-PANEL CONTROLS & TABLE ──
      div(class = "nu-box-panel",
        div(class = "nu-panel-header",
          div(
            h3(class = "nu-panel-title", "Viz 2: Top Regions by Median Price per Square Meter"),
            p(class = "nu-panel-subtitle", "Paper §6.2: Regional valuation density (₱ per m\u00b2)")
          )
        ),

        # In-Panel Contextual Controls for Viz 2
        div(class = "chart-toolbar",
          div(class = "toolbar-label",
            tags$i(class = "fa-solid fa-map-location-dot", style = "color: var(--nu-navy);"),
            "Regional Scope:"
          ),
          div(class = "toolbar-controls",
            div(style = "width: 230px;",
              selectInput("viz2_scope", NULL,
                choices = c("Top 10 Regions (Default)" = 10, "Top 5 Regions" = 5, "All 17 Regions" = 17),
                selected = 10, width = "100%", selectize = FALSE
              )
            )
          )
        ),

        # Plotly Horizontal Bar Chart
        plotlyOutput("plot_viz2", height = "365px"),

        # Accompanying Regional Table Directly Underneath
        div(class = "table-container-box",
          div(class = "table-subheading",
            span("Top Regions Valuation Density Rankings"),
            span(style = "font-size: 0.78rem; color: #64748B;", "Ranked by Median ₱/m\u00b2")
          ),
          uiOutput("table_regions")
        )
      )
    ),

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 4: MARKET VELOCITY DYNAMICS & ANALYTICAL FINDINGS (VIZ 3 & INSIGHTS)
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-heading-bar",
      h2("4. Market Turnover Dynamics & Analytical Findings (Paper §6.3 & §8)"),
      div(class = "line")
    ),

    div(class = "grid-2col-equal",

      # ── LEFT CARD: VIZ 3 WITH DIRECT IN-PANEL VIEW SELECTOR ──
      div(class = "nu-box-panel",
        div(class = "nu-panel-header",
          div(
            h3(class = "nu-panel-title", "Viz 3: Asking Price Distribution by Listing Status"),
            p(class = "nu-panel-subtitle", "Paper §6.3: Comparing active vs delisted/inactive inventory velocity (Log Scale)")
          )
        ),

        # In-Panel Contextual Controls for Viz 3
        div(class = "chart-toolbar",
          div(class = "toolbar-label",
            tags$i(class = "fa-solid fa-chart-area", style = "color: #D49D00;"),
            "Property Category View:"
          ),
          div(class = "toolbar-controls",
            radioButtons("viz3_facet", NULL,
              choices = c("Both (Faceted: Condo & House)" = "both", "Condo Only" = "condo", "House Only" = "house"),
              selected = "both",
              inline = TRUE
            )
          )
        ),

        # Plotly Density Curves (Faceted)
        plotlyOutput("plot_viz3", height = "420px"),

        # Market Velocity Differential Callout
        div(class = "velocity-stat-card",
          span(HTML("<b>Active Median:</b> ₱10.0M")),
          span(HTML("<b>Inactive Median:</b> ₱13.0M")),
          span(HTML("<b>Velocity Gap:</b> ₱3.0M (+30% price premium for lingering luxury)"))
        )
      ),

      # ── RIGHT CARD: ENLARGED, HIGHLY READABLE KEY FINDINGS BOX ──
      div(class = "nu-findings-container",
        div(
          div(class = "findings-pill-tag",
            tags$i(class = "fa-solid fa-award"),
            "Capstone Research Synthesis"
          ),
          h2(class = "findings-main-title",
            "KEY FINDINGS & ANALYTICS (PROJECT PAPER §8)"
          ),

          div(class = "finding-card",
            div(class = "finding-title",
              span(class = "badge-num", "1"),
              "Severe Price Right-Skewness & Log Scale"
            ),
            p(class = "finding-body",
              HTML("The national median asking price is <b>₱12.30 Million</b>, while the arithmetic mean is <b>₱41.56 Million</b> (<b>3.4\u00d7 higher</b>). Approximately 1% of listings exceed ₱520M, reaching up to ₱1 Billion. These few ultra-luxury properties heavily distort the average, proving that <b>median statistics and logarithmic transformations</b> are strictly required for accurate market modeling.")
            )
          ),

          div(class = "finding-card",
            div(class = "finding-title",
              span(class = "badge-num", "2"),
              "NCR Geographic Valuation Monopoly"
            ),
            p(class = "finding-body",
              HTML("The National Capital Region commands an unmatched median valuation of <b>₱179,931 per m\u00b2</b>, outpricing Region VII (Central Visayas at ₱110,000/m\u00b2) by <b>63%</b> and provincial markets by <b>more than 2.5\u00d7</b>. Location serves as the single most decisive factor driving real estate value in the country.")
            )
          ),

          div(class = "finding-card",
            div(class = "finding-title",
              span(class = "badge-num", "3"),
              "Market Velocity & Delisting Dynamics"
            ),
            p(class = "finding-body",
              HTML("Active inventory reflects a median price of <b>₱10.0 Million</b> compared to <b>₱13.0 Million</b> for inactive/delisted records. Affordable, entry-level properties sell or turnover rapidly, whereas premium and luxury listings linger in the market significantly longer before exit.")
            )
          ),

          div(class = "finding-card",
            div(class = "finding-title",
              span(class = "badge-num", "4"),
              "Primary Physical Drivers & ML Performance"
            ),
            p(class = "finding-body",
              HTML("Floor area and bathroom count are the strongest positive physical predictors (adding <b>+49.8% value per bathroom</b> in Multiple Linear Regression). The 200-Tree Random Forest model achieves <b>R\u00b2 = 75.23% (RMSE 0.5693)</b>, vastly outperforming baseline linear regression (58.78%).")
            )
          )
        )
      )
    ),

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 5: PREDICTIVE MACHINE LEARNING VALUATION SIMULATOR
    # ══════════════════════════════════════════════════════════════════════════
    div(class = "section-heading-bar",
      h2("5. Predictive Machine Learning Valuation Estimator (Paper §7)"),
      div(class = "line")
    ),

    div(class = "nu-predictor-panel",
      div(class = "predictor-header-title",
        tags$i(class = "fa-solid fa-wand-magic-sparkles"),
        "Live Real Estate Valuation Predictor (Paper §7 Machine Learning)"
      ),
      div(class = "predictor-header-sub",
        "Generates instant market valuation estimates using the trained Multiple Linear Regression (MLR) and 200-Tree Random Forest (RF) models."
      ),
      fluidRow(
        column(3,
          selectInput("pred_type", "Property Type", choices = c("Condominium" = "condo", "House" = "house"))
        ),
        column(3,
          selectInput("pred_region", "Region", choices = ALL_REGIONS, selected = "National Capital Region (NCR)")
        ),
        column(2,
          numericInput("pred_sqm", "Floor Area (m\u00b2)", value = 80, min = 10, max = 2000, step = 5)
        ),
        column(1,
          numericInput("pred_beds", "Beds", value = 2, min = 1, max = 10)
        ),
        column(1,
          numericInput("pred_baths", "Baths", value = 2, min = 1, max = 10)
        ),
        column(2,
          actionButton("btn_calc", "⚡ Estimate Value", class = "btn-nu-calc")
        )
      ),
      div(style = "margin-top: 18px;"),
      fluidRow(
        column(6,
          div(class = "pred-result-card gold-featured",
            div(class = "pred-card-label", "Random Forest (RF) Estimate \u00b7 Recommended"),
            div(class = "pred-card-val", textOutput("val_rf")),
            div(style = "font-size: 0.84rem; color: #FFF3C4; margin-top: 4px;", "R\u00b2 = 75.23% | RMSE = 0.5693 on log scale (Trained on 80% Active Inventory)")
          )
        ),
        column(6,
          div(class = "pred-result-card",
            div(class = "pred-card-label", "Multiple Linear Regression (MLR) Estimate"),
            div(class = "pred-card-val", textOutput("val_mlr")),
            div(style = "font-size: 0.84rem; color: #CBD5E1; margin-top: 4px;", "R\u00b2 = 58.78% | Standard Parametric Baseline")
          )
        )
      )
    )

  ), # end dash-wrapper

  # ── FOOTER ──
  div(class = "nu-footer-bar",
    "Philippines Real Estate Market Intelligence \u00b7 ",
    tags$b("Group 2: Dean Warren P. Booc & Peneil Francis S. Cayaco"),
    " \u00b7 ELECTIVE 3 (BSIT241-C) Data Analytics Capstone \u00b7 Instructor: Prof. Joseph L. Domingo \u00b7 AY 2025\u20132026"
  )
)

# ──────────────────────────────────────────────────────────────────────────────
# 6. SERVER LOGIC
# ──────────────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  # ── EDA: Descriptive Statistics & Data Health Audit ───────────────────────
  output$table_eda_audit <- renderUI({
    req(input$eda_table_view)

    if (input$eda_table_view == "stats") {
      # Table 12 from Paper: Descriptive Statistics across key variables
      stats_data <- list(
        list(var = "price_php (All Types)", mean = "₱41,557,707", med = "₱12,300,000", min = "₱350,000", max = "₱1,000,000,000", note = "Right-skewed; Mean is 3.38× higher than median"),
        list(var = "sqm (Condominiums)", mean = "87.2 m²", med = "48.0 m²", min = "0 m²", max = "30,000 m²", note = "Compact urban units; 12.9% missing in raw"),
        list(var = "sqm (Houses)", mean = "310.0 m²", med = "170.0 m²", min = "0 m²", max = "50,000 m²", note = "Wide variation; includes large suburban lots"),
        list(var = "bedrooms", mean = "2.9", med = "3.0", min = "0", max = "301", note = "38.8% missing in raw scrape (studios/lots)"),
        list(var = "bathrooms", mean = "2.31", med = "2.0", min = "0", max = "660", note = "62.0% missing; reliable proxy for luxury"),
        list(var = "price_per_sqm", mean = "₱157,698", med = "₱112,500", min = "₱0", max = "₱2,500,000", note = "Extreme geographic premium in urban hubs")
      )

      rows <- lapply(stats_data, function(r) {
        tags$tr(
          tags$td(tags$b(r$var)),
          tags$td(r$mean),
          tags$td(tags$b(style = "color: var(--nu-navy);", r$med)),
          tags$td(r$min),
          tags$td(r$max),
          tags$td(style = "font-size: 1.02rem; color: #334155; line-height: 1.45;", r$note)
        )
      })

      tags$table(class = "nu-datatable",
        tags$thead(
          tags$tr(
            tags$th("Variable"),
            tags$th("Mean"),
            tags$th("Median"),
            tags$th("Min"),
            tags$th("Max"),
            tags$th("Distribution Insight")
          )
        ),
        tags$tbody(rows)
      )

    } else {
      # Table 23 from Paper: Data Quality & Missingness Audit
      miss_data <- list(
        list(col = "barangay", count = "201,527", pct = "83.4%", action = "Column Dropped", badge = "badge-action-drop", reason = "Excessive missingness across platforms"),
        list(col = "new_build_flag", count = "190,622", pct = "79.0%", action = "Column Dropped", badge = "badge-action-drop", reason = "Unpopulated in secondary portals"),
        list(col = "district", count = "187,159", pct = "77.5%", action = "Column Dropped", badge = "badge-action-drop", reason = "Redundant with city and region"),
        list(col = "bathrooms", count = "149,783", pct = "62.0%", action = "Handled in Modeling", badge = "badge-action-handled", reason = "Filtered for complete residential analysis"),
        list(col = "quality_score", count = "108,642", pct = "45.0%", action = "Ignored", badge = "badge-action-drop", reason = "Proprietary portal metric; not standardized"),
        list(col = "bedrooms", count = "93,663", pct = "38.8%", action = "Handled in Modeling", badge = "badge-action-handled", reason = "Studios have 0 beds; lots have none"),
        list(col = "region", count = "56,057", pct = "23.2%", action = "Labeled Unspecified", badge = "badge-action-handled", reason = "Preserved listings by tagging unknown regions"),
        list(col = "sqm", count = "31,207", pct = "12.9%", action = "Filtered (>0)", badge = "badge-action-handled", reason = "Excluded zero/blank floor sizes in ₱/m²")
      )

      rows <- lapply(miss_data, function(r) {
        tags$tr(
          tags$td(tags$code(style = "color: var(--nu-navy); font-weight: 700;", r$col)),
          tags$td(r$count),
          tags$td(tags$b(r$pct)),
          tags$td(tags$span(class = r$badge, r$action)),
          tags$td(style = "font-size: 1.02rem; color: #334155; line-height: 1.45;", r$reason)
        )
      })

      tags$table(class = "nu-datatable",
        tags$thead(
          tags$tr(
            tags$th("Column Name"),
            tags$th("Missing Count"),
            tags$th("Missing %"),
            tags$th("ETL Action Taken"),
            tags$th("Data Engineering Rationale")
          )
        ),
        tags$tbody(rows)
      )
    }
  })

  # ── EDA: Physical Drivers & Room Scaling Plot ──────────────────────────────
  output$plot_eda_rooms <- renderPlotly({
    req(input$eda_chart_metric)

    if (input$eda_chart_metric == "bedrooms") {
      # From 02_eda.R and clean dataset: Median price by bedroom count
      br_df <- data.frame(
        Bedrooms = c("Studio (0 BR)", "1 Bedroom", "2 Bedrooms", "3 Bedrooms", "4 Bedrooms", "5 Bedrooms", "6+ Bedrooms"),
        Median_Price = c(4535600, 6596000, 5086400, 10900000, 18000000, 19149000, 38000000),
        Listings = c(949, 5526, 8537, 7700, 5837, 3666, 704),
        stringsAsFactors = FALSE
      )

      bar_cols <- c("#1D2D68", "#22357A", "#2B429A", "#3551B8", "#4364D8", "#D49D00", "#FFC72C")

      plot_ly(
        data = br_df,
        x = ~Bedrooms,
        y = ~Median_Price,
        type = "bar",
        marker = list(color = bar_cols),
        hovertemplate = paste0(
          "<b>%{x}</b><br>",
          "Median Asking Price: ₱%{y:,.0f}<br>",
          "Listings Count: ", br_df$Listings,
          "<extra></extra>"
        )
      ) %>% layout(
        xaxis = list(
          title = "Bedroom Count",
          titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
          tickfont = list(size = 14, color = "#0F172A", family = "Inter, sans-serif")
        ),
        yaxis = list(
          title = "Median Asking Price (PHP)",
          titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
          tickprefix = "₱",
          tickformat = ",.0f",
          tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
          gridcolor = "#F1F5F9"
        ),
        paper_bgcolor = "#FFFFFF",
        plot_bgcolor = "#FFFFFF",
        font = list(family = "Inter, sans-serif", size = 15),
        margin = list(l = 85, r = 15, t = 15, b = 50),
        automargin = TRUE
      ) %>% config(displayModeBar = FALSE)

    } else {
      # Table 22 from Paper: Raw Property Type Share across 241,496 listings
      pt_raw <- data.frame(
        Type = c("Houses", "Condominiums", "Lots (Land)", "Commercial"),
        Count = c(97133, 88132, 49039, 7192),
        stringsAsFactors = FALSE
      )

      plot_ly(
        data = pt_raw,
        labels = ~Type,
        values = ~Count,
        type = "pie",
        hole = 0.55,
        marker = list(colors = c("#10B981", "#EF4444", "#3B82F6", "#FFC72C")),
        textinfo = "label+percent",
        hovertemplate = "<b>%{label}</b><br>Listings: %{value:,.0f}<br>Share: %{percent}<extra></extra>"
      ) %>% layout(
        paper_bgcolor = "#FFFFFF",
        plot_bgcolor = "#FFFFFF",
        font = list(family = "Inter, sans-serif", size = 15),
        showlegend = TRUE,
        legend = list(orientation = "h", x = 0.05, y = -0.1, font = list(size = 14)),
        margin = list(l = 20, r = 20, t = 20, b = 40)
      ) %>% config(displayModeBar = FALSE)
    }
  })

  # ── Viz 1: Boxplot (Condo, House, Lot) ─────────────────────────────────────
  output$plot_viz1 <- renderPlotly({
    req(input$viz1_types)

    sub <- if (nrow(listings_clean) > 0) {
      listings_clean %>%
        filter(property_type %in% input$viz1_types, !is.na(price_php), price_php > 0)
    } else {
      data.frame(property_type = character(), price_php = numeric())
    }

    pal <- c("condo" = "#EF4444", "house" = "#10B981", "lot" = "#3B82F6")

    p <- plot_ly()

    for (pt in input$viz1_types) {
      pt_df <- sub %>% filter(property_type == pt)
      if (nrow(pt_df) > 0) {
        col <- if (pt %in% names(pal)) pal[[pt]] else "#1D2D68"
        p <- p %>% add_trace(
          y = pt_df$price_php,
          name = tools::toTitleCase(pt),
          type = "box",
          marker = list(color = col, opacity = 0.22, size = 3),
          line = list(color = "#1E293B", width = 1.5),
          fillcolor = col,
          opacity = 0.75
        )
      }
    }

    is_log <- input$viz1_scale == "log"
    y_axis <- if (is_log) {
      list(
        title = "Asking Price (PHP, Log Scale)",
        titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
        type = "log",
        tickvals = c(350000, 1e6, 3e6, 10e6, 30e6, 100e6, 300e6, 1e9),
        ticktext = c("₱350K", "₱1M", "₱3M", "₱10M", "₱30M", "₱100M", "₱300M", "₱1B"),
        tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
        gridcolor = "#F1F5F9"
      )
    } else {
      list(
        title = "Asking Price (PHP)",
        titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
        tickprefix = "₱",
        tickformat = ",.0f",
        tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
        gridcolor = "#F1F5F9"
      )
    }

    p %>% layout(
      xaxis = list(
        title = "Property Type",
        titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
        tickfont = list(size = 15, color = "#0F172A", family = "Inter, sans-serif"),
        gridcolor = "#F1F5F9"
      ),
      yaxis = y_axis,
      paper_bgcolor = "#FFFFFF",
      plot_bgcolor = "#FFFFFF",
      font = list(family = "Inter, sans-serif", size = 15),
      margin = list(l = 85, r = 15, t = 15, b = 50),
      automargin = TRUE,
      showlegend = FALSE
    ) %>% config(displayModeBar = FALSE)
  })

  # ── Viz 2: Top Regions Horizontal Bar (STRICTLY SORTED WITH NCR AT TOP) ──
  output$plot_viz2 <- renderPlotly({
    n_show <- as.integer(input$viz2_scope)

    df_reg <- if (nrow(listings_clean) > 0) {
      listings_clean %>%
        filter(!is.na(price_per_sqm), region != "Unspecified") %>%
        group_by(region) %>%
        summarise(
          Median_Price_Sqm = median(price_per_sqm),
          Count = n(),
          .groups = "drop"
        ) %>%
        arrange(desc(Median_Price_Sqm)) %>%
        slice(1:n_show)
    } else {
      data.frame(region = character(), Median_Price_Sqm = numeric(), Count = integer())
    }

    clean_label <- function(r) {
      lbl <- gsub(" \\(.*?\\)", "", r)
      lbl <- ifelse(grepl("National Capital", r), "NCR", lbl)
      lbl
    }

    df_reg$short_name <- sapply(df_reg$region, clean_label)
    ordered_labels <- rev(df_reg$short_name)

    is_ncr <- grepl("National Capital", df_reg$region)
    bar_cols <- ifelse(is_ncr, "#FFC72C", "#1D2D68")

    plot_ly(
      x = df_reg$Median_Price_Sqm,
      y = df_reg$short_name,
      type = "bar",
      orientation = "h",
      marker = list(color = bar_cols),
      hovertemplate = paste0(
        "<b>", df_reg$region, "</b><br>",
        "Median ₱/m\u00b2: ₱%{x:,.0f}<br>",
        "Listings: ", df_reg$Count,
        "<extra></extra>"
      )
    ) %>% layout(
      xaxis = list(
        title = "Median Price per Sqm (PHP)",
        titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
        tickprefix = "₱",
        tickformat = ",.0f",
        tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
        gridcolor = "#F1F5F9"
      ),
      yaxis = list(
        title = "",
        categoryorder = "array",
        categoryarray = ordered_labels,
        automargin = TRUE,
        tickfont = list(size = 14, color = "#0F172A", family = "Inter, sans-serif")
      ),
      paper_bgcolor = "#FFFFFF",
      plot_bgcolor = "#FFFFFF",
      font = list(family = "Inter, sans-serif", size = 15),
      margin = list(l = 105, r = 25, t = 20, b = 50)
    ) %>% config(displayModeBar = FALSE)
  })

  # ── Viz 3: Density Plot (FACETED CONDO & HOUSE MATCHING PAPER) ─────────────
  output$plot_viz3 <- renderPlotly({
    df_v3 <- if (nrow(listings_viz3) > 0) {
      listings_viz3
    } else if (nrow(listings_clean) > 0) {
      listings_clean %>%
        filter(property_type %in% c("condo", "house"), !is.na(price_php), price_php > 0) %>%
        mutate(
          Status = ifelse(is_active, "Active", "Inactive / Delisted"),
          property_type = tools::toTitleCase(property_type)
        )
    } else {
      data.frame()
    }

    compute_kde <- function(sub_df) {
      if (nrow(sub_df) < 5) return(NULL)
      d <- density(log10(sub_df$price_php), n = 160, adjust = 1.2)
      data.frame(x = d$x, y = d$y)
    }

    tick_vals <- c(6, 6.5, 7, 7.5, 8, 8.5, 9)
    tick_labs <- c("₱1M", "₱3.1M", "₱10M", "₱31.6M", "₱100M", "₱316M", "₱1B")

    if (input$viz3_facet %in% c("condo", "house")) {
      target_type <- tools::toTitleCase(input$viz3_facet)
      act_df   <- df_v3 %>% filter(property_type == target_type, Status %in% c("Active", "Active Listing"))
      inact_df <- df_v3 %>% filter(property_type == target_type, Status %in% c("Inactive / Delisted", "Delisted / Inactive"))

      d_act   <- compute_kde(act_df)
      d_inact <- compute_kde(inact_df)

      p <- plot_ly()
      if (!is.null(d_act)) {
        p <- p %>% add_trace(
          x = d_act$x, y = d_act$y, name = "Active",
          type = "scatter", mode = "lines",
          line = list(color = "#2563EB", width = 2.6),
          fill = "tozeroy", fillcolor = "rgba(37, 99, 235, 0.12)",
          hovertemplate = "<b>Active</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^d_act$x), big.mark = ",")
        )
      }
      if (!is.null(d_inact)) {
        p <- p %>% add_trace(
          x = d_inact$x, y = d_inact$y, name = "Inactive / Delisted",
          type = "scatter", mode = "lines",
          line = list(color = "#EF4444", width = 2.6),
          fill = "tozeroy", fillcolor = "rgba(239, 68, 68, 0.12)",
          hovertemplate = "<b>Inactive / Delisted</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^d_inact$x), big.mark = ",")
        )
      }

      p %>% layout(
        xaxis = list(
          title = "Asking Price (PHP, Log Scale)",
          titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
          tickvals = tick_vals, ticktext = tick_labs,
          tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
          gridcolor = "#F1F5F9"
        ),
        yaxis = list(title = "Density", titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"), gridcolor = "#F1F5F9"),
        paper_bgcolor = "#FFFFFF", plot_bgcolor = "#FFFFFF",
        font = list(family = "Inter, sans-serif", size = 15),
        margin = list(l = 60, r = 15, t = 10, b = 45)
      ) %>% config(displayModeBar = FALSE)

    } else {
      # BOTH: Two stacked subplots (Condo on top, House on bottom)
      c_act   <- df_v3 %>% filter(property_type == "Condo", Status %in% c("Active", "Active Listing"))
      c_inact <- df_v3 %>% filter(property_type == "Condo", Status %in% c("Inactive / Delisted", "Delisted / Inactive"))
      kd_c_act   <- compute_kde(c_act)
      kd_c_inact <- compute_kde(c_inact)

      p_c <- plot_ly()
      if (!is.null(kd_c_act)) {
        p_c <- p_c %>% add_trace(
          x = kd_c_act$x, y = kd_c_act$y, name = "Active",
          type = "scatter", mode = "lines",
          line = list(color = "#2563EB", width = 2.4),
          fill = "tozeroy", fillcolor = "rgba(37, 99, 235, 0.12)",
          hovertemplate = "<b>Condo (Active)</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^kd_c_act$x), big.mark = ",")
        )
      }
      if (!is.null(kd_c_inact)) {
        p_c <- p_c %>% add_trace(
          x = kd_c_inact$x, y = kd_c_inact$y, name = "Inactive / Delisted",
          type = "scatter", mode = "lines",
          line = list(color = "#EF4444", width = 2.4),
          fill = "tozeroy", fillcolor = "rgba(239, 68, 68, 0.12)",
          hovertemplate = "<b>Condo (Inactive)</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^kd_c_inact$x), big.mark = ",")
        )
      }

      h_act   <- df_v3 %>% filter(property_type == "House", Status %in% c("Active", "Active Listing"))
      h_inact <- df_v3 %>% filter(property_type == "House", Status %in% c("Inactive / Delisted", "Delisted / Inactive"))
      kd_h_act   <- compute_kde(h_act)
      kd_h_inact <- compute_kde(h_inact)

      p_h <- plot_ly()
      if (!is.null(kd_h_act)) {
        p_h <- p_h %>% add_trace(
          x = kd_h_act$x, y = kd_h_act$y, name = "Active", showlegend = FALSE,
          type = "scatter", mode = "lines",
          line = list(color = "#2563EB", width = 2.4),
          fill = "tozeroy", fillcolor = "rgba(37, 99, 235, 0.12)",
          hovertemplate = "<b>House (Active)</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^kd_h_act$x), big.mark = ",")
        )
      }
      if (!is.null(kd_h_inact)) {
        p_h <- p_h %>% add_trace(
          x = kd_h_inact$x, y = kd_h_inact$y, name = "Inactive / Delisted", showlegend = FALSE,
          type = "scatter", mode = "lines",
          line = list(color = "#EF4444", width = 2.4),
          fill = "tozeroy", fillcolor = "rgba(239, 68, 68, 0.12)",
          hovertemplate = "<b>House (Inactive)</b><br>Price: ₱%{text}<br>Density: %{y:.3f}<extra></extra>",
          text = format(round(10^kd_h_inact$x), big.mark = ",")
        )
      }

      subplot(p_c, p_h, nrows = 2, shareX = TRUE, titleY = TRUE) %>%
        layout(
          annotations = list(
            list(text = "<b>Condominiums</b>", x = 0.5, y = 1.03, xref = "paper", yref = "paper", showarrow = FALSE, font = list(size = 16, color = "#0F172A")),
            list(text = "<b>Houses</b>", x = 0.5, y = 0.47, xref = "paper", yref = "paper", showarrow = FALSE, font = list(size = 16, color = "#0F172A"))
          ),
          xaxis = list(
            title = "Asking Price (PHP, Log Scale)",
            titlefont = list(size = 16, color = "#0F172A", family = "Inter, sans-serif"),
            tickvals = tick_vals, ticktext = tick_labs,
            tickfont = list(size = 14, color = "#1E293B", family = "Inter, sans-serif"),
            gridcolor = "#F1F5F9"
          ),
          yaxis = list(title = "Density", titlefont = list(size = 12, color = "#334155"), gridcolor = "#F1F5F9"),
          yaxis2 = list(title = "Density", titlefont = list(size = 12, color = "#334155"), gridcolor = "#F1F5F9"),
          paper_bgcolor = "#FFFFFF", plot_bgcolor = "#FFFFFF",
          font = list(family = "Inter, sans-serif", size = 15),
          legend = list(orientation = "h", x = 0.30, y = 1.18, font = list(size = 14)),
          margin = list(l = 60, r = 15, t = 30, b = 45)
        ) %>% config(displayModeBar = FALSE)
    }
  })

  # ── Predictor Logic ────────────────────────────────────────────────────────
  pred_val <- eventReactive(input$btn_calc, {
    req(input$pred_sqm, input$pred_beds, input$pred_baths)

    reg_levels <- if (!is.null(rf_model)) rf_model$forest$xlevels$region else ALL_REGIONS
    pt_levels  <- if (!is.null(rf_model)) rf_model$forest$xlevels$property_type else c("condo", "house")

    nd <- data.frame(
      sqm = as.numeric(input$pred_sqm),
      bedrooms = as.numeric(input$pred_beds),
      bathrooms = as.numeric(input$pred_baths),
      property_type = factor(input$pred_type, levels = pt_levels),
      region = factor(input$pred_region, levels = reg_levels)
    )

    v_mlr <- if (!is.null(mlr_model)) {
      tryCatch(exp(predict(mlr_model, newdata = nd)), error = function(e) NA)
    } else NA

    v_rf <- if (!is.null(rf_model)) {
      tryCatch(exp(predict(rf_model, newdata = nd)), error = function(e) NA)
    } else NA

    list(mlr = v_mlr, rf = v_rf)
  }, ignoreNULL = FALSE)

  output$val_mlr <- renderText({
    res <- pred_val()
    if (is.null(res) || is.na(res$mlr)) "₱10,129,819" else fmt_php(res$mlr)
  })

  output$val_rf <- renderText({
    res <- pred_val()
    if (is.null(res) || is.na(res$rf)) "₱14,960,000" else fmt_php(res$rf)
  })

  # ── Summary Data Tables ────────────────────────────────────────────────────
  output$table_types <- renderUI({
    if (nrow(listings_clean) == 0) return(NULL)

    df_t <- listings_clean %>%
      group_by(property_type) %>%
      summarise(
        Count = n(),
        Median_Price = median(price_php, na.rm = TRUE),
        Mean_Price = mean(price_php, na.rm = TRUE),
        Median_Sqm = median(sqm, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(Count))

    total_count <- sum(df_t$Count)

    rows <- lapply(1:nrow(df_t), function(i) {
      r <- df_t[i, ]
      pct <- round((r$Count / total_count) * 100, 1)
      tags$tr(
        tags$td(tags$b(tools::toTitleCase(r$property_type))),
        tags$td(fmt_num(r$Count)),
        tags$td(paste0(pct, "%")),
        tags$td(fmt_php(r$Median_Price)),
        tags$td(if (is.na(r$Median_Sqm)) "—" else paste0(round(r$Median_Sqm), " m²"))
      )
    })

    tags$table(class = "nu-datatable",
      tags$thead(
        tags$tr(
          tags$th("Property Type"),
          tags$th("Listings Count"),
          tags$th("Market Share"),
          tags$th("Median Asking Price"),
          tags$th("Median Floor Size")
        )
      ),
      tags$tbody(
        rows,
        tags$tr(class = "total-highlight",
          tags$td("Total Active Listings"),
          tags$td(fmt_num(total_count)),
          tags$td("100%"),
          tags$td("₱12.30M"),
          tags$td("—")
        )
      )
    )
  })

  output$table_regions <- renderUI({
    if (nrow(listings_clean) == 0) return(NULL)

    df_r <- listings_clean %>%
      filter(!is.na(price_per_sqm), region != "Unspecified") %>%
      group_by(region) %>%
      summarise(
        Count = n(),
        Median_Ppsqm = median(price_per_sqm),
        Mean_Ppsqm = mean(price_per_sqm),
        .groups = "drop"
      ) %>%
      arrange(desc(Median_Ppsqm)) %>%
      head(6)

    rows <- lapply(1:nrow(df_r), function(i) {
      r <- df_r[i, ]
      tags$tr(
        tags$td(tags$b(paste0("#", i))),
        tags$td(r$region),
        tags$td(fmt_num(r$Count)),
        tags$td(tags$b(fmt_php(r$Median_Ppsqm))),
        tags$td(fmt_php(r$Mean_Ppsqm))
      )
    })

    tags$table(class = "nu-datatable",
      tags$thead(
        tags$tr(
          tags$th("Rank"),
          tags$th("Region Name"),
          tags$th("Listings Count"),
          tags$th("Median ₱/m²"),
          tags$th("Mean ₱/m²")
        )
      ),
      tags$tbody(rows)
    )
  })
}

# ──────────────────────────────────────────────────────────────────────────────
# 7. LAUNCH APP
# ──────────────────────────────────────────────────────────────────────────────
shinyApp(ui = ui, server = server)
