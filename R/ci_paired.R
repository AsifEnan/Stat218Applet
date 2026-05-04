#' Paired Data Confidence Interval
#'
#' @description
#' Constructs a confidence interval for the true mean difference between
#' paired measurements (\eqn{\mu_d}) using one of three methods: the 2SD
#' simulation method, a general simulation method, or a theory-based
#' T-interval.
#'
#' Paired data arises when each subject contributes **two related
#' measurements** -- for example, a before/after reading, a left/right
#' measurement, or two treatments applied to the same subject. Because
#' the two measurements within each pair are linked, we work with the
#' **differences** rather than treating the two groups independently.
#'
#' This function accepts input in **three ways**:
#'
#' - **Summary Statistics:** You already know the mean difference, standard
#'   deviation of differences, and number of pairs. Pass `x_bar_d`, `sd_d`,
#'   and `n_d` directly. Note that `method = "2SD"` and
#'   `method = "simulation"` are not available with summary statistics.
#'
#' - **Single Differences Column:** You have a dataset with one column
#'   containing the pre-computed differences. Use `formula = ~ Differences`
#'   with your data frame.
#'
#' - **Two Columns (Before/After):** You have a dataset with two separate
#'   columns -- one for each measurement. Use `formula = After ~ Before`
#'   and the function computes differences as After minus Before for each
#'   pair automatically.
#'
#' @param x_bar_d The observed sample mean of the differences.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_d The standard deviation of the differences across all pairs.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_d A whole number representing the total number of pairs.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A formula specifying the data structure. Two formats
#'   are accepted:
#'   \describe{
#'     \item{`~ Differences`}{A one-sided formula when your dataset contains
#'       a single column of pre-computed differences.}
#'     \item{`After ~ Before`}{A two-sided formula when your dataset has two
#'       separate measurement columns. Differences are computed as
#'       After minus Before.}
#'   }
#'   **Only used when NOT providing `x_bar_d`, `sd_d`, and `n_d`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   containing the variable(s) named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param name A short descriptive label for what the differences represent.
#'   Used in plot axis labels. For example, `name = "After - Before"`.
#'   Defaults to `"Differences"`.
#' @param conf_level The desired confidence level as a decimal. Default is
#'   `0.95` for a 95% confidence interval. Common choices are `0.90`,
#'   `0.95`, and `0.99`. Note that `method = "2SD"` only works at `0.95`.
#' @param method The method used to construct the confidence interval.
#'   Must be one of:
#'   \describe{
#'     \item{`"2SD"`}{(default) The 2SD Simulation Method. Uses a
#'       sign-flipping bootstrap centered at the observed mean difference.
#'       For each repetition, a coin is flipped for every pair -- heads
#'       flips the sign of that pair's difference, tails leaves it as is.
#'       The interval is \eqn{\bar{x}_d \pm 2 \times SD}.
#'       Can only be used with 95%
#'        confidence interval. Requires raw data.}
#'     \item{`"simulation"`}{The Bootstrap Simulation Method. Same
#'       sign-flipping bootstrap as 2SD, but uses the middle `conf_level`%
#'       of the simulated distribution to find bounds. Works for any
#'       confidence level. Requires raw data.}
#'     \item{`"theory"`}{The Theory-Based T-Interval. Uses the formula
#'       SE = s_d / sqrt(n_d) and the appropriate t* multiplier. Works for
#'       any confidence level and with both summary statistics and raw data.
#'       Degrees of freedom = n_d - 1, handled automatically.}
#'   }
#' @param sim_reps The number of sign-flipping repetitions when
#'   `method = "2SD"` or `method = "simulation"`. Default is `1000`.
#'
#' @return An S3 object of class `stat218_ci_paired` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the interval.}
#'     \item{`plot(result)`}{Shows the bootstrap or theoretical distribution
#'       with the confidence interval shaded and labeled, plus a forest
#'       plot of the interval below.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step construction of the interval with proper fraction
#'       notation.}
#'   }
#'
#' @details
#' ## The Core Idea
#' A paired confidence interval gives a range of plausible values for the
#' true mean difference \eqn{\mu_d}. An interval entirely above zero
#' suggests the "After" measurement tends to be higher; entirely below
#' zero suggests it tends to be lower; an interval containing zero is
#' consistent with no systematic difference.
#'
#' ## Why Paired and Not Two-Sample?
#' Because the two measurements within each pair are linked to the same
#' subject, treating them as independent groups ignores that connection.
#' By working with differences, we control for subject-to-subject
#' variability and gain statistical power.
#'
#' ## The 2SD Method (Sign-Flipping Bootstrap)
#' Under the null hypothesis for a CI, we center the bootstrap at the
#' observed mean difference. For each repetition, a coin is flipped for
#' every pair -- heads flips the sign of that pair's difference (simulating
#' the idea that the two measurements are interchangeable), tails leaves it
#' as is. The SD of the resulting distribution estimates the SE, and the
#' interval is \eqn{\bar{x}_d \pm 2 \times SD}.
#'
#' ## Theory Method
#' Uses the formula SE = s_d / sqrt(n_d) with the t* multiplier from the
#' T-distribution with df = n_d - 1. This is the most reliable approach
#' when validity conditions are met.
#'
#' ## Validity Conditions
#' The theory-based T-interval is most reliable when:
#' - The number of pairs \eqn{n_d \geq 20}, **or**
#' - The distribution of the differences is roughly symmetric.
#'
#' @examples
#' # --- Summary Statistics (theory, default) ---
#' result <- ci_paired(x_bar_d = 4.2, sd_d = 6.8, n_d = 25,
#'                     name = "Post - Pre", method = "theory")
#' print(result)
#' \dontrun{
#' plot(result)
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics (theory, 90% CI) ---
#' result2 <- ci_paired(x_bar_d = 4.2, sd_d = 6.8, n_d = 25,
#'                      name = "Post - Pre", conf_level = 0.90,
#'                      method = "theory")
#' print(result2)
#' \dontrun{
#' plot(result2)
#' plot_steps(result2)
#'}
#'
#' # --- Single Differences Column (2SD method) ---
#' \dontrun{
#' result3 <- ci_paired(formula = ~ extra,
#'                      data = sleep[sleep$group == 1, ],
#'                      name = "Extra Sleep (hours)", method = "2SD")
#' print(result3)
#' }
#' \dontrun{
#' plot(result3)
#' plot_steps(result3)
#'}
#'
#' # --- Two Columns Before/After (simulation, 90% CI) ---
#' study_data <- data.frame(
#'   Before = c(72, 68, 75, 80, 65, 70, 78, 82, 69, 74),
#'   After  = c(78, 72, 80, 84, 70, 75, 82, 85, 73, 79)
#' )
#' result4 <- ci_paired(formula = After ~ Before, data = study_data,
#'                      name = "After - Before", conf_level = 0.90,
#'                      method = "simulation")
#' print(result4)
#' \dontrun{
#' plot(result4)
#' plot_steps(result4)
#'}
#'
#' # --- Two Columns Before/After (theory) ---
#' result5 <- ci_paired(formula = After ~ Before, data = study_data,
#'                      name = "After - Before", method = "theory")
#' print(result5)
#' \dontrun{
#' plot(result5)
#' plot_steps(result5)
#'}
#'
#' @export
ci_paired <- function(x_bar_d = NULL, sd_d = NULL, n_d = NULL,
                      formula = NULL, data = NULL,
                      name = "Differences",
                      conf_level = 0.95,
                      method = "2SD",
                      sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar_d) || !is.null(sd_d) ||
    !is.null(n_d)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (x_bar_d/sd_d/n_d)}.",
      "i" = "These are two different ways to use {.fn ci_paired} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula} and {.arg data}, and remove the summary stat arguments.",
      "*" = "If you only have {.strong summary statistics}: use {.arg x_bar_d}, {.arg sd_d}, and {.arg n_d}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg x_bar_d}, {.arg sd_d}, and {.arg n_d}.",
      "*" = "{.strong Raw data}: provide {.arg formula} and {.arg data}."
    ))
  }

  # Summary stats + simulation/2SD -- not possible
  if (summary_stat_provided && method %in% c("2SD", "simulation")) {
    cli::cli_abort(c(
      "x" = "The {.val {method}} method is not available when using summary statistics.",
      "i" = "The sign-flipping bootstrap requires the individual difference values for each pair.",
      "i" = "Since you only provided summary statistics, there are no individual values to resample from.",
      "i" = "Please either:",
      "*" = "Use {.code method = \"theory\"} with your summary statistics, or",
      "*" = "Provide raw data via {.arg formula} and {.arg data} to use {.val {method}}."
    ))
  }

  # Store raw differences for bootstrap
  raw_diffs <- NULL

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame.",
        "i" = "For a single differences column: {.code ci_paired(formula = ~ Differences, data = your_data)}",
        "i" = "For two columns:                 {.code ci_paired(formula = After ~ Before, data = your_data)}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "Use one of these two formats:",
        "*" = "Single differences column: {.code formula = ~ Differences}",
        "*" = "Two columns (Before/After): {.code formula = After ~ Before}"
      ))
    }

    vars <- all.vars(formula)

    # ---- One-sided formula: ~ Differences ----
    if (length(vars) == 1) {
      diff_var <- vars[1]

      if (!diff_var %in% names(data)) {
        cli::cli_abort(c(
          "x" = "The variable {.val {diff_var}} was not found in your data.",
          "i" = "Available variables are: {.val {names(data)}}."
        ))
      }

      col <- data[[diff_var]]

      if (!is.numeric(col)) {
        cli::cli_abort(c(
          "x" = "The variable {.val {diff_var}} must be numeric.",
          "i" = "It appears to contain non-numeric values. Check your data."
        ))
      }

      raw_diffs <- na.omit(col)

      cli::cli_inform(c(
        "v" = "Using pre-computed differences from variable {.val {diff_var}}.",
        "*" = "Number of pairs (n_d): {length(raw_diffs)}"
      ))

      # ---- Two-sided formula: After ~ Before ----
    } else if (length(vars) == 2) {
      after_var  <- vars[1]
      before_var <- vars[2]

      if (!after_var %in% names(data)) {
        cli::cli_abort(c(
          "x" = "The variable {.val {after_var}} was not found in your data.",
          "i" = "Available variables are: {.val {names(data)}}."
        ))
      }

      if (!before_var %in% names(data)) {
        cli::cli_abort(c(
          "x" = "The variable {.val {before_var}} was not found in your data.",
          "i" = "Available variables are: {.val {names(data)}}."
        ))
      }

      after_col  <- data[[after_var]]
      before_col <- data[[before_var]]

      if (!is.numeric(after_col) || !is.numeric(before_col)) {
        cli::cli_abort(c(
          "x" = "Both variables in the formula must be numeric.",
          "i" = "Check that {.val {after_var}} and {.val {before_var}} contain numbers."
        ))
      }

      if (length(after_col) != length(before_col)) {
        cli::cli_abort(c(
          "x" = "The two columns must have the same number of rows.",
          "i" = "{.val {after_var}} has {length(after_col)} rows, {.val {before_var}} has {length(before_col)} rows."
        ))
      }

      raw_diffs <- na.omit(after_col - before_col)

      cli::cli_inform(c(
        "v" = "Differences computed as {.val {after_var}} minus {.val {before_var}}.",
        "*" = "Number of pairs (n_d): {length(raw_diffs)}"
      ))

    } else {
      cli::cli_abort(c(
        "x" = "The formula must have either one or two variables.",
        "i" = "Use {.code ~ Differences} for a single column, or {.code After ~ Before} for two columns.",
        "i" = "You provided: {.code {deparse(formula)}}"
      ))
    }

    x_bar_d <- mean(raw_diffs)
    sd_d    <- sd(raw_diffs)
    n_d     <- length(raw_diffs)
  }

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  if (!is.numeric(x_bar_d)) {
    cli::cli_abort(c(
      "x" = "{.arg x_bar_d} must be a numeric value.",
      "i" = "You provided: {.val {x_bar_d}}"
    ))
  }

  if (!is.numeric(sd_d) || sd_d <= 0) {
    cli::cli_abort(c(
      "x" = "{.arg sd_d} must be a positive number.",
      "i" = "You provided: {.val {sd_d}}",
      "i" = "Standard deviations cannot be zero or negative."
    ))
  }

  if (!is.numeric(n_d) || n_d != round(n_d) || n_d <= 1) {
    cli::cli_abort(c(
      "x" = "{.arg n_d} must be a whole number greater than 1.",
      "i" = "You provided: {.val {n_d}}"
    ))
  }

  if (!is.numeric(conf_level) || conf_level <= 0 || conf_level >= 1) {
    cli::cli_abort(c(
      "x" = "{.arg conf_level} must be a number between 0 and 1.",
      "i" = "You provided: {.val {conf_level}}",
      "i" = "Common choices are {.val 0.90}, {.val 0.95}, or {.val 0.99}."
    ))
  }

  if (!method %in% c("2SD", "simulation", "theory")) {
    cli::cli_abort(c(
      "x" = "{.arg method} must be one of {.val 2SD}, {.val simulation}, or {.val theory}.",
      "i" = "You provided: {.val {method}}"
    ))
  }

  if (!is.numeric(sim_reps) || sim_reps < 100) {
    cli::cli_abort(c(
      "x" = "{.arg sim_reps} must be a number of at least 100.",
      "i" = "You provided: {.val {sim_reps}}"
    ))
  }

  # 2SD only valid at 95%
  if (method == "2SD" && conf_level != 0.95) {
    cli::cli_abort(c(
      "x" = "The 2SD method is only valid for 95% confidence intervals.",
      "i" = "You requested a {conf_level * 100}% confidence interval.",
      "i" = "The 2SD method uses a multiplier of 2, which only approximates the correct multiplier at 95% confidence.",
      "i" = "To construct a {conf_level * 100}% confidence interval using simulation, please use:",
      " " = "{.code method = \"simulation\"}"
    ))
  }

  # Validity warning for theory method
  if (method == "theory" && n_d < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based T-interval may not be met.",
      "i" = "There are only {n_d} pairs, which is fewer than 20.",
      "i" = "Proceed only if the distribution of differences is roughly symmetric.",
      "i" = "Otherwise consider using {.code method = \"2SD\"} or {.code method = \"simulation\"} if raw data is available."
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  sim_data <- NULL

  if (method %in% c("2SD", "simulation")) {
    # Sign-flipping bootstrap centered at observed mean difference
    sim_data <- replicate(sim_reps, {
      signs <- sample(c(-1, 1), size = n_d, replace = TRUE)
      x_bar_d + mean((raw_diffs - x_bar_d) * signs)
    })

    se        <- sd(sim_data)
    df        <- NA
    dist_type <- "Simulated"

    if (method == "2SD") {
      multiplier <- 2
      me         <- multiplier * se
      lower      <- x_bar_d - me
      upper      <- x_bar_d + me
      calc_type  <- "multiplier"
    } else {
      multiplier <- NA
      me         <- NA
      alpha      <- 1 - conf_level
      lower      <- unname(quantile(sim_data, alpha / 2))
      upper      <- unname(quantile(sim_data, 1 - alpha / 2))
      calc_type  <- "percentile"
    }

  } else {
    # Theory -- T-interval
    se         <- sd_d / sqrt(n_d)
    df         <- n_d - 1
    multiplier <- abs(qt((1 - conf_level) / 2, df = df))
    dist_type  <- "T"
    me         <- multiplier * se
    lower      <- x_bar_d - me
    upper      <- x_bar_d + me
    calc_type  <- "multiplier"
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar_d    = x_bar_d,
    sd_d       = sd_d,
    n_d        = n_d,
    name       = name,
    conf_level = conf_level,
    method     = method,
    calc_type  = calc_type,
    multiplier = multiplier,
    dist_type  = dist_type,
    df         = df,
    se         = se,
    me         = me,
    lower      = lower,
    upper      = upper,
    sim_data   = sim_data,
    raw_diffs  = raw_diffs
  )

  class(res) <- "stat218_ci_paired"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_ci_paired
print.stat218_ci_paired <- function(x, ...) {
  cli::cli_h1("{x$conf_level * 100}% Confidence Interval for Mean Difference ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Point Estimate (x-bar_d): {round(x$x_bar_d, 4)}",
    "i" = "SD of Differences (s_d):  {round(x$sd_d, 4)}",
    "i" = "Number of Pairs (n_d):    {x$n_d}",
    "i" = "SD of Sampling Distribution: {round(x$se, 4)}",
    "*" = "Interval: ({round(x$lower, 4)}, {round(x$upper, 4)})"
  ))

  if (x$method == "theory" && x$n_d < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- fewer than 20 pairs (n_d = {x$n_d}).",
      "i" = "Verify that the distribution of differences is roughly symmetric.",
      "i" = "Consider using {.code method = \"2SD\"} or {.code method = \"simulation\"} if raw data is available."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_ci_paired
plot.stat218_ci_paired <- function(x, ...) {

  pct_label <- paste0(x$conf_level * 100, "%")

  # ---- Forest Plot (bottom) ----
  p_forest <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      ggplot2::aes(x = x$lower, xend = x$upper, y = 0, yend = 0),
      linewidth = 2, color = "#2C3E50") +
    ggplot2::geom_point(
      ggplot2::aes(x = x$x_bar_d, y = 0),
      size = 6, color = "#D55E00") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$lower, y = -0.4, label = round(x$lower, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$upper, y = -0.4, label = round(x$upper, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$x_bar_d, y = 0.4,
                   label = paste("Mean Diff =", round(x$x_bar_d, 4))),
      size = 5, fontface = "bold") +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    ggplot2::labs(
      title = paste0(pct_label, " Confidence Interval"),
      x = paste("Mean of", x$name), y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks.y       = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )

  if (x$calc_type == "multiplier") {
    mid_left  <- (x$lower + x$x_bar_d) / 2
    mid_right <- (x$x_bar_d + x$upper) / 2
    me_label  <- paste("ME =", round(x$me, 4))
    p_forest  <- p_forest +
      ggplot2::geom_text(
        ggplot2::aes(x = mid_left,  y = 0.3, label = me_label),
        size = 4.5, color = "#555555") +
      ggplot2::geom_text(
        ggplot2::aes(x = mid_right, y = 0.3, label = me_label),
        size = 4.5, color = "#555555")
  } else {
    p_forest <- p_forest +
      ggplot2::geom_text(
        ggplot2::aes(x = x$x_bar_d, y = 0.7,
                     label = "Bounds found via Percentiles"),
        size = 4.5, color = "#555555", fontface = "italic")
  }

  # ---- Distribution Plot (top) ----
  if (x$method %in% c("2SD", "simulation")) {

    plot_data       <- data.frame(sim = x$sim_data)
    plot_data$in_ci <- plot_data$sim >= x$lower & plot_data$sim <= x$upper
    ci_mid          <- (x$lower + x$upper) / 2
    y_label_pos     <- max(table(cut(x$sim_data, breaks = 40))) * 0.5

    p_dist <- ggplot2::ggplot(plot_data,
                              ggplot2::aes(x = sim, fill = in_ci)) +
      ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0) +
      ggplot2::geom_vline(xintercept = c(x$lower, x$upper),
                          color = "black", linetype = "dashed",
                          linewidth = 1) +
      ggplot2::annotate("text",
                        x = x$lower, y = Inf, label = round(x$lower, 4),
                        vjust = 2, hjust = 1.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = x$upper, y = Inf, label = round(x$upper, 4),
                        vjust = 2, hjust = -0.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = ci_mid, y = y_label_pos, label = pct_label,
                        size = 7, fontface = "bold", color = "#2C3E50") +
      ggplot2::scale_fill_manual(
        values = c("FALSE" = "gray80", "TRUE" = "#3498DB")) +
      ggplot2::labs(
        title    = "Sign-Flipping Bootstrap Distribution",
        subtitle = paste0("Centered at Observed Mean Difference = ",
                          round(x$x_bar_d, 4)),
        x = paste("Simulated Mean of", x$name),
        y = "Count") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {
    val <- dens <- sim <-  NA

    x_vals    <- seq(x$x_bar_d - 4 * x$se, x$x_bar_d + 4 * x$se,
                     length.out = 1000)
    y_vals    <- dt((x_vals - x$x_bar_d) / x$se, df = x$df) / x$se
    plot_data <- data.frame(val = x_vals, dens = y_vals)
    ci_mid    <- (x$lower + x$upper) / 2
    y_label_pos <- max(y_vals) * 0.5

    p_dist <- ggplot2::ggplot(plot_data,
                              ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data = subset(plot_data, val >= x$lower & val <= x$upper),
        fill = "#3498DB", alpha = 0.5) +
      ggplot2::geom_vline(xintercept = c(x$lower, x$upper),
                          color = "black", linetype = "dashed",
                          linewidth = 1) +
      ggplot2::annotate("text",
                        x = x$lower, y = Inf, label = round(x$lower, 4),
                        vjust = 2, hjust = 1.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = x$upper, y = Inf, label = round(x$upper, 4),
                        vjust = 2, hjust = -0.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = ci_mid, y = y_label_pos, label = pct_label,
                        size = 7, fontface = "bold", color = "#2C3E50") +
      ggplot2::labs(
        title    = paste0("Theoretical T-Distribution (df = ", x$df, ")"),
        subtitle = paste0("Centered at Observed Mean Difference = ",
                          round(x$x_bar_d, 4)),
        x = paste("Mean of", x$name),
        y = "Density") +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.text.y  = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
  }

  # Validity caption
  if (x$method == "theory" && x$n_d < 20) {
    p_dist <- p_dist +
      ggplot2::labs(caption = paste0(
        "Warning: fewer than 20 pairs (n_d = ", x$n_d, "). ",
        "Validity conditions may not be met."
      )) +
      ggplot2::theme(
        plot.caption = ggplot2::element_text(
          color = "#C0392B", face = "bold", size = 9, hjust = 0
        )
      )
  }

  return(p_dist / p_forest + patchwork::plot_layout(heights = c(3, 1)))
}

# ============================================================
# PLOT_STEPS METHOD -- 3-panel patchwork
# ============================================================

#' @export
#' @method plot_steps stat218_ci_paired
plot_steps.stat218_ci_paired <- function(x, ...) {

  pct <- x$conf_level * 100

  # Validity warning -- top of bottom panel
  warning_text <- ""
  if (x$method == "theory" && x$n_d < 20) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "There are fewer than 20 pairs. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "2SD") {
    method_blurb <- paste0(
      "We use the <b>2SD Sign-Flipping Bootstrap</b>. For each repetition, ",
      "a coin is flipped for every pair -- heads flips the sign of that ",
      "pair's difference, tails leaves it as is. The SD of the resulting ",
      "distribution estimates the standard error:<br>",
      "&bull; SD of Sampling Distribution = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = 2 (standard for 95% confidence)<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times SD(\bar{x}_d)$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$ME = 2 \\times ", round(x$se, 4),
             " = ", round(x$me, 4), "$"),
      output = "character"
    )
    use_math_panel <- TRUE

  } else if (x$method == "simulation") {
    method_blurb <- paste0(
      "We use the <b>Bootstrap Simulation Method</b> with sign-flipping. ",
      "Same bootstrap as the 2SD method, but instead of a multiplier, ",
      "we take the middle ", pct, "% of the simulated distribution directly:<br>",
      "&bull; Lower Bound = ", (1 - x$conf_level) / 2 * 100,
      "th percentile = <b>", round(x$lower, 4), "</b><br>",
      "&bull; Upper Bound = ", (1 - (1 - x$conf_level) / 2) * 100,
      "th percentile = <b>", round(x$upper, 4), "</b>"
    )
    use_math_panel <- FALSE

  } else {
    method_blurb <- paste0(
      "We use the <b>Theory-Based T-Interval</b>. The standard error of ",
      "the mean difference is computed from s<sub>d</sub> and n<sub>d</sub>. ",
      "The T-distribution with df = ", x$df,
      " provides the multiplier for ", pct, "% confidence.<br>",
      "&bull; SD of Sampling Distribution = s<sub>d</sub> / &radic;n<sub>d</sub>",
      " = ", round(x$sd_d, 4), " / &radic;", x$n_d,
      " = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = ", round(x$multiplier, 3),
      " (from the T-distribution with df = ", x$df, ")<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times \frac{s_d}{\sqrt{n_d}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$ME = ", round(x$multiplier, 3),
             " \\times \\frac{", round(x$sd_d, 4),
             "}{\\sqrt{", x$n_d, "}} = ", round(x$me, 4), "$"),
      output = "character"
    )
    use_math_panel <- TRUE
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Confidence Interval Construction</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data (Differences)</b></span><br>",
    "&bull; <b>Mean Difference (x&#772;<sub>d</sub>):</b> ", round(x$x_bar_d, 4), "<br>",
    "&bull; <b>SD of Differences (s<sub>d</sub>):</b> ", round(x$sd_d, 4), "<br>",
    "&bull; <b>Number of Pairs (n<sub>d</sub>):</b> ", x$n_d, "<br><br>",

    "<span style='font-size:14pt;'><b>2. The Margin of Error</b></span><br>",
    method_blurb
  )

  p_top <- ggplot2::ggplot() +
    ggtext::geom_textbox(
      ggplot2::aes(x = 0, y = 1, label = top_html),
      width = ggplot2::unit(0.95, "npc"),
      hjust = 0, vjust = 1,
      box.color = NA, fill = NA,
      size = 5, lineheight = 1.5
    ) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.8, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 20, r = 20, b = 0, l = 20))

  # ---- PANEL 2: Math equations ----
  if (use_math_panel) {
    p_math_data <- data.frame(
      x     = c(0.1, 0.1),
      y     = c(3.0, 0),
      label = c(tex_formula, tex_calc)
    )
    p_math <- ggplot2::ggplot(p_math_data,
                              ggplot2::aes(x = x, y = y, label = label)) +
      ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-1.5, 4.5),
                               clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20,
                                                   b = 10, l = 40))
  } else {
    p_math <- ggplot2::ggplot() + ggplot2::theme_void()
  }

  # ---- PANEL 3: Bottom HTML -- warning at top ----
  if (x$calc_type == "multiplier") {
    interval_html <- paste0(
      "<b>Confidence Interval</b> = x&#772;<sub>d</sub> &plusmn; ME<br>",
      "CI = ", round(x$x_bar_d, 4), " &plusmn; ", round(x$me, 4),
      " &rarr; <b>(", round(x$lower, 4), ", ", round(x$upper, 4), ")</b>"
    )
  } else {
    interval_html <- paste0(
      "<b>Confidence Interval: (",
      round(x$lower, 4), ", ", round(x$upper, 4), ")</b>"
    )
  }

  bottom_html <- paste0(
    warning_text,
    "<span style='font-size:14pt;'><b>3. The Interval</b></span><br>",
    interval_html, "<br><br>",
    "<i>Practical Interpretation:</i> We are ", pct,
    "% confident that the true population mean difference (&mu;<sub>d</sub>) is between ",
    round(x$lower, 4), " and ", round(x$upper, 4), ".<br>",
    "<i>Frequentist Interpretation:</i> If we were to take 100 random ",
    "samples of paired data and calculate a confidence interval for each, ",
    "we would expect approximately ", pct,
    " of those intervals to contain the true mean difference."
  )

  p_bottom <- ggplot2::ggplot() +
    ggtext::geom_textbox(
      ggplot2::aes(x = 0, y = 1, label = bottom_html),
      width = ggplot2::unit(0.95, "npc"),
      hjust = 0, vjust = 1,
      box.color = NA, fill = NA,
      size = 5, lineheight = 1.5
    ) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.15, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 20,
                                                 b = 20, l = 20))

  if (use_math_panel) {
    return(
      p_top / p_math / p_bottom +
        patchwork::plot_layout(heights = c(2.6, 1.2, 3.2))
    )
  } else {
    return(
      p_top / p_bottom +
        patchwork::plot_layout(heights = c(3, 2))
    )
  }
}
