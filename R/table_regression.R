#' Formatted Simple Linear Regression and ANOVA Tables
#'
#' @description
#' Fits a simple linear regression model and produces a publication-quality
#' formatted table using the `gt` package. Two table types are available:
#'
#' - **Regression Table** (`table_type = "regression"`, the default): Displays
#'   the intercept and slope with their standard errors, t-statistics, p-values,
#'   and a confidence interval for the slope. Includes an automatically
#'   generated plain-English interpretation of the confidence interval.
#'
#' - **ANOVA Table** (`table_type = "anova"`): Displays the analysis of
#'   variance decomposition of the regression model -- Model (Regression),
#'   Error (Residuals), and Total rows -- with sums of squares, degrees of
#'   freedom, mean squares, the F-statistic, and p-value. Includes \eqn{R^2}
#'   in the footer.
#'
#' This function accepts input via `formula` and `data` only -- raw data
#' is required to fit the model.
#'
#' @param formula A two-sided formula of the form `response ~ explanatory`
#'   identifying the response (y) and explanatory (x) variables in your
#'   dataset. For example, `formula = mpg ~ wt` where both columns exist
#'   in `data`.
#' @param data A data frame containing the variables named in `formula`.
#' @param table_type A character string controlling which table is produced.
#'   Must be one of:
#'   \describe{
#'     \item{`"regression"`}{(default) Produces a coefficients table with
#'       the intercept and slope, standard errors, t-statistics, p-values,
#'       and a confidence interval for the slope. A plain-English
#'       interpretation of the slope confidence interval is shown in the
#'       table footer.}
#'     \item{`"anova"`}{Produces an ANOVA decomposition table showing the
#'       Model (Regression), Error (Residuals), and Total rows with sums
#'       of squares, degrees of freedom, mean squares, the F-statistic,
#'       and p-value. \eqn{R^2} is shown in the table footer.}
#'   }
#' @param conf_level The confidence level for the slope confidence interval
#'   shown in the regression table. Must be a number strictly between 0 and
#'   1. Default is `0.95` (95% confidence interval). Only used when
#'   `table_type = "regression"`.
#'
#' @return A `gt` table object. The table can be further customized using
#'   standard `gt` functions, or saved to HTML, PDF, or Word using
#'   `gt::gtsave()`.
#'
#' @details
#' ## Regression Table
#' The regression table displays the fitted model
#' \deqn{\hat{y} = b_0 + b_1 x}
#' with the following columns:
#' - **Term**: Intercept (\eqn{b_0}) and the explanatory variable name (\eqn{b_1})
#' - **Coefficient**: The estimated value of each term
#' - **SE**: Standard error of the estimate
#' - **t-stat**: The standardized test statistic (\eqn{t = b_1 / SE_{b_1}})
#' - **p-value**: Two-sided p-value for testing H\eqn{_0}: \eqn{\beta = 0}
#' - **Lower / Upper**: Confidence interval bounds for each term
#'
#' The footer provides a plain-English interpretation of the slope confidence
#' interval, automatically adjusting wording based on whether the interval
#' is entirely positive, entirely negative, or straddles zero.
#'
#' ## ANOVA Table
#' The ANOVA table decomposes the total variability in the response variable
#' into two sources:
#' - **Model (Regression)**: Variability explained by the linear relationship
#'   with the explanatory variable (\eqn{SS_{Model}}, \eqn{df = 1})
#' - **Error (Residuals)**: Variability left unexplained by the model
#'   (\eqn{SS_{Error}}, \eqn{df = n - 2})
#' - **Total**: Total variability in the response (\eqn{SS_{Total}},
#'   \eqn{df = n - 1})
#'
#' The F-statistic is \eqn{F = MS_{Model} / MS_{Error}} and tests the same
#' null hypothesis as the slope t-test: H\eqn{_0}: \eqn{\beta_1 = 0}.
#' \eqn{R^2 = SS_{Model} / SS_{Total}} is shown in the footer.
#'
#' ## Connection Between the Two Tables
#' For simple linear regression with one explanatory variable, the F-test
#' in the ANOVA table and the two-sided t-test for the slope in the
#' regression table are mathematically equivalent: \eqn{F = t^2} and both
#' produce the same p-value.
#'
#' @importFrom stats anova
#'
#' @examples
#' # --- Regression table, mtcars ---
#' # Does car weight predict fuel efficiency?
#' table_regression(
#'   formula = mpg ~ wt,
#'   data    = mtcars
#' )
#'
#' # --- Regression table, custom confidence level ---
#' table_regression(
#'   formula    = mpg ~ wt,
#'   data       = mtcars,
#'   conf_level = 0.99
#' )
#'
#' # --- ANOVA table, mtcars ---
#' table_regression(
#'   formula    = mpg ~ wt,
#'   data       = mtcars,
#'   table_type = "anova"
#' )
#'
#' # --- Regression table, ISI dataset ---
#' # Does study time predict GPA?
#' table_regression(
#'   formula = gpa ~ hours,
#'   data    = gpa
#' )
#'
#' # --- ANOVA table, ISI dataset ---
#' table_regression(
#'   formula    = gpa ~ hours,
#'   data       = gpa,
#'   table_type = "anova"
#' )
#'
#' # --- Regression table, iris dataset ---
#' # Does sepal length predict petal length?
#' table_regression(
#'   formula = Petal.Length ~ Sepal.Length,
#'   data    = iris
#' )
#'
#' # --- ANOVA table, iris dataset ---
#' table_regression(
#'   formula    = Petal.Length ~ Sepal.Length,
#'   data       = iris,
#'   table_type = "anova"
#' )
#'
#' @export
table_regression <- function(formula, data,
                             table_type = "regression",
                             conf_level = 0.95) {

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  if (missing(formula) || is.null(formula)) {
    cli::cli_abort(c(
      "x" = "No formula was provided.",
      "i" = "Please supply a two-sided formula like {.code formula = response ~ explanatory}.",
      "i" = "For example: {.code table_regression(formula = mpg ~ wt, data = mtcars)}"
    ))
  }

  if (missing(data) || is.null(data)) {
    cli::cli_abort(c(
      "x" = "No data was provided.",
      "i" = "Please supply a data frame using the {.arg data} argument.",
      "i" = "For example: {.code table_regression(formula = mpg ~ wt, data = mtcars)}"
    ))
  }

  vars <- all.vars(formula)

  if (length(vars) != 2) {
    cli::cli_abort(c(
      "x" = "The formula must reference exactly two variables in the form {.code response ~ explanatory}.",
      "i" = "You provided: {.code {deparse(formula)}}"
    ))
  }

  y_name <- vars[1]
  x_name <- vars[2]

  if (!y_name %in% names(data)) {
    cli::cli_abort(c(
      "x" = "The response variable {.val {y_name}} was not found in your data.",
      "i" = "Available variables are: {.val {names(data)}}."
    ))
  }

  if (!x_name %in% names(data)) {
    cli::cli_abort(c(
      "x" = "The explanatory variable {.val {x_name}} was not found in your data.",
      "i" = "Available variables are: {.val {names(data)}}."
    ))
  }

  y_col <- data[[y_name]]
  x_col <- data[[x_name]]

  if (!is.numeric(y_col)) {
    cli::cli_abort(c(
      "x" = "The response variable {.val {y_name}} must be numeric.",
      "i" = "It appears to contain non-numeric values. Check your data."
    ))
  }

  if (!is.numeric(x_col)) {
    cli::cli_abort(c(
      "x" = "The explanatory variable {.val {x_name}} must be numeric.",
      "i" = "It appears to contain non-numeric values. Check your data."
    ))
  }

  if (!table_type %in% c("regression", "anova")) {
    cli::cli_abort(c(
      "x" = "{.arg table_type} must be either {.val regression} or {.val anova}.",
      "i" = "You provided: {.val {table_type}}"
    ))
  }

  if (!is.numeric(conf_level) || conf_level <= 0 || conf_level >= 1) {
    cli::cli_abort(c(
      "x" = "{.arg conf_level} must be a number strictly between 0 and 1.",
      "i" = "You provided: {.val {conf_level}}",
      "i" = "Common choices: {.val 0.90}, {.val 0.95}, {.val 0.99}."
    ))
  }

  # ============================================================
  # FIT MODEL
  # ============================================================

  valid_idx <- complete.cases(x_col, y_col)
  x_clean  <- x_col[valid_idx]
  y_clean  <- y_col[valid_idx]
  n        <- length(x_clean)

  mod         <- lm(y_clean ~ x_clean)
  mod_summary <- summary(mod)

  # ============================================================
  # REGRESSION TABLE
  # ============================================================

  if (table_type == "regression") {

    coef_matrix <- mod_summary$coefficients
    ci_matrix   <- confint(mod, level = conf_level)
    pct         <- conf_level * 100

    table_df <- data.frame(
      Term    = c("Intercept", x_name),
      Coeff   = coef_matrix[, 1],
      SE      = coef_matrix[, 2],
      t_stat  = coef_matrix[, 3],
      p_value = coef_matrix[, 4],
      Lower   = ci_matrix[, 1],
      Upper   = ci_matrix[, 2],
      stringsAsFactors = FALSE
    )

    # Dynamic CI interpretation
    lower_b1 <- round(table_df$Lower[2], 4)
    upper_b1 <- round(table_df$Upper[2], 4)

    if (lower_b1 > 0 && upper_b1 > 0) {
      direction <- "increase"
      b1_str    <- paste("between", lower_b1, "and", upper_b1)
    } else if (lower_b1 < 0 && upper_b1 < 0) {
      direction <- "decrease"
      b1_str    <- paste("between", abs(upper_b1), "and", abs(lower_b1))
    } else {
      direction <- "change"
      b1_str    <- paste("by between", lower_b1, "and", upper_b1)
    }

    interp_text <- paste0(
      "CI Interpretation: We are ", pct,
      "% confident that for every 1 unit increase in ", x_name,
      ", the true population mean ", y_name,
      " will ", direction, " ", b1_str, " units."
    )

    tbl <- gt::gt(table_df) |>
      gt::tab_header(
        title    = gt::md("**Simple Linear Regression Output**"),
        subtitle = gt::md(paste0("Model: **", y_name, "** ~ **", x_name, "**"))
      ) |>
      gt::cols_label(
        Term    = "Term",
        Coeff   = "Coefficient",
        SE      = "Std. Error",
        t_stat  = "t-statistic",
        p_value = "p-value",
        Lower   = paste0("Lower ", pct, "%"),
        Upper   = paste0("Upper ", pct, "%")
      ) |>
      gt::fmt_number(
        columns  = c(Coeff, SE, t_stat, Lower, Upper),
        decimals = 4
      ) |>
      gt::fmt_number(
        columns  = p_value,
        decimals = 4
      ) |>
      gt::sub_small_vals(
        columns   = p_value,
        threshold = 0.0001
      ) |>
      gt::tab_style(
        style     = gt::cell_fill(color = "#2C3E50"),
        locations = gt::cells_column_labels()
      ) |>
      gt::tab_style(
        style     = gt::cell_text(color = "white", weight = "bold"),
        locations = gt::cells_column_labels()
      ) |>
      gt::tab_style(
        style     = list(
          gt::cell_fill(color = "#F2F3F4"),
          gt::cell_borders(
            sides  = "top",
            color  = "#2C3E50",
            weight = gt::px(2)
          )
        ),
        locations = gt::cells_body(rows = 2)
      ) |>
      gt::tab_style(
        style     = gt::cell_text(weight = "bold"),
        locations = gt::cells_body(columns = Term)
      ) |>
      gt::tab_source_note(
        source_note = gt::md(paste0("*", interp_text, "*"))
      ) |>
      gt::tab_options(
        table.width                  = gt::pct(85),
        heading.align                = "left",
        table.border.top.color       = "black",
        table.border.bottom.color    = "black",
        source_notes.font.size       = 12
      )

    return(tbl)
  }

  # ============================================================
  # ANOVA TABLE
  # ============================================================

  if (table_type == "anova") {

    aov_obj  <- anova(mod)
    ss_model <- aov_obj[["Sum Sq"]][1]
    ss_error <- aov_obj[["Sum Sq"]][2]
    ss_total <- ss_model + ss_error
    df_model <- aov_obj[["Df"]][1]
    df_error <- aov_obj[["Df"]][2]
    df_total <- df_model + df_error
    ms_model <- ss_model / df_model
    ms_error <- ss_error / df_error
    f_stat   <- ms_model / ms_error
    p_val    <- aov_obj[["Pr(>F)"]][1]
    r2       <- round(ss_model / ss_total, 4)

    anova_df <- data.frame(
      Source  = c("Model (Regression)", "Error (Residuals)", "Total"),
      SS      = c(ss_model, ss_error, ss_total),
      DF      = c(df_model, df_error, df_total),
      MS      = c(ms_model, ms_error, NA),
      F_stat  = c(f_stat,   NA,       NA),
      P_value = c(p_val,    NA,       NA),
      stringsAsFactors = FALSE
    )

    r2_text <- paste0(
      "R\u00b2 = ", r2, " -- The linear relationship with ", x_name,
      " explains ", r2 * 100, "% of the variability in ", y_name, "."
    )

    tbl <- gt::gt(anova_df) |>
      gt::tab_header(
        title    = gt::md("**ANOVA Table: Simple Linear Regression**"),
        subtitle = gt::md(paste0("Model: **", y_name, "** ~ **", x_name, "**"))
      ) |>
      gt::cols_label(
        Source  = "Source",
        SS      = "Sum of Squares",
        DF      = "df",
        MS      = "Mean Square",
        F_stat  = "F-statistic",
        P_value = "p-value"
      ) |>
      gt::fmt_number(
        columns  = c("SS", "MS"),
        decimals = 4
      ) |>
      gt::fmt_number(
        columns  = "F_stat",
        decimals = 4,
        rows     = 1
      ) |>
      gt::fmt_number(
        columns  = "P_value",
        decimals = 4,
        rows     = 1
      ) |>
      gt::sub_small_vals(
        columns   = "P_value",
        threshold = 0.0001
      ) |>
      gt::sub_missing(
        columns      = c("MS", "F_stat", "P_value"),
        missing_text = "--"
      ) |>
      gt::tab_style(
        style     = gt::cell_fill(color = "#2C3E50"),
        locations = gt::cells_column_labels()
      ) |>
      gt::tab_style(
        style     = gt::cell_text(color = "white", weight = "bold"),
        locations = gt::cells_column_labels()
      ) |>
      gt::tab_style(
        style     = gt::cell_text(weight = "bold"),
        locations = gt::cells_body(columns = "Source")
      ) |>
      gt::tab_style(
        style     = list(
          gt::cell_fill(color = "#F2F3F4"),
          gt::cell_borders(
            sides  = "top",
            color  = "#2C3E50",
            weight = gt::px(2)
          )
        ),
        locations = gt::cells_body(rows = 3)
      ) |>
      gt::tab_source_note(
        source_note = gt::md(paste0("*", r2_text, "*"))
      ) |>
      gt::tab_options(
        table.width               = gt::pct(85),
        heading.align             = "left",
        table.border.top.color    = "black",
        table.border.bottom.color = "black",
        source_notes.font.size    = 12
      )

    return(tbl)
  }
}
