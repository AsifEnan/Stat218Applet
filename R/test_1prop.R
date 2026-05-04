#' 1-Sample Proportion Hypothesis Test
#'
#' @description
#' Tests a claim about a single population proportion (\eqn{\pi}) using either
#' a simulation-based approach (The Great Shuffle) or a theory-based Z-test.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the number of successes and the
#'   sample size (common in textbook homework problems where the data is
#'   summarized for you). Pass `successes` and `n` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R (common in
#'   activities and projects). Pass `formula` and `data` instead, and the
#'   function will count the successes for you.
#'
#' @param successes A whole number representing the count of "successes"
#'   (i.e., the number of times the outcome of interest was observed) in your
#'   sample. For example, if 34 out of 80 students passed, `successes = 34`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n A whole number representing the total sample size (how many
#'   observations were collected in total). For example, if you surveyed
#'   80 students, `n = 80`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A one-sided formula of the form `~ variable` that identifies
#'   the categorical variable in your dataset to analyze. For example,
#'   `formula = ~ Passed` where `Passed` is a column in your data frame.
#'   **Only used when NOT providing `successes` and `n`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   that contains the variable named in `formula`.
#'   **Only used when NOT providing `successes` and `n`.**
#' @param success_level A character string specifying which value of your
#'   categorical variable counts as a "success". For example, if your variable
#'   contains `"Yes"` and `"No"`, use `success_level = "Yes"`. This argument
#'   is **required** when using `formula` and `data`.
#' @param null_pi The hypothesized population proportion under the null
#'   hypothesis (H\eqn{_0}). This is the value you are testing your sample
#'   against. Must be a number strictly between 0 and 1. Default is `0.5`.
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\pi \neq} `null_pi` (default) --
#'       use when testing if the proportion is *different from* the null.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\pi >} `null_pi` --
#'       use when testing if the proportion is *greater than* the null.}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\pi <} `null_pi` --
#'       use when testing if the proportion is *less than* the null.}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"simulation"`}{Uses a simulation-based approach (The Great
#'       Shuffle). Recommended as the default and most intuitive approach for
#'       intro stats. The null distribution is built by repeatedly drawing
#'       random samples under the assumption that H\eqn{_0} is true.}
#'     \item{`"theory"`}{Uses the traditional Z-test formula. Appropriate when
#'       validity conditions are met: at least 10 expected successes and 10
#'       expected failures under the null (i.e., \eqn{n \cdot \pi_0 \geq 10}
#'       and \eqn{n \cdot (1 - \pi_0) \geq 10}).}
#'   }
#' @param sim_reps The number of simulated shuffles to run when
#'   `method = "simulation"`. More repetitions give a more stable p-value
#'   estimate. Default is `1000`. Increasing to `5000` or `10000` is
#'   reasonable for final analyses.
#'
#' @return An S3 object of class `stat218_1prop` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary of the test.}
#'     \item{`plot(result)`}{Plots the null distribution with shaded p-value
#'       region, p-value annotation on the shaded area(s), and the SD of the
#'       Null Distribution. Use `plot(result, plot_type = "dotplot")` for a
#'       dot plot (simulation only).}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a one-sample proportion test, we are asking: *"Is the proportion we
#' observed in our sample consistent with some claimed population proportion,
#' or is it too far away to be explained by random chance alone?"*
#'
#' The null hypothesis always takes the form H\eqn{_0}: \eqn{\pi =} `null_pi`,
#' where \eqn{\pi} (Greek letter "pi") represents the **true, unknown
#' population proportion**.
#'
#' ## Simulation Method (The Great Shuffle)
#' We simulate what the world would look like *if the null hypothesis were
#' true* by repeatedly drawing samples of size `n` from a population where
#' the true proportion is exactly `null_pi`. The SD of that simulated null
#' distribution goes in the denominator of the test statistic. The p-value
#' is the proportion of simulated samples as extreme as or more extreme than
#' our observed \eqn{\hat{p}}.
#'
#' ## Theory Method (Z-Test)
#' We standardize our observed \eqn{\hat{p}} using the formula:
#' \deqn{Z = \frac{\hat{p} - \pi_0}{SD_{null}}, \quad \text{where }
#' SD_{null} = \sqrt{\frac{\pi_0(1-\pi_0)}{n}}}
#' The SD of the null distribution is computed from the formula rather than
#' simulated -- but it represents the exact same concept.
#'
#' ## Validity Conditions for Theory Method
#' The theory-based Z-test is only reliable when:
#' - \eqn{n \cdot \pi_0 \geq 10} (at least 10 expected successes under H\eqn{_0})
#' - \eqn{n \cdot (1 - \pi_0) \geq 10} (at least 10 expected failures under H\eqn{_0})
#'
#' If these are not met, use `method = "simulation"` instead.
#'
#' @examples
#' # --- Summary Statistics Path ---
#' # A claim that 50% of students prefer online learning.
#' # In a sample of 80 students, 52 said yes.
#' result <- test_1prop(successes = 52, n = 80, null_pi = 0.5,
#'                      alternative = "two.sided", method = "theory")
#' print(result)
#' plot(result)
#' \dontrun{
#' plot_steps(result)
#' }
#'
#' # --- Raw Data Path ---
#' # Using mtcars: is the proportion of manual transmission cars different from 50%?
#' car_data <- mtcars
#' car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
#' result2 <- test_1prop(formula = ~ transmission, data = car_data,
#'                       success_level = "Manual", null_pi = 0.5,
#'                       alternative = "two.sided", method = "simulation")
#' print(result2)
#' plot(result2)
#' \dontrun{
#' plot_steps(result2)
#'}
#'
#' @export
test_1prop <- function(successes = NULL, n = NULL,
                       formula = NULL, data = NULL,
                       success_level = NULL,
                       null_pi = 0.5,
                       alternative = "two.sided",
                       method = "simulation",
                       sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(successes) || !is.null(n)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided -- conflict error
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (successes/n)}.",
      "i" = "These are two different ways to use {.fn test_1prop} -- please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula} and {.arg data}, and remove {.arg successes} and {.arg n}.",
      "*" = "If you only have {.strong summary statistics}: use {.arg successes} and {.arg n}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg successes} and {.arg n}.",
      "*" = "{.strong Raw data}: provide {.arg formula} and {.arg data}."
    ))
  }

  # Case 2: Raw data path -- extract successes and n
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code test_1prop(formula = ~ YourVariable, data = your_data, success_level = \"Yes\")}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "Please also specify which variable to analyze. For example:",
        " " = "{.code test_1prop(formula = ~ YourVariable, data = your_data, success_level = \"Yes\")}"
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
        "i" = "Available variables in your data are: {.val {names(data)}}."
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
      "*" = "Success level : {.val {success_level}}",
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

  if (!is.numeric(null_pi) || null_pi <= 0 || null_pi >= 1) {
    cli::cli_abort(c(
      "x" = "{.arg null_pi} must be a number strictly between 0 and 1.",
      "i" = "You provided: {.val {null_pi}}",
      "i" = "Example: {.code null_pi = 0.5} means you are testing whether the true proportion is 50%."
    ))
  }

  if (!alternative %in% c("two.sided", "greater", "less")) {
    cli::cli_abort(c(
      "x" = "{.arg alternative} must be one of {.val two.sided}, {.val greater}, or {.val less}.",
      "i" = "You provided: {.val {alternative}}",
      "i" = "Use {.val two.sided} if testing for any difference, {.val greater} if testing for an increase, {.val less} if testing for a decrease."
    ))
  }

  if (!method %in% c("simulation", "theory")) {
    cli::cli_abort(c(
      "x" = "{.arg method} must be either {.val simulation} or {.val theory}.",
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
  if (method == "theory") {
    exp_success <- n * null_pi
    exp_failure <- n * (1 - null_pi)
    if (exp_success < 10 || exp_failure < 10) {
      cli::cli_warn(c(
        "!" = "Validity conditions for the theory-based Z-test may not be met.",
        "i" = "Expected successes under H0: {round(exp_success, 1)} (need >= 10)",
        "i" = "Expected failures under H0:  {round(exp_failure, 1)} (need >= 10)",
        "i" = "Consider using {.code method = \"simulation\"} for a more reliable p-value."
      ))
    }
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  p_hat <- successes / n

  if (method == "simulation") {
    sim_data  <- rbinom(sim_reps, size = n, prob = null_pi) / n
    se        <- sd(sim_data)
    stat_val  <- (p_hat - null_pi) / se
    stat_name <- "Z_sim"

    if (alternative == "greater") {
      p_val <- sum(sim_data >= p_hat) / sim_reps
    } else if (alternative == "less") {
      p_val <- sum(sim_data <= p_hat) / sim_reps
    } else {
      obs_diff <- abs(p_hat - null_pi)
      p_val    <- sum(abs(sim_data - null_pi) >= obs_diff) / sim_reps
    }

  } else if (method == "theory") {
    sim_data  <- NULL
    se        <- sqrt((null_pi * (1 - null_pi)) / n)
    stat_val  <- (p_hat - null_pi) / se
    stat_name <- "Z"

    if (alternative == "greater") {
      p_val <- pnorm(stat_val, lower.tail = FALSE)
    } else if (alternative == "less") {
      p_val <- pnorm(stat_val, lower.tail = TRUE)
    } else {
      p_val <- 2 * pnorm(abs(stat_val), lower.tail = FALSE)
    }
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    successes   = successes,
    n           = n,
    p_hat       = p_hat,
    null_pi     = null_pi,
    alternative = alternative,
    method      = method,
    se          = se,
    stat_val    = stat_val,
    stat_name   = stat_name,
    p_val       = p_val,
    sim_data    = sim_data
  )

  class(res) <- "stat218_1prop"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_1prop
print.stat218_1prop <- function(x, ...) {
  cli::cli_h1("1-Sample Proportion Test ({tools::toTitleCase(x$method)})")

  cli::cli_bullets(c(
    "i" = "Sample Proportion (p-hat): {round(x$p_hat, 4)} ({x$successes}/{x$n})",
    "i" = "Null Hypothesis (pi0): {x$null_pi}",
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
#' @method plot stat218_1prop
plot.stat218_1prop <- function(x, plot_type = "histogram", ...) {

  obs_diff      <- abs(x$p_hat - x$null_pi)
  sd_null_label <- paste0("SD of Null Distribution = ", round(x$se, 4))

  if (x$alternative == "greater") {
    v_lines <- x$p_hat
  } else if (x$alternative == "less") {
    v_lines <- x$p_hat
  } else {
    v_lines <- c(x$null_pi - obs_diff, x$null_pi + obs_diff)
  }

  # ---- Simulation branch ----
  if (x$method == "simulation") {

    plot_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater") {
      plot_data$tail <- plot_data$sim >= x$p_hat
    } else if (x$alternative == "less") {
      plot_data$tail <- plot_data$sim <= x$p_hat
    } else {
      plot_data$tail <- abs(plot_data$sim - x$null_pi) >= obs_diff
    }

    p1 <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail))

    if (plot_type == "dotplot") {
      max_stack    <- max(table(plot_data$sim))
      dynamic_size <- ifelse(max_stack > 25, 25 / max_stack, 1)
      p1 <- p1 + ggplot2::geom_dotplot(
        method = "histodot", binwidth = 1 / x$n,
        dotsize = dynamic_size, color = "white", stackgroups = TRUE
      ) +
        ggplot2::theme(axis.text.y  = ggplot2::element_blank(),
                       axis.ticks.y = ggplot2::element_blank())
    } else {
      p1 <- p1 + ggplot2::geom_histogram(color = "white", bins = 30)
    }

    # P-value annotation(s)
    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$null_pi - obs_diff * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        ) +
        ggplot2::annotate("text",
                          x = x$null_pi + obs_diff * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    } else {
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$p_hat, y = Inf, vjust = 2,
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
        title    = paste0("Null Distribution of Simulated Proportions (",
                          tools::toTitleCase(x$alternative), " Test)"),
        subtitle = paste0("Based on ", length(x$sim_data),
                          " shuffles | Centered at pi0 = ", x$null_pi),
        x = "Simulated Proportion",
        y = if (plot_type == "dotplot") "" else "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

    # ---- Theory branch ----
  } else {
    val <- dens <- sim <-  NA

    x_vals    <- seq(x$null_pi - 4 * x$se, x$null_pi + 4 * x$se, length.out = 1000)
    y_vals    <- dnorm(x_vals, mean = x$null_pi, sd = x$se)
    plot_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater") {
      plot_data$tail <- plot_data$val >= x$p_hat
    } else if (x$alternative == "less") {
      plot_data$tail <- plot_data$val <= x$p_hat
    } else {
      plot_data$tail <- abs(plot_data$val - x$null_pi) >= obs_diff
    }

    p1 <- ggplot2::ggplot(plot_data, ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data  = subset(plot_data, tail == TRUE),
        ggplot2::aes(group = val > x$null_pi),
        fill  = "#D55E00", alpha = 0.7
      ) +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1)

    # P-value annotation(s)
    y_mid <- max(y_vals) * 0.25
    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p1 <- p1 +
        ggplot2::annotate("text",
                          x = x$null_pi - obs_diff * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        ) +
        ggplot2::annotate("text",
                          x = x$null_pi + obs_diff * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4
        )
    } else {
      x_pos <- if (x$alternative == "greater") x$p_hat + obs_diff * 0.8 else x$p_hat - obs_diff * 0.8
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
        title    = "Theoretical Normal Distribution (Z-Curve)",
        subtitle = paste0("Centered at Null Proportion pi0 = ", x$null_pi),
        x = "Sample Proportion",
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
#' @method plot_steps stat218_1prop
plot_steps.stat218_1prop <- function(x, alpha = 0.05, ...) {

  pval_pct <- round(x$p_val * 100, 2)
  z_dir    <- ifelse(x$stat_val > 0, "above", "below")

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

  # ---- Build plotmath expressions for the math panel ----
  # Using R's native plotmath -- no latex2exp, no \text{}, no \mathbf{}
  # plotmath reference: plain() for plain text, bold() for bold, frac() for fractions
  #
  # Formula line:  Z = (p-hat - pi_0) / "SD of Null Distribution"
  # Calc line:     Z = (p_hat_val - null_pi_val) / se_val = bold(stat_val)

  p_hat_r   <- round(x$p_hat, 4)
  se_r      <- round(x$se, 4)
  stat_r    <- round(x$stat_val, 3)
  null_pi_r <- x$null_pi

  if (x$method == "simulation") {
    stat_label <- "Z[sim]"
    method_blurb <- paste0(
      "Because we used <b>The Great Shuffle (simulation)</b>, the SD of the Null Distribution ",
      "is estimated empirically from the ", length(x$sim_data),
      " simulated samples centered at &pi;<sub>0</sub> = ", x$null_pi, ".<br>",
      "&bull; SD of Null Distribution = ", se_r, "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    expr_formula <- 'Z[sim] == frac(hat(p) - pi[0], "SD of Null Distribution")'
    expr_calc    <- paste0(
      'Z[sim] == paste(frac(', p_hat_r, ' - ', null_pi_r, ', ', se_r, '), " = ", bold(', stat_r, '))'
    )
  } else {
    stat_label <- "Z"
    method_blurb <- paste0(
      "Using the <b>theory-based Z-test</b>, the SD of the Null Distribution is computed ",
      "directly from the formula using &pi;<sub>0</sub> = ", x$null_pi, " and n = ", x$n, ".<br>",
      "&bull; SD of Null Distribution = &radic;(&pi;<sub>0</sub>(1 &minus; &pi;<sub>0</sub>) / n)",
      " = &radic;(", x$null_pi, " &times; ", round(1 - x$null_pi, 4), " / ", x$n, ")",
      " = ", se_r, "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    expr_formula <- 'Z == frac(hat(p) - pi[0], "SD of Null Distribution")'
    expr_calc    <- paste0(
      'Z == paste(frac(', p_hat_r, ' - ', null_pi_r, ', ', se_r, '), " = ", bold(', stat_r, '))'
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>Observed Statistic:</b> p&#770; = <sup>", x$successes, "</sup>&frasl;<sub>",
    x$n, "</sub> = ", round(x$p_hat, 4), "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &pi; = ", x$null_pi, "<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>a</sub>: &pi; ", alt_symbol, " ", x$null_pi, "<br><br>",

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
    "<i>Interpretation of Statistic:</i> The observed sample proportion is ",
    abs(round(x$stat_val, 2)), " standard errors <b>", z_dir,
    "</b> the null hypothesized value.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",

    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",

    "<i>Interpretation of P-value:</i> Assuming the null hypothesis (&pi; = ", x$null_pi,
    ") is completely true, there is a ", pval_pct, "% probability of observing a sample proportion ",
    dir_text, " ", round(x$p_hat, 4), " just by random chance.<br>",
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
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 0, r = 20, b = 20, l = 20))

  # ---- Stitch all three panels ----
  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.2, 1.2, 2.8))
  )
}
