#' Correlation Hypothesis Test
#'
#' @param x Numeric vector for the explanatory variable
#' @param y Numeric vector for the response variable
#' @param alternative "two.sided", "greater", or "less"
#' @param method "theory" or "simulation"
#' @param sim_reps Number of iterations for Simulation (default 1000)
#'
#' @return An S3 object of class stat218_test_correlation
#' @export
test_correlation <- function(x, y, alternative = "two.sided", method = "theory", sim_reps = 1000) {

  # 1. Clean the data (safely handle missing values)
  valid_data <- complete.cases(x, y)
  x_clean <- x[valid_data]
  y_clean <- y[valid_data]

  n <- length(x_clean)
  if (n < 3) stop("Error: You need at least 3 valid data pairs to test correlation.")

  r_obs <- cor(x_clean, y_clean)
  df <- n - 2
  t_stat <- r_obs * sqrt((n - 2) / (1 - r_obs^2))

  # 2. Theory vs Simulation Routing
  if (method == "theory") {
    if (alternative == "greater") p_val <- 1 - pt(t_stat, df = df)
    else if (alternative == "less") p_val <- pt(t_stat, df = df)
    else p_val <- 2 * pt(-abs(t_stat), df = df)

    res <- list(
      n = n, r_obs = r_obs, t_stat = t_stat, df = df, p_val = p_val,
      alternative = alternative, method = method
    )

  } else if (method == "simulation") {
    # Randomization Test: Shuffle 'y' to break the relationship
    sim_data <- replicate(sim_reps, {
      cor(x_clean, sample(y_clean, size = n, replace = FALSE))
    })

    if (alternative == "greater") p_val <- mean(sim_data >= r_obs)
    else if (alternative == "less") p_val <- mean(sim_data <= r_obs)
    else p_val <- mean(abs(sim_data) >= abs(r_obs))

    res <- list(
      n = n, r_obs = r_obs, t_stat = t_stat, df = df, p_val = p_val,
      alternative = alternative, method = method, sim_data = sim_data
    )

  } else {
    stop("Error: Method must be 'theory' or 'simulation'.")
  }

  class(res) <- "stat218_test_correlation"
  return(res)
}

#' @export
#' @method print stat218_test_correlation
print.stat218_test_correlation <- function(x, ...) {
  cli::cli_h1("Correlation Hypothesis Test ({stringr::str_to_title(x$method)})")
  cli::cli_bullets(c(
    "i" = "Null Hypothesis: rho = 0",
    "i" = "Alternative: rho {ifelse(x$alternative == 'two.sided', '!=', ifelse(x$alternative == 'greater', '>', '<'))} 0",
    "*" = "Valid Pairs (n): {x$n}",
    "*" = "Observed Correlation (r): {round(x$r_obs, 4)}",
    "*" = "P-value: {round(x$p_val, 4)}"
  ))
  invisible(x)
}

#' @export
#' @method plot stat218_test_correlation
plot.stat218_test_correlation <- function(x, ...) {

  # Dynamic Axis Setup
  if (x$method == "simulation") {
    target_val <- x$r_obs
    x_label <- "Correlation Coefficient (r)"
    x_min <- -1
    x_max <- 1
  } else {
    target_val <- x$t_stat
    x_label <- "Standardized Statistic (t)"
    limit <- max(abs(target_val) * 1.2, 4)
    x_min <- -limit
    x_max <- limit
  }

  p_bottom <- ggplot2::ggplot() +
    # The line segment is now completely dynamic!
    ggplot2::geom_segment(ggplot2::aes(x = x_min, xend = x_max, y = 0, yend = 0), linewidth = 1.5, color = "#2C3E50") +
    ggplot2::geom_point(ggplot2::aes(x = target_val, y = 0), size = 6, color = "#3498DB") +
    ggplot2::geom_text(ggplot2::aes(x = target_val, y = -0.4, label = paste("Observed =", round(target_val, 3))), size = 5, fontface = "bold", color = "#2C3E50") +
    ggplot2::scale_y_continuous(limits = c(-1, 1)) +
    ggplot2::labs(x = x_label, y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank(), panel.grid.minor.y = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank())

  if (x$method == "theory") {
    p_bottom <- p_bottom + ggplot2::coord_cartesian(xlim = c(x_min, x_max))
  }

  if (x$method == "simulation") {
    plot_data <- data.frame(sim = x$sim_data)

    if (x$alternative == "greater") plot_data$tail <- plot_data$sim >= x$r_obs
    else if (x$alternative == "less") plot_data$tail <- plot_data$sim <= x$r_obs
    else plot_data$tail <- abs(plot_data$sim) >= abs(x$r_obs)

    p_top <- ggplot2::ggplot(plot_data, ggplot2::aes(x = sim, fill = tail)) +
      ggplot2::geom_histogram(color = "white", bins = 40) +
      ggplot2::geom_vline(xintercept = x$r_obs, color = "black", linetype = "dashed", linewidth = 1) +
      ggplot2::scale_fill_manual(values = c("FALSE" = "gray80", "TRUE" = "#D55E00")) +
      ggplot2::labs(title = "Simulated Null Distribution (Shuffled y)", subtitle = "Centered at rho = 0", x = "", y = "Count") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none") +
      ggplot2::coord_cartesian(xlim = c(-1, 1))

  } else {
    if (x$alternative == "greater") v_lines <- x$t_stat
    else if (x$alternative == "less") v_lines <- x$t_stat
    else v_lines <- c(-abs(x$t_stat), abs(x$t_stat))

    x_vals <- seq(x_min, x_max, length.out = 1000)
    y_vals <- dt(x_vals, df = x$df)
    plot_data <- data.frame(val = x_vals, dens = y_vals)

    if (x$alternative == "greater") plot_data$tail <- plot_data$val >= x$t_stat
    else if (x$alternative == "less") plot_data$tail <- plot_data$val <= x$t_stat
    else plot_data$tail <- abs(plot_data$val) >= abs(x$t_stat)

    p_top <- ggplot2::ggplot(plot_data, ggplot2::aes(x = val, y = dens)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_area(data = subset(plot_data, tail == TRUE), ggplot2::aes(group = val > 0), fill = "#D55E00", alpha = 0.7) +
      ggplot2::geom_vline(xintercept = v_lines, color = "black", linetype = "dashed", linewidth = 1) +
      ggplot2::labs(title = paste0("Theoretical T-Distribution (df = ", x$df, ")"), subtitle = "Centered at rho = 0", x = "", y = "Density") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank())
  }

  return(p_top / p_bottom + patchwork::plot_layout(heights = c(3, 1)))
}

#' @export
#' @method plot_steps stat218_test_correlation
plot_steps.stat218_test_correlation <- function(x, alpha = 0.05, ...) {

  alt_sign <- ifelse(x$alternative == "two.sided", "&ne;", ifelse(x$alternative == "greater", "&gt;", "&lt;"))
  pval_pct <- round(x$p_val * 100, 2)

  p_conc <- ifelse(x$p_val <= alpha,
                   paste0("<i>Conclusion:</i> Since the p-value is &le; &alpha; (", alpha, "), we have strong evidence against the null. We <b>Reject the Null Hypothesis (H<sub>0</sub>)</b>."),
                   paste0("<i>Conclusion:</i> Since the p-value is > &alpha; (", alpha, "), we lack strong evidence against the null. We <b>Fail to Reject the Null Hypothesis (H<sub>0</sub>)</b>."))

  top_html <- paste0(
    "<span style='font-size:20pt; color:#2C3E50;'><b>Detailed Analysis & Interpretation</b></span><br><br>",
    "<span style='font-size:14pt;'><b>1. The Sample Data</b></span><br>",
    "&bull; <b>Valid Pairs (n):</b> ", x$n, "<br>",
    "&bull; <b>Observed Correlation (r):</b> ", round(x$r_obs, 4), "<br>",
    "&bull; <b>Alternative Hypothesis:</b> H<sub>A</sub>: &rho; ", alt_sign, " 0<br><br>"
  )

  if (x$method == "theory") {
    top_html <- paste0(top_html, "<span style='font-size:14pt;'><b>2. Standardized Test Statistic</b></span><br>",
                       "We calculate a <b>t-statistic</b> using degrees of freedom df = n - 2 (", x$df, ").")

    tex_formula <- latex2exp::TeX(r"($t = r \cdot \sqrt{\frac{n - 2}{1 - r^2}}$)", output = "character")
    tex_calc <- latex2exp::TeX(paste0("$t = ", round(x$r_obs, 3), " \\cdot \\sqrt{\\frac{", x$n, " - 2}{1 - (", round(x$r_obs, 3), ")^2}} = ", round(x$t_stat, 3), "$"), output = "character")

    p_math_data <- data.frame(x = c(0.1, 0.1), y = c(3.5, 0), label = c(tex_formula, tex_calc))
    p_math <- ggplot2::ggplot(p_math_data, ggplot2::aes(x = x, y = y, label = label)) +
      ggplot2::geom_text(parse = TRUE, size = 6, hjust = 0) +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-2.0, 5.0), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(plot.margin = ggplot2::margin(t=10, r=20, b=10, l=40))

    dir_text <- ifelse(x$alternative == "greater", "greater than or equal to", ifelse(x$alternative == "less", "less than or equal to", "as extreme as or more extreme than"))
    interp_text <- paste0("<i>Interpretation of P-value:</i> Assuming the population correlation is exactly 0, there is a ", pval_pct, "% probability of observing a standardized statistic ", dir_text, " ", round(x$t_stat, 2), " just by random chance.<br>")

  } else {
    top_html <- paste0(top_html, "<span style='font-size:14pt;'><b>2. Randomization Test (Simulation)</b></span><br>",
                       "We simulate the null hypothesis (no relationship) by randomly shuffling the response variable 1,000 times, calculating a simulated <i>r</i> for each shuffle.")

    p_math <- ggplot2::ggplot() + ggplot2::theme_void()

    dir_text <- ifelse(x$alternative == "greater", "greater than or equal to", ifelse(x$alternative == "less", "less than or equal to", "as extreme as or more extreme than"))
    interp_text <- paste0("<i>Interpretation of P-value:</i> Assuming there is truly no relationship (&rho; = 0), there is a ", pval_pct, "% probability of observing a sample correlation ", dir_text, " ", round(x$r_obs, 4), " just by random shuffling.<br>")
  }

  p_top <- ggplot2::ggplot() +
    ggtext::geom_textbox(ggplot2::aes(x = 0, y = 1, label = top_html), width = ggplot2::unit(0.95, "npc"), hjust = 0, vjust = 1, box.color = NA, fill = NA, size = 5, lineheight = 1.5) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.5, 1)) + ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t=20, r=20, b=0, l=20))

  bottom_html <- paste0(
    "<span style='font-size:14pt;'><b>3. The P-Value</b></span><br>",
    "&bull; <b>p-value = ", round(x$p_val, 4), "</b> (", pval_pct, "%)<br><br>",
    interp_text,
    p_conc
  )

  p_bottom <- ggplot2::ggplot() +
    ggtext::geom_textbox(ggplot2::aes(x = 0, y = 1, label = bottom_html), width = ggplot2::unit(0.95, "npc"), hjust = 0, vjust = 1, box.color = NA, fill = NA, size = 5, lineheight = 1.5) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(-0.5, 1)) + ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(t=0, r=20, b=20, l=20))

  if (x$method == "theory") {
    return(p_top / p_math / p_bottom + patchwork::plot_layout(heights = c(2.2, 1.8, 3.8)))
  } else {
    return(p_top / p_bottom + patchwork::plot_layout(heights = c(2.5, 3)))
  }
}

