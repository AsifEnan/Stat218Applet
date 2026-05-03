#' Correlation Hypothesis Test
#'
#' @description
#' Tests whether the linear association between two quantitative variables is
#' statistically significant -- that is, whether the true population correlation
#' coefficient (\eqn{\rho}, pronounced "rho") is different from zero.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the observed correlation
#'   coefficient and the sample size (common in textbook problems where
#'   results are summarized for you). Pass `r_obs` and `n` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R. Pass
#'   `formula` and `data` instead, using a two-sided formula of the form
#'   `response ~ explanatory`, and the function will compute the correlation
#'   for you automatically.
#'
#' @param r_obs The observed sample correlation coefficient (a number between
#'   -1 and 1). For example, if the correlation between height and weight in
#'   your sample was 0.72, use `r_obs = 0.72`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n A whole number representing the total number of paired observations
#'   in your sample. For example, if you measured 40 pairs of (x, y) values,
#'   use `n = 40`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A two-sided formula of the form `response ~ explanatory`
#'   identifying the two numeric variables to correlate. For example,
#'   `formula = heart_rate ~ body_temp` where both columns exist in `data`.
#'   **Only used when NOT providing `r_obs` and `n`.**
#' @param data A data frame containing the variables named in `formula`.
#'   **Only used when NOT providing `r_obs` and `n`.**
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\rho \neq 0} (default) -- use when
#'       testing whether the correlation is *different from* zero in either
#'       direction.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\rho > 0} -- use when testing whether
#'       there is a *positive* linear association.}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\rho < 0} -- use when testing whether
#'       there is a *negative* linear association.}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"theory"`}{(default) Converts the observed correlation to a
#'       T-statistic and uses a T-distribution with \eqn{df = n - 2} to
#'       compute the p-value. Appropriate when both variables are roughly
#'       normally distributed and the relationship appears linear.}
#'     \item{`"simulation"`}{Uses a randomization test. The response variable
#'       is repeatedly shuffled to break any existing relationship, and the
#'       correlation is recomputed each time to build a null distribution
#'       centered at \eqn{\rho = 0}. Requires raw data via `formula` and
#'       `data`.}
#'   }
#' @param sim_reps The number of shuffles to perform when
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000` or
#'   `10000` gives a more stable p-value estimate.
#'
#' @return An S3 object of class `stat218_test_correlation` containing all
#'   computed values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary including the observed
#'       correlation, test statistic, degrees of freedom, and p-value.}
#'     \item{`plot(result)`}{Plots the null distribution (simulated or
#'       theoretical T-curve) with orange shaded tail(s), p-value annotation,
#'       and the SD of the Null Distribution labeled on the plot.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation -- great
#'       for checking your work or studying before an exam.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a correlation test, we are asking: *"Is the linear association we
#' observed between two variables in our sample strong enough to conclude
#' that a real relationship exists in the population, or could it have
#' happened by random chance even if \eqn{\rho = 0}?"*
#'
#' The null hypothesis is always H\eqn{_0}: \eqn{\rho = 0} -- no linear
#' association between the two variables in the population.
#'
#' ## Theory Method
#' When `method = "theory"`, the observed correlation \eqn{r} is converted
#' to a T-statistic using the formula:
#' \deqn{t = r \cdot \sqrt{\frac{n - 2}{1 - r^2}}}
#' This T-statistic follows a T-distribution with \eqn{df = n - 2} under
#' the null hypothesis.
#'
#' ## Simulation Method (Randomization Test)
#' When `method = "simulation"`, the response variable is shuffled
#' repeatedly to destroy any real relationship while keeping the
#' explanatory variable fixed. Each shuffle produces a simulated
#' correlation under the null hypothesis of \eqn{\rho = 0}. The
#' proportion of simulated correlations as extreme as the observed one
#' is the p-value. Requires raw data via `formula` and `data`.
#'
#' ## Validity Conditions (Theory Method)
#' The theory-based method is appropriate when:
#' - Both variables are roughly normally distributed (or \eqn{n} is large)
#' - The relationship between the two variables appears linear (check a
#'   scatterplot first using `explore_2vars()`)
#' - There are no severe outliers
#'
#' @examples
#' # --- Summary Statistics Path (two-sided, theory) ---
#' # Observed correlation of 0.54 from 40 pairs of observations.
#' result <- test_correlation(
#'   r_obs       = 0.54,
#'   n           = 40,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' print(result)
#' \dontrun{
#' plot(result)
#' plot_steps(result)
#' }
#'
#' # --- Raw Data Path (theory) ---
#' # Using the tempheart dataset: does heart rate correlate with body temperature?
#' result2 <- test_correlation(
#'   formula     = heart_rate ~ body_temp,
#'   data        = tempheart,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' print(result2)
#' \dontrun{
#' plot(result2)
#' plot_steps(result2)
#' }
#'
#' # --- Raw Data Path (simulation) ---
#' result3 <- test_correlation(
#'   formula     = heart_rate ~ body_temp,
#'   data        = tempheart,
#'   alternative = "two.sided",
#'   method      = "simulation",
#'   sim_reps    = 5000
#' )
#' print(result3)
#' \dontrun{
#' plot(result3)
#' }
#'
#' @export
test_correlation <- function(r_obs = NULL, n = NULL,
                             formula = NULL, data = NULL,
                             alternative = "two.sided",
                             method = "theory",
                             sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION
  # ============================================================

  summary_stat_provided <- !is.null(r_obs) || !is.null(n)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (r_obs/n)}.",
      "i" = "These are two different ways to use {.fn test_correlation} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula} and {.arg data}, and remove {.arg r_obs} and {.arg n}.",
      "*" = "If you only have {.strong summary statistics}: use {.arg r_obs} and {.arg n}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg r_obs} and {.arg n}.",
      "*" = "{.strong Raw data}: provide {.arg formula} and {.arg data}."
    ))
  }

  # Summary stats + simulation -- not possible
  if (summary_stat_provided && method == "simulation") {
    cli::cli_abort(c(
      "x" = "Simulation is not available when using summary statistics.",
      "i" = "The simulation method works by shuffling individual data values.",
      "i" = "Since you only provided summary statistics, there are no individual values to shuffle.",
      "i" = "Please either:",
      "*" = "Use {.code method = \"theory\"} with your summary statistics, or",
      "*" = "Provide raw data via {.arg formula} and {.arg data} to use simulation."
    ))
  }

  # Raw data vectors (stored for plot use)
  x_clean <- NULL
  y_clean <- NULL
  x_name  <- "Explanatory"
  y_name  <- "Response"

  # ---- Raw data path ----
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code test_correlation(formula = y ~ x, data = your_data)}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "The formula should look like: {.code response ~ explanatory}"
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
        "x" = "The variable {.val {y_name}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    if (!x_name %in% names(data)) {
      cli::cli_abort(c(
        "x" = "The variable {.val {x_name}} was not found in your data.",
        "i" = "Available variables are: {.val {names(data)}}."
      ))
    }

    y_col <- data[[y_name]]
    x_col <- data[[x_name]]

    if (!is.numeric(y_col)) {
      cli::cli_abort(c(
        "x" = "The response variable {.val {y_name}} must be numeric for a correlation test.",
        "i" = "It appears to contain non-numeric values. Check your data."
      ))
    }

    if (!is.numeric(x_col)) {
      cli::cli_abort(c(
        "x" = "The explanatory variable {.val {x_name}} must be numeric for a correlation test.",
        "i" = "It appears to contain non-numeric values. Check your data."
      ))
    }

    valid_idx <- complete.cases(x_col, y_col)
    x_clean   <- x_col[valid_idx]
    y_clean   <- y_col[valid_idx]
    n         <- length(x_clean)
    r_obs     <- cor(x_clean, y_clean)

    cli::cli_inform(c(
      "v" = "Data extracted from {.val {y_name}} ~ {.val {x_name}}:",
      "*" = "n = {n}",
      "*" = "Observed correlation (r) = {round(r_obs, 4)}"
    ))
  }

  # ---- Input validation ----
  if (!is.numeric(r_obs) || r_obs < -1 || r_obs > 1) {
    cli::cli_abort(c(
      "x" = "{.arg r_obs} must be a number between -1 and 1.",
      "i" = "You provided: {.val {r_obs}}"
    ))
  }

  if (!is.numeric(n) || n != round(n) || n < 3) {
    cli::cli_abort(c(
      "x" = "{.arg n} must be a whole number of at least 3.",
      "i" = "You provided: {.val {n}}"
    ))
  }

  if (!alternative %in% c("two.sided", "greater", "less")) {
    cli::cli_abort(c(
      "x" = "{.arg alternative} must be one of {.val two.sided}, {.val greater}, or {.val less}.",
      "i" = "You provided: {.val {alternative}}"
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
      "i" = "You provided: {.val {sim_reps}}"
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  df     <- n - 2
  t_stat <- r_obs * sqrt((n - 2) / (1 - r_obs^2))

  sim_data <- NULL

  if (method == "theory") {

    if (alternative == "greater")    p_val <- 1 - pt(t_stat, df = df)
    else if (alternative == "less")  p_val <- pt(t_stat, df = df)
    else                             p_val <- 2 * pt(-abs(t_stat), df = df)

    sd_null <- sd(dt(seq(-4, 4, length.out = 1000), df = df))

  } else {

    sim_data <- replicate(sim_reps, {
      cor(x_clean, sample(y_clean, size = n, replace = FALSE))
    })

    if (alternative == "greater")    p_val <- mean(sim_data >= r_obs)
    else if (alternative == "less")  p_val <- mean(sim_data <= r_obs)
    else                             p_val <- mean(abs(sim_data) >= abs(r_obs))

    sd_null <- sd(sim_data)
  }

  # Validity warning
  if (method == "theory" && n < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based test may not be met.",
      "i" = "The sample size is {n}, which is less than 20.",
      "i" = "Proceed only if both variables are roughly normally distributed.",
      "i" = "Otherwise consider using {.code method = \"simulation\"} with raw data."
    ))
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    r_obs       = r_obs,
    n           = n,
    df          = df,
    t_stat      = t_stat,
    sd_null     = sd_null,
    p_val       = p_val,
    alternative = alternative,
    method      = method,
    sim_data    = sim_data,
    x_clean     = x_clean,
    y_clean     = y_clean,
    x_name      = x_name,
    y_name      = y_name
  )

  class(res) <- "stat218_test_correlation"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_test_correlation
print.stat218_test_correlation <- function(x, ...) {

  cli::cli_h1("Correlation Hypothesis Test ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Null Hypothesis: rho = 0",
    "i" = "Alternative: rho {ifelse(x$alternative == 'two.sided', '!=', ifelse(x$alternative == 'greater', '>', '<'))} 0",
    "*" = "Sample Size (n): {x$n}",
    "*" = "Observed Correlation (r): {round(x$r_obs, 4)}",
    "*" = "SD of Null Distribution: {round(x$sd_null, 4)}",
    "*" = "Test Statistic (T): {round(x$t_stat, 4)}",
    "*" = "Degrees of Freedom: {x$df}",
    "*" = "P-Value: {round(x$p_val, 4)}"
  ))

  if (x$method == "theory" && x$n < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- n = {x$n} is less than 20.",
      "i" = "Verify that both variables are roughly normally distributed.",
      "i" = "Consider using {.code method = \"simulation\"} if raw data is available."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_test_correlation
plot.stat218_test_correlation <- function(x, ...) {

  sd_null_label <- paste0("SD of Null Distribution = ", round(x$sd_null, 4))

  # Validity caption
  validity_caption <- ""
  if (x$method == "theory" && x$n < 20) {
    validity_caption <- paste0(
      "Warning: n = ", x$n, " is less than 20. ",
      "Validity conditions may not be met. Consider method = \"simulation\"."
    )
  }

  # ---- Simulation branch ----
  if (x$method == "simulation") {

    plot_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$sim >= x$r_obs
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$sim <= x$r_obs
    else
      plot_data$tail <- abs(plot_data$sim) >= abs(x$r_obs)

    v_lines <- if (x$alternative == "two.sided")
      c(-abs(x$r_obs), abs(x$r_obs)) else x$r_obs

    p_dist <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail)) +
      ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0)

    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = -abs(x$r_obs) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(x$r_obs) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = x$r_obs, y = Inf, vjust = 2,
                          label = paste0("p-value = ", round(x$p_val, 4)),
                          color = "#D55E00", fontface = "bold", size = 4)
    }

    p_dist <- p_dist +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1) +
      ggplot2::scale_fill_manual(values = c("FALSE" = "gray80", "TRUE" = "#D55E00")) +
      ggplot2::annotate("text",
                        x = Inf, y = Inf, hjust = 1.05, vjust = 4,
                        label = sd_null_label,
                        color = "#2C3E50", fontface = "italic", size = 3.8) +
      ggplot2::labs(
        title    = "Randomization Distribution of Correlation Coefficients",
        subtitle = paste0("Based on ", length(x$sim_data),
                          " shuffles | Centered at rho = 0"),
        x = "Simulated Correlation (r)", y = "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {

    # ---- Theory branch ----
    limit     <- max(abs(x$t_stat) * 1.5, 4)
    x_vals    <- seq(-limit, limit, length.out = 1000)
    y_vals    <- dt(x_vals, df = x$df)
    plot_data <- data.frame(val = x_vals, dens = y_vals)

    v_lines <- if (x$alternative == "two.sided")
      c(-abs(x$t_stat), abs(x$t_stat)) else x$t_stat

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$val >= x$t_stat
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$val <= x$t_stat
    else
      plot_data$tail <- abs(plot_data$val) >= abs(x$t_stat)

    y_mid  <- max(y_vals) * 0.25

    p_dist <- ggplot2::ggplot(plot_data, ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data = subset(plot_data, tail == TRUE),
        ggplot2::aes(group = val > 0),
        fill = "#D55E00", alpha = 0.7
      ) +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1)

    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = -abs(x$t_stat) * 1.5, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(x$t_stat) * 1.5, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = x$t_stat * 1.5, y = y_mid,
                          label = paste0("p-value = ", round(x$p_val, 4)),
                          color = "#D55E00", fontface = "bold", size = 4)
    }

    p_dist <- p_dist +
      ggplot2::annotate("text",
                        x = Inf, y = Inf, hjust = 1.05, vjust = 2,
                        label = sd_null_label,
                        color = "#2C3E50", fontface = "italic", size = 3.8) +
      ggplot2::labs(
        title    = paste0("Theoretical T-Distribution (df = ", x$df, ")"),
        subtitle = "Centered at rho = 0",
        x = "Standardized Statistic (T)", y = "Density"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.y  = ggplot2::element_blank(),
                     axis.ticks.y = ggplot2::element_blank())
  }

  if (validity_caption != "") {
    p_dist <- p_dist +
      ggplot2::labs(caption = validity_caption) +
      ggplot2::theme(
        plot.caption = ggplot2::element_text(
          color = "#C0392B", face = "bold", size = 9, hjust = 0
        )
      )
  }

  return(p_dist)
}

# ============================================================
# PLOT_STEPS METHOD
# ============================================================

#' @export
#' @method plot_steps stat218_test_correlation
plot_steps.stat218_test_correlation <- function(x, alpha = 0.05, ...) {

  pval_pct  <- round(x$p_val * 100, 2)
  t_dir     <- ifelse(x$t_stat > 0, "above", "below")

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

  if (abs(x$t_stat) >= 2) {
    z_conc <- "Since the standardized statistic is outside the typical &plusmn;2 range, it is an unusual result. We <b>Reject the Null Hypothesis (H<sub>0</sub>)</b>."
  } else {
    z_conc <- "Since the standardized statistic is within the typical &plusmn;2 range, it is a plausible result under random chance. We <b>Fail to Reject the Null Hypothesis (H<sub>0</sub>)</b>."
  }

  if (x$p_val <= alpha) {
    p_conc <- paste0("<i>Conclusion:</i> Since the p-value is less than or equal to our significance level (&alpha; = ", alpha, "), we have strong evidence against the null. We <b>Reject the Null Hypothesis (H<sub>0</sub>)</b>.")
  } else {
    p_conc <- paste0("<i>Conclusion:</i> Since the p-value is greater than our significance level (&alpha; = ", alpha, "), we lack strong evidence against the null. We <b>Fail to Reject the Null Hypothesis (H<sub>0</sub>)</b>.")
  }

  # Validity warning -- at TOP of bottom panel
  warning_text <- ""
  if (x$method == "theory" && x$n < 20) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "n = ", x$n, " is less than 20. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Method-specific blurb and equations ----
  if (x$method == "simulation") {

    method_blurb <- paste0(
      "We use a <b>Randomization Test</b> -- the response variable is shuffled ",
      "repeatedly to break any real association, simulating a world where ",
      "&rho; = 0. The correlation is recomputed for each shuffle.<br>",
      "&bull; SD of Null Distribution = ", round(x$sd_null, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )

    tex_formula <- latex2exp::TeX(
      r"($Z_{sim} = \frac{r - 0}{SD_{null}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$Z_{sim} = \\frac{", round(x$r_obs, 4), " - 0}{",
             round(x$sd_null, 4), "} = ", round(x$t_stat, 3), "$"),
      output = "character"
    )

  } else {

    method_blurb <- paste0(
      "We convert the observed correlation to a <b>T-statistic</b> using ",
      "degrees of freedom df = n - 2 = ", x$df, ".<br>",
      "&bull; SD of Null Distribution = ", round(x$sd_null, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )

    tex_formula <- latex2exp::TeX(
      r"($T = \frac{r \cdot \sqrt{\frac{n-2}{1-r^2}}}{SD_{null}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$T = \\frac{", round(x$r_obs, 3),
             " \\cdot \\sqrt{\\frac{", x$n, "-2}{1-(", round(x$r_obs, 3), ")^2}}}{",
             round(x$sd_null, 4), "} = ", round(x$t_stat, 3), "$"),
      output = "character"
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>Sample Size (n):</b> ", x$n, "<br>",
    "&bull; <b>Observed Correlation (r):</b> ", round(x$r_obs, 4), "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &rho; = 0<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>A</sub>: &rho; ", alt_symbol, " 0<br><br>",

    "<span style='font-size:14pt;'><b>2. Standardized Test Statistic (T)</b></span><br>",
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

  # ---- PANEL 2: Equations ----
  p_math_data <- data.frame(
    x     = c(0.1, 0.1),
    y     = c(3.5, 0),
    label = c(tex_formula, tex_calc)
  )

  p_math <- ggplot2::ggplot(p_math_data,
                            ggplot2::aes(x = x, y = y, label = label)) +
    ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-2.0, 5.0), clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20, b = 10, l = 40))

  # ---- PANEL 3: Bottom HTML -- warning at top ----
  bottom_html <- paste0(
    warning_text,
    "<i>Interpretation of Statistic:</i> The observed correlation is ",
    abs(round(x$t_stat, 2)), " standard errors <b>", t_dir,
    "</b> the null hypothesized value of 0.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",

    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",

    "<i>Interpretation of P-value:</i> Assuming there is truly no linear association ",
    "between the two variables (&rho; = 0), there is a ", pval_pct,
    "% probability of observing a correlation ", dir_text, " ",
    round(x$r_obs, 4), " just by random chance.<br>",
    p_conc
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
    ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 20, b = 20, l = 20))

  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.6, 1.8, 3.5))
  )
}
