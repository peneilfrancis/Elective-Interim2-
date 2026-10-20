# ==============================================================================
# MASTER EXECUTION SCRIPT: run_all.R
# Philippines Real Estate Market Analysis & Price Prediction Using R
# Elective 3 – BSIT241-C Capstone Project
# ==============================================================================

cat("\n======================================================================\n")
cat("   PHILIPPINES REAL ESTATE MARKET ANALYSIS & VALUATION PLATFORM\n")
cat("   Group 2: Dean Warren P. Booc & Peneil Francis S. Cayaco\n")
cat("   Instructor: Prof. Joseph L. Domingo | Academic Year: 2026-2027\n")
cat("======================================================================\n\n")

# 1. Check and install required packages
required_pkgs <- c("tidyverse", "randomForest", "shiny", "plotly", "bslib")
missing_pkgs <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]

if (length(missing_pkgs) > 0) {
  cat("Installing missing CRAN packages:", paste(missing_pkgs, collapse = ", "), "\n")
  install.packages(missing_pkgs, repos = "https://cloud.r-project.org")
} else {
  cat("All required CRAN packages are installed and ready.\n\n")
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(randomForest)
  library(shiny)
  library(plotly)
  library(bslib)
})

# 2. Run Data Cleaning & Scrubbing Pipeline (Scripts/01_data_cleaning.R)
cat("[1/5] Running Data Cleaning & Scrubbing Funnel...\n")
source("Scripts/01_data_cleaning.R")

# 3. Run Exploratory Data Analysis (Scripts/02_eda.R)
cat("\n[2/5] Running Exploratory Data Analysis...\n")
source("Scripts/02_eda.R")

# 4. Generate Publication Visualizations (Scripts/03_visualizations.R)
cat("\n[3/5] Generating Visualizations 1, 2, and 3...\n")
source("Scripts/03_visualizations.R")

# 5. Train & Evaluate Models (Scripts/04_modeling.R)
cat("\n[4/5] Training MLR & Random Forest Models (set.seed: 42)...\n")
source("Scripts/04_modeling.R")

# 6. Generate Model Valuation Diagnostics (Scripts/plot_model_diagnostics.R)
cat("\n[5/5] Generating Model Valuation Diagnostics (Figure 4)...\n")
source("Scripts/plot_model_diagnostics.R")

cat("\n======================================================================\n")
cat("   PIPELINE COMPLETE! All datasets, figures, and models are generated.\n")
cat("   To launch the interactive dashboard, run: shiny::runApp('app.R')\n")
cat("======================================================================\n\n")
