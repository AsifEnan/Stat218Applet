#' Generate a Formal Regression Table with CI Interpretation
#'
#' @param x Numeric vector for the explanatory variable
#' @param y Numeric vector for the response variable
#' @param x_name Character string for the explanatory variable name
#' @param y_name Character string for the response variable name
#' @param conf_level Desired confidence level for the interval (default 0.95)
#'
#' @return A gt table object
#' @export
table_regression <- function(x, y, x_name = "Explanatory Variable", y_name = "Response Variable", conf_level = 0.95) {

  # Ensure the gt package is available
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("The 'gt' package is required for this function. Please install it using install.packages('gt').")
  }

  # 1. Clean the data
  valid_data <- complete.cases(x, y)
  x_clean <- x[valid_data]
  y_clean <- y[valid_data]

  # 2. Fit Model and Extract Statistics
  mod <- lm(y_clean ~ x_clean)
  mod_summary <- summary(mod)
  coef_matrix <- mod_summary$coefficients
  ci_matrix <- confint(mod, level = conf_level)

  # Build the data frame for the table
  table_df <- data.frame(
    Term = c("Intercept", x_name),
    Coeff = coef_matrix[, 1],
    SE = coef_matrix[, 2],
    t_stat = coef_matrix[, 3],
    p_value = coef_matrix[, 4],
    Lower = ci_matrix[, 1],
    Upper = ci_matrix[, 2],
    stringsAsFactors = FALSE
  )

  # 3. Dynamic Confidence Interval Interpretation
  lower_b1 <- round(table_df$Lower[2], 4)
  upper_b1 <- round(table_df$Upper[2], 4)
  pct <- conf_level * 100

  # Smart wording based on positive/negative bounds
  if (lower_b1 > 0 && upper_b1 > 0) {
    direction <- "increase"
    b1_str <- paste("between", lower_b1, "and", upper_b1)
  } else if (lower_b1 < 0 && upper_b1 < 0) {
    direction <- "decrease"
    b1_str <- paste("between", abs(upper_b1), "and", abs(lower_b1)) # Flip for absolute phrasing
  } else {
    direction <- "change"
    b1_str <- paste("by between", lower_b1, "and", upper_b1)
  }

  interp_text <- paste0(
    "Confidence Interval Interpretation: We are ", pct,
    "% confident that for every 1 unit increase in ", x_name,
    ", the true population mean ", y_name, " will ", direction, " ", b1_str, " units."
  )

  # 4. Build the gt Table
  tbl <- gt::gt(table_df) |>
    gt::tab_header(
      title = gt::md("**Simple Linear Regression Output**"),
      subtitle = paste0("Model: Predicted ", y_name, " ~ ", x_name)
    ) |>
    gt::cols_label(
      Term = "Term",
      Coeff = "Coefficient",
      SE = "SE",
      t_stat = "t-stat",
      p_value = "p-value",
      Lower = paste0("Lower ", pct, "%"),
      Upper = paste0("Upper ", pct, "%")
    ) |>
    gt::fmt_number(
      columns = c(Coeff, SE, t_stat, Lower, Upper),
      decimals = 4
    ) |>
    gt::fmt_number(
      columns = p_value,
      decimals = 4
    ) |>
    # Clean up extremely small p-values so they don't show as 0.0000
    gt::sub_small_vals(
      columns = p_value,
      threshold = 0.0001
    ) |>
    gt::tab_source_note(
      source_note = gt::md(paste0("**", interp_text, "**"))
    ) |>
    gt::tab_options(
      table.width = gt::pct(80),
      heading.align = "left",
      column_labels.font.weight = "bold",
      table.border.top.color = "black",
      table.border.bottom.color = "black"
    )

  return(tbl)
}
