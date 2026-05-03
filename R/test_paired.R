#' Paired Data Hypothesis Test
#'
#' @description
#' Tests whether the true mean difference between paired measurements is zero
#' (\eqn{\mu_d = 0}) using either a theory-based T-test or a
#' simulation-based sign-flipping approach (when raw data is provided).
#'
#' Paired data arises when each subject contributes **two related
#' measurements** -- for example, a before/after reading, a left/right
#' measurement, or two treatments applied to the same subject. Because the
#' two measurements within each pair are linked, we work with the
#' **differences** rather than treating the two groups independently.
#'
#' This function accepts input in **three ways**:
#'
#' - **Summary Statistics:** You already know the mean difference, standard
#'   deviation of differences, and number of pairs. Pass `x_bar_d`, `sd_d`,
#'   and `n_d` directly. Note that `method = "simulation"` is not available
#'   with summary statistics -- simulation requires the individual difference
#'   values.
#'
#' - **Single Differences Column:** You have a dataset with one column
#'   containing the pre-computed differences (After minus Before, or
#'   Treatment minus Control, etc.). Use `formula = ~ Differences` with
#'   your data frame.
#'
#' - **Two Columns (Before/After):** You have a dataset with two separate
#'   columns -- one for each measurement. Use `formula = After ~ Before`
#'   and the function computes the differences automatically as
#'   After minus Before for each pair.
#'
#' @param x_bar_d The observed sample mean of the differences. Positive
#'   values mean the first measurement (or "After") tends to be larger;
#'   negative values mean it tends to be smaller.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_d The standard deviation of the differences across all pairs.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_d A whole number representing the total number of pairs.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A formula specifying the data structure. Two formats
#'   are accepted:
#'   \describe{
#'     \item{`~ Differences`}{A one-sided formula when your dataset
#'       contains a single column of pre-computed differences. Replace
#'       `Differences` with the actual column name.}
#'     \item{`After ~ Before`}{A two-sided formula when your dataset
#'       has two separate measurement columns. The function computes
#'       `After - Before` for each row automatically.}
#'   }
#'   **Only used when NOT providing `x_bar_d`, `sd_d`, and `n_d`.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   containing the variable(s) named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param name A short descriptive label for what the differences represent.
#'   Used in plot axis labels. For example, `name = "After - Before"` or
#'   `name = "Treatment - Control"`. Defaults to `"Differences"`.
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\mu_d \neq 0} (default) --
#'       use when testing if the mean difference is simply *different
#'       from zero* in either direction.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\mu_d > 0} --
#'       use when testing if the mean difference is *positive* (After
#'       tends to be larger than Before).}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\mu_d < 0} --
#'       use when testing if the mean difference is *negative* (After
#'       tends to be smaller than Before).}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"theory"`}{(default) Uses a one-sample T-test on the
#'       differences, with degrees of freedom = n\eqn{_d} - 1 handled
#'       automatically in the background. Appropriate when the number of
#'       pairs is at least 20, or when the distribution of differences
#'       is roughly symmetric.}
#'     \item{`"simulation"`}{Uses a Sign-Flipping simulation. For each
#'       repetition, a coin is flipped for every pair -- heads means the
#'       sign of that pair's difference is flipped (swapping which
#'       measurement came "first"), tails means it stays as is. This
#'       simulates the null hypothesis that the two measurements are
#'       completely interchangeable. Requires raw data.}
#'   }
#' @param sim_reps The number of sign-flipping repetitions when
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000`
#'   gives a more stable p-value estimate.
#'
#' @return An S3 object of class `stat218_test_paired` containing all
#'   computed values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary including the mean
#'       difference, SD of null distribution, test statistic, and p-value.}
#'     \item{`plot(result)`}{Plots the null distribution with shaded
#'       p-value region(s) and SD of Null Distribution annotated.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a paired data test, we reduce the problem to a **one-sample mean
#' test on the differences**. Instead of comparing two groups, we ask:
#' *"Is the average difference we observed across all pairs consistent
#' with zero (no real effect), or is it too far from zero to be explained
#' by random chance alone?"*
#'
#' The null hypothesis always takes the form H\eqn{_0}: \eqn{\mu_d = 0},
#' where \eqn{\mu_d} is the true mean of all possible pair differences in
#' the population.
#'
#' ## Why Paired and Not Two-Sample?
#' Because the two measurements within each pair are linked to the same
#' subject, treating them as two independent groups would ignore that
#' connection and throw away important information. By working with
#' differences, we control for subject-to-subject variability.
#'
#' ## Simulation Method (Sign-Flipping)
#' Under the null hypothesis, the two measurements for each subject are
#' completely interchangeable -- it does not matter which one we call
#' "Before" and which we call "After." To simulate this, we flip a coin
#' for each pair. Heads means we swap the two values (flipping the sign
#' of the difference); tails means we leave them as is. We then compute
#' the mean of all the (possibly flipped) differences. Repeating this
#' thousands of times builds the null distribution. The SD of that
#' distribution goes in the denominator of the test statistic.
#'
#' ## Validity Conditions
#' The theory-based T-test is most reliable when:
#' - The number of pairs \eqn{n_d \geq 20}, **or**
#' - The distribution of the differences is roughly symmetric, even
#'   for smaller samples.
#'
#' A warning is issued automatically if `n_d < 20` and
#' `method = "theory"`.
#'
#' @examples
#' # --- Summary Statistics Path (two-sided, theory) ---
#' # Students took a pre-test and post-test. Mean improvement was 4.2 points.
#' result <- test_paired(
#'   x_bar_d = 4.2, sd_d = 6.8, n_d = 25,
#'   name = "Post - Pre",
#'   alternative = "two.sided", method = "theory"
#' )
#' print(result)
#' plot(result)
#' \dontrun{
#' plot_steps(result)
#'}
#'
#' # --- Single Differences Column (simulation) ---
#' # Compute the difference (wide - narrow) and store it as a new column
#' firstbase$diff <- firstbase$wide - firstbase$narrow
#' result2 <- test_paired(
#'  formula     = ~ diff,
#'  data        = firstbase,
#'  alternative = "two.sided",
#'  method      = "simulation"
#')
#' plot(result2)
#' \dontrun{
#' plot_steps(result2)
#'}
#'
#' # --- Two Columns Before/After (theory) ---
#' # Using a manually created before/after dataset.
#' study_data <- data.frame(
#'   Before = c(72, 68, 75, 80, 65, 70, 78, 82, 69, 74),
#'   After  = c(78, 72, 80, 84, 70, 75, 82, 85, 73, 79)
#' )
#' result3 <- test_paired(
#'   formula = After ~ Before, data = study_data,
#'   name = "After - Before",
#'   alternative = "greater", method = "theory"
#' )
#' print(result3)
#' plot(result3)
#' \dontrun{
#' plot_steps(result3)
#' }
#'
#' # --- Two Columns Before/After (simulation, sign-flipping) ---
#' result4 <- test_paired(
#'   formula = After ~ Before, data = study_data,
#'   name = "After - Before",
#'   alternative = "greater", method = "simulation", sim_reps = 2000
#' )
#' print(result4)
#' plot(result4)
#' \dontrun{
#' plot_steps(result4)
#' }
#'
#' @export
test_paired <- function(x_bar_d = NULL, sd_d = NULL, n_d = NULL,
                        formula = NULL, data = NULL,
                        name = "Differences",
                        alternative = "two.sided",
                        method = "theory",
                        sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar_d) || !is.null(sd_d) || !is.null(n_d)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (x_bar_d/sd_d/n_d)}.",
      "i" = "These are two different ways to use {.fn test_paired} -- please choose one:",
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

  # Summary stats + simulation -- not possible
  if (summary_stat_provided && method == "simulation") {
    cli::cli_abort(c(
      "x" = "Simulation is not available when using summary statistics.",
      "i" = "The sign-flipping simulation requires the individual difference values for each pair.",
      "i" = "Since you only provided summary statistics, there are no individual values to flip.",
      "i" = "Please either:",
      "*" = "Use {.code method = \"theory\"} with your summary statistics, or",
      "*" = "Provide raw data via {.arg formula} and {.arg data} to use simulation."
    ))
  }

  # Store raw differences for simulation
  raw_diffs <- NULL

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame.",
        "i" = "For a single differences column: {.code test_paired(formula = ~ Differences, data = your_data)}",
        "i" = "For two columns:                 {.code test_paired(formula = After ~ Before, data = your_data)}"
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

    # Extract summary stats from raw differences
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

  # Validity condition warning for theory method
  if (method == "theory" && n_d < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based T-test may not be met.",
      "i" = "There are only {n_d} pairs, which is fewer than 20.",
      "i" = "Proceed only if the distribution of differences is roughly symmetric.",
      "i" = "Otherwise consider using {.code method = \"simulation\"} if raw data is available."
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  sim_data <- NULL

  if (method == "theory") {
    se       <- sd_d / sqrt(n_d)
    stat_val <- x_bar_d / se
    df       <- n_d - 1

    if (alternative == "greater")    p_val <- 1 - pt(stat_val, df = df)
    else if (alternative == "less")  p_val <- pt(stat_val, df = df)
    else                             p_val <- 2 * pt(-abs(stat_val), df = df)

  } else if (method == "simulation") {
    # Sign-flipping permutation test
    # For each repetition, randomly flip signs of individual differences
    sim_data <- replicate(sim_reps, {
      signs <- sample(c(-1, 1), size = n_d, replace = TRUE)
      mean(raw_diffs * signs)
    })

    se       <- sd(sim_data)
    stat_val <- x_bar_d / se
    df       <- NA

    if (alternative == "greater")    p_val <- sum(sim_data >= x_bar_d) / sim_reps
    else if (alternative == "less")  p_val <- sum(sim_data <= x_bar_d) / sim_reps
    else                             p_val <- sum(abs(sim_data) >= abs(x_bar_d)) / sim_reps
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar_d     = x_bar_d,
    sd_d        = sd_d,
    n_d         = n_d,
    name        = name,
    se          = se,
    stat_val    = stat_val,
    df          = df,
    p_val       = p_val,
    alternative = alternative,
    method      = method,
    sim_data    = sim_data,
    raw_diffs   = raw_diffs
  )

  class(res) <- "stat218_test_paired"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_test_paired
print.stat218_test_paired <- function(x, ...) {
  cli::cli_h1("Paired Data Hypothesis Test ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "Mean Difference (x-bar_d): {round(x$x_bar_d, 4)}",
    "i" = "SD of Differences (s_d):   {round(x$sd_d, 4)}",
    "i" = "Number of Pairs (n_d):     {x$n_d}",
    "i" = "Null Hypothesis: mu_d = 0",
    "i" = "Alternative: mu_d {ifelse(x$alternative == 'two.sided', '!=', ifelse(x$alternative == 'greater', '>', '<'))} 0",
    "*" = "SD of Null Distribution: {round(x$se, 4)}",
    "*" = "Test Statistic ({ifelse(x$method == 'simulation', 'Z_sim', 'T')}): {round(x$stat_val, 3)}",
    "*" = "P-Value: {round(x$p_val, 4)}"
  ))

  if (x$method == "theory" && x$n_d < 20) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- fewer than 20 pairs (n_d = {x$n_d}).",
      "i" = "Verify that the distribution of differences is roughly symmetric.",
      "i" = "Consider using {.code method = \"simulation\"} if raw data is available."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_test_paired
plot.stat218_test_paired <- function(x, ...) {

  obs_val       <- x$x_bar_d
  sd_null_label <- paste0("SD of Null Distribution = ", round(x$se, 4))

  if (x$alternative == "greater")    v_lines <- obs_val
  else if (x$alternative == "less")  v_lines <- obs_val
  else                               v_lines <- c(-abs(obs_val), abs(obs_val))

  # Validity caption
  validity_caption <- ""
  if (x$method == "theory" && x$n_d < 20) {
    validity_caption <- paste0(
      "Warning: fewer than 20 pairs (n_d = ", x$n_d, "). ",
      "Validity conditions may not be met. Consider method = \"simulation\"."
    )
  }

  # ---- Simulation branch ----
  if (x$method == "simulation") {

    plot_data <- data.frame(sim = x$sim_data)

    bin_width <- diff(range(x$sim_data)) / 40

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$sim >= (obs_val - bin_width / 2)
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$sim <= (obs_val + bin_width / 2)
    else
      plot_data$tail <- abs(plot_data$sim) >= (abs(obs_val) - bin_width / 2)

    p_dist <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail)) +
      ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0)

    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = -abs(obs_val) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(obs_val) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = obs_val, y = Inf, vjust = 2,
                          label = paste0("p-value = ", round(x$p_val, 4)),
                          color = "#D55E00", fontface = "bold", size = 4)
    }

    p_dist <- p_dist +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1) +
      ggplot2::scale_fill_manual(
        values = c("FALSE" = "gray80", "TRUE" = "#D55E00")) +
      ggplot2::annotate("text",
                        x = Inf, y = Inf, hjust = 1.05, vjust = 4,
                        label = sd_null_label,
                        color = "#2C3E50", fontface = "italic", size = 3.8) +
      ggplot2::labs(
        title    = "Sign-Flipping Null Distribution",
        subtitle = paste0("Based on ", length(x$sim_data),
                          " sign-flips | Centered at Null Difference = 0"),
        x = paste("Simulated Mean of", x$name),
        y = "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

    # ---- Theory branch ----
  } else {

    x_vals <- seq(-4 * x$se, 4 * x$se, length.out = 1000)
    y_vals <- dt(x_vals / x$se, df = x$df) / x$se

    plot_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$val >= obs_val
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$val <= obs_val
    else
      plot_data$tail <- abs(plot_data$val) >= abs(obs_val)

    p_dist <- ggplot2::ggplot(plot_data, ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data = subset(plot_data, tail == TRUE),
        ggplot2::aes(group = val > 0),
        fill = "#D55E00", alpha = 0.7
      ) +
      ggplot2::geom_vline(xintercept = v_lines, color = "black",
                          linetype = "dashed", linewidth = 1)

    y_mid <- max(y_vals) * 0.25
    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = -abs(obs_val) * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(obs_val) * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      x_pos  <- if (x$alternative == "greater") obs_val * 1.5 else obs_val * 1.5
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = x_pos, y = y_mid,
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
        subtitle = "Centered at Null Difference = 0",
        x = paste("Mean of", x$name),
        y = "Density"
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
# PLOT_STEPS METHOD -- 3-panel patchwork with latex2exp
# ============================================================

#' @export
#' @method plot_steps stat218_test_paired
plot_steps.stat218_test_paired <- function(x, alpha = 0.05, ...) {

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

  if (abs(x$stat_val) >= 2) {
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
  if (x$method == "theory" && x$n_d < 20) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "There are fewer than 20 pairs. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "simulation") {
    stat_label   <- "Z[sim]"
    method_blurb <- paste0(
      "We use a <b>Sign-Flipping simulation</b>. For each repetition, a coin is flipped ",
      "for every pair -- heads flips the sign of that pair's difference (swapping which ",
      "measurement came first), tails leaves it as is. This simulates the null hypothesis ",
      "that the two measurements are completely interchangeable.<br>",
      "&bull; SD of Null Distribution = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($Z_{sim} = \frac{\bar{x}_d - 0}{SD_{null}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$Z_{sim} = \\frac{", round(x$x_bar_d, 4), " - 0}{",
             round(x$se, 4), "} = ", round(x$stat_val, 3), "$"),
      output = "character"
    )
  } else {
    stat_label   <- "T"
    method_blurb <- paste0(
      "We treat the differences as a single sample and apply a <b>one-sample T-test</b>. ",
      "The SD of the Null Distribution is computed from the standard deviation of the ",
      "differences divided by &radic;n<sub>d</sub>:<br>",
      "&bull; SD of Null Distribution = s<sub>d</sub> / &radic;n<sub>d</sub> = ",
      round(x$sd_d, 4), " / &radic;", x$n_d, " = ", round(x$se, 4),
      "<br>The degrees of freedom are handled automatically in the background.<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($T = \frac{\bar{x}_d - 0}{\frac{s_d}{\sqrt{n_d}}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$T = \\frac{", round(x$x_bar_d, 4), " - 0}{\\frac{",
             round(x$sd_d, 4), "}{\\sqrt{", x$n_d, "}}} = ",
             round(x$stat_val, 3), "$"),
      output = "character"
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>Mean Difference (x&#772;<sub>d</sub>):</b> ", round(x$x_bar_d, 4), "<br>",
    "&bull; <b>SD of Differences (s<sub>d</sub>):</b> ", round(x$sd_d, 4), "<br>",
    "&bull; <b>Number of Pairs (n<sub>d</sub>):</b> ", x$n_d, "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &mu;<sub>d</sub> = 0<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>A</sub>: &mu;<sub>d</sub> ",
    alt_symbol, " 0<br><br>",

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
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.8, 1)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 20, r = 20, b = 0, l = 20))

  # ---- PANEL 2: latex2exp equations ----
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
    "<i>Interpretation of Statistic:</i> The observed mean difference is ",
    abs(round(x$stat_val, 2)), " standard errors <b>", z_dir,
    "</b> the null hypothesized value of 0.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",

    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",

    "<i>Interpretation of P-value:</i> Assuming the true mean difference is exactly zero, ",
    "there is a ", pval_pct, "% probability of observing a mean difference ",
    dir_text, " ", round(x$x_bar_d, 4), " just by random chance.<br>",
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

  # ---- Stitch all three panels ----
  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.6, 1.8, 3.5))
  )
}
