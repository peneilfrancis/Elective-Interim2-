# ==============================================================================
# SCRIPT 03: DATA VISUALIZATIONS
# Matches: Paper Section 6 – Exploratory Visualizations (Figures 1, 2, and 3)
# ==============================================================================

library(tidyverse)
library(scales)

# Robust directory resolution
data_dir  <- if (dir.exists("Datasets")) "Datasets" else if (dir.exists("../Datasets")) "../Datasets" else "Datasets"
plots_dir <- if (dir.exists("Plots")) "Plots" else if (dir.exists("../Plots")) "../Plots" else "Plots"
if (!dir.exists(plots_dir)) dir.create(plots_dir, recursive = TRUE)

# Formatting helper for comma labels
format_comma <- function(x) format(x, big.mark = ",", scientific = FALSE)

# Load dataset
listings_raw <- read_csv(file.path(data_dir, "listings.csv"))

cat("Loaded listings for visualization:", nrow(listings_raw), "rows\n")

# ──────────────────────────────────────────────────────────────────────────────
# Visualization 1: Price Distribution by Property Type (Log Scale)
# Matches: Paper Figure 1
# ──────────────────────────────────────────────────────────────────────────────
cat("\nGenerating Visualization 1: Asking Price Distribution by Property Type...\n")
p1 <- listings_raw %>%
  filter(property_type %in% c("house", "condo", "lot"), !is.na(price_php), price_php > 0) %>%
  ggplot(aes(x = property_type, y = price_php, fill = property_type)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.1) +
  scale_y_log10(labels = format_comma) +
  scale_fill_manual(values = c("house" = "#2B6CB0", "condo" = "#D69E2E", "lot" = "#38A169")) +
  theme_minimal() +
  labs(
    title = "Distribution of Asking Prices by Property Type",
    subtitle = "Using logarithmic scale due to right-skewed prices",
    x = "Property Type",
    y = "Asking Price (PHP, Log Scale)"
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(face = "bold")
  )

ggsave(file.path(plots_dir, "viz1.png"), plot = p1, width = 8, height = 5.5, dpi = 300)
cat("Saved:", file.path(plots_dir, "viz1.png"), "\n")

# ──────────────────────────────────────────────────────────────────────────────
# Visualization 2: Top 10 Regions by Median Price Per Sqm
# Matches: Paper Figure 2
# ──────────────────────────────────────────────────────────────────────────────
cat("\nGenerating Visualization 2: Top 10 Regions by Median Price Per Sqm...\n")
p2 <- listings_raw %>%
  filter(!is.na(price_per_sqm), region != "Unspecified") %>%
  group_by(region) %>%
  summarise(Median_Price_Sqm = median(price_per_sqm), .groups = "drop") %>%
  arrange(desc(Median_Price_Sqm)) %>%
  slice(1:10) %>%
  ggplot(aes(x = reorder(region, Median_Price_Sqm), y = Median_Price_Sqm)) +
  geom_col(fill = "#1D2D68", width = 0.7) +
  coord_flip() +
  scale_y_continuous(labels = format_comma) +
  theme_minimal() +
  labs(
    title = "Top 10 Regions by Median Price per Square Meter",
    subtitle = "Ranking regional real estate valuation density across the Philippines",
    x = "Region",
    y = "Median Price per Sqm (PHP)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(face = "bold")
  )

ggsave(file.path(plots_dir, "viz2.png"), plot = p2, width = 8.5, height = 5.5, dpi = 300)
cat("Saved:", file.path(plots_dir, "viz2.png"), "\n")

# ──────────────────────────────────────────────────────────────────────────────
# Visualization 3: Asking Price Distribution by Listing Status
# Matches: Paper Figure 3 & Interactive Shiny Density Curve
# ──────────────────────────────────────────────────────────────────────────────
cat("\nGenerating Visualization 3: Asking Price Distribution by Listing Status...\n")
viz3_data <- listings_raw %>%
  filter(
    property_type %in% c("house", "condo"),
    !is.na(price_php),
    price_php > 0,
    !is.na(is_active)
  ) %>%
  mutate(
    Status = ifelse(is_active == TRUE, "Active", "Inactive / Delisted"),
    property_type = tools::toTitleCase(property_type)
  )

p3 <- ggplot(viz3_data, aes(x = price_php, color = Status)) +
  geom_density(linewidth = 1.2) +
  scale_x_log10(labels = format_comma) +
  facet_wrap(~ property_type, ncol = 1) +
  scale_color_manual(values = c("Active" = "#2196F3", "Inactive / Delisted" = "#E57373")) +
  labs(
    title = "Asking Price Distribution by Listing Status and Property Type",
    subtitle = "Comparing active vs inactive market inventory (Log Scale)",
    x = "Asking Price (PHP, Log Scale)",
    y = "Density (Concentration of Listings)",
    color = "Listing Status"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),
    plot.title = element_text(face = "bold", size = 14),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(plots_dir, "viz3.png"), plot = p3, width = 8, height = 6, dpi = 300)
cat("Saved:", file.path(plots_dir, "viz3.png"), "\n")

# Save processed viz3 dataset for Shiny dashboard
saveRDS(viz3_data, file.path(data_dir, "listings_viz3.rds"))
cat("Saved fast-loading RDS:", file.path(data_dir, "listings_viz3.rds"), "\n")
cat("\nAll visualizations successfully generated and saved to Plots/ and Datasets/.\n")