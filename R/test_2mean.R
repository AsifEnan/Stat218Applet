#' 2-Sample Means Hypothesis Test
#'
#' @description
#' Tests whether two population means are equal (\eqn{\mu_1 = \mu_2}) using
#' either a theory-based Z-test or T-test, or a simulation-based permutation
#' approach (when raw data is provided).
#'
#' This function accepts input in **two ways**:
#'
#' - **Summary Statistics:** You already know the sample mean, standard
#'   deviation, and sample size for both groups (common in textbook homework
#'   problems). Pass `x_bar_1`, `sd_1`, `n_1`, `x_bar_2`, `sd_2`, and `n_2`
#'   directly. Note that `method = "simulation"` is not available with summary
#'   statistics -- simulation requires access to the individual data values.
#'
#' - **Raw Data:** You have an actual dataset loaded into R (common in
#'   activities and projects). Pass `formula` and `data` instead, and the
#'   function computes all summary statistics for you. Both
#'   `method = "theory"` and `method = "simulation"` are available with
#'   raw data.
#'
#' @param x_bar_1 The observed sample mean of Group 1. For example, if the
#'   average rolling time for black-capped beetles was 4.2 seconds,
#'   `x_bar_1 = 4.2`.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_1 The standard deviation of Group 1. Whether this is a sample
#'   SD or population SD is determined by `sd_type`.
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
#'   to the two groups. For example, `group_names = c("Black Cap", "Clear Cap")`.
#'   Defaults to `c("Group 1", "Group 2")`. When using raw data, group names
#'   are extracted automatically from the grouping variable.
#'   **Only used when NOT providing `formula` and `data`.**
#' @param sd_type A character string telling the function whether the standard
#'   deviations provided are from the **population** or the **sample**.
#'   Must be one of:
#'   \describe{
#'     \item{`"sample"`}{(default) The standard deviations were calculated
#'       from the sample data. A **T-test** is used with degrees of freedom
#'       computed automatically using the Satterthwaite approximation.}
#'     \item{`"population"`}{The true population standard deviations
#'       (\eqn{\sigma}) are known. A **Z-test** is used. This is rare in
#'       practice but occasionally given in textbook problems.}
#'   }
#' @param formula A two-sided formula of the form `Response ~ Group` that
#'   identifies the numeric response variable and the grouping variable in
#'   your dataset. For example, `formula = RollingTime ~ CapType` where
#'   `RollingTime` is the quantitative outcome and `CapType` defines the
#'   two groups.
#'   **Only used when NOT providing summary statistics.**
#' @param data A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
#'   that contains the variables named in `formula`.
#'   **Only used when NOT providing summary statistics.**
#' @param alternative The direction of the alternative hypothesis
#'   (H\eqn{_a}). Must be one of:
#'   \describe{
#'     \item{`"two.sided"`}{H\eqn{_a}: \eqn{\mu_1 - \mu_2 \neq 0} (default)
#'       -- use when testing if the two means are simply *different*.}
#'     \item{`"greater"`}{H\eqn{_a}: \eqn{\mu_1 - \mu_2 > 0} --
#'       use when testing if Group 1's mean is *greater than* Group 2's.}
#'     \item{`"less"`}{H\eqn{_a}: \eqn{\mu_1 - \mu_2 < 0} --
#'       use when testing if Group 1's mean is *less than* Group 2's.}
#'   }
#' @param method The method used to calculate the p-value. Must be one of:
#'   \describe{
#'     \item{`"theory"`}{(default) Uses the Z-test (if `sd_type = "population"`)
#'       or T-test (if `sd_type = "sample"`) with an unpooled standard error.
#'       Appropriate when both groups have at least 20 observations, or when
#'       the distributions are known to be roughly symmetric.}
#'     \item{`"simulation"`}{Uses a Permutation Test. All numerical values
#'       from both groups are pooled together and repeatedly reshuffled into
#'       two groups of the original sizes. Think of it as writing each
#'       observation on an index card, shuffling all cards, and re-dealing
#'       them into two piles. This method requires raw data and is not
#'       available when using summary statistics.}
#'   }
#' @param sim_reps The number of permutation shuffles when
#'   `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
#'   a more stable p-value estimate.
#'
#' @return An S3 object of class `stat218_2mean` containing all computed
#'   values. You can use the following methods on the result:
#'   \describe{
#'     \item{`print(result)`}{Displays a clean summary including both group
#'       means, the observed difference, SD of null distribution, test
#'       statistic, and p-value.}
#'     \item{`plot(result)`}{Default shows the null distribution with shaded
#'       p-value region(s) and SD of Null Distribution annotated. Use
#'       `plot(result, plot_type = "boxplot")` for side-by-side boxplots of
#'       the two groups (only available when raw data was provided).}
#'     \item{`plot_steps(result)`}{Displays a detailed three-panel
#'       step-by-step interpretation with proper fraction notation.}
#'   }
#'
#' @details
#' ## The Core Idea
#' In a two-sample mean test, we ask: *"Is the difference in average values
#' we observed between two groups consistent with random chance, or is there
#' real evidence that the two population means are different?"*
#'
#' The null hypothesis always takes the form
#' H\eqn{_0}: \eqn{\mu_1 - \mu_2 = 0}, meaning we assume no difference
#' between the two population means.
#'
#' ## Simulation Method (Permutation Test)
#' We simulate the null hypothesis by treating all observed values as
#' interchangeable between groups -- just like the beetle study in the
#' textbook. All values are pooled, shuffled, and re-dealt into two groups
#' of the original sizes. The difference in group means is recorded for each
#' shuffle. The SD of that simulated null distribution goes in the denominator
#' of the test statistic. The p-value is the proportion of shuffles that
#' produced a difference as extreme as or more extreme than observed.
#'
#' ## Theory Method (Unpooled T-test or Z-test)
#' Unlike the two-proportion test, the two-mean test uses an **unpooled**
#' standard error because there is no natural pooling assumption for means.
#' When `sd_type = "sample"`, degrees of freedom are computed automatically
#' using the Satterthwaite approximation and handled in the background.
#'
#' ## Validity Conditions
#' The theory-based test is most reliable when:
#' - Both groups have at least 20 observations (n\eqn{_1 \geq 20} and
#'   n\eqn{_2 \geq 20}), **or**
#' - The distributions within both groups are known to be roughly symmetric,
#'   even for smaller samples.
#'
#' A warning is issued automatically if either group has fewer than 20
#' observations and `method = "theory"`.
#'
#' @examples
#' # --- Summary Statistics Path (two-sided, theory T-test) ---
#' # Comparing average exam scores between two teaching methods.
#' result <- test_2mean(
#'   x_bar_1 = 78.3, sd_1 = 9.1, n_1 = 35,
#'   x_bar_2 = 73.5, sd_2 = 8.4, n_2 = 32,
#'   group_names = c("New Method", "Traditional"),
#'   alternative = "two.sided", method = "theory"
#' )
#' print(result)
#' plot(result)
#' \dontrun{
#' plot_steps(result)
#'}
#'
#' # --- Summary Statistics Path (one-sided, theory Z-test) ---
#' result2 <- test_2mean(
#'   x_bar_1 = 82.1, sd_1 = 10.0, n_1 = 40,
#'   x_bar_2 = 78.5, sd_2 = 9.5,  n_2 = 40,
#'   group_names = c("Treatment", "Control"),
#'   sd_type = "population",
#'   alternative = "greater", method = "theory"
#' )
#' print(result2)
#' plot(result2)
#' \dontrun{
#' plot_steps(result2)
#' }
#'
#' # --- Raw Data Path (two-sided, simulation) ---
#' # Using mtcars: does average MPG differ between automatic and manual?
#' car_data <- mtcars
#' car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
#' result3 <- test_2mean(
#'   formula = mpg ~ transmission, data = car_data,
#'   alternative = "two.sided", method = "simulation"
#' )
#' print(result3)
#' plot(result3)
#' plot(result3, plot_type = "boxplot")
#' \dontrun{
#' plot_steps(result3)
#' }
#'
#' # --- Raw Data Path (two-sided, theory T-test) ---
#' result4 <- test_2mean(
#'   formula = mpg ~ transmission, data = car_data,
#'   alternative = "two.sided", method = "theory"
#' )
#' print(result4)
#' plot(result4)
#' plot(result4, plot_type = "boxplot")
#' \dontrun{
#' plot_steps(result4)
#' }
#'
#' @export
test_2mean <- function(x_bar_1 = NULL, sd_1 = NULL, n_1 = NULL,
                       x_bar_2 = NULL, sd_2 = NULL, n_2 = NULL,
                       group_names = NULL,
                       sd_type = "sample",
                       formula = NULL, data = NULL,
                       alternative = "two.sided",
                       method = "theory",
                       sim_reps = 1000) {

  # ============================================================
  # ROUTING STATION -- Phase Two dual-input logic
  # ============================================================

  summary_stat_provided <- !is.null(x_bar_1) || !is.null(sd_1) || !is.null(n_1) ||
    !is.null(x_bar_2) || !is.null(sd_2) || !is.null(n_2)
  formula_provided      <- !is.null(formula) || !is.null(data)

  # Case 1: Both paths provided
  if (summary_stat_provided && formula_provided) {
    cli::cli_abort(c(
      "x" = "You provided both a dataset {.emph (formula/data)} and summary statistics.",
      "i" = "These are two different ways to use {.fn test_2mean} -- please choose one:",
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

  # Summary stats + simulation -- not possible
  if (summary_stat_provided && method == "simulation") {
    cli::cli_abort(c(
      "x" = "Simulation is not available when using summary statistics.",
      "i" = "The simulation method works by shuffling individual data values between groups.",
      "i" = "Since you only provided summary statistics, there are no individual values to shuffle.",
      "i" = "Please either:",
      "*" = "Use {.code method = \"theory\"} with your summary statistics, or",
      "*" = "Provide raw data via {.arg formula} and {.arg data} to use simulation."
    ))
  }

  # Raw data store -- will hold individual vectors for boxplot and simulation
  raw_data_1 <- NULL
  raw_data_2 <- NULL

  # Case 2: Raw data path
  if (formula_provided) {

    if (is.null(data)) {
      cli::cli_abort(c(
        "x" = "You provided {.arg formula} but forgot to provide {.arg data}.",
        "i" = "Please also pass in your data frame. For example:",
        " " = "{.code test_2mean(formula = Response ~ Group, data = your_data)}"
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
        "x" = "The response variable {.val {response_var}} must be numeric for a means test.",
        "i" = "It appears to contain non-numeric values. Check your data."
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

    raw_data_1 <- na.omit(response_col[as.character(group_col) == group_names[1]])
    raw_data_2 <- na.omit(response_col[as.character(group_col) == group_names[2]])

    x_bar_1 <- mean(raw_data_1)
    sd_1    <- sd(raw_data_1)
    n_1     <- length(raw_data_1)

    x_bar_2 <- mean(raw_data_2)
    sd_2    <- sd(raw_data_2)
    n_2     <- length(raw_data_2)

    # Raw data always uses sample SD
    sd_type <- "sample"

    cli::cli_inform(c(
      "v" = "Data extracted from {.val {response_var}} ~ {.val {group_var}}:",
      "*" = "{group_names[1]}: x-bar = {round(x_bar_1, 4)}, s = {round(sd_1, 4)}, n = {n_1}",
      "*" = "{group_names[2]}: x-bar = {round(x_bar_2, 4)}, s = {round(sd_2, 4)}, n = {n_2}"
    ))
  }

  # Set default group names if not provided
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
  if (method == "theory" && (n_1 < 20 || n_2 < 20)) {
    cli::cli_warn(c(
      "!" = "Validity conditions for the theory-based test may not be met.",
      "i" = "At least one group has fewer than 20 observations:",
      "*" = "{group_names[1]}: n = {n_1}",
      "*" = "{group_names[2]}: n = {n_2}",
      "i" = "Proceed only if the distributions within both groups are roughly symmetric.",
      "i" = "Otherwise consider using {.code method = \"simulation\"}."
    ))
  }

  # ============================================================
  # MATH ENGINE
  # ============================================================

  obs_diff <- x_bar_1 - x_bar_2
  se       <- sqrt((sd_1^2 / n_1) + (sd_2^2 / n_2))
  sim_data <- NULL

  if (method == "theory") {
    stat_val <- obs_diff / se

    if (sd_type == "population") {
      stat_name <- "Z"
      dist_type <- "Normal"
      df        <- NA

      if (alternative == "greater")    p_val <- 1 - pnorm(stat_val)
      else if (alternative == "less")  p_val <- pnorm(stat_val)
      else                             p_val <- 2 * pnorm(-abs(stat_val))

    } else {
      stat_name <- "T"
      dist_type <- "T-Distribution"

      # Satterthwaite approximation -- handled in background
      num <- (sd_1^2 / n_1 + sd_2^2 / n_2)^2
      den <- ((sd_1^2 / n_1)^2 / (n_1 - 1)) + ((sd_2^2 / n_2)^2 / (n_2 - 1))
      df  <- num / den

      if (alternative == "greater")    p_val <- 1 - pt(stat_val, df = df)
      else if (alternative == "less")  p_val <- pt(stat_val, df = df)
      else                             p_val <- 2 * pt(-abs(stat_val), df = df)
    }

  } else if (method == "simulation") {
    # Permutation Test -- shuffle all values between the two groups
    all_values <- c(raw_data_1, raw_data_2)

    sim_data <- replicate(sim_reps, {
      shuffled <- sample(all_values)
      mean(shuffled[1:n_1]) - mean(shuffled[(n_1 + 1):(n_1 + n_2)])
    })

    se        <- sd(sim_data)
    stat_val  <- obs_diff / se
    stat_name <- "Z_sim"
    dist_type <- "Simulation"
    df        <- NA

    if (alternative == "greater")    p_val <- sum(sim_data >= obs_diff) / sim_reps
    else if (alternative == "less")  p_val <- sum(sim_data <= obs_diff) / sim_reps
    else                             p_val <- sum(abs(sim_data) >= abs(obs_diff)) / sim_reps
  }

  # ============================================================
  # BUNDLE INTO S3 OBJECT
  # ============================================================

  res <- list(
    x_bar_1     = x_bar_1, sd_1 = sd_1, n_1 = n_1,
    x_bar_2     = x_bar_2, sd_2 = sd_2, n_2 = n_2,
    group_names = group_names,
    sd_type     = sd_type,
    obs_diff    = obs_diff,
    se          = se,
    stat_val    = stat_val,
    stat_name   = stat_name,
    df          = df,
    p_val       = p_val,
    alternative = alternative,
    method      = method,
    dist_type   = dist_type,
    sim_data    = sim_data,
    raw_data_1  = raw_data_1,
    raw_data_2  = raw_data_2
  )

  class(res) <- "stat218_2mean"
  return(res)
}

# ============================================================
# PRINT METHOD
# ============================================================

#' @export
#' @method print stat218_2mean
print.stat218_2mean <- function(x, ...) {
  sd_symbol <- ifelse(x$sd_type == "population", "sigma", "s")

  cli::cli_h1("2-Sample Means Hypothesis Test ({tools::toTitleCase(x$method)})")
  cli::cli_bullets(c(
    "i" = "{x$group_names[1]}: x-bar = {round(x$x_bar_1, 4)}  |  {sd_symbol} = {round(x$sd_1, 4)}  |  n = {x$n_1}",
    "i" = "{x$group_names[2]}: x-bar = {round(x$x_bar_2, 4)}  |  {sd_symbol} = {round(x$sd_2, 4)}  |  n = {x$n_2}",
    "i" = "Null Hypothesis: mu1 - mu2 = 0",
    "i" = "Alternative: mu1 - mu2 {ifelse(x$alternative == 'two.sided', '!=', ifelse(x$alternative == 'greater', '>', '<'))} 0",
    "*" = "Observed Difference (x-bar1 - x-bar2): {round(x$obs_diff, 4)}",
    "*" = "SD of Null Distribution: {round(x$se, 4)}",
    "*" = "Test Statistic ({x$stat_name}): {round(x$stat_val, 3)}",
    "*" = "P-Value: {round(x$p_val, 4)}"
  ))

  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    cli::cli_warn(c(
      "!" = "Validity conditions may not be met -- at least one group has fewer than 20 observations.",
      "i" = "Verify that distributions within both groups are roughly symmetric.",
      "i" = "Consider using {.code method = \"simulation\"} if raw data is available."
    ))
  }

  invisible(x)
}

# ============================================================
# PLOT METHOD
# ============================================================

#' @export
#' @method plot stat218_2mean
plot.stat218_2mean <- function(x, plot_type = "distribution", ...) {

  # ---- Boxplot branch (raw data only) ----
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

    p_box <- ggplot2::ggplot(box_data,
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
        x = "Group",
        y = "Value"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

    return(p_box)
  }

  # ---- Default: null distribution plot ----
  obs_diff      <- x$obs_diff
  sd_null_label <- paste0("SD of Null Distribution = ", round(x$se, 4))
  x_label       <- paste0("Difference in Sample Means (",
                          x$group_names[1], " - ", x$group_names[2], ")")

  if (x$alternative == "greater")    v_lines <- obs_diff
  else if (x$alternative == "less")  v_lines <- obs_diff
  else                               v_lines <- c(-abs(obs_diff), abs(obs_diff))

  # Validity caption for theory method
  validity_caption <- ""
  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    validity_caption <- paste0(
      "Warning: at least one group has fewer than 20 observations. ",
      "Validity conditions may not be met. Consider method = \"simulation\"."
    )
  }

  # ---- Simulation branch ----
  if (x$method == "simulation") {

    plot_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$sim >= obs_diff
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$sim <= obs_diff
    else
      plot_data$tail <- abs(plot_data$sim) >= abs(obs_diff)

    p_dist <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail)) +
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
        title    = "Permutation Distribution of Differences in Means",
        subtitle = paste0("Based on ", length(x$sim_data),
                          " shuffles | Centered at Null Difference = 0"),
        x = x_label, y = "Count"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")

    # ---- Theory branch ----
  } else {
    val <- dens <- sim <-  NA

    x_vals <- seq(-4 * x$se, 4 * x$se, length.out = 1000)

    if (x$sd_type == "population") {
      y_vals     <- dnorm(x_vals, mean = 0, sd = x$se)
      dist_title <- "Theoretical Normal Distribution (Z-Curve)"
    } else {
      y_vals     <- dt(x_vals / x$se, df = x$df) / x$se
      dist_title <- paste0("Theoretical T-Distribution (df = ",
                           round(x$df, 2), ")")
    }

    plot_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater")
      plot_data$tail <- plot_data$val >= obs_diff
    else if (x$alternative == "less")
      plot_data$tail <- plot_data$val <= obs_diff
    else
      plot_data$tail <- abs(plot_data$val) >= abs(obs_diff)

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
        title    = dist_title,
        subtitle = "Centered at Null Difference = 0",
        x = x_label, y = "Density"
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
#' @method plot_steps stat218_2mean
plot_steps.stat218_2mean <- function(x, alpha = 0.05, ...) {

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
  if (x$method == "theory" && (x$n_1 < 20 || x$n_2 < 20)) {
    warning_text <- paste0(
      "<span style='color:#C0392B; font-size:12pt;'><b>&#9888; Validity Condition Warning:</b> ",
      "At least one group has fewer than 20 observations. ",
      "Consider rerunning with simulation method for more reliable results.</span><br><br>"
    )
  }

  # ---- Build method-specific blurb and equations ----
  if (x$method == "simulation") {
    method_blurb <- paste0(
      "We use a <b>Permutation Test</b> -- all values from both groups are pooled, ",
      "shuffled, and re-dealt into two groups of the original sizes. This simulates ",
      "the null hypothesis that group membership does not affect the outcome.<br>",
      "&bull; SD of Null Distribution = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($Z_{sim} = \frac{(\bar{x}_1 - \bar{x}_2) - 0}{SD_{null}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$Z_{sim} = \\frac{", round(x$obs_diff, 4), " - 0}{",
             round(x$se, 4), "} = ", round(x$stat_val, 3), "$"),
      output = "character"
    )

  } else if (x$sd_type == "population") {
    method_blurb <- paste0(
      "Because the population standard deviations (&sigma;) are <b>known</b>, ",
      "we compute the exact SD of the Null Distribution and use a <b>Z-statistic</b>:<br>",
      "&bull; SD of Null Distribution = &radic;(&sigma;<sub>1</sub><sup>2</sup>/n<sub>1</sub> + &sigma;<sub>2</sub><sup>2</sup>/n<sub>2</sub>)",
      " = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($Z = \frac{(\bar{x}_1 - \bar{x}_2) - 0}{\sqrt{\frac{\sigma_1^2}{n_1} + \frac{\sigma_2^2}{n_2}}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$Z = \\frac{", round(x$obs_diff, 4), " - 0}{\\sqrt{\\frac{",
             round(x$sd_1, 4), "^2}{", x$n_1, "} + \\frac{",
             round(x$sd_2, 4), "^2}{", x$n_2, "}}} = ",
             round(x$stat_val, 3), "$"),
      output = "character"
    )

  } else {
    method_blurb <- paste0(
      "Because the population standard deviations are <b>unknown</b>, we use ",
      "sample standard deviations to estimate the SD of the Null Distribution ",
      "and apply a <b>T-statistic</b>. The degrees of freedom are handled ",
      "automatically in the background.<br>",
      "&bull; SD of Null Distribution = &radic;(s<sub>1</sub><sup>2</sup>/n<sub>1</sub> + s<sub>2</sub><sup>2</sup>/n<sub>2</sub>)",
      " = ", round(x$se, 4), "<br><br>",
      "<i>The formula and calculation are shown below:</i>"
    )
    tex_formula <- latex2exp::TeX(
      r"($T = \frac{(\bar{x}_1 - \bar{x}_2) - 0}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}$)",
      output = "character"
    )
    tex_calc <- latex2exp::TeX(
      paste0("$T = \\frac{", round(x$obs_diff, 4), " - 0}{\\sqrt{\\frac{",
             round(x$sd_1, 4), "^2}{", x$n_1, "} + \\frac{",
             round(x$sd_2, 4), "^2}{", x$n_2, "}}} = ",
             round(x$stat_val, 3), "$"),
      output = "character"
    )
  }

  # ---- PANEL 1: Top HTML ----
  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",

    "<span style='font-size:14pt;'><b>1. The Data & Hypotheses</b></span><br>",
    "&bull; <b>", x$group_names[1], ":</b> x&#772;<sub>1</sub> = ", round(x$x_bar_1, 4),
    " &nbsp;|&nbsp; ", sd_symbol, "<sub>1</sub> = ", round(x$sd_1, 4),
    " &nbsp;|&nbsp; n<sub>1</sub> = ", x$n_1, "<br>",
    "&bull; <b>", x$group_names[2], ":</b> x&#772;<sub>2</sub> = ", round(x$x_bar_2, 4),
    " &nbsp;|&nbsp; ", sd_symbol, "<sub>2</sub> = ", round(x$sd_2, 4),
    " &nbsp;|&nbsp; n<sub>2</sub> = ", x$n_2, "<br>",
    "&bull; <b>Observed Difference (x&#772;<sub>1</sub> &minus; x&#772;<sub>2</sub>):</b> ",
    round(x$obs_diff, 4), "<br>",
    "&bull; <b>Null Hypothesis:</b> H<sub>0</sub>: &mu;<sub>1</sub> &minus; &mu;<sub>2</sub> = 0<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>A</sub>: &mu;<sub>1</sub> &minus; &mu;<sub>2</sub> ",
    alt_symbol, " 0<br><br>",

    "<span style='font-size:14pt;'><b>2. Standardized Test Statistic (", x$stat_name, ")</b></span><br>",
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
    "<i>Interpretation of Statistic:</i> The observed difference in sample means is ",
    abs(round(x$stat_val, 2)), " standard errors <b>", z_dir,
    "</b> the null hypothesized value of 0.<br>",
    "<i>Conclusion:</i> ", z_conc, "<br><br>",

    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",

    "<i>Interpretation of P-value:</i> Assuming there is truly no difference between ",
    "the two population means, there is a ", pval_pct,
    "% probability of observing a difference in sample means ",
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

  # ---- Stitch all three panels ----
  return(
    p_top / p_math / p_bottom +
      patchwork::plot_layout(heights = c(2.6, 1.8, 3.5))
  )
}
