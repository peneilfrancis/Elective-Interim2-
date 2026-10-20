# ==============================================================================
# SCRIPT 01: DATA PREPARATION AND CLEANING
# Matches: Paper Section 4.2 – R Code Used for Cleaning
# ==============================================================================
library(tidyverse)

# Robust directory resolution for Datasets
data_dir <- if (dir.exists("Datasets")) "Datasets" else if (dir.exists("../Datasets")) "../Datasets" else "Datasets"

# Load raw dataset
listings_raw <- read_csv(file.path(data_dir, "listings.csv"))

cat("BEFORE CLEANING\n")
cat("Rows:", nrow(listings_raw), "| Columns:", ncol(listings_raw), "\n\n")

# Drop columns with high missing rates and no analytical value
listings_clean <- listings_raw %>%
  select(-property_subtype, -new_build_flag, -district, -barangay)

# Label missing region as Unspecified
listings_clean <- listings_clean %>%
  mutate(region = ifelse(is.na(region) | region == "", "Unspecified", region))

# Keep only active listings
listings_clean <- listings_clean %>%
  filter(is_active == TRUE)

# Remove duplicate listings using canonical_id
listings_clean <- listings_clean %>%
  distinct(canonical_id, .keep_all = TRUE)

# Floor area subset — exclude sqm = 0 or missing
listings_buildings <- listings_clean %>%
  filter(!is.na(sqm) & sqm > 0)

# Residential subset — house and condo only, bedrooms 10 or less
listings_residential <- listings_buildings %>%
  filter(property_type %in% c("house", "condo")) %>%
  filter(is.na(bedrooms) | bedrooms <= 10)

cat("AFTER CLEANING\n")
cat("Main dataset:         ", nrow(listings_clean), "rows |", ncol(listings_clean), "columns\n")
cat("Floor area subset:    ", nrow(listings_buildings), "rows\n")
cat("Residential subset:   ", nrow(listings_residential), "rows\n\n")

# Save cleaned subsets for subsequent scripts
if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
write_csv(listings_clean,       file.path(data_dir, "listings_clean.csv"))
write_csv(listings_buildings,   file.path(data_dir, "listings_buildings.csv"))
write_csv(listings_residential, file.path(data_dir, "listings_residential.csv"))
saveRDS(listings_clean,         file.path(data_dir, "listings_clean.rds"))
cat("Cleaned files successfully written to:", data_dir, "\n")
