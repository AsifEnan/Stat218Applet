#' 2-Sample Proportions Hypothesis Test
#'
#' @description
#' Tests whether two population proportions are equal
#' (\eqn{\pi_1 = \pi_2}) using either a simulation-based approach
#' (Randomization Test) or a theory-based Z-test using a pooled proportion.
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the number of successes and
#'   sample sizes for both groups (common in textbook homework problems).
#'   Pass `success_1`, `n_1`, `success_2`, and `n_2` directly.
#'
#' - **Raw Data:** You have an actual dataset loaded into R (common in
#'   activities and projects). Pass `formula`, `data`, and `success_level`
#'   instead, and the function will extract the group counts for you.
#'
#' @param success_1 A whole number representing the count of successes in
#'   Group 1. For example, if 45 out of 100 patients in the treatment group
#'   recovered, `success_1 = 45`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_1 A whole number representing the total sample size of Group 1.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param success_2 A whole number representing the count of successes in
#'   Group 2. For example, if 25 out of 100 patients in the placebo group
#'   recovered, `success_2 = 25`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param n_2 A whole number representing the total sample size of Group 2.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param group_names A character vector of length 2 giving meaningful names
#'   to the two groups. For example, `group_names = c("Treatment", "Placebo")`.
#'   Defaults to `c("Group 1", "Group 2")`. When using raw data, group names
#'   are extracted automatically from the grouping variable.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param formula A two-sided formula of the form `Response ~ Group` that
#'   identifies the response (categorical outcome) variable and the grouping
#'   variable in your dataset. For example, `formula = Recovered ~ Treatment`
#'   where `Recovered` is the outcome and `Treatment` defines the two groups.
#'   **Only used when NOT providing summary statistics.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   that contains the variables named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param success_level A character string specifying which value of the
#'   response variable counts as a "success". For example, if the response
#'   variable contains `"Yes"` and `"No"`, use `success_level = "Yes"`.
#'   This argument is **required** when using `formula` and `data`.
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\pi_1 - \pi_2 \neq 0} (default)
#'       — use when testing if the two proportions are simply *different*.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\pi_1 - \pi_2 > 0} —
#'       use when testing if Group 1's proportion is *greater than* Group 2's.}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\pi_1 - \pi_2 < 0} —
#'       use when testing if Group 1's proportion is *less than* Group 2's.}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"theory"`}{(default) Uses the traditional two-proportion Z-test
#'       with a pooled proportion. Appropriate when all four cells in the 2x2
#'       contingency table have at least 10 observations.}
#'     \item{`"simulation"`}{Uses a Randomization Test (Shuffling the Deck).
#'       All successes and failures are pooled together and repeatedly
#'       re-dealt into the two group sizes, simulating the null hypothesis
#'       of no difference. More flexible than theory when cell counts are
#'       small.}
#'   }
#' @param sim_reps The number of randomization shuffles when
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
#'   a more stable p-value estimate.
#'
#' @return An S3 object of class `stat218_2prop` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary including both sample
#'       proportions, the observed difference, SD of null distribution, test
#'       statistic, and p-value.}
#'     \item{`plot(result)`}{Shows a beautified 2x2 contingency table
#'       alongside the null distribution plot with shaded p-value region(s)
#'       and SD of Null Distribution annotated.}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a two-sample proportion test, we ask: *"Is the difference in proportions
#' we observed between two groups consistent with random chance, or is there
#' real evidence that the two population proportions are different?"*
#'
#' The null hypothesis always takes the form
#' H\eqn{_0}: \eqn{\pi_1 - \pi_2 = 0}, meaning we assume no difference
#' between the two population proportions.
#'
#' ## Simulation Method (Randomization Test)
#' We simulate the null hypothesis by pooling all successes and failures
#' together and repeatedly shuffling them back into the two group sizes.
#' Each shuffle gives a new simulated difference in proportions. The SD of
#' that simulated null distribution goes in the denominator of the test
#' statistic. The p-value is the proportion of shuffles that produced a
#' difference as extreme as or more extreme than what we observed.
#'
#' ## Theory Method (Pooled Z-Test)
#' Because the null hypothesis assumes \eqn{\pi_1 = \pi_2}, we estimate the
#' common proportion using a **pooled proportion**:
#' \deqn{\hat{p} = \frac{\text{success}_1 + \text{success}_2}{n_1 + n_2}}
#' This pooled proportion is then used to compute the SD of the null
#' distribution:
#' \deqn{SD_{null} = \sqrt{\hat{p}(1-\hat{p})\left(\frac{1}{n_1} +
#' \frac{1}{n_2}\right)}}
#'
#' ## Validity Conditions for Theory Method
#' The theory-based Z-test is reliable when **all four cells** in the 2x2
#' contingency table have at least 10 observations:
#' - Successes in Group 1 \eqn{\geq 10}
#' - Failures in Group 1 \eqn{\geq 10}
#' - Successes in Group 2 \eqn{\geq 10}
#' - Failures in Group 2 \eqn{\geq 10}
#'
#' A warning is issued automatically if any cell falls below 10.
#'
#' @examples
#' # --- Summary Statistics Path (two-sided, theory) ---
#' # A clinical trial: 45 of 100 in treatment recovered vs 25 of 100 placebo.
#' result <- test_2prop(
#'   success_1 = 45, n_1 = 100,
#'   success_2 = 25, n_2 = 100,
#'   group_names = c("Treatment", "Placebo"),
#'   alternative = "two.sided", method = "theory"
#' )
#' print(result)
#' plot(result)
#' plot_steps(result)
#'
#' # --- Summary Statistics Path (one-sided, simulation) ---
#' # Testing if Group A has a higher success rate than Group B.
#' result2 <- test_2prop(
#'   success_1 = 38, n_1 = 80,
#'   success_2 = 29, n_2 = 80,
#'   group_names = c("Group A", "Group B"),
#'   alternative = "greater", method = "simulation"
#' )
#' print(result2)
#' plot(result2)
#' plot_steps(result2)
#'
#' # --- Raw Data Path (two-sided, theory) ---
#' # Using mtcars: does the proportion of manual cars differ by engine type?
#' car_data <- mtcars
#' car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
#' car_data$engine <- ifelse(mtcars$vs == 1, "Straight", "V-shaped")
#' result3 <- test_2prop(
#'   formula = transmission ~ engine, data = car_data,
#'   success_level = "Manual", alternative = "two.sided",
#'   method = "theory"
#' )
#' print(result3)
#' plot(result3)
#' plot_steps(result3)
#'
#' # --- Raw Data Path (one-sided, simulation) ---
#' result4 <- test_2prop(
#'   formula = transmission ~ engine, data = car_data,
#'   success_level = "Manual", alternative = "greater",
#'   method = "simulation"
#' )
#' print(result4)
#' plot(result4)
#' plot_steps(result4)
#'
#' @export
test_2prop <- function(success_1 = NULL, n_1 = NULL,
                       success_2 = NULL, n_2 = NULL,
                       group_names = NULL,
                       formula = NULL, data = NULL,
                       success_level = NULL,
                       alternative = "two.sided",
                       method = "theory",
                       sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION — Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(success_1) || !is.null(n_1) ||
    !is.null(success_2) || !is.null(n_2)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics {.emph (success_1/n_1/success_2/n_2)}.",
      "i" = "These are two different ways to use {.fn test_2prop} — please choose one:",
      " " = " ",
      "*" = "If you have {.strong raw data}: use {.arg formula}, {.arg data}, and {.arg success_level}, and remove the summary stat arguments.",
      "*" = "If you only have {.strong summary statistics}: use {.arg success_1}, {.arg n_1}, {.arg success_2}, and {.arg n_2}, and remove {.arg formula} and {.arg data}."
    ))
  }

  # Case 4: Neither path provided
  if (!summary_stat_provided && !formula_provided) {
    cli::cli_abort(c(
      "x" = "No input was provided.",
      "i" = "You must supply either:",
      "*" = "{.strong Summary statistics}: provide {.arg success_1}, {.arg n_1}, {.arg success_2}, and {.arg n_2}.",
      "*" = "{.strong Raw data}: provide {.arg formula}, {.arg data}, and {.arg success_level}."
    ))
  }

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code test_2prop(formula = Response ~ Group, data = your_data, success_level = \"Yes\")}"
      ))
    }

    if (is.null(formula)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg data} but forgot to provide {.arg formula}.",
        "i" = "The formula should look like: {.code Response ~ Group}",
        "i" = "Where {.code Response} is your outcome variable and {.code Group} defines the two groups."
      ))
    }

    if (is.null(success_level)) {
      cli::cli_abort(c(
        "x" = "You must specify {.arg success_level} when using raw data.",
        "i" = "This tells the function which value of your response variable counts as a success.",
        "i" = "For example, if your response variable has values {.val Yes} and {.val No}, use:",
        " " = "{.code success_level = \"Yes\"}"
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

    # Validate success_level exists in response variable
    if (!success_level %in% response_col) {
      cli::cli_abort(c(
        "x" = "The success level {.val {success_level}} was not found in the variable {.val {response_var}}.",
        "i" = "The values present in {.val {response_var}} are: {.val {unique(response_col)}}."
      ))
    }

    # Validate exactly 2 groups
    group_levels <- unique(na.omit(as.character(group_col)))
    if (length(group_levels) != 2) {
      cli::cli_abort(c(
        "x" = "The grouping variable {.val {group_var}} has {length(group_levels)} unique value(s): {.val {group_levels}}.",
        "i" = "This function requires exactly 2 groups.",
        "i" = "Please filter your data down to just the two groups you want to compare before running the test."
      ))
    }

    group_names <- group_levels

    # Extract counts for each group
    grp1_rows  <- data[as.character(group_col) == group_names[1], ]
    grp2_rows  <- data[as.character(group_col) == group_names[2], ]

    success_1  <- sum(grp1_rows[[response_var]] == success_level, na.rm = TRUE)
    n_1        <- nrow(grp1_rows)
    success_2  <- sum(grp2_rows[[response_var]] == success_level, na.rm = TRUE)
    n_2        <- nrow(grp2_rows)

    cli::cli_inform(c(
      "v" = "Data extracted from {.val {response_var}} ~ {.val {group_var}}:",
      "*" = "{group_names[1]}: {success_1} successes out of {n_1}",
      "*" = "{group_names[2]}: {success_2} successes out of {n_2}",
      "i" = "Success level: {.val {success_level}}"
    ))
  }

  # Set default group names if not provided via summary stats path
  if (is.null(group_names)) group_names <- c("Group 1", "Group 2")

  # ============================================================
  # INPUT VALIDATION
  # ============================================================

  for (val in list(list(success_1, "success_1"), list(success_2, "success_2"))) {
    if (!is.numeric(val[[1]]) || val[[1]] != round(val[[1]]) || val[[1]] < 0) {
      cli::cli_abort(c(
        "x" = "{.arg {val[[2]]}} must be a non-negative whole number.",
        "i" = "You provided: {.val {val[[1]]}}"
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

  if (success_1 > n_1) {
    cli::cli_abort(c(
      "x" = "Successes in Group 1 ({success_1}) cannot exceed the sample size n_1 ({n_1}).",
      "i" = "Please double-check your values."
    ))
  }

  if (success_2 > n_2) {
    cli::cli_abort(c(
      "x" = "Successes in Group 2 ({success_2}) cannot exceed the sample size n_2 ({n_2}).",
      "i" = "Please double-check your values."
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
  # MATH ENGINE — unchanged from Phase One
  # ============================================================

  p1_hat   <- success_1 / n_1
  p2_hat   <- success_2 / n_2
  obs_diff <- p1_hat - p2_hat
  p_pooled <- (success_1 + success_2) / (n_1 + n_2)

  fail_1   <- n_1 - success_1
  fail_2   <- n_2 - success_2
  min_cell <- min(success_1, fail_1, success_2, fail_2)

  # Validity warning for theory method
  if (method == "theory" && min_cell < 10) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based Z-test may not be met.",
      "i" = "All four cells in the 2x2 table must have at least 10 observations.",
      "i" = "Minimum cell count found: {min_cell}",
      "i" = "Consider using {.code method = \"simulation\"} for a more reliable p-value."
    ))
  }

  if (method == "theory") {
    se        <- sqrt(p_pooled * (1 - p_pooled) * ((1 / n_1) + (1 / n_2)))
    stat_val  <- obs_diff / se
    stat_name <- "Z"
    sim_data  <- NULL

    if (alternative == "greater")    p_val <- 1 - pnorm(stat_val)
    else if (alternative == "less")  p_val <- pnorm(stat_val)
    else                             p_val <- 2 * pnorm(-abs(stat_val))

  } else if (method == "simulation") {
    total_success <- success_1 + success_2
    total_fail    <- fail_1 + fail_2
    deck          <- c(rep(1, total_success), rep(0, total_fail))

    sim_data <- replicate(sim_reps, {
      shuffled <- sample(deck)
      mean(shuffled[1:n_1]) - mean(shuffled[(n_1 + 1):(n_1 + n_2)])
    })

    se        <- sd(sim_data)
    stat_val  <- obs_diff / se
    stat_name <- "Z_sim"

    if (alternative == "greater")    p_val <- sum(sim_data >= obs_diff) / sim_reps
    else if (alternative == "less")  p_val <- sum(sim_data <= obs_diff) / sim_reps
    else                             p_val <- sum(abs(sim_data) >= abs(obs_diff)) / sim_reps
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    success_1   = success_1, n_1 = n_1, p1_hat = p1_hat,
    success_2   = success_2, n_2 = n_2, p2_hat = p2_hat,
    group_names = group_names,
    obs_diff    = obs_diff,
    p_pooled    = p_pooled,
    min_cell    = min_cell,
    alternative = alternative,
    method      = method,
    stat_val    = stat_val,
    stat_name   = stat_name,
    se          = se,
    p_val       = p_val,
    sim_data    = sim_data
  )

  class(res) <- "stat218_2prop"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_2prop
print.stat218_2prop <- function(x, ...) {
  cli::cli_h1("2-Sample Proportions Hypothesis Test ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "{x$group_names[1]}: p1-hat = {round(x$p1_hat, 4)}  (successes = {x$success_1}, n = {x$n_1})",
    "i" = "{x$group_names[2]}: p2-hat = {round(x$p2_hat, 4)}  (successes = {x$success_2}, n = {x$n_2})",
    "i" = "Null Hypothesis: pi1 - pi2 = 0",
    "i" = "Alternative: pi1 - pi2 {ifelse(x$alternative == 'two.sided', '!=', ifelse(x$alternative == 'greater', '>', '<'))} 0",
    "*" = "Observed Difference (p1-hat - p2-hat): {round(x$obs_diff, 4)}",
    "*" = "SD of Null Distribution: {round(x$se, 4)}",
    "*" = "Test Statistic ({x$stat_name}): {round(x$stat_val, 3)}",
    "*" = "P-Value: {round(x$p_val, 4)}"
  ))

  if (x$method == "theory" && x$min_cell < 10) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based Z-test may not be met.",
      "i" = "All four cells in the 2x2 table must have at least 10 observations.",
      "i" = "Minimum cell count found: {x$min_cell}.",
      "i" = "Consider using {.code method = \"simulation\"} for a more reliable result."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_2prop
plot.stat218_2prop <- function(x, ...) {

  obs_diff      <- x$obs_diff
  sd_null_label <- paste0("SD of Null Distribution = ", round(x$se, 4))

  if (x$alternative == "greater")    v_lines <- obs_diff
  else if (x$alternative == "less")  v_lines <- obs_diff
  else                               v_lines <- c(-abs(obs_diff), abs(obs_diff))

  x_label <- paste0("Difference in Proportions (",
                    x$group_names[1], " - ", x$group_names[2], ")")

  # Validity warning subtitle for theory method
  validity_subtitle <- ""
  if (x$method == "theory" && x$min_cell < 10) {
    validity_subtitle <- paste0(
      "Warning: min cell count = ", x$min_cell,
      " (< 10) — validity conditions may not be met. Consider method = \"simulation\"."
    )
  }

  # ---- 1. Beautified gt contingency table ----
  fail_1 <- x$n_1 - x$success_1
  fail_2 <- x$n_2 - x$success_2

  ct_data <- data.frame(
    Group   = c(x$group_names[1], x$group_names[2], "Total"),
    Success = c(x$success_1, x$success_2, x$success_1 + x$success_2),
    Failure = c(fail_1, fail_2, fail_1 + fail_2),
    Total   = c(x$n_1, x$n_2, x$n_1 + x$n_2)
  )

  gt_table <- gt::gt(ct_data) |>
    gt::tab_header(title = "Observed 2x2 Contingency Table") |>
    gt::cols_label(
      Group   = "",
      Success = "Success",
      Failure = "Failure",
      Total   = "Total"
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
      locations = gt::cells_body(columns = Group)
    ) |>
    gt::tab_style(
      style     = gt::cell_fill(color = "#F4F6F7"),
      locations = gt::cells_body(rows = 3)
    ) |>
    gt::tab_style(
      style     = gt::cell_text(weight = "bold"),
      locations = gt::cells_body(rows = 3)
    ) |>
    gt::tab_style(
      style     = gt::cell_borders(sides = "top", color = "#2C3E50",
                                   weight = gt::px(2)),
      locations = gt::cells_body(rows = 3)
    ) |>
    gt::cols_align(align = "center",
                   columns = c(Success, Failure, Total)) |>
    gt::tab_options(
      table.font.size          = gt::px(13),
      table.width              = gt::pct(90),
      heading.title.font.size  = gt::px(13),
      heading.align            = "center"
    )

  # ---- 2. Distribution plot ----
  if (x$method == "simulation") {

    plot_dist_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater")
      plot_dist_data$tail <- plot_dist_data$sim >= obs_diff
    else if (x$alternative == "less")
      plot_dist_data$tail <- plot_dist_data$sim <= obs_diff
    else
      plot_dist_data$tail <- abs(plot_dist_data$sim) >= abs(obs_diff)

    # boundary = 0 ensures bins align cleanly so the observed line
    # never splits a bar half-orange / half-grey
    p_dist <- ggplot2::ggplot(plot_dist_data,
                              ggplot2::aes(x = sim, fill = tail)) +
      ggplot2::geom_histogram(color = "white", bins = 40, boundary = 0)

    if (x$alternative == "two.sided") {
      half_pval <- round(x$p_val / 2, 4)
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = -abs(obs_diff) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(obs_diff) * 1.5, y = Inf, vjust = 2,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      p_dist <- p_dist +
        ggplot2::annotate("text",
                          x = obs_diff, y = Inf, vjust = 2,
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
        title    = "Randomization Distribution (Simulated)",
        subtitle = paste0("Based on ", length(x$sim_data),
                          " shuffles | Centered at Null Difference = 0"),
        x = x_label, y = "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

  } else {

    x_vals         <- seq(-4 * x$se, 4 * x$se, length.out = 1000)
    y_vals         <- dnorm(x_vals, mean = 0, sd = x$se)
    plot_dist_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater")
      plot_dist_data$tail <- plot_dist_data$val >= obs_diff
    else if (x$alternative == "less")
      plot_dist_data$tail <- plot_dist_data$val <= obs_diff
    else
      plot_dist_data$tail <- abs(plot_dist_data$val) >= abs(obs_diff)

    p_dist <- ggplot2::ggplot(plot_dist_data,
                              ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(
        data = subset(plot_dist_data, tail == TRUE),
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
                          x = -abs(obs_diff) * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4) +
        ggplot2::annotate("text",
                          x =  abs(obs_diff) * 1.8, y = y_mid,
                          label = paste0("p/2 = ", half_pval),
                          color = "#D55E00", fontface = "bold", size = 4)
    } else {
      x_pos  <- if (x$alternative == "greater") obs_diff * 1.5 else obs_diff * 1.5
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
        title    = "Theoretical Normal Distribution (Z-Curve)",
        subtitle = "Centered at Null Difference = 0",
        x = x_label, y = "Density"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.y  = ggplot2::element_blank(),
                     axis.ticks.y = ggplot2::element_blank())
  }

  # Add validity warning as a caption if needed
  if (validity_subtitle != "") {
    p_dist <- p_dist +
      ggplot2::labs(caption = validity_subtitle) +
      ggplot2::theme(
        plot.caption = ggplot2::element_text(
          color = "#C0392B", face = "bold", size = 9, hjust = 0
        )
      )
  }

  # ---- 3. Combine ----
  gt_grob <- gt::as_gtable(gt_table)
  p_table <- ggplot2::ggplot() +
    ggplot2::annotation_custom(gt_grob) +
    ggplot2::theme_void()

  return(p_dist / p_table + patchwork::plot_layout(heights = c(2.5, 1)))
}

# ============================================================
# PLOT_STEPS METHOD — 3-panel patchwork
# ============================================================

#' @export
#' @method plot_steps stat218_2prop
plot_steps.stat218_2prop <- function(x, alpha = 0.05, ...) {

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

  # Validity warning — placed at TOP of bottom panel so it never gets cut off
  warning_text <- ""
  if (x$method == "theory" && x$min_cell < 10) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "At least one cell in the 2x2 table has fewer than 10 observations. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  if (x$method == "simulation") {
    method_blurb <- paste0(
      "We estimate the SD of the Null Distribution using a <b>Randomization Test</b>. ",
      "All successes and failures are pooled together and repeatedly re-dealt into ",
      "the two group sizes, simulating the null hypothesis of no difference.<br>",
      "&bull; SD of Null Distribution = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($Z_{sim} = \frac{(\hat{p}_1 - \hat{p}_2) - 0}{SD_{null}}$)",
      output = "character"
    )
    # Plain number — no \mathbf{}
    tex_calc <- latex2exp::TeX(
      paste0("$Z_{sim} = \\frac{", round(x$obs_diff, 4), " - 0}{",
             round(x$se, 4), "} = ", round(x$stat_val, 3), "$"),
      output = "character"
    )
  } else {
    method_blurb <- paste0(
      "Because H<sub>0</sub> assumes &pi;<sub>1</sub> = &pi;<sub>2</sub>, we use a ",
      "<b>Pooled Proportion</b> to estimate the common SD of the Null Distribution:<br>",
      "&bull; Pooled Proportion (p&#770;) = (", x$success_1, " + ", x$success_2,
      ") / (", x$n_1, " + ", x$n_2, ") = <b>", round(x$p_pooled, 4), "</b><br>",
      "&bull; SD of Null Distribution = &radic;(p&#770;(1 &minus; p&#770;)(1/n<sub>1</sub> + 1/n<sub>2</sub>))",
      " = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($Z = \frac{\hat{p}_1 - \hat{p}_2 - 0}{\sqrt{\hat{p}(1 - \hat{p})(\frac{1}{n_1} + \frac{1}{n_2})}}$)",
      output = "character"
    )
    # Plain number — no \mathbf{}
    tex_calc <- latex2exp::TeX(
      paste0("$Z = \\frac{", round(x$p1_hat, 4), " - ", round(x$p2_hat, 4),
             "}{\\sqrt{", round(x$p_pooled, 4), "(1 - ", round(x$p_pooled, 4),
             ")(\\frac{1}{", x$n_1, "} + \\frac{1}{", x$n_2,
             "})}} = ", round(x$stat_val, 3), "$"),
      output = "character"
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",
    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>", x$group_names[1], ":</b> p&#770;<sub>1</sub> = ",
    round(x$p1_hat, 4), " (", x$success_1, " successes out of n = ", x$n_1, ")<br>",
    "&bull; <b>", x$group_names[2], ":</b> p&#770;<sub>2</sub> = ",
    round(x$p2_hat, 4), " (", x$success_2, " successes out of n = ", x$n_2, ")<br>",
    "&bull; <b>Observed Difference (p&#770;<sub>1</sub> &minus; p&#770;<sub>2</sub>):</b> ",
    round(x$obs_diff, 4), "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &pi;<sub>1</sub> &minus; &pi;<sub>2</sub> = 0<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>A</sub>: &pi;<sub>1</sub> &minus; &pi;<sub>2</sub> ",
    alt_symbol, " 0<br><br>",
    "<span style='font-size:14pt;'><b>2. Standardized Test Statistic</b></span><br>",
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

  # ---- PANEL 2: latex2exp equations ----
  p_math_data <- data.frame(
    x     = c(0.1, 0.1),
    y     = c(4.0, 0),
    label = c(tex_formula, tex_calc)
  )

  p_math <- ggplot2::ggplot(p_math_data,
                            ggplot2::aes(x = x, y = y, label = label)) +
    ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-2.0, 6.0), clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20, b = 10, l = 40))

  # ---- PANEL 3: Bottom HTML — warning at top so it never clips ----
  bottom_html <- paste0(
    warning_text,
    "<i>Interpretation of Statistic:</i> The observed difference in proportions is ",
    abs(round(x$stat_val, 2)), " standard errors <b>", z_dir,
    "</b> the null hypothesized value of 0.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",
    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",
    "<i>Interpretation of P-value:</i> Assuming there is truly no difference between ",
    "the two population proportions, there is a ", pval_pct,
    "% probability of observing a difference in sample proportions ",
    dir_text, " ", round(x$obs_diff, 4), " just by random chance.<br>",
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

  # ---- Stitch — taller bottom panel to prevent clipping ----
  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.0, 1.8, 3.5))
  )
}
