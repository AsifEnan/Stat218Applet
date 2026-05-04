#' 1-Sample Mean Confidence Interval
#'
#' @description
#' Constructs a confidence interval for a single population mean (\eqn{\mu})
#' using one of three methods: the 2SD simulation method, a general
#' simulation method, or a theory-based approach.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the sample mean, standard
#'   deviation, and sample size. Pass `x_bar`, `sd_val`, and `n` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R. Pass `formula`
#'   and `data` instead, and the function computes all summary statistics
#'   automatically.
#'
#' @param x_bar The observed sample mean-the average value from your sample.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n A whole number representing the total sample size.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_val The standard deviation. Whether this is a population or
#'   sample SD is determined by `sd_type`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_type A character string specifying whether the standard deviation
#'   is from the population or the sample. Must be one of:
#'   \describe{
#'     \item{`"sample"`}{(default) The SD was calculated from your sample
#'       data. When `method = "theory"`, a T-test multiplier is used.}
#'     \item{`"population"`}{The true population SD (\eqn{\sigma}) is known.
#'       When `method = "theory"`, a Z multiplier is used.}
#'   }
#'   When raw data is provided via `formula` and `data`, this is always
#'   set to `"sample"` automatically.
#' @param formula A one-sided formula of the form `~ variable` identifying
#'   the numeric variable in your dataset. For example, `formula = ~ Height`.
#'   **Only used when NOT providing `x_bar`, `n`, and `sd_val`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   containing the variable named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param conf_level The desired confidence level as a decimal. Default is
#'   `0.95` for a 95% confidence interval. Common choices are `0.90`,
#'   `0.95`, and `0.99`. Note that `method = "2SD"` only works at `0.95`.
#' @param method The method used to construct the confidence interval.
#'   Must be one of:
#'   \describe{
#'     \item{`"2SD"`}{(default) The 2SD Simulation Method. A parametric
#'       bootstrap distribution is generated centered at `x_bar`, and the
#'       interval is constructed as \eqn{\bar{x} \pm 2 \times SD(\bar{x})}.
#'       This method is only valid for 95% confidence intervals. If you
#'       need a different confidence level, use `method = "simulation"`.}
#'     \item{`"simulation"`}{The Bootstrap Simulation Method. Same
#'       parametric bootstrap as 2SD, but uses the middle `conf_level`% of
#'       the simulated distribution to find the bounds. Works for any
#'       confidence level.}
#'     \item{`"theory"`}{The Theory-Based Method. Uses the formula
#'       \eqn{SE = s/\sqrt{n}} (or \eqn{\sigma/\sqrt{n}}) and the
#'       appropriate Z* or t* multiplier. Works for any confidence level.
#'       Requires validity conditions to be met.}
#'   }
#' @param sim_reps The number of bootstrap samples when `method = "2SD"` or
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
#'   a more stable interval.
#'
#' @return An S3 object of class `stat218_1mean_ci` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the interval.}
#'     \item{`plot(result)`}{Shows the bootstrap or theoretical distribution
#'       with the confidence interval shaded and labeled, plus a forest
#'       plot of the interval below.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step construction of the interval.}
#'   }
#'
#' @details
#' ## The Core Idea
#' A confidence interval gives a range of plausible values for the true
#' population mean \eqn{\mu}. Rather than giving a single point estimate
#' (which is almost certainly not exactly right), a confidence interval
#' acknowledges uncertainty and says: *"We are X% confident the true mean
#' falls somewhere in this range."*
#'
#' ## The 2SD Method
#' The book introduces this as the primary simulation-based approach for
#' 95% confidence intervals. We simulate the sampling distribution of the
#' sample mean by drawing many bootstrap samples, then use
#' \eqn{\bar{x} \pm 2 \times SD} of that distribution as our interval.
#' The multiplier of 2 is an approximation of the true 1.96 used in theory.
#'
#' ## Theory Method
#' Uses the formula SE = s/\eqn{\sqrt{n}} (or \eqn{\sigma}/\eqn{\sqrt{n}}
#' if the population SD is known), multiplied by the appropriate critical
#' value from the Z or T distribution. Requires:
#' - \eqn{n \geq 20}, **or**
#' - The underlying distribution is roughly symmetric.
#'
#' @examples
#' # --- Summary Statistics (2SD method, default) ---
#' result <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35)
#' print(result)
#' \dontrun{
#' plot(result)
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics (theory, T-interval) ---
#' result2 <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35,
#'                     sd_type = "sample", conf_level = 0.95,
#'                     method = "theory")
#' print(result2)
#' \dontrun{
#' plot(result2)
#' plot_steps(result2)
#' }
#'
#' # --- Summary Statistics (simulation, 90% CI) ---
#' result3 <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35,
#'                     conf_level = 0.90, method = "simulation")
#' print(result3)
#' \dontrun{
#' plot(result3)
#' plot_steps(result3)
#'}
#'
#' # --- Raw Data (2SD method) ---
#' result4 <- ci_1mean(formula = ~ mpg, data = mtcars, method = "2SD")
#' print(result4)
#' \dontrun{
#' plot(result4)
#' plot_steps(result4)
#' }
#'
#' # --- Raw Data (theory, T-interval) ---
#' result5 <- ci_1mean(formula = ~ mpg, data = mtcars, method = "theory")
#' print(result5)
#' \dontrun{
#' plot(result5)
#' plot_steps(result5)
#'}
#'
#' @export
ci_1mean <- function(x_bar = NULL, n = NULL, sd_val = NULL,
                     sd_type = "sample",
                     formula = NULL, data = NULL,
                     conf_level = 0.95,
                     method = "2SD",
                     sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar) || !is.null(n) || !is.null(sd_val)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (x_bar/n/sd_val)}.",
      "i" = "These are two different ways to use {.fn ci_1mean} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula} and {.arg data}, and remove {.arg x_bar}, {.arg n}, and {.arg sd_val}.",
      "*" = "If you only have {.strong summary statistics}: use {.arg x_bar}, {.arg n}, and {.arg sd_val}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg x_bar}, {.arg n}, and {.arg sd_val}.",
      "*" = "{.strong Raw data}: provide {.arg formula} and {.arg data}."
    ))
  }

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code ci_1mean(formula = ~ YourVariable, data = your_data)}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "Please specify which variable to analyze. For example:",
        " " = "{.code ci_1mean(formula = ~ YourVariable, data = your_data)}"
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

    if (!is.numeric(col)) {
      cli::cli_abort(c(
        "x" = "The variable {.val {var_name}} must be numeric for a mean confidence interval.",
        "i" = "It appears to contain non-numeric values. Check your data."
      ))
    }

    col    <- col[!is.na(col)]
    x_bar  <- mean(col)
    n      <- length(col)
    sd_val <- sd(col)
    sd_type <- "sample"

    cli::cli_inform(c(
      "v" = "Data extracted from variable {.val {var_name}}:",
      "*" = "Sample Mean (x-bar): {round(x_bar, 4)}",
      "*" = "Sample SD (s):       {round(sd_val, 4)}",
      "*" = "Sample Size (n):     {n}",
      "i" = "{.arg sd_type} automatically set to {.val sample} from raw data."
    ))
  }

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  if (!is.numeric(x_bar)) {
    cli::cli_abort(c(
      "x" = "{.arg x_bar} must be a numeric value.",
      "i" = "You provided: {.val {x_bar}}"
    ))
  }

  if (!is.numeric(n) || n != round(n) || n <= 0) {
    cli::cli_abort(c(
      "x" = "{.arg n} must be a positive whole number.",
      "i" = "You provided: {.val {n}}"
    ))
  }

  if (!is.numeric(sd_val) || sd_val <= 0) {
    cli::cli_abort(c(
      "x" = "{.arg sd_val} must be a positive number.",
      "i" = "You provided: {.val {sd_val}}",
      "i" = "Standard deviations cannot be zero or negative."
    ))
  }

  if (!sd_type %in% c("sample", "population")) {
    cli::cli_abort(c(
      "x" = "{.arg sd_type} must be either {.val sample} or {.val population}.",
      "i" = "You provided: {.val {sd_type}}"
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

  # Validity condition warning for theory method
  if (method == "theory" && n < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based interval may not be met.",
      "i" = "Your sample size is n = {n}, which is less than 20.",
      "i" = "Proceed only if the underlying data is known to be roughly symmetric.",
      "i" = "Otherwise consider using {.code method = \"2SD\"} or {.code method = \"simulation\"}."
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  if (method == "2SD" || method == "simulation") {
    sim_data  <- replicate(sim_reps, mean(rnorm(n, mean = x_bar, sd = sd_val)))
    se        <- sd(sim_data)
    df        <- NA
    dist_type <- "Simulated"

    if (method == "2SD") {
      multiplier <- 2
      me         <- multiplier * se
      lower      <- x_bar - me
      upper      <- x_bar + me
      calc_type  <- "multiplier"
    } else {
      # simulation -- percentile method, works for any conf_level
      multiplier <- NA
      me         <- NA
      alpha      <- 1 - conf_level
      lower      <- unname(quantile(sim_data, alpha / 2))
      upper      <- unname(quantile(sim_data, 1 - alpha / 2))
      calc_type  <- "percentile"
    }

  } else if (method == "theory") {
    sim_data  <- NULL
    se        <- sd_val / sqrt(n)

    if (sd_type == "population") {
      multiplier <- abs(qnorm((1 - conf_level) / 2))
      dist_type  <- "Z"
      df         <- NA
    } else {
      df         <- n - 1
      multiplier <- abs(qt((1 - conf_level) / 2, df = df))
      dist_type  <- "T"
    }

    me        <- multiplier * se
    lower     <- x_bar - me
    upper     <- x_bar + me
    calc_type <- "multiplier"
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar      = x_bar,
    n          = n,
    sd_val     = sd_val,
    sd_type    = sd_type,
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
    sim_data   = sim_data
  )

  class(res) <- "stat218_1mean_ci"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_1mean_ci
print.stat218_1mean_ci <- function(x, ...) {
  sd_symbol <- ifelse(x$sd_type == "population", "sigma", "s")

  cli::cli_h1("{x$conf_level * 100}% Confidence Interval ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Point Estimate (x-bar): {round(x$x_bar, 4)}",
    "i" = "Standard Deviation ({sd_symbol}): {round(x$sd_val, 4)}  |  n: {x$n}",
    "i" = "SD of Sampling Distribution: {round(x$se, 4)}",
    "*" = "Interval: ({round(x$lower, 4)}, {round(x$upper, 4)})"
  ))

  if (x$method == "theory" && x$n < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- n = {x$n} is less than 20.",
      "i" = "Verify the data is roughly symmetric before trusting these results.",
      "i" = "Consider using {.code method = \"2SD\"} or {.code method = \"simulation\"}."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_1mean_ci
plot.stat218_1mean_ci <- function(x, ...) {

  pct_label <- paste0(x$conf_level * 100, "%")

  # ---- Forest Plot (bottom) ----
  p_forest <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      ggplot2::aes(x = x$lower, xend = x$upper, y = 0, yend = 0),
      linewidth = 2, color = "#2C3E50") +
    ggplot2::geom_point(
      ggplot2::aes(x = x$x_bar, y = 0),
      size = 6, color = "#D55E00") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$lower, y = -0.4, label = round(x$lower, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$upper, y = -0.4, label = round(x$upper, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$x_bar, y = 0.4,
                   label = paste("x-bar =", round(x$x_bar, 4))),
      size = 5, fontface = "bold") +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    ggplot2::labs(
      title = paste0(pct_label, " Confidence Interval"),
      x = "Sample Mean", y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y       = ggplot2::element_blank(),
      axis.ticks.y      = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )

  if (x$calc_type == "multiplier") {
    mid_left  <- (x$lower + x$x_bar) / 2
    mid_right <- (x$x_bar + x$upper) / 2
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
        ggplot2::aes(x = x$x_bar, y = 0.7,
                     label = "Bounds found via Percentiles"),
        size = 4.5, color = "#555555", fontface = "italic")
  }

  # ---- Distribution Plot (top) ----
  if (x$method %in% c("2SD", "simulation")) {
    # avoid warning about bindings
    in_ci <- NA

    plot_data       <- data.frame(sim = x$sim_data)
    plot_data$in_ci <- plot_data$sim >= x$lower & plot_data$sim <= x$upper

    # midpoint for confidence level label inside shaded region
    ci_mid <- (x$lower + x$upper) / 2
    y_label_pos <- max(table(cut(x$sim_data,
                                 breaks = 40))) * 0.5

    p_dist <- ggplot2::ggplot(plot_data,
                              ggplot2::aes(x = sim, fill = in_ci)) +
      ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0) +
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
      ggplot2::scale_fill_manual(
        values = c("FALSE" = "gray80", "TRUE" = "#3498DB")) +
      ggplot2::labs(
        title    = "Parametric Bootstrap Distribution",
        subtitle = paste0("Centered at x-bar = ", round(x$x_bar, 4)),
        x        = "Sample Mean",
        y        = "Count") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {
    val <- dens <- sim <-  NA

    x_vals <- seq(x$x_bar - 4 * x$se, x$x_bar + 4 * x$se,
                  length.out = 1000)

    if (x$sd_type == "population") {
      y_vals     <- dnorm(x_vals, mean = x$x_bar, sd = x$se)
      dist_title <- "Theoretical Normal Distribution (Z-Curve)"
    } else {
      y_vals     <- dt((x_vals - x$x_bar) / x$se, df = x$df) / x$se
      dist_title <- paste0("Theoretical T-Distribution (df = ",
                           round(x$df, 1), ")")
    }

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
        title    = dist_title,
        subtitle = paste0("Centered at x-bar = ", round(x$x_bar, 4)),
        x        = "Sample Mean",
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
#' @method plot_steps stat218_1mean_ci
plot_steps.stat218_1mean_ci <- function(x, ...) {

  pct       <- x$conf_level * 100
  sd_symbol <- ifelse(x$sd_type == "population", "&sigma;", "s")

  # Validity warning -- top of bottom panel
  warning_text <- ""
  if (x$method == "theory" && x$n < 20) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "Your sample size (n = ", x$n, ") is less than 20. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "2SD") {
    method_blurb <- paste0(
      "We use the <b>2SD Method</b>. A parametric bootstrap distribution ",
      "is generated centered at x&#772; = ", round(x$x_bar, 4), ". ",
      "The SD of that distribution is our estimated standard error:<br>",
      "&bull; SD of Sampling Distribution = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = 2 (standard for 95% confidence)<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times SD(\bar{x})$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$ME = 2 \\times ", round(x$se, 4), " = ", round(x$me, 4), "$"),
      output = "character"
    )

  } else if (x$method == "simulation") {
    method_blurb <- paste0(
      "We use the <b>Bootstrap Simulation Method</b>. A parametric bootstrap ",
      "distribution is generated centered at x&#772; = ", round(x$x_bar, 4), ". ",
      "Instead of using a multiplier, we take the middle ", pct,
      "% of the simulated distribution as our interval bounds directly.<br>",
      "&bull; Lower Bound = ", (1 - x$conf_level) / 2 * 100,
      "th percentile = <b>", round(x$lower, 4), "</b><br>",
      "&bull; Upper Bound = ", (1 - (1 - x$conf_level) / 2) * 100,
      "th percentile = <b>", round(x$upper, 4), "</b>"
    )

  } else {
    # Theory method
    if (x$sd_type == "population") {
      method_blurb <- paste0(
        "We use the <b>Theory-Based Method</b>. Because &sigma; is known, ",
        "we use the standard normal distribution to find our multiplier.<br>",
        "&bull; SD of Sampling Distribution = &sigma;/&radic;n = ",
        round(x$sd_val, 4), "/&radic;", x$n, " = ", round(x$se, 4), "<br>",
        "&bull; Multiplier = ", round(x$multiplier, 3),
        " (from the Z-distribution for ", pct, "% confidence)<br><br>",
        "<i>The formula and calculation are shown below:</i>"
      )
    } else {
      method_blurb <- paste0(
        "We use the <b>Theory-Based Method</b>. Because &sigma; is unknown, ",
        "we use the T-distribution with df = ", x$df,
        " to find our multiplier.<br>",
        "&bull; SD of Sampling Distribution = s/&radic;n = ",
        round(x$sd_val, 4), "/&radic;", x$n, " = ", round(x$se, 4), "<br>",
        "&bull; Multiplier = ", round(x$multiplier, 3),
        " (from the T-distribution with df = ", x$df,
        " for ", pct, "% confidence)<br><br>",
        "<i>The formula and calculation are shown below:</i>"
      )
    }

    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times \frac{SD}{\sqrt{n}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$ME = ", round(x$multiplier, 3),
             " \\times \\frac{", round(x$sd_val, 4),
             "}{\\sqrt{", x$n, "}} = ", round(x$me, 4), "$"),
      output = "character"
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Confidence Interval Construction</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data</b></span><br>",
    "&bull; <b>Observed Mean (x&#772;):</b> ", round(x$x_bar, 4),
    "&nbsp;&nbsp;|&nbsp;&nbsp;<b>Sample Size (n):</b> ", x$n,
    "&nbsp;&nbsp;|&nbsp;&nbsp;<b>Standard Deviation (", sd_symbol, "):</b> ",
    round(x$sd_val, 4), "<br><br>",

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

  # ---- PANEL 2: Math equations (or empty for simulation percentile) ----
  if (x$method == "simulation") {
    # No math panel needed for percentile approach
    p_math <- ggplot2::ggplot() + ggplot2::theme_void()
    use_math_panel <- FALSE
  } else {
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
    use_math_panel <- TRUE
  }

  # ---- PANEL 3: Bottom HTML ----
  if (x$calc_type == "multiplier") {
    interval_html <- paste0(
      "<b>Confidence Interval</b> = x&#772; &plusmn; ME<br>",
      "CI = ", round(x$x_bar, 4), " &plusmn; ", round(x$me, 4),
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
    "% confident that the true population mean is between ",
    round(x$lower, 4), " and ", round(x$upper, 4), ".<br>",
    "<i>Frequentist Interpretation:</i> If we were to take 100 random ",
    "samples and calculate a confidence interval for each, we would expect ",
    "approximately ", pct, " of those intervals to contain the true ",
    "population mean."
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

  # ---- Stitch panels ----
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
