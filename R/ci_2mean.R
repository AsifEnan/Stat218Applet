#' 2-Sample Means Confidence Interval
#'
#' @description
#' Constructs a confidence interval for the difference between two population
#' means (\eqn{\mu_1 - \mu_2}) using one of three methods: the 2SD simulation
#' method, a general simulation method, or a theory-based approach.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the sample mean, standard
#'   deviation, and sample size for both groups. Pass `x_bar_1`, `sd_1`,
#'   `n_1`, `x_bar_2`, `sd_2`, and `n_2` directly. Note that
#'   `method = "2SD"` and `method = "simulation"` are not available with
#'   summary statistics -- they require the individual data values.
#'
#' - **Raw Data:** You have an actual dataset loaded into R. Pass `formula`
#'   and `data` instead, and the function computes all summary statistics
#'   automatically. All three methods are available with raw data.
#'
#' @param x_bar_1 The observed sample mean of Group 1.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_1 The standard deviation of Group 1. Whether this is a
#'   population or sample SD is determined by `sd_type`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_1 The sample size of Group 1.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param x_bar_2 The observed sample mean of Group 2.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_2 The standard deviation of Group 2.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_2 The sample size of Group 2.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param group_names A character vector of length 2 giving meaningful names
#'   to the two groups. For example,
#'   `group_names = c("Treatment", "Control")`.
#'   Defaults to `c("Group 1", "Group 2")`. When using raw data, group
#'   names are extracted automatically from the grouping variable.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_type A character string specifying whether the standard
#'   deviations are from the population or the sample. Must be one of:
#'   \describe{
#'     \item{`"sample"`}{(default) The SDs were calculated from the sample
#'       data. When `method = "theory"`, a T-interval is used with degrees
#'       of freedom computed automatically via the Satterthwaite
#'       approximation.}
#'     \item{`"population"`}{The true population SDs (\eqn{\sigma}) are
#'       known. When `method = "theory"`, a Z-interval is used.}
#'   }
#'   When raw data is provided, this is always set to `"sample"`
#'   automatically.
#' @param formula A two-sided formula of the form `Response ~ Group`
#'   identifying the numeric response variable and the grouping variable
#'   in your dataset. For example, `formula = Score ~ Method`.
#'   **Only used when NOT providing summary statistics.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   containing the variables named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param conf_level The desired confidence level as a decimal. Default is
#'   `0.95` for a 95% confidence interval. Common choices are `0.90`,
#'   `0.95`, and `0.99`. Note that `method = "2SD"` only works at `0.95`.
#' @param method The method used to construct the confidence interval.
#'   Must be one of:
#'   \describe{
#'     \item{`"2SD"`}{(default) The 2SD Simulation Method. A parametric
#'       bootstrap distribution is generated for the difference in means by independently drawing samples from both groups.
#'       This method is only valid for 95% confidence intervals.The interval
#'       is \eqn{(\bar{x}_1 - \bar{x}_2) \pm 2 \times SD}. If you
#'       need a different confidence level, use `method = "simulation"`.}
#'     \item{`"simulation"`}{The Bootstrap Simulation Method. Same
#'       parametric bootstrap as 2SD, but uses the middle `conf_level`% of
#'       the simulated distribution to find the bounds. Works for any
#'       confidence level.}
#'     \item{`"theory"`}{The Theory-Based Method. Uses the unpooled
#'       standard error formula and the appropriate Z* or t* multiplier.
#'       Works for any confidence level and with both summary statistics
#'       and raw data.}
#'   }
#' @param sim_reps The number of bootstrap samples when `method = "2SD"`
#'   or `method = "simulation"`. Default is `1000`.
#' @note To display the bootstrap distribution as a dotplot instead of a
#'   histogram, use \code{plot(result, plot_type = "dotplot")} after
#'   running this function. Only available for \code{method = "2SD"} or
#'   \code{method = "simulation"}.
#'
#' @return An S3 object of class `stat218_2mean_ci` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the interval.}
#'     \item{`plot(result)`}{Default shows the bootstrap or theoretical
#'       distribution with the confidence interval shaded and labeled,
#'       plus a forest plot below. Use
#'       `plot(result, plot_type = "boxplot")` for side-by-side boxplots
#'       (raw data only).}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step construction of the interval.}
#'   }
#'
#' @details
#' ## The Core Idea
#' A two-sample mean confidence interval gives a range of plausible values
#' for the true difference between two population means \eqn{\mu_1 - \mu_2}.
#' A positive interval suggests Group 1 tends to be higher; a negative
#' interval suggests Group 2 tends to be higher; an interval containing
#' zero is consistent with no difference.
#'
#' ## The 2SD Method
#' A parametric bootstrap where repeated samples of size `n_1` are drawn
#' from Normal(\eqn{\bar{x}_1}, s_1) and size `n_2` from
#' Normal(\eqn{\bar{x}_2}, s_2). The difference in sample means is recorded
#' for each repetition. The SD of those differences estimates the SE, and
#' the interval is point estimate \eqn{\pm 2 \times SD}.
#'
#' ## Theory Method
#' Uses the unpooled standard error:
#' \deqn{SE = \sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}
#' The degrees of freedom are computed automatically using the
#' Satterthwaite approximation and handled in the background.
#'
#' ## Validity Conditions
#' The theory-based interval is most reliable when:
#' - Both groups have at least 20 observations, **or**
#' - The distributions within both groups are roughly symmetric.
#'
#' @examples
#' # --- Summary Statistics (theory T-interval, default) ---
#' result <- ci_2mean(
#'   x_bar_1 = 78.3, sd_1 = 9.1, n_1 = 35,
#'   x_bar_2 = 73.5, sd_2 = 8.4, n_2 = 32,
#'   group_names = c("New Method", "Traditional"),
#'   method = "theory"
#' )
#' print(result)
#' \dontrun{
#' plot(result)
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics (theory, 90% CI) ---
#' result2 <- ci_2mean(
#'   x_bar_1 = 78.3, sd_1 = 9.1, n_1 = 35,
#'   x_bar_2 = 73.5, sd_2 = 8.4, n_2 = 32,
#'   group_names = c("New Method", "Traditional"),
#'   conf_level = 0.90, method = "theory"
#' )
#' print(result2)
#' \dontrun{
#' plot(result2)
#' plot_steps(result2)
#'}
#'
#' # --- Raw Data (2SD method) ---
#' car_data <- mtcars
#' car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
#' result3 <- ci_2mean(
#'   formula = mpg ~ transmission, data = car_data,
#'   method = "2SD"
#' )
#' print(result3)
#' \dontrun{
#' plot(result3)
#' plot(result3, plot_type = "boxplot")
#' plot_steps(result3)
#'}
#'
#' # --- Raw Data (simulation, 90% CI) ---
#' result4 <- ci_2mean(
#'   formula = mpg ~ transmission, data = car_data,
#'   conf_level = 0.90, method = "simulation"
#' )
#' print(result4)
#' \dontrun{
#' plot(result4)
#' plot_steps(result4)
#'}
#'
#' # --- Raw Data (theory T-interval) ---
#' result5 <- ci_2mean(
#'   formula = mpg ~ transmission, data = car_data,
#'   method = "theory"
#' )
#' print(result5)
#' \dontrun{
#' plot(result5)
#' plot(result5, plot_type = "boxplot")
#' plot_steps(result5)
#'}
#'
#' @export
ci_2mean <- function(x_bar_1 = NULL, sd_1 = NULL, n_1 = NULL,
                     x_bar_2 = NULL, sd_2 = NULL, n_2 = NULL,
                     group_names = NULL,
                     sd_type = "sample",
                     formula = NULL, data = NULL,
                     conf_level = 0.95,
                     method = "2SD",
                     sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar_1) || !is.null(sd_1) ||
    !is.null(n_1) || !is.null(x_bar_2) ||
    !is.null(sd_2) || !is.null(n_2)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics.",
      "i" = "These are two different ways to use {.fn ci_2mean} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula} and {.arg data}, and remove the summary stat arguments.",
      "*" = "If you only have {.strong summary statistics}: use {.arg x_bar_1}, {.arg sd_1}, {.arg n_1}, etc., and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg x_bar_1}, {.arg sd_1}, {.arg n_1}, {.arg x_bar_2}, {.arg sd_2}, and {.arg n_2}.",
      "*" = "{.strong Raw data}: provide {.arg formula} and {.arg data}."
    ))
  }

  # Summary stats + simulation/2SD -- not possible
  if (summary_stat_provided && method %in% c("2SD", "simulation")) {
    cli::cli_abort(c(
      "x" = "The {.val {method}} method is not available when using summary statistics.",
      "i" = "Bootstrap simulation requires the individual data values from both groups.",
      "i" = "Since you only provided summary statistics, there are no individual values to bootstrap from.",
      "i" = "Please either:",
      "*" = "Use {.code method = \"theory\"} with your summary statistics, or",
      "*" = "Provide raw data via {.arg formula} and {.arg data} to use {.val {method}}."
    ))
  }

  # Store raw data for boxplot and bootstrap
  raw_data_1 <- NULL
  raw_data_2 <- NULL

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code ci_2mean(formula = Response ~ Group, data = your_data)}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "The formula should look like: {.code Response ~ Group}",
        "i" = "Where {.code Response} is your numeric outcome and {.code Group} defines the two groups."
      ))
    }

    vars <- all.vars(formula)

    if (length(vars) != 2) {
      cli::cli_abort(c(
        "x" = "The formula must have exactly two variables in the form {.code Response ~ Group}.",
        "i" = "You provided: {.code {deparse(formula)}}"
      ))
    }

    response_var <- vars[1]
    group_var    <- vars[2]

    if (!response_var %in% names(data)) {
      cli::cli_abort(c(
        "x" = "The response variable {.val {response_var}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    if (!group_var %in% names(data)) {
      cli::cli_abort(c(
        "x" = "The grouping variable {.val {group_var}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    response_col <- data[[response_var]]
    group_col    <- data[[group_var]]

    if (!is.numeric(response_col)) {
      cli::cli_abort(c(
        "x" = "The response variable {.val {response_var}} must be numeric.",
        "i" = "It appears to contain non-numeric values. Check your data."
      ))
    }

    group_levels <- unique(na.omit(as.character(group_col)))
    if (length(group_levels) != 2) {
      cli::cli_abort(c(
        "x" = "The grouping variable {.val {group_var}} has {length(group_levels)} unique value(s): {.val {group_levels}}.",
        "i" = "This function requires exactly 2 groups.",
        "i" = "Please filter your data down to just the two groups you want to compare."
      ))
    }

    group_names <- group_levels
    raw_data_1  <- na.omit(response_col[as.character(group_col) == group_names[1]])
    raw_data_2  <- na.omit(response_col[as.character(group_col) == group_names[2]])

    x_bar_1 <- mean(raw_data_1)
    sd_1    <- sd(raw_data_1)
    n_1     <- length(raw_data_1)

    x_bar_2 <- mean(raw_data_2)
    sd_2    <- sd(raw_data_2)
    n_2     <- length(raw_data_2)
    sd_type <- "sample"

    cli::cli_inform(c(
      "v" = "Data extracted from {.val {response_var}} ~ {.val {group_var}}:",
      "*" = "{group_names[1]}: x-bar = {round(x_bar_1, 4)}, s = {round(sd_1, 4)}, n = {n_1}",
      "*" = "{group_names[2]}: x-bar = {round(x_bar_2, 4)}, s = {round(sd_2, 4)}, n = {n_2}"
    ))
  }

  if (is.null(group_names)) group_names <- c("Group 1", "Group 2")

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  for (val in list(list(x_bar_1, "x_bar_1"), list(x_bar_2, "x_bar_2"))) {
    if (!is.numeric(val[[1]])) {
      cli::cli_abort(c(
        "x" = "{.arg {val[[2]]}} must be a numeric value.",
        "i" = "You provided: {.val {val[[1]]}}"
      ))
    }
  }

  for (val in list(list(sd_1, "sd_1"), list(sd_2, "sd_2"))) {
    if (!is.numeric(val[[1]]) || val[[1]] <= 0) {
      cli::cli_abort(c(
        "x" = "{.arg {val[[2]]}} must be a positive number.",
        "i" = "You provided: {.val {val[[1]]}}",
        "i" = "Standard deviations cannot be zero or negative."
      ))
    }
  }

  for (val in list(list(n_1, "n_1"), list(n_2, "n_2"))) {
    if (!is.numeric(val[[1]]) || val[[1]] != round(val[[1]]) || val[[1]] <= 0) {
      cli::cli_abort(c(
        "x" = "{.arg {val[[2]]}} must be a positive whole number.",
        "i" = "You provided: {.val {val[[1]]}}"
      ))
    }
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
  if (method == "theory" && (n_1 < 20 || n_2 < 20)) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based interval may not be met.",
      "i" = "At least one group has fewer than 20 observations:",
      "*" = "{group_names[1]}: n = {n_1}",
      "*" = "{group_names[2]}: n = {n_2}",
      "i" = "Verify that the distributions within both groups are roughly symmetric.",
      "i" = "Otherwise consider using {.code method = \"2SD\"} or {.code method = \"simulation\"} if raw data is available."
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  obs_diff <- x_bar_1 - x_bar_2
  sim_data <- NULL

  if (method %in% c("2SD", "simulation")) {
    # Parametric bootstrap -- draw independently from both groups
    sim_data <- replicate(sim_reps, {
      s1 <- mean(rnorm(n_1, mean = x_bar_1, sd = sd_1))
      s2 <- mean(rnorm(n_2, mean = x_bar_2, sd = sd_2))
      s1 - s2
    })

    se        <- sd(sim_data)
    df        <- NA
    dist_type <- "Simulated"

    if (method == "2SD") {
      multiplier <- 2
      me         <- multiplier * se
      lower      <- obs_diff - me
      upper      <- obs_diff + me
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
    # Theory method
    se <- sqrt((sd_1^2 / n_1) + (sd_2^2 / n_2))

    if (sd_type == "population") {
      multiplier <- abs(qnorm((1 - conf_level) / 2))
      df         <- NA
      dist_type  <- "Z"
    } else {
      num        <- (sd_1^2 / n_1 + sd_2^2 / n_2)^2
      den        <- ((sd_1^2 / n_1)^2 / (n_1 - 1)) +
        ((sd_2^2 / n_2)^2 / (n_2 - 1))
      df         <- num / den
      multiplier <- abs(qt((1 - conf_level) / 2, df = df))
      dist_type  <- "T"
    }

    me        <- multiplier * se
    lower     <- obs_diff - me
    upper     <- obs_diff + me
    calc_type <- "multiplier"
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar_1     = x_bar_1, sd_1 = sd_1, n_1 = n_1,
    x_bar_2     = x_bar_2, sd_2 = sd_2, n_2 = n_2,
    group_names = group_names,
    sd_type     = sd_type,
    conf_level  = conf_level,
    method      = method,
    calc_type   = calc_type,
    multiplier  = multiplier,
    dist_type   = dist_type,
    df          = df,
    obs_diff    = obs_diff,
    se          = se,
    me          = me,
    lower       = lower,
    upper       = upper,
    sim_data    = sim_data,
    raw_data_1  = raw_data_1,
    raw_data_2  = raw_data_2
  )

  class(res) <- "stat218_2mean_ci"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_2mean_ci
print.stat218_2mean_ci <- function(x, ...) {
  sd_symbol <- ifelse(x$sd_type == "population", "sigma", "s")

  cli::cli_h1("{x$conf_level * 100}% Confidence Interval for Difference in Means ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "{x$group_names[1]}: x-bar = {round(x$x_bar_1, 4)}  |  {sd_symbol} = {round(x$sd_1, 4)}  |  n = {x$n_1}",
    "i" = "{x$group_names[2]}: x-bar = {round(x$x_bar_2, 4)}  |  {sd_symbol} = {round(x$sd_2, 4)}  |  n = {x$n_2}",
    "i" = "Point Estimate (x-bar1 - x-bar2): {round(x$obs_diff, 4)}",
    "i" = "SD of Sampling Distribution: {round(x$se, 4)}",
    "*" = "Interval: ({round(x$lower, 4)}, {round(x$upper, 4)})"
  ))

  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- at least one group has fewer than 20 observations.",
      "i" = "{x$group_names[1]}: n = {x$n_1}  |  {x$group_names[2]}: n = {x$n_2}",
      "i" = "Verify that the distributions within both groups are roughly symmetric."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' Plot Method for ci_2mean Results
#'
#' @param x A \code{stat218_2mean_ci} result object from \code{ci_2mean()}.
#' @param plot_type The type of plot for the bootstrap distribution.
#'   Must be \code{"histogram"} (default) or \code{"dotplot"}.
#'   Only available when \code{method = "2SD"} or \code{method = "simulation"}.
#' @param ... Additional arguments (currently unused).
#' @export
#' @method plot stat218_2mean_ci
plot.stat218_2mean_ci <- function(x, plot_type = "distribution", ...) {

  x_label <- paste0("Difference in Sample Means (",
                    x$group_names[1], " - ", x$group_names[2], ")")
  pct_label <- paste0(x$conf_level * 100, "%")

  # ---- Boxplot branch ----
  if (plot_type == "boxplot") {

    if (is.null(x$raw_data_1) || is.null(x$raw_data_2)) {
      cli::cli_abort(c(
        "x" = "The boxplot requires raw data.",
        "i" = "This result was created using summary statistics, so individual values are not available.",
        "i" = "To use the boxplot, provide raw data via {.arg formula} and {.arg data}."
      ))
    }

    box_data <- data.frame(
      value = c(x$raw_data_1, x$raw_data_2),
      group = factor(
        c(rep(x$group_names[1], length(x$raw_data_1)),
          rep(x$group_names[2], length(x$raw_data_2))),
        levels = x$group_names
      )
    )

    return(
      ggplot2::ggplot(box_data,
                      ggplot2::aes(x = group, y = value, fill = group)) +
        ggplot2::geom_boxplot(alpha = 0.7, outlier.shape = NA, width = 0.5) +
        ggplot2::geom_jitter(width = 0.15, size = 2, alpha = 0.6,
                             color = "#2C3E50") +
        ggplot2::scale_fill_manual(
          values = c("#2C3E50", "#D55E00")) +
        ggplot2::labs(
          title    = paste0("Side-by-Side Boxplot: ",
                            x$group_names[1], " vs ", x$group_names[2]),
          subtitle = paste0(
            x$group_names[1], ": x-bar = ", round(x$x_bar_1, 3),
            "  |  ",
            x$group_names[2], ": x-bar = ", round(x$x_bar_2, 3)
          ),
          x = "Group", y = "Value"
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(legend.position = "none")
    )
  }

  # ---- Forest Plot (bottom) ----
  p_forest <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      ggplot2::aes(x = x$lower, xend = x$upper, y = 0, yend = 0),
      linewidth = 2, color = "#2C3E50") +
    ggplot2::geom_point(
      ggplot2::aes(x = x$obs_diff, y = 0),
      size = 6, color = "#D55E00") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$lower, y = -0.4, label = round(x$lower, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$upper, y = -0.4, label = round(x$upper, 4)),
      size = 5, color = "#2C3E50") +
    ggplot2::geom_text(
      ggplot2::aes(x = x$obs_diff, y = 0.4,
                   label = paste("Difference =", round(x$obs_diff, 4))),
      size = 5, fontface = "bold") +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    ggplot2::labs(
      title = paste0(pct_label, " Confidence Interval"),
      x = x_label, y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y        = ggplot2::element_blank(),
      axis.ticks.y       = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    )

  if (x$calc_type == "multiplier") {
    mid_left  <- (x$lower + x$obs_diff) / 2
    mid_right <- (x$obs_diff + x$upper) / 2
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
        ggplot2::aes(x = x$obs_diff, y = 0.7,
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
        title    = "Parametric Bootstrap Distribution of Differences",
        subtitle = paste0("Centered at Observed Difference = ",
                          round(x$obs_diff, 4)),
        x = x_label, y = "Count") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {

    x_vals <- seq(x$obs_diff - 4 * x$se, x$obs_diff + 4 * x$se,
                  length.out = 1000)

    if (x$sd_type == "population") {
      y_vals     <- dnorm(x_vals, mean = x$obs_diff, sd = x$se)
      dist_title <- "Theoretical Normal Distribution (Z-Curve)"
    } else {
      y_vals     <- dt((x_vals - x$obs_diff) / x$se, df = x$df) / x$se
      dist_title <- paste0("Theoretical T-Distribution (df = ",
                           round(x$df, 2), ")")
    }

    plot_data   <- data.frame(val = x_vals, dens = y_vals)
    ci_mid      <- (x$lower + x$upper) / 2
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
        subtitle = paste0("Centered at Observed Difference = ",
                          round(x$obs_diff, 4)),
        x = x_label, y = "Density") +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.text.y  = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank()
      )
  }

  # Validity caption
  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    p_dist <- p_dist +
      ggplot2::labs(caption = paste0(
        "Warning: at least one group has fewer than 20 observations. ",
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
#' @method plot_steps stat218_2mean_ci
plot_steps.stat218_2mean_ci <- function(x, ...) {

  pct       <- x$conf_level * 100
  sd_symbol <- ifelse(x$sd_type == "population", "&sigma;", "s")

  # Validity warning -- top of bottom panel
  warning_text <- ""
  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "At least one group has fewer than 20 observations. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "2SD") {
    method_blurb <- paste0(
      "We use the <b>2SD Method</b>. A parametric bootstrap distribution is ",
      "generated by independently drawing repeated samples from both groups:<br>",
      "&bull; ", x$n_1, " values from Normal(", round(x$x_bar_1, 4),
      ", ", round(x$sd_1, 4), ") for ", x$group_names[1], "<br>",
      "&bull; ", x$n_2, " values from Normal(", round(x$x_bar_2, 4),
      ", ", round(x$sd_2, 4), ") for ", x$group_names[2], "<br>",
      "The SD of the simulated differences is our estimated standard error:<br>",
      "&bull; SD of Sampling Distribution = ", round(x$se, 4), "<br>",
      "&bull; Multiplier = 2 (standard for 95% confidence)<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($ME = Multiplier \times SD(\bar{x}_1 - \bar{x}_2)$)",
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
      "We use the <b>Bootstrap Simulation Method</b>. Same parametric bootstrap ",
      "as the 2SD method, but instead of a multiplier, we take the middle ",
      pct, "% of the simulated distribution directly as our interval bounds:<br>",
      "&bull; Lower Bound = ", (1 - x$conf_level) / 2 * 100,
      "th percentile = <b>", round(x$lower, 4), "</b><br>",
      "&bull; Upper Bound = ", (1 - (1 - x$conf_level) / 2) * 100,
      "th percentile = <b>", round(x$upper, 4), "</b>"
    )
    use_math_panel <- FALSE

  } else {
    # Theory method
    if (x$sd_type == "population") {
      method_blurb <- paste0(
        "We use the <b>Theory-Based Method</b>. Because the population ",
        "standard deviations (&sigma;) are known, we use the Z-distribution ",
        "to find our multiplier.<br>",
        "&bull; SD of Sampling Distribution = &radic;(&sigma;<sub>1</sub><sup>2</sup>/n<sub>1</sub> + &sigma;<sub>2</sub><sup>2</sup>/n<sub>2</sub>)",
        " = ", round(x$se, 4), "<br>",
        "&bull; Multiplier = ", round(x$multiplier, 3),
        " (from the Z-distribution for ", pct, "% confidence)<br><br>",
        "<i>The formula and calculation are shown below:</i>"
      )
      tex_formula <- latex2exp::TeX(
        r"($ME = Multiplier \times \sqrt{\frac{\sigma_1^2}{n_1} + \frac{\sigma_2^2}{n_2}}$)",
        output = "character"
      )
    } else {
      method_blurb <- paste0(
        "We use the <b>Theory-Based Method</b>. Because the population ",
        "standard deviations are unknown, we use sample SDs to estimate ",
        "the SD of the sampling distribution. The T-distribution is used ",
        "with degrees of freedom computed automatically in the background.<br>",
        "&bull; SD of Sampling Distribution = &radic;(s<sub>1</sub><sup>2</sup>/n<sub>1</sub> + s<sub>2</sub><sup>2</sup>/n<sub>2</sub>)",
        " = ", round(x$se, 4), "<br>",
        "&bull; Multiplier = ", round(x$multiplier, 3),
        " (from the T-distribution for ", pct, "% confidence)<br><br>",
        "<i>The formula and calculation are shown below:</i>"
      )
      tex_formula <- latex2exp::TeX(
        r"($ME = Multiplier \times \sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}$)",
        output = "character"
      )
    }

    tex_calc <- latex2exp::TeX(
      paste0("$ME = ", round(x$multiplier, 3),
             " \\times \\sqrt{\\frac{", round(x$sd_1, 4),
             "^2}{", x$n_1, "} + \\frac{", round(x$sd_2, 4),
             "^2}{", x$n_2, "}} = ", round(x$me, 4), "$"),
      output = "character"
    )
    use_math_panel <- TRUE
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Confidence Interval Construction</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data</b></span><br>",
    "&bull; <b>", x$group_names[1], ":</b> x&#772;<sub>1</sub> = ",
    round(x$x_bar_1, 4), " &nbsp;|&nbsp; ", sd_symbol, "<sub>1</sub> = ",
    round(x$sd_1, 4), " &nbsp;|&nbsp; n<sub>1</sub> = ", x$n_1, "<br>",
    "&bull; <b>", x$group_names[2], ":</b> x&#772;<sub>2</sub> = ",
    round(x$x_bar_2, 4), " &nbsp;|&nbsp; ", sd_symbol, "<sub>2</sub> = ",
    round(x$sd_2, 4), " &nbsp;|&nbsp; n<sub>2</sub> = ", x$n_2, "<br>",
    "&bull; <b>Point Estimate (x&#772;<sub>1</sub> &minus; x&#772;<sub>2</sub>):</b> ",
    round(x$obs_diff, 4), "<br><br>",

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
      y     = c(3.5, 0),
      label = c(tex_formula, tex_calc)
    )
    p_math <- ggplot2::ggplot(p_math_data,
                              ggplot2::aes(x = x, y = y, label = label)) +
      ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-2.0, 5.0),
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
      "<b>Confidence Interval</b> = (x&#772;<sub>1</sub> &minus; x&#772;<sub>2</sub>) &plusmn; ME<br>",
      "CI = ", round(x$obs_diff, 4), " &plusmn; ", round(x$me, 4),
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
    "% confident that the true difference in population means (&mu;<sub>1</sub> &minus; &mu;<sub>2</sub>) is between ",
    round(x$lower, 4), " and ", round(x$upper, 4), ".<br>",
    "<i>Frequentist Interpretation:</i> If we were to take 100 random ",
    "samples and calculate a confidence interval for each, we would expect ",
    "approximately ", pct, " of those intervals to contain the true ",
    "difference in population means."
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
        patchwork::plot_layout(heights = c(2.6, 1.8, 3.2))
    )
  } else {
    return(
      p_top / p_bottom +
        patchwork::plot_layout(heights = c(3, 2))
    )
  }
}
