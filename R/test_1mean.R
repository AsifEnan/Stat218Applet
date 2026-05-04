#' 1-Sample Mean Hypothesis Test
#'
#' @description
#' Tests a claim about a single population mean (\eqn{\mu}) using either a
#' simulation-based approach (Parametric Bootstrap) or a theory-based Z-test
#' or T-test, depending on what is known about the population standard
#' deviation.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the sample mean, sample size,
#'   and standard deviation (common in textbook homework problems where the
#'   data is summarized for you). Pass `x_bar`, `n`, and `sd_val` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R (common in
#'   activities and projects). Pass `formula` and `data` instead, and the
#'   function will compute the mean, sample size, and standard deviation
#'   for you automatically.
#'
#' @param x_bar The observed sample mean -- the average value calculated from
#'   your sample. For example, if the average resting heart rate of 30
#'   students was 72.4 beats per minute, `x_bar = 72.4`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n A whole number representing the total sample size (how many
#'   observations were collected). For example, if you measured 30 students,
#'   `n = 30`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_val The standard deviation of the variable. Whether this is the
#'   population standard deviation (\eqn{\sigma}) or the sample standard
#'   deviation (s) is determined by the `sd_type` argument.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_type A character string telling the function whether the standard
#'   deviation you provided is from the **population** or the **sample**.
#'   Must be one of:
#'   \describe{
#'     \item{`"sample"`}{(default) The standard deviation was calculated from
#'       your sample data (this is the most common case in practice). When
#'       this is chosen and `method = "theory"`, a **T-test** is used because
#'       the true population spread is unknown.}
#'     \item{`"population"`}{The true population standard deviation
#'       (\eqn{\sigma}) is known -- this is rare in real life but sometimes
#'       given in textbook problems. When chosen and `method = "theory"`,
#'       a **Z-test** is used.}
#'   }
#' @param formula A one-sided formula of the form `~ variable` that identifies
#'   the numeric variable in your dataset to analyze. For example,
#'   `formula = ~ HeartRate` where `HeartRate` is a column in your data frame.
#'   **Only used when NOT providing `x_bar`, `n`, and `sd_val`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   that contains the variable named in `formula`.
#'   **Only used when NOT providing `x_bar`, `n`, and `sd_val`.**
#' @param null_mu The hypothesized population mean under the null hypothesis
#'   (H\eqn{_0}). This is the value you are testing your sample against.
#'   For example, if you are testing whether the average height is different
#'   from 65 inches, `null_mu = 65`. Default is `0`.
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\mu \neq} `null_mu` (default) --
#'       use when testing if the mean is *different from* the null in either
#'       direction.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\mu >} `null_mu` --
#'       use when testing if the mean is *greater than* the null.}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\mu <} `null_mu` --
#'       use when testing if the mean is *less than* the null.}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"theory"`}{(default) Uses the traditional Z-test (if
#'       `sd_type = "population"`) or T-test (if `sd_type = "sample"`).
#'       Appropriate when validity conditions are met: the sample size is
#'       at least 20, or the underlying population is known to be roughly
#'       symmetric.}
#'     \item{`"simulation"`}{Uses a Parametric Bootstrap simulation. A
#'       hypothetical population centered at `null_mu` is created and
#'       repeated samples are drawn to build the null distribution. This
#'       method is more flexible and does not rely on distributional
#'       assumptions.}
#'   }
#' @param sim_reps The number of bootstrap samples to draw when
#'   `method = "simulation"`. More repetitions give a more stable p-value
#'   estimate. Default is `1000`. Increasing to `5000` or `10000` is
#'   reasonable for final analyses.
#'
#' @return An S3 object of class `stat218_1mean` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the test including
#'       the observed mean, null hypothesis, SD of the null distribution,
#'       test statistic, and p-value.}
#'     \item{`plot(result)`}{Plots the null distribution with shaded p-value
#'       region(s), p-value annotation on the shaded area(s), and the SD of
#'       the Null Distribution labeled on the plot.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation -- great
#'       for checking your work or studying before an exam.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a one-sample mean test, we are asking: *"Is the average value we
#' observed in our sample consistent with some claimed population mean, or
#' is it too far away to be explained by random chance alone?"*
#'
#' The null hypothesis always takes the form H\eqn{_0}: \eqn{\mu =} `null_mu`,
#' where \eqn{\mu} (Greek letter "mu") represents the **true, unknown
#' population mean**.
#'
#' ## Z-Test vs. T-Test (Theory Method)
#' When `method = "theory"`, the choice between Z and T depends entirely on
#' what you know about the population:
#' - If the **true population standard deviation** (\eqn{\sigma}) **is known**
#'   (`sd_type = "population"`), use the **Z-test**.
#' - If only the **sample standard deviation** (s) is available
#'   (`sd_type = "sample"`), use the **T-test**. This is the most common
#'   real-world situation. The degrees of freedom are handled automatically
#'   in the background.
#'
#' ## Simulation Method (Parametric Bootstrap)
#' We simulate what the world would look like *if the null hypothesis were
#' true* by repeatedly drawing samples of size `n` from a Normal distribution
#' centered at `null_mu` with standard deviation `sd_val`. The SD of that
#' simulated null distribution goes in the denominator of the test statistic.
#' The p-value is the proportion of simulated sample means as extreme as or
#' more extreme than our observed \eqn{\bar{x}}.
#'
#' ## Validity Conditions for Theory Method
#' The theory-based test is most reliable when:
#' - Sample size \eqn{n \geq 20} (Central Limit Theorem kicks in), **or**
#' - The underlying distribution of the variable is known to be roughly
#'   symmetric even for smaller samples.
#'
#' A warning will be issued automatically if `n < 20` and
#' `method = "theory"`.
#'
#' @examples
#' # --- Summary Statistics Path (one-sided, theory Z-test) ---
#' # Testing whether the average daily step count exceeds 8000.
#' # A fitness study reported: x-bar = 8450, n = 40, sigma = 1200 (known).
#' result <- test_1mean(x_bar = 8450, n = 40, sd_val = 1200,
#'                      sd_type = "population", null_mu = 8000,
#'                      alternative = "greater", method = "theory")
#' print(result)
#' plot(result)
#' \dontrun{
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics Path (two-sided, theory T-test) ---
#' # Testing whether the average exam score differs from 75.
#' # Sample: x-bar = 78.3, n = 25, s = 9.1 (sample SD).
#' result2 <- test_1mean(x_bar = 78.3, n = 25, sd_val = 9.1,
#'                       sd_type = "sample", null_mu = 75,
#'                       alternative = "two.sided", method = "theory")
#' print(result2)
#' plot(result2)
#' \dontrun{
#' plot_steps(result2)
#' }
#'
#' # --- Raw Data Path (one-sided, simulation) ---
#' # Using mtcars: testing whether the average MPG exceeds 18.
#' result3 <- test_1mean(formula = ~ mpg, data = mtcars,
#'                       null_mu = 18, alternative = "greater",
#'                       method = "simulation")
#' print(result3)
#' plot(result3)
#' \dontrun{
#' plot_steps(result3)
#'}
#'
#' # --- Raw Data Path (two-sided, theory T-test) ---
#' # Using mtcars: testing whether average horsepower differs from 150.
#' result4 <- test_1mean(formula = ~ hp, data = mtcars,
#'                       null_mu = 150, alternative = "two.sided",
#'                       method = "theory")
#' print(result4)
#' plot(result4)
#' \dontrun{
#' plot_steps(result4)
#' }
#'
#' @export
test_1mean <- function(x_bar = NULL, n = NULL, sd_val = NULL,
                       sd_type = "sample",
                       formula = NULL, data = NULL,
                       null_mu = 0,
                       alternative = "two.sided",
                       method = "theory",
                       sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar) || !is.null(n) || !is.null(sd_val)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided -- conflict error
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (x_bar/n/sd_val)}.",
      "i" = "These are two different ways to use {.fn test_1mean} -- please choose one:",
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

  # Case 2: Raw data path -- extract x_bar, n, sd_val
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code test_1mean(formula = ~ YourVariable, data = your_data, null_mu = 0)}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "Please also specify which variable to analyze. For example:",
        " " = "{.code test_1mean(formula = ~ YourVariable, data = your_data, null_mu = 0)}"
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
        "i" = "Available variables in your data are: {.val {names(data)}}."
      ))
    }

    col <- data[[var_name]]

    if (!is.numeric(col)) {
      cli::cli_abort(c(
        "x" = "The variable {.val {var_name}} must be numeric for a mean test.",
        "i" = "It appears to contain non-numeric values. Check your data."
      ))
    }

    col    <- col[!is.na(col)]
    x_bar  <- mean(col)
    n      <- length(col)
    sd_val <- sd(col)

    cli::cli_inform(c(
      "v" = "Data extracted from variable {.val {var_name}}:",
      "*" = "Sample Mean (x-bar): {round(x_bar, 4)}",
      "*" = "Sample SD (s):       {round(sd_val, 4)}",
      "*" = "Sample Size (n):     {n}",
      "i" = "{.arg sd_type} automatically set to {.val sample} from raw data."
    ))

    # When using raw data, sd_type is always "sample"
    sd_type <- "sample"
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
      "i" = "You provided: {.val {sd_type}}",
      "i" = "Use {.val sample} if your SD was calculated from your data (most common), or {.val population} if the true population SD is known."
    ))
  }

  if (!is.numeric(null_mu)) {
    cli::cli_abort(c(
      "x" = "{.arg null_mu} must be a numeric value.",
      "i" = "You provided: {.val {null_mu}}"
    ))
  }

  if (!alternative %in% c("two.sided", "greater", "less")) {
    cli::cli_abort(c(
      "x" = "{.arg alternative} must be one of {.val two.sided}, {.val greater}, or {.val less}.",
      "i" = "You provided: {.val {alternative}}",
      "i" = "Use {.val two.sided} if testing for any difference, {.val greater} if testing for an increase, {.val less} if testing for a decrease."
    ))
  }

  if (!method %in% c("theory", "simulation")) {
    cli::cli_abort(c(
      "x" = "{.arg method} must be either {.val theory} or {.val simulation}.",
      "i" = "You provided: {.val {method}}"
    ))
  }

  if (!is.numeric(sim_reps) || sim_reps < 100) {
    cli::cli_abort(c(
      "x" = "{.arg sim_reps} must be a number of at least 100.",
      "i" = "You provided: {.val {sim_reps}}",
      "i" = "The default of 1000 is recommended for stable p-value estimates."
    ))
  }

  # Validity condition warning for theory method
  if (method == "theory" && n < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based test may not be met.",
      "i" = "Your sample size is n = {n}, which is less than 20.",
      "i" = "The Central Limit Theorem does not guarantee a normal sampling distribution at this size.",
      "i" = "Proceed only if the underlying data is known to be roughly symmetric.",
      "i" = "Otherwise, consider using {.code method = \"simulation\"}."
    ))
  }

  # ============================================================
  # MATH ENGINE -- unchanged from Phase One
  # ============================================================

  if (method == "theory") {
    se       <- sd_val / sqrt(n)
    stat_val <- (x_bar - null_mu) / se
    sim_data <- NULL

    if (sd_type == "population") {
      stat_name <- "Z"
      df        <- NA
      if (alternative == "greater")      p_val <- 1 - pnorm(stat_val)
      else if (alternative == "less")    p_val <- pnorm(stat_val)
      else                               p_val <- 2 * pnorm(-abs(stat_val))
    } else {
      stat_name <- "T"
      df        <- n - 1
      if (alternative == "greater")      p_val <- 1 - pt(stat_val, df)
      else if (alternative == "less")    p_val <- pt(stat_val, df)
      else                               p_val <- 2 * pt(-abs(stat_val), df)
    }

  } else if (method == "simulation") {
    sim_data  <- replicate(sim_reps, mean(rnorm(n, mean = null_mu, sd = sd_val)))
    se        <- sd(sim_data)
    stat_val  <- (x_bar - null_mu) / se
    stat_name <- "Z_sim"
    df        <- NA

    if (alternative == "greater") {
      p_val <- sum(sim_data >= x_bar) / sim_reps
    } else if (alternative == "less") {
      p_val <- sum(sim_data <= x_bar) / sim_reps
    } else {
      obs_diff <- abs(x_bar - null_mu)
      p_val    <- sum(abs(sim_data - null_mu) >= obs_diff) / sim_reps
    }
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar       = x_bar,
    n           = n,
    sd_val      = sd_val,
    sd_type     = sd_type,
    null_mu     = null_mu,
    alternative = alternative,
    method      = method,
    stat_val    = stat_val,
    stat_name   = stat_name,
    se          = se,
    p_val       = p_val,
    sim_data    = sim_data,
    df          = df
  )

  class(res) <- "stat218_1mean"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_1mean
print.stat218_1mean <- function(x, ...) {
  sd_symbol <- ifelse(x$sd_type == "population", "sigma", "s")

  cli::cli_h1("1-Sample Mean Hypothesis Test ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Observed Mean (x-bar): {round(x$x_bar, 4)}",
    "i" = "Standard Deviation ({sd_symbol}): {round(x$sd_val, 4)}  |  n: {x$n}",
    "i" = "Null Hypothesis (mu0): {x$null_mu}",
    "i" = "Alternative: {x$alternative}",
    "*" = "SD of Null Distribution: {round(x$se, 4)}",
    "*" = "Test Statistic ({x$stat_name}): {round(x$stat_val, 3)}",
    "*" = "P-Value: {round(x$p_val, 4)}"
  ))
  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_1mean
plot.stat218_1mean <- function(x, ...) {

  obs_diff      <- abs(x$x_bar - x$null_mu)
  sd_null_label <- paste0("SD of Null Distribution = ", round(x$se, 4))

  if (x$alternative == "greater")     v_lines <- x$x_bar
  else if (x$alternative == "less")   v_lines <- x$x_bar
  else v_lines <- c(x$null_mu - obs_diff, x$null_mu + obs_diff)

  # ---- Simulation branch ----
  if (x$method == "simulation") {

    plot_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$sim >= x$x_bar
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$sim <= x$x_bar
    else
      plot_data$tail <- abs(plot_data$sim - x$null_mu) >= obs_diff

    p1 <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail)) +
      ggplot2::geom_histogram(color = "white", bins = 40)

    # P-value annotation(s)
    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$null_mu - obs_diff * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        ) +
        ggplot2::annotate("text",
                          x = x$null_mu + obs_diff * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    } else {
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$x_bar, y = Inf, vjust = 2,
                          label = paste0("p-value = ", round(x$p_val, 4)),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    }

    p1 <- p1 +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1) +
      ggplot2::scale_fill_manual(values = c("FALSE" = "gray80", "TRUE" = "#D55E00")) +
      ggplot2::annotate("text",
                        x = Inf, y = Inf, hjust = 1.05, vjust = 4,
                        label = sd_null_label,
                        color = "#2C3E50", fontface = "italic", size = 3.8
      ) +
      ggplot2::labs(
        title    = paste0("Parametric Bootstrap Distribution of Sample Means (",
                          tools::toTitleCase(x$alternative), " Test)"),
        subtitle = paste0("Based on ", length(x$sim_data),
                          " samples | Centered at mu0 = ", x$null_mu),
        x = "Simulated Sample Mean",
        y = "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

    # ---- Theory branch ----
  } else {
    val <- dens <- sim <-  NA

    x_vals <- seq(x$null_mu - 4 * x$se, x$null_mu + 4 * x$se, length.out = 1000)

    if (x$sd_type == "population") {
      y_vals     <- dnorm(x_vals, mean = x$null_mu, sd = x$se)
      title_dist <- "Theoretical Normal Distribution (Z-Curve)"
    } else {
      y_vals     <- dt((x_vals - x$null_mu) / x$se, df = x$df) / x$se
      title_dist <- paste0("Theoretical T-Distribution (df = ", x$df, ")")
    }

    plot_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$val >= x$x_bar
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$val <= x$x_bar
    else
      plot_data$tail <- abs(plot_data$val - x$null_mu) >= obs_diff

    p1 <- ggplot2::ggplot(plot_data, ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data = subset(plot_data, tail == TRUE),
        ggplot2::aes(group = val > x$null_mu),
        fill = "#D55E00", alpha = 0.7
      ) +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1)

    # P-value annotation(s)
    y_mid <- max(y_vals) * 0.25
    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$null_mu - obs_diff * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        ) +
        ggplot2::annotate("text",
                          x = x$null_mu + obs_diff * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    } else {
      x_pos <- if (x$alternative == "greater") x$x_bar + obs_diff * 0.8 else x$x_bar - obs_diff * 0.8
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x_pos, y = y_mid,
                          label = paste0("p-value = ", round(x$p_val, 4)),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    }

    p1 <- p1 +
      ggplot2::annotate("text",
                        x = Inf, y = Inf, hjust = 1.05, vjust = 2,
                        label = sd_null_label,
                        color = "#2C3E50", fontface = "italic", size = 3.8
      ) +
      ggplot2::labs(
        title    = title_dist,
        subtitle = paste0("Centered at Null Mean mu0 = ", x$null_mu),
        x = "Sample Mean",
        y = "Density"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.y  = ggplot2::element_blank(),
                     axis.ticks.y = ggplot2::element_blank())
  }

  return(p1)
}

# ============================================================
# PLOT_STEPS METHOD -- 3-panel patchwork with plotmath fractions
# ============================================================

#' @export
#' @method plot_steps stat218_1mean
plot_steps.stat218_1mean <- function(x, alpha = 0.05, ...) {

  pval_pct  <- round(x$p_val * 100, 2)
  z_dir     <- ifelse(x$stat_val > 0, "above", "below")
  sd_symbol <- ifelse(x$sd_type == "population", "&sigma;", "s")

  if (x$alternative == "greater") {
    dir_text   <- "greater than or equal to"
    alt_symbol <- "&gt;"
  } else if (x$alternative == "less") {
    dir_text   <- "less than or equal to"
    alt_symbol <- "&lt;"
  } else {
    dir_text   <- "as extreme as or more extreme than"
    alt_symbol <- "&ne;"
  }

  # +/- 2 rule conclusion
  if (abs(x$stat_val) >= 2) {
    z_conc <- "Since the standardized statistic is outside the typical &plusmn;2 range, it is an unusual result. We <b>Reject the Null Hypothesis (H<sub>0</sub>)</b>."
  } else {
    z_conc <- "Since the standardized statistic is within the typical &plusmn;2 range, it is a plausible result under random chance. We <b>Fail to Reject the Null Hypothesis (H<sub>0</sub>)</b>."
  }

  # P-value conclusion
  if (x$p_val <= alpha) {
    p_conc <- paste0("<i>Conclusion:</i> Since the p-value is less than or equal to our significance level (&alpha; = ", alpha, "), we have strong evidence against the null. We <b>Reject the Null Hypothesis (H<sub>0</sub>)</b>.")
  } else {
    p_conc <- paste0("<i>Conclusion:</i> Since the p-value is greater than our significance level (&alpha; = ", alpha, "), we lack strong evidence against the null. We <b>Fail to Reject the Null Hypothesis (H<sub>0</sub>)</b>.")
  }

  # Validity warning text for bottom panel
  warning_text <- ""
  if (x$method == "theory" && x$n < 20) {
    warning_text <- paste0(
      "<br><br><span style='color:#C0392B; font-size:12pt;'><b>Note on Validity Conditions:</b> ",
      "Because the sample size (n = ", x$n, ") is less than 20, the Central Limit Theorem does not ",
      "guarantee a normal sampling distribution. You must verify that the underlying data is roughly ",
      "symmetric before trusting these theory-based results.</span>"
    )
  }

  # Rounded values for plotmath
  x_bar_r  <- round(x$x_bar, 4)
  sd_val_r <- round(x$sd_val, 4)
  se_r     <- round(x$se, 4)
  stat_r   <- round(x$stat_val, 3)
  n_r      <- x$n
  null_r   <- x$null_mu

  # ---- Build method-specific blurb and plotmath expressions ----
  if (x$method == "simulation") {
    stat_label   <- "Z[sim]"
    method_blurb <- paste0(
      "Because we used the <b>Parametric Bootstrap (simulation)</b>, the SD of the Null ",
      "Distribution is estimated from the ", length(x$sim_data), " simulated sample means ",
      "centered at &mu;<sub>0</sub> = ", null_r, ".<br>",
      "&bull; SD of Null Distribution = ", se_r, "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    expr_formula <- 'Z[sim] == frac(bar(x) - mu[0], "SD of Null Distribution")'
    expr_calc    <- paste0(
      'Z[sim] == paste(frac(', x_bar_r, ' - ', null_r, ', ', se_r, '), " = ", bold(', stat_r, '))'
    )

  } else if (x$sd_type == "population") {
    stat_label   <- "Z"
    method_blurb <- paste0(
      "Because the true population standard deviation (&sigma;) is <b>known</b>, ",
      "the SD of the Null Distribution is computed using &sigma; = ", sd_val_r, " and n = ", n_r, ".<br>",
      "&bull; SD of Null Distribution = &sigma; / &radic;n = ",
      sd_val_r, " / &radic;", n_r, " = ", se_r, "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    expr_formula <- 'Z == frac(bar(x) - mu[0], "SD of Null Distribution")'
    expr_calc    <- paste0(
      'Z == paste(frac(', x_bar_r, ' - ', null_r, ', ', se_r, '), " = ", bold(', stat_r, '))'
    )

  } else {
    stat_label   <- "T"
    method_blurb <- paste0(
      "Because the true population standard deviation (&sigma;) is <b>unknown</b>, we use ",
      "the sample standard deviation (s = ", sd_val_r, ") to estimate it. This gives us a ",
      "<b>T-statistic</b>. The degrees of freedom are handled automatically in the background.<br>",
      "&bull; SD of Null Distribution = s / &radic;n = ",
      sd_val_r, " / &radic;", n_r, " = ", se_r, "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    expr_formula <- 'T == frac(bar(x) - mu[0], "SD of Null Distribution")'
    expr_calc    <- paste0(
      'T == paste(frac(', x_bar_r, ' - ', null_r, ', ', se_r, '), " = ", bold(', stat_r, '))'
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>Observed Mean (x&#772;):</b> ", x_bar_r,
    "&nbsp;&nbsp;|&nbsp;&nbsp;<b>Sample Size (n):</b> ", n_r,
    "&nbsp;&nbsp;|&nbsp;&nbsp;<b>Standard Deviation (", sd_symbol, "):</b> ", sd_val_r, "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &mu; = ", null_r, "<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>a</sub>: &mu; ", alt_symbol, " ", null_r, "<br><br>",

    "<span style='font-size:14pt;'><b>2. Standardized Test Statistic (", stat_label, ")</b></span><br>",
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
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.5, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 20, r = 20, b = 0, l = 20))

  # ---- PANEL 2: plotmath equations (proper full-line fractions) ----
  p_math_data <- data.frame(
    x     = c(0.05, 0.05),
    y     = c(2.5, 0),
    label = c(expr_formula, expr_calc)
  )

  p_math <- ggplot2::ggplot(p_math_data, ggplot2::aes(x = x, y = y, label = label)) +
    ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-1.5, 4.0), clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20, b = 10, l = 40))

  # ---- PANEL 3: Bottom HTML ----
  bottom_html <- paste0(
    "<i>Interpretation of Statistic:</i> The observed sample mean is ",
    abs(round(x$stat_val, 2)), " standard errors <b>", z_dir,
    "</b> the null hypothesized value.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",

    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",

    "<i>Interpretation of P-value:</i> Assuming the true population mean is exactly ",
    null_r, ", there is a ", pval_pct, "% probability of observing a sample mean ",
    dir_text, " ", x_bar_r, " just by random chance.<br>",
    p_conc,
    warning_text
  )

  p_bottom <- ggplot2::ggplot() +
    ggtext::geom_textbox(
      ggplot2::aes(x = 0, y = 1, label = bottom_html),
      width = ggplot2::unit(0.95, "npc"),
      hjust = 0, vjust = 1,
      box.color = NA, fill = NA,
      size = 5, lineheight = 1.5
    ) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 20, b = 20, l = 20))

  # ---- Stitch all three panels ----
  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.2, 1.2, 2.8))
  )
}
