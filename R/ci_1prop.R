#' 1-Sample Proportion Confidence Interval
#'
#' @description
#' Constructs a confidence interval for a single population proportion
#' (\eqn{\pi}) using one of three methods: the 2SD simulation method, a
#' general simulation method, or a theory-based approach.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the number of successes and
#'   the sample size. Pass `successes` and `n` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R. Pass `formula`,
#'   `data`, and `success_level` instead, and the function counts the
#'   successes for you automatically.
#'
#' @param successes A whole number representing the count of successes
#'   observed in your sample. For example, if 42 out of 80 students passed,
#'   `successes = 42`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n A whole number representing the total sample size.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A one-sided formula of the form `~ variable` identifying
#'   the categorical variable in your dataset. For example,
#'   `formula = ~ Passed`.
#'   **Only used when NOT providing `successes` and `n`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   containing the variable named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param success_level A character string specifying which value of your
#'   categorical variable counts as a "success". For example, if your
#'   variable contains `"Yes"` and `"No"`, use `success_level = "Yes"`.
#'   **Required when using `formula` and `data`.**
#' @param conf_level The desired confidence level as a decimal. Default is
#'   `0.95` for a 95% confidence interval. Common choices are `0.90`,
#'   `0.95`, and `0.99`. Note that `method = "2SD"` only works at `0.95`.
#' @param method The method used to construct the confidence interval.
#'   Must be one of:
#'   \describe{
#'     \item{`"2SD"`}{(default) The 2SD Simulation Method. A bootstrap
#'       distribution is generated centered at `p_hat` by drawing repeated
#'       samples of size `n` from a population with proportion `p_hat`.
#'       The interval is \eqn{\hat{p} \pm 2 \times SD(\hat{p})}. Only
#'       valid for 95% confidence. Use `method = "simulation"` for other
#'       confidence levels.}
#'     \item{`"simulation"`}{The Bootstrap Simulation Method. Same
#'       bootstrap as 2SD, but uses the middle `conf_level`% of the
#'       simulated distribution to find bounds directly. Works for any
#'       confidence level.}
#'     \item{`"theory"`}{The Theory-Based Method. Uses the formula
#'       \eqn{SE = \sqrt{\hat{p}(1-\hat{p})/n}} and the appropriate
#'       Z* multiplier. Works for any confidence level. Requires validity
#'       conditions: at least 10 expected successes and 10 expected
#'       failures in the sample.}
#'   }
#' @param sim_reps The number of bootstrap samples when `method = "2SD"` or
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
#'   a more stable interval.
#' @note To display the bootstrap distribution as a dotplot instead of a
#'   histogram, use \code{plot(result, plot_type = "dotplot")} after
#'   running this function. Only available for \code{method = "2SD"} or
#'   \code{method = "simulation"}.
#'
#' @return An S3 object of class `stat218_1prop_ci` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the interval.}
#'     \item{`plot(result)`}{Shows the bootstrap or theoretical distribution
#'       with the confidence interval shaded and labeled, plus a forest
#'       plot of the interval below. Use `plot(result, plot_type = "dotplot")`
#'       for a dot plot of the bootstrap distribution (simulation methods
#'       only).}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step construction of the interval.}
#'   }
#'
#' @details
#' ## The Core Idea
#' A confidence interval gives a range of plausible values for the true
#' population proportion \eqn{\pi}. Rather than reporting just \eqn{\hat{p}},
#' we acknowledge sampling variability and say: *"We are X% confident the
#' true proportion falls somewhere in this range."*
#'
#' ## The 2SD Method
#' The book's primary simulation-based approach for 95% confidence intervals.
#' We simulate the sampling distribution of \eqn{\hat{p}} by drawing many
#' bootstrap samples from a population where the true proportion equals our
#' observed \eqn{\hat{p}}. The interval is constructed as
#' \eqn{\hat{p} \pm 2 \times SD} of that distribution. The multiplier of 2
#' is an approximation of the true 1.96 used in theory.
#'
#' ## Theory Method
#' Uses the formula \eqn{SE = \sqrt{\hat{p}(1-\hat{p})/n}} and the
#' appropriate Z* multiplier. Requires:
#' - At least 10 successes in the sample (\eqn{n \cdot \hat{p} \geq 10})
#' - At least 10 failures in the sample (\eqn{n \cdot (1-\hat{p}) \geq 10})
#'
#' @examples
#' # --- Summary Statistics (2SD method, default) ---
#' result <- ci_1prop(successes = 42, n = 80)
#' print(result)
#' \dontrun{
#' plot(result)
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics (theory, 95% CI) ---
#' result2 <- ci_1prop(successes = 42, n = 80,
#'                     conf_level = 0.95, method = "theory")
#' print(result2)
#'\dontrun{
#' plot(result2)
#' plot_steps(result2)
#'}
#'
#' # --- Summary Statistics (simulation, 90% CI) ---
#' result3 <- ci_1prop(successes = 42, n = 80,
#'                     conf_level = 0.90, method = "simulation")
#' print(result3)
#'\dontrun{
#' plot(result3)
#' plot_steps(result3)
#'}
#'
#' # --- Raw Data (2SD method) ---
#' car_data <- mtcars
#' car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
#' result4 <- ci_1prop(formula = ~ transmission, data = car_data,
#'                     success_level = "Manual", method = "2SD")
#' print(result4)
#' \dontrun{
#' plot(result4)
#' plot_steps(result4)
#'}
#'
#' # --- Raw Data (theory) ---
#' result5 <- ci_1prop(formula = ~ transmission, data = car_data,
#'                     success_level = "Manual", method = "theory")
#' print(result5)
#' \dontrun{
#' plot(result5)
#' plot_steps(result5)
#'}
#'
#' @export
ci_1prop <- function(successes = NULL, n = NULL,
                     formula = NULL, data = NULL,
                     success_level = NULL,
                     conf_level = 0.95,
                     method = "2SD",
                     sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(successes) || !is.null(n)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (successes/n)}.",
      "i" = "These are two different ways to use {.fn ci_1prop} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula}, {.arg data}, and {.arg success_level}, and remove {.arg successes} and {.arg n}.",
      "*" = "If you only have {.strong summary statistics}: use {.arg successes} and {.arg n}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg successes} and {.arg n}.",
      "*" = "{.strong Raw data}: provide {.arg formula}, {.arg data}, and {.arg success_level}."
    ))
  }

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code ci_1prop(formula = ~ YourVariable, data = your_data, success_level = \"Yes\")}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "Please specify which variable to analyze. For example:",
        " " = "{.code ci_1prop(formula = ~ YourVariable, data = your_data, success_level = \"Yes\")}"
      ))
    }

    if (is.null(success_level)) {
      cli::cli_abort(c(
        "x" = "You must specify {.arg success_level} when using raw data.",
        "i" = "This tells the function which value of your variable counts as a success.",
        "i" = "For example, if your variable has values {.val Yes} and {.val No}, use:",
        " " = "{.code success_level = \"Yes\"}"
      ))
    }

    var_name <- all.vars(formula)

    if (length(var_name) != 1) {
      cli::cli_abort(c(
        "x" = "The formula must reference exactly one variable, like {.code ~ YourVariable}.",
        "i" = "You provided: {.code {deparse(formula)}}"
      ))
    }

    if (!var_name %in% names(data)) {
      cli::cli_abort(c(
        "x" = "The variable {.val {var_name}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    col <- data[[var_name]]

    if (!success_level %in% col) {
      cli::cli_abort(c(
        "x" = "The success level {.val {success_level}} was not found in the variable {.val {var_name}}.",
        "i" = "The values present in {.val {var_name}} are: {.val {unique(col)}}."
      ))
    }

    n         <- sum(!is.na(col))
    successes <- sum(col == success_level, na.rm = TRUE)

    cli::cli_inform(c(
      "v" = "Data extracted from variable {.val {var_name}}:",
      "*" = "Success level: {.val {success_level}}",
      "*" = "Successes: {successes}  |  Sample size (n): {n}"
    ))
  }

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  if (!is.numeric(successes) || successes != round(successes) || successes < 0) {
    cli::cli_abort(c(
      "x" = "{.arg successes} must be a non-negative whole number.",
      "i" = "You provided: {.val {successes}}"
    ))
  }

  if (!is.numeric(n) || n != round(n) || n <= 0) {
    cli::cli_abort(c(
      "x" = "{.arg n} must be a positive whole number.",
      "i" = "You provided: {.val {n}}"
    ))
  }

  if (successes > n) {
    cli::cli_abort(c(
      "x" = "The number of successes ({successes}) cannot be greater than the sample size n ({n}).",
      "i" = "Please double-check your values."
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

  # 2SD method only valid at 95%
  if (method == "2SD" && conf_level != 0.95) {
    cli::cli_abort(c(
      "x" = "The 2SD method is only valid for 95% confidence intervals.",
      "i" = "You requested a {conf_level * 100}% confidence interval.",
      "i" = "The 2SD method uses a multiplier of 2, which only approximates the correct multiplier at 95% confidence.",
      "i" = "To construct a {conf_level * 100}% confidence interval using simulation, please use:",
      " " = "{.code method = \"simulation\"}"
    ))
  }

  # Compute p_hat
  p_hat <- successes / n

  # Validity condition warning for theory method
  if (method == "theory") {
    exp_success <- n * p_hat
    exp_failure <- n * (1 - p_hat)
    if (exp_success < 10 || exp_failure < 10) {
      cli::cli_warn(c(
        "!" = "Validity conditions for the theory-based interval may not be met.",
        "i" = "Observed successes: {successes} (need \u2265 10)",
        "i" = "Observed failures:  {n - successes} (need \u2265 10)",
        "i" = "Consider using {.code method = \"2SD\"} or {.code method = \"simulation\"} instead."
      ))
    }
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  if (method == "2SD" || method == "simulation") {
    sim_data  <- rbinom(sim_reps, size = n, prob = p_hat) / n
    se        <- sd(sim_data)

    if (method == "2SD") {
      multiplier <- 2
      me         <- multiplier * se
      lower      <- p_hat - me
      upper      <- p_hat + me
      calc_type  <- "multiplier"
    } else {
      multiplier <- NA
      me         <- NA
      alpha      <- 1 - conf_level
      lower      <- unname(quantile(sim_data, alpha / 2))
      upper      <- unname(quantile(sim_data, 1 - alpha / 2))
      calc_type  <- "percentile"
    }

  } else if (method == "theory") {
    sim_data   <- NULL
    se         <- sqrt((p_hat * (1 - p_hat)) / n)
    multiplier <- abs(qnorm((1 - conf_level) / 2))
    me         <- multiplier * se
    lower      <- p_hat - me
    upper      <- p_hat + me
    calc_type  <- "multiplier"
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    successes  = successes,
    n          = n,
    p_hat      = p_hat,
    conf_level = conf_level,
    method     = method,
    calc_type  = calc_type,
    multiplier = multiplier,
    se         = se,
    me         = me,
    lower      = lower,
    upper      = upper,
    sim_data   = sim_data
  )

  class(res) <- "stat218_1prop_ci"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_1prop_ci
print.stat218_1prop_ci <- function(x, ...) {
  cli::cli_h1("{x$conf_level * 100}% Confidence Interval ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Point Estimate (p-hat): {round(x$p_hat, 4)}  ({x$successes} successes out of n = {x$n})",
    "i" = "SD of Sampling Distribution: {round(x$se, 4)}",
    "*" = "Interval: ({round(x$lower, 4)}, {round(x$upper, 4)})"
  ))

  if (x$method == "theory") {
    if (x$successes < 10 || (x$n - x$successes) < 10) {
      cli::cli_warn(c(
        "!" = "Validity conditions may not be met.",
        "i" = "Observed successes: {x$successes} | Observed failures: {x$n - x$successes} (both need \u2265 10).",
        "i" = "Consider using {.code method = \"2SD\"} or {.code method = \"simulation\"}."
      ))
    }
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' Plot Method for ci_1prop Results
#'
#' @param x A \code{stat218_1prop_ci} result object from \code{ci_1prop()}.
#' @param plot_type The type of plot for the bootstrap distribution.
#'   Must be \code{"histogram"} (default) or \code{"dotplot"}.
#'   Only available when \code{method = "2SD"} or \code{method = "simulation"}.
#' @param ... Additional arguments (currently unused).
#' @export
#' @method plot stat218_1prop_ci
plot.stat218_1prop_ci <- function(x, plot_type = "histogram", ...) {

  pct_label <- paste0(x$conf_level * 100, "%")

  # Dotplot only available for simulation methods
  if (plot_type == "dotplot" && x$method == "theory") {
    cli::cli_abort(c(
      "x" = "The dotplot is only available for simulation-based methods.",
      "i" = "You used {.code method = \"theory\"}, which produces a continuous curve.",
      "i" = "Use {.code plot(result)} for the default histogram, or rerun with {.code method = \"2SD\"} or {.code method = \"simulation\"}."
    ))
  }

  # ---- Forest Plot (bottom) ----
  p_forest <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      ggplot2::aes(x = x$lower, xend = x$upper, y = 0, yend = 0),
      linewidth = 2, color = "#2C3E50") +
    ggplot2::geom_point(
      ggplot2::aes(x = x$p_hat, y = 0),
      size = 6, color = "#D55E00") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$lower, y = -0.4, label = round(x$lower, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$upper, y = -0.4, label = round(x$upper, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$p_hat, y = 0.4,
                   label = paste("p-hat =", round(x$p_hat, 4))),
      size = 5, fontface = "bold") +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    ggplot2::labs(
      title = paste0(pct_label, " Confidence Interval"),
      x = "Sample Proportion", y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks.y       = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )

  if (x$calc_type == "multiplier") {
    mid_left  <- (x$lower + x$p_hat) / 2
    mid_right <- (x$p_hat + x$upper) / 2
    me_label  <- paste("ME =", round(x$me, 4))
    p_forest  <- p_forest +
      ggplot2::geom_text(
        ggplot2::aes(x = mid_left, y = 0.3, label = me_label),
        size = 4.5, color = "#555555") +
      ggplot2::geom_text(
        ggplot2::aes(x = mid_right, y = 0.3, label = me_label),
        size = 4.5, color = "#555555")
  } else {
    p_forest <- p_forest +
      ggplot2::geom_text(
        ggplot2::aes(x = x$p_hat, y = 0.7,
                     label = "Bounds found via Percentiles"),
        size = 4.5, color = "#555555", fontface = "italic")
  }

  # ---- Distribution Plot (top) ----
  if (x$method %in% c("2SD", "simulation")) {

    plot_data       <- data.frame(sim = x$sim_data)
    plot_data$in_ci <- plot_data$sim >= x$lower & plot_data$sim <= x$upper
    ci_mid          <- (x$lower + x$upper) / 2

    if (plot_type == "dotplot") {

      max_stack    <- max(table(round(x$sim_data, 4)))
      dynamic_size <- ifelse(max_stack > 15, 15 / max_stack, 1)

      p_dist <- ggplot2::ggplot(plot_data,
                                ggplot2::aes(x = sim, fill = in_ci)) +
        ggplot2::geom_dotplot(
          method      = "histodot",
          binwidth    = 1 / x$n,
          dotsize     = dynamic_size,
          color       = "white",
          stackgroups = TRUE
        ) +
        ggplot2::annotate("text",
                          x = ci_mid, y = 0.5,
                          label = pct_label,
                          size = 7, fontface = "bold", color = "#2C3E50") +
        ggplot2::theme(
          axis.text.y  = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank()
        )

    } else {

      # Default: histogram
      y_label_pos <- max(table(cut(x$sim_data, breaks = 40))) * 0.5

      p_dist <- ggplot2::ggplot(plot_data,
                                ggplot2::aes(x = sim, fill = in_ci)) +
        ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0) +
        ggplot2::annotate("text",
                          x = ci_mid, y = y_label_pos,
                          label = pct_label,
                          size = 7, fontface = "bold", color = "#2C3E50")
    }

    p_dist <- p_dist +
      ggplot2::geom_vline(xintercept = c(x$lower, x$upper),
                          color = "black", linetype = "dashed",
                          linewidth = 1) +
      ggplot2::annotate("text",
                        x = x$lower, y = Inf,
                        label = round(x$lower, 4),
                        vjust = 2, hjust = 1.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = x$upper, y = Inf,
                        label = round(x$upper, 4),
                        vjust = 2, hjust = -0.1, size = 4.5) +
      ggplot2::scale_fill_manual(
        values = c("FALSE" = "gray80", "TRUE" = "#3498DB")) +
      ggplot2::labs(
        title    = "Bootstrap Simulated Distribution",
        subtitle = paste0("Centered at p-hat = ", round(x$p_hat, 4)),
        x        = "Sample Proportion",
        y        = if (plot_type == "dotplot") "" else "Count") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {
    val <- dens <- sim <-  NA

    # Theory curve -- unchanged
    x_vals    <- seq(x$p_hat - 4 * x$se, x$p_hat + 4 * x$se,
                     length.out = 1000)
    y_vals    <- dnorm(x_vals, mean = x$p_hat, sd = x$se)
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
                        x = x$lower, y = Inf,
                        label = round(x$lower, 4),
                        vjust = 2, hjust = 1.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = x$upper, y = Inf,
                        label = round(x$upper, 4),
                        vjust = 2, hjust = -0.1, size = 4.5) +
      ggplot2::annotate("text",
                        x = ci_mid, y = y_label_pos,
                        label = pct_label,
                        size = 7, fontface = "bold", color = "#2C3E50") +
      ggplot2::labs(
        title    = "Theoretical Normal Distribution",
        subtitle = paste0("Centered at p-hat = ", round(x$p_hat, 4)),
        x        = "Sample Proportion",
        y        = "Density") +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.text.y  = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
  }

  return(p_dist / p_forest + patchwork::plot_layout(heights = c(3, 1)))
}

# ============================================================
# PLOT_STEPS METHOD -- 3-panel patchwork
# ============================================================

#' @export
#' @method plot_steps stat218_1prop_ci
plot_steps.stat218_1prop_ci <- function(x, ...) {

  pct <- x$conf_level * 100

  # Validity warning -- top of bottom panel
  warning_text <- ""
  if (x$method == "theory" &&
      (x$successes < 10 || (x$n - x$successes) < 10)) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "At least one cell has fewer than 10 observations. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "2SD") {
    method_blurb <- paste0(
      "We use the <b>2SD Method</b>. A bootstrap distribution is generated ",
      "centered at p&#770; = ", round(x$p_hat, 4), " by drawing ", x$n,
      " observations at a time. ",
      "The SD of that distribution is our estimated standard error:<br>",
      "&bull; SD of Sampling Distribution = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = 2 (standard for 95% confidence)<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times SD(\hat{p})$)",
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
      "We use the <b>Bootstrap Simulation Method</b>. A bootstrap ",
      "distribution is generated centered at p&#770; = ",
      round(x$p_hat, 4), ". Instead of using a multiplier, we take ",
      "the middle ", pct, "% of the simulated distribution as our ",
      "interval bounds directly.<br>",
      "&bull; Lower Bound = ", (1 - x$conf_level) / 2 * 100,
      "th percentile = <b>", round(x$lower, 4), "</b><br>",
      "&bull; Upper Bound = ", (1 - (1 - x$conf_level) / 2) * 100,
      "th percentile = <b>", round(x$upper, 4), "</b>"
    )
    use_math_panel <- FALSE

  } else {
    method_blurb <- paste0(
      "We use the <b>Theory-Based Method</b>. The SD of the sampling ",
      "distribution is computed using the formula for a proportion:<br>",
      "&bull; SD of Sampling Distribution = &radic;(p&#770;(1 &minus; p&#770;) / n)",
      " = &radic;(", round(x$p_hat, 4), " &times; ",
      round(1 - x$p_hat, 4), " / ", x$n, ") = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = ", round(x$multiplier, 3),
      " (from the Z-distribution for ", pct, "% confidence)<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times \sqrt{\frac{\hat{p}(1 - \hat{p})}{n}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$ME = ", round(x$multiplier, 3),
             " \\times \\sqrt{\\frac{", round(x$p_hat, 4),
             "(1 - ", round(x$p_hat, 4), ")}{", x$n, "}} = ",
             round(x$me, 4), "$"),
      output = "character"
    )
    use_math_panel <- TRUE
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Confidence Interval Construction</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data</b></span><br>",
    "&bull; <b>Observed Proportion (p&#770;):</b> ",
    round(x$p_hat, 4), " (", x$successes, " successes out of n = ", x$n, ")<br><br>",

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

  # ---- PANEL 3: Bottom HTML ----
  if (x$calc_type == "multiplier") {
    interval_html <- paste0(
      "<b>Confidence Interval</b> = p&#770; &plusmn; ME<br>",
      "CI = ", round(x$p_hat, 4), " &plusmn; ", round(x$me, 4),
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
    "% confident that the true population proportion is between ",
    round(x$lower, 4), " and ", round(x$upper, 4), ".<br>",
    "<i>Frequentist Interpretation:</i> If we were to take 100 random ",
    "samples and calculate a confidence interval for each, we would expect ",
    "approximately ", pct, " of those intervals to contain the true ",
    "population proportion."
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
        patchwork::plot_layout(heights = c(2.6, 1.2, 2.8))
    )
  } else {
    return(
      p_top / p_bottom +
        patchwork::plot_layout(heights = c(3, 2))
    )
  }
}
