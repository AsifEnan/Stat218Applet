#' Explore the Relationship Between Two Variables
#'
#' @description
#' Produces an appropriate visualization and summary statistics for the
#' relationship between two variables. The function automatically detects
#' variable types and routes to the correct display mode:
#'
#' - **Both numeric** -- Scatterplot with crosshairs and correlation
#'   annotation (correlation mode), or a regression line with equation
#'   panel (regression mode). An optional `group` argument produces
#'   separate colored points and lines per group.
#'
#' - **Numeric response, categorical explanatory** -- Side-by-side
#'   boxplots with individual points overlaid, group means marked, and
#'   group sample sizes annotated. Use this before running
#'   `test_2mean()` or `ci_2mean()`.
#'
#' This function accepts input via `formula` and `data` only.
#'
#' @param formula A two-sided formula of the form `response ~ explanatory`.
#'   The response variable (`y`) is placed on the vertical axis and the
#'   explanatory variable (`x`) on the horizontal axis. Both quantitative
#'   and categorical explanatory variables are supported. For example:
#'   \itemize{
#'     \item \code{formula = gpa ~ hours} (both numeric -- scatterplot)
#'     \item \code{formula = time ~ frame} (numeric ~ categorical -- boxplot)
#'   }
#' @param data A data frame containing the variables named in `formula`
#'   and, optionally, the variable named in `group`.
#' @param group An optional character string naming a categorical column
#'   in `data` to use for grouping. Only applies when both variables are
#'   numeric. When supplied, separate colored points, crosshairs
#'   (correlation mode), or regression lines (regression mode) are drawn
#'   for each group level. For example, `group = "Sex"` if `data` has a
#'   column called `Sex`. Default is `NULL` (no grouping).
#' @param fit_line Logical. Only applies when both variables are numeric.
#'   Controls which display mode is used:
#'   \describe{
#'     \item{`FALSE`}{(default) **Correlation Mode** -- draws crosshairs at
#'       the sample means and annotates the correlation coefficient. Use
#'       this first to assess the form, direction, and strength of the
#'       association before running `test_correlation()`.}
#'     \item{`TRUE`}{**Regression Mode** -- overlays the least-squares
#'       regression line and displays the fitted equation and \eqn{R^2}
#'       in a second panel. Use this before running `test_regression()`.}
#'   }
#'   When the explanatory variable is categorical, `fit_line` is ignored
#'   and a boxplot is always produced.
#'
#' @return A `ggplot2` object (correlation or boxplot mode) or a
#'   `patchwork` object combining the scatterplot and equation panel
#'   (regression mode). The result can be further customized with
#'   standard `ggplot2` functions if needed.
#'
#' @details
#' ## When to Use This Function
#' Always explore your data visually before running a formal inference
#' procedure. `explore_2vars()` is designed to be the natural first step:
#'
#' - Before `test_2mean()` or `ci_2mean()`: use
#'   `explore_2vars(formula = response ~ group, data = mydata)` to see
#'   side-by-side boxplots of the two groups.
#' - Before `test_correlation()`: use
#'   `explore_2vars(formula = y ~ x, data = mydata)` to check for a
#'   linear relationship.
#' - Before `test_regression()`: use
#'   `explore_2vars(formula = y ~ x, data = mydata, fit_line = TRUE)` to
#'   see the regression line and equation.
#'
#' ## Boxplot Mode (Numeric Response ~ Categorical Explanatory)
#' When the explanatory variable is categorical, the function produces:
#' - Side-by-side boxplots for each group
#' - Individual data points overlaid (jittered to avoid overlap)
#' - A red triangle marking the group mean
#' - Group sample sizes annotated below each box
#' - A subtitle summarizing the mean and SD for each group
#'
#' ## Correlation Strength Interpretation
#' In correlation mode, the subtitle automatically interprets \eqn{r}:
#' - \eqn{|r| \geq 0.7}: **Strong**
#' - \eqn{0.4 \leq |r| < 0.7}: **Moderate**
#' - \eqn{|r| < 0.4}: **Weak**
#'
#' Direction is described as **Positive** (\eqn{r > 0}) or
#' **Negative** (\eqn{r < 0}).
#'
#' ## Regression Equation Panel
#' In regression mode, the lower panel displays:
#' - The general form: \eqn{\hat{y} = b_0 + b_1 x}
#' - The specific fitted equation with numeric coefficients
#' - The correlation coefficient \eqn{r} and \eqn{R^2}
#'
#' When `group` is supplied, separate equations are shown for each group.
#'
#' @examples
#' # --- Boxplot Mode: numeric response, categorical explanatory ---
#' # Do carbon and steel bike frames produce different ride times?
#' explore_2vars(
#'   formula = time ~ frame,
#'   data    = biketimes
#' )
#'
#' # Do breastfed children have higher GCI scores?
#' explore_2vars(
#'   formula = gci ~ feeding,
#'   data    = breastfeedintell
#' )
#'
#' # --- Correlation Mode: both numeric ---
#' # Is there a linear association between body temp and heart rate?
#' explore_2vars(
#'   formula = heart_rate ~ body_temp,
#'   data    = tempheart
#' )
#'
#' # --- Regression Mode: both numeric ---
#' # How well does study time predict GPA?
#' explore_2vars(
#'   formula  = gpa ~ hours,
#'   data     = gpa,
#'   fit_line = TRUE
#' )
#'
#' # --- Regression Mode with Grouping ---
#' \dontrun{
#' mtcars$engine_type <- ifelse(mtcars$vs == 0, "V-Shaped", "Straight")
#' explore_2vars(
#'   formula  = mpg ~ wt,
#'   data     = mtcars,
#'   group    = "engine_type",
#'   fit_line = TRUE
#' )
#' }
#'
#' @export
explore_2vars <- function(formula, data, group = NULL, fit_line = FALSE) {

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  if (missing(formula) || is.null(formula)) {
    cli::cli_abort(c(
      "x" = "No formula was provided.",
      "i" = "Please supply a two-sided formula like {.code formula = response ~ explanatory}.",
      "i" = "For example: {.code explore_2vars(formula = gpa ~ hours, data = your_data)}"
    ))
  }

  if (missing(data) || is.null(data)) {
    cli::cli_abort(c(
      "x" = "No data was provided.",
      "i" = "Please supply a data frame using the {.arg data} argument.",
      "i" = "For example: {.code explore_2vars(formula = gpa ~ hours, data = your_data)}"
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

  # Response must always be numeric
  if (!is.numeric(y_col)) {
    cli::cli_abort(c(
      "x" = "The response variable {.val {y_name}} must be numeric.",
      "i" = "It appears to contain non-numeric values.",
      "i" = "If you have two categorical variables, use {.fn test_2prop} instead."
    ))
  }

  # Detect whether explanatory is numeric or categorical
  x_is_numeric <- is.numeric(x_col)

  # ============================================================
  # ROUTE: Categorical explanatory -> BOXPLOT MODE
  # ============================================================

  if (!x_is_numeric) {

    valid_idx <- complete.cases(x_col, y_col)
    df_clean  <- data.frame(
      x = as.factor(x_col[valid_idx]),
      y = y_col[valid_idx]
    )

    # Inform if fit_line was requested -- does not apply here
    if (fit_line) {
      cli::cli_inform(c(
        "i" = "{.arg fit_line = TRUE} is not used when the explanatory variable is categorical.",
        "i" = "Producing side-by-side boxplots instead."
      ))
    }

    # Inform if group was requested -- does not apply here
    if (!is.null(group)) {
      cli::cli_inform(c(
        "i" = "{.arg group} is not used in boxplot mode.",
        "i" = "The grouping is already defined by {.val {x_name}}."
      ))
    }

    # Build group summary for subtitle
    group_levels  <- levels(df_clean$x)
    summary_parts <- vapply(group_levels, function(g) {
      sub_y <- df_clean$y[df_clean$x == g]
      paste0(g, ": mean = ", round(mean(sub_y), 2),
             ", SD = ", round(stats::sd(sub_y), 2),
             ", n = ", length(sub_y))
    }, character(1))
    subtitle_text <- paste(summary_parts, collapse = "  |  ")

    # Group means for triangle markers
    group_means <- tapply(df_clean$y, df_clean$x, mean)
    means_df    <- data.frame(
      x = factor(names(group_means), levels = group_levels),
      y = as.numeric(group_means)
    )

    # Group sample sizes for annotation below boxes
    group_ns <- tapply(df_clean$y, df_clean$x, length)
    y_min    <- min(df_clean$y, na.rm = TRUE)
    y_range  <- diff(range(df_clean$y, na.rm = TRUE))
    ns_df    <- data.frame(
      x     = factor(names(group_ns), levels = group_levels),
      label = paste0("n = ", as.numeric(group_ns)),
      y     = y_min - y_range * 0.08
    )

    p <- ggplot2::ggplot(df_clean, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_boxplot(
        fill          = "#AED6F1",
        color         = "#2C3E50",
        width         = 0.5,
        outlier.shape = NA
      ) +
      ggplot2::geom_jitter(
        width = 0.15,
        size  = 2,
        alpha = 0.5,
        color = "#2C3E50"
      ) +
      ggplot2::geom_point(
        data  = means_df,
        ggplot2::aes(x = x, y = y),
        shape = 17,
        size  = 4,
        color = "#C0392B"
      ) +
      ggplot2::geom_text(
        data     = ns_df,
        ggplot2::aes(x = x, y = y, label = label),
        size     = 4,
        color    = "#555555",
        fontface = "italic"
      ) +
      ggplot2::labs(
        title    = "Side-by-Side Boxplots",
        subtitle = subtitle_text,
        x        = x_name,
        y        = y_name,
        caption  = "Red triangle = group mean"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        plot.title    = ggplot2::element_text(size = 16, face = "bold"),
        plot.subtitle = ggplot2::element_text(size = 11, color = "#555555"),
        plot.caption  = ggplot2::element_text(size = 10, color = "#C0392B",
                                              face = "italic", hjust = 0)
      )

    return(p)
  }

  # ============================================================
  # ROUTE: Both numeric -> existing scatterplot behavior
  # ============================================================

  # ---- Build clean data frame ----
  if (!is.null(group)) {

    if (!group %in% names(data)) {
      cli::cli_abort(c(
        "x" = "The grouping variable {.val {group}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    group_col <- data[[group]]
    valid_idx <- complete.cases(x_col, y_col, group_col)
    df_clean  <- data.frame(
      x     = x_col[valid_idx],
      y     = y_col[valid_idx],
      group = as.factor(group_col[valid_idx])
    )

  } else {

    valid_idx <- complete.cases(x_col, y_col)
    df_clean  <- data.frame(
      x = x_col[valid_idx],
      y = y_col[valid_idx]
    )
  }

  # ============================================================
  # HELPER: Interpret correlation strength
  # ============================================================

  interpret_r <- function(r_val) {
    dir   <- ifelse(r_val > 0, "Positive", "Negative")
    abs_r <- abs(r_val)
    str   <- ifelse(abs_r >= 0.7, "Strong",
                    ifelse(abs_r >= 0.4, "Moderate", "Weak"))
    paste0("Form: Linear | Direction: ", dir, " | Strength: ", str,
           "  (r = ", round(r_val, 3), ")")
  }

  # ============================================================
  # BASE SCATTERPLOT
  # ============================================================

  if (is.null(group)) {
    p_top <- ggplot2::ggplot(df_clean, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_point(size = 3, color = "#2C3E50", alpha = 0.7)
  } else {
    p_top <- ggplot2::ggplot(df_clean, ggplot2::aes(x = x, y = y,
                                                    color = group)) +
      ggplot2::geom_point(size = 3, alpha = 0.7) +
      ggplot2::labs(color = group)
  }

  p_top <- p_top +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = x_name, y = y_name) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(size = 16, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 12, color = "#555555")
    )

  # ============================================================
  # MODE ROUTING
  # ============================================================

  if (!fit_line) {

    # ==========================================
    # CORRELATION MODE
    # ==========================================

    x_bar     <- mean(df_clean$x)
    y_bar     <- mean(df_clean$y)
    r_overall <- stats::cor(df_clean$x, df_clean$y)

    p_top <- p_top +
      ggplot2::geom_vline(xintercept = x_bar, linetype = "dashed",
                          color = "gray50") +
      ggplot2::geom_hline(yintercept = y_bar, linetype = "dashed",
                          color = "gray50") +
      ggplot2::labs(
        title    = "Scatterplot & Correlation Analysis",
        subtitle = interpret_r(r_overall)
      )

    if (!is.null(group)) {
      group_caps <- c()
      for (g in levels(df_clean$group)) {
        sub_df <- df_clean[df_clean$group == g, ]
        r_g    <- round(stats::cor(sub_df$x, sub_df$y), 3)
        group_caps <- c(group_caps, paste0(g, ": r = ", r_g))
      }
      cap_text <- paste("Group Correlations:",
                        paste(group_caps, collapse = "  |  "))
      p_top <- p_top +
        ggplot2::labs(caption = cap_text) +
        ggplot2::theme(
          plot.caption = ggplot2::element_text(
            size = 12, hjust = 0, face = "bold", color = "#2C3E50"
          )
        )
    }

    return(p_top)

  } else {

    # ==========================================
    # REGRESSION MODE
    # ==========================================

    if (is.null(group)) {
      r2       <- round(summary(stats::lm(y ~ x, data = df_clean))$r.squared, 3)
      sub_text <- paste0(r2 * 100, "% of the variability in ", y_name,
                         " is explained by its linear relationship with ",
                         x_name, ".")
      p_top <- p_top +
        ggplot2::geom_smooth(method = "lm", se = FALSE,
                             color = "#C0392B", linewidth = 1.2) +
        ggplot2::labs(title    = "Simple Linear Regression Analysis",
                      subtitle = sub_text)
    } else {
      p_top <- p_top +
        ggplot2::geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
        ggplot2::labs(title    = "Simple Linear Regression Analysis",
                      subtitle = "Separate lines of best fit shown for each group.")
    }

    # ---- Build equation panel using native R plotmath ----
    math_labels <- data.frame(
      x     = numeric(),
      y     = numeric(),
      label = character(),
      stringsAsFactors = FALSE
    )
    curr_y <- 0
    y_step <- 1.5

    if (is.null(group)) {
      mod   <- stats::lm(y ~ x, data = df_clean)
      b0    <- round(stats::coef(mod)[1], 3)
      b1    <- round(stats::coef(mod)[2], 3)
      r2    <- round(summary(mod)$r.squared, 3)
      r_val <- round(stats::cor(df_clean$x, df_clean$y), 3)

      if (b1 < 0) {
        spec_eq <- paste0('widehat("', y_name, '") == ', b0,
                          ' - ', abs(b1), ' * ("', x_name, '")')
      } else {
        spec_eq <- paste0('widehat("', y_name, '") == ', b0,
                          ' + ', abs(b1), ' * ("', x_name, '")')
      }

      math_labels <- rbind(math_labels,
                           data.frame(x = 0, y = curr_y,
                                      label = "bold('Overall Linear Model')"))
      curr_y <- curr_y - y_step
      math_labels <- rbind(math_labels,
                           data.frame(x = 0.05, y = curr_y,
                                      label = "hat(y) == b[0] + b[1]*x"))
      curr_y <- curr_y - y_step
      math_labels <- rbind(math_labels,
                           data.frame(x = 0.05, y = curr_y, label = spec_eq))
      curr_y <- curr_y - y_step
      math_labels <- rbind(math_labels,
                           data.frame(x = 0.05, y = curr_y,
                                      label = paste0("r == ", r_val,
                                                     " ~~~~~~~~~ R^2 == ", r2)))

    } else {

      for (g in levels(df_clean$group)) {
        sub_df <- df_clean[df_clean$group == g, ]
        mod_g  <- stats::lm(y ~ x, data = sub_df)
        b0_g   <- round(stats::coef(mod_g)[1], 3)
        b1_g   <- round(stats::coef(mod_g)[2], 3)
        r2_g   <- round(summary(mod_g)$r.squared, 3)
        r_g    <- round(stats::cor(sub_df$x, sub_df$y), 3)

        if (b1_g < 0) {
          spec_eq <- paste0('widehat("', y_name, '") == ', b0_g,
                            ' - ', abs(b1_g), ' * ("', x_name, '")')
        } else {
          spec_eq <- paste0('widehat("', y_name, '") == ', b0_g,
                            ' + ', abs(b1_g), ' * ("', x_name, '")')
        }

        math_labels <- rbind(math_labels,
                             data.frame(x = 0, y = curr_y,
                                        label = paste0("bold('Group: ", g, "')")))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels,
                             data.frame(x = 0.05, y = curr_y,
                                        label = "hat(y) == b[0] + b[1]*x"))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels,
                             data.frame(x = 0.05, y = curr_y, label = spec_eq))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels,
                             data.frame(x = 0.05, y = curr_y,
                                        label = paste0("r == ", r_g,
                                                       " ~~~~~~~~~ R^2 == ", r2_g)))
        curr_y <- curr_y - 2.5
      }
    }

    p_bottom <- ggplot2::ggplot(math_labels,
                                ggplot2::aes(x = x, y = y, label = label)) +
      ggplot2::geom_text(parse = TRUE, size = 5, hjust = 0) +
      ggplot2::coord_cartesian(xlim = c(0, 1),
                               ylim = c(curr_y - 1, 1), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20,
                                                   b = 20, l = 40))

    return(p_top / p_bottom + patchwork::plot_layout(heights = c(3, 1.8)))
  }
}
