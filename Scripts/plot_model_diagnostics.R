# ==============================================================================
# SCRIPT: plot_model_diagnostics.R
# Recreate Section 7.6 Model Valuation Diagnostics Plot in RStudio
# Compares Multiple Linear Regression (MLR) vs. Random Forest on Unseen Test Data
# ==============================================================================

# 1. Load required libraries
library(tidyverse)
library(randomForest)

# 2. Determine project directories
data_dir   <- if (dir.exists("Datasets")) "Datasets" else if (dir.exists("../Datasets")) "../Datasets" else "Datasets"
plots_dir  <- if (dir.exists("Plots")) "Plots" else if (dir.exists("../Plots")) "../Plots" else "Plots"
models_dir <- if (dir.exists("Models")) "Models" else if (dir.exists("../Models")) "../Models" else "Models"

if (!dir.exists(plots_dir)) dir.create(plots_dir, recursive = TRUE)

# 3. Load residential dataset and filter complete cases
cat("Loading listings data...\n")
residential <- read_csv(file.path(data_dir, "listings_residential.csv"), show_col_types = FALSE)

model_data <- residential %>%
  filter(!is.na(price_php), price_php > 0,
         !is.na(sqm), sqm > 0,
         !is.na(bedrooms), !is.na(bathrooms), !is.na(region)) %>%
  mutate(log_price = log(price_php),
         property_type = as.factor(property_type),
         region = as.factor(region))

# 4. Extract the exact 20% test partition (seed = 42, N = 3,158)
set.seed(42)
sample_idx <- sample(seq_len(nrow(model_data)), size = floor(0.8 * nrow(model_data)))
test_set <- model_data[-sample_idx, ]

cat("Test set records:", nrow(test_set), "\n")

# 5. Load pre-trained models
cat("Loading trained models...\n")
mlr_model <- readRDS(file.path(models_dir, "mlr_model.rds"))
rf_model  <- readRDS(file.path(models_dir, "rf_model.rds"))

# 6. Generate test set predictions
test_set$pred_mlr <- predict(mlr_model, newdata = test_set)
test_set$pred_rf  <- predict(rf_model, newdata = test_set)

# 7. Prepare faceted dataframe
df_mlr <- data.frame(
  Actual = test_set$log_price,
  Predicted = test_set$pred_mlr,
  Model = "Multiple Linear Regression (MLR)\nTest R² = 0.5878 | RMSE = 0.7345 | MAE = 0.5429"
)

df_rf <- data.frame(
  Actual = test_set$log_price,
  Predicted = test_set$pred_rf,
  Model = "Random Forest Regression (ntree = 200)\nTest R² = 0.7523 | RMSE = 0.5693 | MAE = 0.4172"
)

plot_df <- rbind(df_mlr, df_rf)

# 8. Build the diagnostic plot using ggplot2
p <- ggplot(plot_df, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.2, size = 1.2, color = "#1D2D68") +
  geom_abline(intercept = 0, slope = 1, color = "#DC2626", linetype = "dashed", linewidth = 0.9) +
  geom_smooth(method = "lm", color = "#FFC72C", se = FALSE, linewidth = 0.8) +
  facet_wrap(~ Model, ncol = 2) +
  scale_x_continuous(
    name = "Actual Log Asking Price: log(price_php)",
    breaks = seq(13, 20, by = 1),
    labels = function(x) paste0(x, "\n(₱", round(exp(x) / 1e6, 1), "M)")
  ) +
  scale_y_continuous(
    name = "Predicted Log Asking Price",
    breaks = seq(13, 20, by = 1),
    labels = function(x) paste0(x, "\n(₱", round(exp(x) / 1e6, 1), "M)")
  ) +
  labs(
    title = "Model Valuation Diagnostics: Actual vs. Predicted Asking Prices",
    subtitle = "Comparing Multiple Linear Regression and Random Forest on Unseen Test Data (N = 3,158 | Red Dashed Line = Perfect 45° Fit | Yellow = Trend)",
    caption = "Source: Philippines Real Estate Asking Prices Analysis • Elective 3 Research Project"
  ) +
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(size = 14, face = "bold", color = "#1D2D68", margin = ggplot2::margin(b = 4)),
    plot.subtitle = element_text(size = 10, color = "#475569", margin = ggplot2::margin(b = 10)),
    plot.caption = element_text(size = 8.5, color = "#94A3B8", margin = ggplot2::margin(t = 8)),
    strip.text = element_text(size = 11, face = "bold", color = "#1D2D68"),
    strip.background = element_rect(fill = "#F1F5F9", color = "#CBD5E1", linewidth = 0.5),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E2E8F0", linewidth = 0.4),
    panel.border = element_rect(color = "#CBD5E1", fill = NA, linewidth = 0.5),
    axis.title = element_text(size = 10, face = "bold", color = "#1E293B"),
    axis.text = element_text(size = 8.5, color = "#475569")
  )

# 9. Display plot in RStudio Plots tab
print(p)

# 10. Save high-resolution PNG
output_plot <- file.path(plots_dir, "model_actual_vs_predicted.png")
ggsave(output_plot, plot = p, width = 10.5, height = 5.2, dpi = 300, bg = "white")
cat("\nPlot successfully rendered in RStudio Plots pane and saved to:\n", output_plot, "\n")
