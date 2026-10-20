# ==============================================================================
# SCRIPT 02: EXPLORATORY DATA ANALYSIS (EDA)
# Matches: Paper Section 5.3 – R Code
# ==============================================================================

library(tidyverse)

# Robust directory resolution for Datasets
data_dir <- if (dir.exists("Datasets")) "Datasets" else if (dir.exists("../Datasets")) "../Datasets" else "Datasets"

# Load raw dataset
listings_raw <- read_csv(file.path(data_dir, "listings.csv"))

# Price statistics
cat("\n--- Price Statistics ---\n")
listings_raw %>%
  filter(!is.na(price_php)) %>%
  summarise(
    Mean   = mean(price_php),
    Median = median(price_php),
    Min    = min(price_php),
    Max    = max(price_php)
  ) %>%
  print()

# sqm stats for condos
cat("\n--- SQM Stats (Condos) ---\n")
listings_raw %>%
  filter(property_type == "condo", !is.na(sqm)) %>%
  summarise(
    Mean   = mean(sqm),
    Median = median(sqm),
    Min    = min(sqm),
    Max    = max(sqm)
  ) %>%
  print()

# sqm stats for houses
cat("\n--- SQM Stats (Houses) ---\n")
listings_raw %>%
  filter(property_type == "house", !is.na(sqm)) %>%
  summarise(
    Mean   = mean(sqm),
    Median = median(sqm),
    Min    = min(sqm),
    Max    = max(sqm)
  ) %>%
  print()

# Bedroom statistics
cat("\n--- Bedroom Statistics ---\n")
listings_raw %>%
  filter(!is.na(bedrooms)) %>%
  summarise(
    Mean   = mean(bedrooms),
    Median = median(bedrooms),
    Min    = min(bedrooms),
    Max    = max(bedrooms)
  ) %>%
  print()

# Bathroom statistics
cat("\n--- Bathroom Statistics ---\n")
listings_raw %>%
  filter(!is.na(bathrooms)) %>%
  summarise(
    Mean   = mean(bathrooms),
    Median = median(bathrooms),
    Min    = min(bathrooms),
    Max    = max(bathrooms)
  ) %>%
  print()

# price_per_sqm statistics
cat("\n--- Price Per SQM Statistics ---\n")
listings_raw %>%
  filter(!is.na(price_per_sqm)) %>%
  summarise(
    Mean   = mean(price_per_sqm),
    Median = median(price_per_sqm),
    Min    = min(price_per_sqm),
    Max    = max(price_per_sqm)
  ) %>%
  print()

# Count and percentage by property type
cat("\n--- Property Type Breakdown ---\n")
listings_raw %>%
  count(property_type) %>%
  mutate(percentage = round(n / sum(n) * 100, 1)) %>%
  arrange(desc(n)) %>%
  print()

# Median price per bedroom count
cat("\n--- Median Price by Bedrooms (>100 listings) ---\n")
listings_raw %>%
  filter(!is.na(bedrooms), !is.na(price_php)) %>%
  group_by(bedrooms) %>%
  summarise(
    Count         = n(),
    Median_Price  = median(price_php)
  ) %>%
  filter(Count > 100) %>%
  arrange(bedrooms) %>%
  print()

# Median price by listing status
cat("\n--- Median Price by Listing Status ---\n")
listings_raw %>%
  filter(!is.na(price_php)) %>%
  group_by(is_active) %>%
  summarise(
    Count        = n(),
    Median_Price = median(price_php)
  ) %>%
  print()

# Count missing values per column
cat("\n--- Missing Values Per Column ---\n")
print(colSums(is.na(listings_raw)))