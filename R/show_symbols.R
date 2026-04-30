#' Show Statistical Symbol Reference Plots
#'
#' @description
#' Renders one or more educational reference plots that display the statistical
#' symbols used throughout STAT 218, organized by topic. Symbols are presented
#' in a two-column layout contrasting **Population (Greek/Parameter)** symbols
#' on the left with **Sample (Latin/Statistic)** symbols on the right.
#'
#' When called with no arguments, all five plots are rendered sequentially into
#' the RStudio plot viewer — use the **left/right arrow buttons** in the Plot
#' tab to scroll between them.
#'
#' @param topic A character string specifying which symbol plot to display.
#'   Must be one of:
#'   \describe{
#'     \item{`"all"`}{Renders all five plots in sequence (default).}
#'     \item{`"proportions"`}{Symbols related to proportions (pi, p-hat, etc.).}
#'     \item{`"means"`}{Symbols related to means and quantitative variables.}
#'     \item{`"tests"`}{Test statistics, decision-making symbols (Z, T, alpha, p-value).}
#'     \item{`"regression"`}{Symbols for correlation and simple linear regression.}
#'     \item{`"mistakes"`}{Common symbol mistakes students make in STAT 218.}
#'   }
#'
#' @return Invisibly returns `NULL`. The function is called for its side effect
#'   of rendering plots to the active graphics device.
#'
#' @details
#' ## The Core Idea: Greek vs. Latin
#' In statistics, **Greek letters** (mu, sigma, pi, rho, beta) refer to
#' **population parameters** — true values that are usually unknown. **Latin
#' (English) letters** (x-bar, s, p-hat, r, b) refer to **sample statistics**
#' — values we actually calculate from our data.
#'
#' ## The Five Themes
#' 1. **Proportions** — categorical data, success/failure outcomes
#' 2. **Means** — quantitative data, averages and spread
#' 3. **Test Statistics** — standardized statistics and decision rules
#' 4. **Regression** — linear relationships between two quantitative variables
#' 5. **Common Mistakes** — frequent symbol confusions to avoid
#'
#' @examples
#' # Show all symbol plots (scroll with arrows in RStudio Plot tab)
#' show_symbols()
#'
#' # Show only the proportions reference
#' show_symbols("proportions")
#'
#' # Show only the means reference
#' show_symbols("means")
#'
#' # Show the common mistakes plot
#' show_symbols("mistakes")
#'
#' @seealso
#' The main inference functions this package provides:
#' [test_1prop()], [ci_1prop()], [test_2prop()], [ci_2prop()],
#' [test_1mean()], [ci_1mean()], [test_2mean()], [ci_2mean()],
#' [test_paired()], [ci_paired()],
#' [test_correlation()], [test_regression()]
#'
#' @export
show_symbols <- function(topic = "all") {

  valid_topics <- c("all", "proportions", "means", "tests", "regression", "mistakes")
  if (!topic %in% valid_topics) {
    stop(paste0(
      'Invalid topic: "', topic, '". ',
      'Choose from: "all", "proportions", "means", "tests", "regression", "mistakes".'
    ))
  }

  # ── Shared style constants ────────────────────────────────────────────────
  COL_POP   <- "#2C3E50"   # dark blue-gray  -> population
  COL_SAM   <- "#1A6B5A"   # dark teal       -> sample
  COL_ALT   <- "#F5F5F5"   # alternating row bg
  COL_HEAD  <- "#ECF0F1"   # header row bg
  SYM_SIZE  <- 9
  DESC_SIZE <- 3.8
  NAME_SIZE <- 4.2

  # ── Core table-drawing helper ─────────────────────────────────────────────
  # Each row is a list with:
  #   concept, pop_sym (plotmath), pop_name, pop_desc,
  #   sam_sym (plotmath), sam_name, sam_desc
  draw_symbol_table <- function(title, subtitle, rows, title_color = COL_POP) {

    n_rows  <- length(rows)
    row_h   <- 1.1
    head_h  <- 1.4
    top_h   <- 1.6
    total_h <- top_h + head_h + n_rows * row_h + 0.4

    p <- ggplot2::ggplot() +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, total_h), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.margin = ggplot2::margin(10, 10, 10, 10),
        plot.background = ggplot2::element_rect(fill = "white", color = NA)
      )

    # Title block
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = total_h - top_h, ymax = total_h,
                        fill = title_color, color = NA) +
      ggplot2::annotate("text",
                        x = 0.5, y = total_h - 0.6,
                        label = title, color = "white",
                        size = 7, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.5, y = total_h - 1.2,
                        label = subtitle, color = "#ECF0F1",
                        size = 4, hjust = 0.5, fontface = "italic")

    # Column headers
    hy_top <- total_h - top_h
    hy_bot <- hy_top - head_h

    # Concept header
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 0.18, ymin = hy_bot, ymax = hy_top,
                        fill = COL_HEAD, color = NA) +
      ggplot2::annotate("text",
                        x = 0.09, y = (hy_top + hy_bot) / 2,
                        label = "Concept", color = "#555555",
                        size = 3.8, fontface = "bold.italic", hjust = 0.5)

    # Population header
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0.18, xmax = 0.52, ymin = hy_bot, ymax = hy_top,
                        fill = COL_POP, color = NA, alpha = 0.12) +
      ggplot2::annotate("text",
                        x = 0.35, y = (hy_top + hy_bot) / 2 + 0.22,
                        label = "POPULATION", color = COL_POP,
                        size = 4.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.35, y = (hy_top + hy_bot) / 2 - 0.20,
                        label = "Greek / Parameter  -  usually unknown",
                        color = COL_POP, size = 3.1, hjust = 0.5, fontface = "italic")

    # Sample header
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0.52, xmax = 1.0, ymin = hy_bot, ymax = hy_top,
                        fill = COL_SAM, color = NA, alpha = 0.12) +
      ggplot2::annotate("text",
                        x = 0.76, y = (hy_top + hy_bot) / 2 + 0.22,
                        label = "SAMPLE", color = COL_SAM,
                        size = 4.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.76, y = (hy_top + hy_bot) / 2 - 0.20,
                        label = "Latin / Statistic  -  calculated from data",
                        color = COL_SAM, size = 3.1, hjust = 0.5, fontface = "italic")

    # Header bottom divider
    p <- p +
      ggplot2::annotate("segment",
                        x = 0, xend = 1, y = hy_bot, yend = hy_bot,
                        color = "#AAAAAA", linewidth = 0.6)

    # Vertical dividers at x = 0.18 and x = 0.52
    for (xv in c(0.18, 0.52)) {
      p <- p +
        ggplot2::annotate("segment",
                          x = xv, xend = xv, y = 0.3, yend = hy_top,
                          color = "#AAAAAA", linewidth = 0.6)
    }

    # Data rows
    for (i in seq_along(rows)) {
      row   <- rows[[i]]
      y_top <- hy_bot - (i - 1) * row_h
      y_bot <- y_top - row_h
      y_mid <- (y_top + y_bot) / 2

      bg <- if (i %% 2 == 0) COL_ALT else "white"
      p <- p +
        ggplot2::annotate("rect",
                          xmin = 0, xmax = 1, ymin = y_bot, ymax = y_top,
                          fill = bg, color = NA) +
        ggplot2::annotate("segment",
                          x = 0, xend = 1, y = y_bot, yend = y_bot,
                          color = "#E0E0E0", linewidth = 0.3)

      # Concept label
      p <- p +
        ggplot2::annotate("text",
                          x = 0.09, y = y_mid,
                          label = row$concept, color = "#333333",
                          size = 3.5, fontface = "bold", hjust = 0.5, lineheight = 0.9)

      # Population: symbol on left, name + desc tight to the right
      p <- p +
        ggplot2::annotate("text",
                          x = 0.225, y = y_mid,
                          label = row$pop_sym, parse = TRUE,
                          color = COL_POP, size = SYM_SIZE,
                          hjust = 0.5, fontface = "bold") +
        ggplot2::annotate("text",
                          x = 0.30, y = y_mid + 0.20,
                          label = row$pop_name, color = COL_POP,
                          size = NAME_SIZE, fontface = "bold", hjust = 0) +
        ggplot2::annotate("text",
                          x = 0.30, y = y_mid - 0.20,
                          label = row$pop_desc, color = "#555555",
                          size = DESC_SIZE, hjust = 0, fontface = "italic", lineheight = 0.9)

      # Sample: symbol on left, name + desc tight to the right
      p <- p +
        ggplot2::annotate("text",
                          x = 0.575, y = y_mid,
                          label = row$sam_sym, parse = TRUE,
                          color = COL_SAM, size = SYM_SIZE,
                          hjust = 0.5, fontface = "bold") +
        ggplot2::annotate("text",
                          x = 0.635, y = y_mid + 0.20,
                          label = row$sam_name, color = COL_SAM,
                          size = NAME_SIZE, fontface = "bold", hjust = 0) +
        ggplot2::annotate("text",
                          x = 0.635, y = y_mid - 0.20,
                          label = row$sam_desc, color = "#555555",
                          size = DESC_SIZE, hjust = 0, fontface = "italic", lineheight = 0.9)
    }

    # Outer border
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 0.3, ymax = total_h,
                        fill = NA, color = "#888888", linewidth = 0.7)

    return(p)
  }

  # ══════════════════════════════════════════════════════════════════════════
  # PLOT 1 — PROPORTIONS
  # ══════════════════════════════════════════════════════════════════════════
  plot_proportions <- function() {
    rows <- list(
      list(
        concept  = "Sample\nSize",
        pop_sym  = "italic(N)",    pop_name = "Capital N",
        pop_desc = "Total population size\ne.g. all UNL students",
        sam_sym  = "italic(n)",    sam_name = "Lowercase n",
        sam_desc = "Number of people\nin your sample"
      ),
      list(
        concept  = "Proportion\n(1 group)",
        pop_sym  = "pi",           pop_name = "pi  (pie)",
        pop_desc = "True population proportion\ne.g. % of all adults who vote",
        sam_sym  = "hat(p)",       sam_name = "p-hat",
        sam_desc = "Observed sample proportion\ne.g. 54 out of 100 = 0.54"
      ),
      list(
        concept  = "Proportion\n(Group 1)",
        pop_sym  = "pi[1]",        pop_name = "pi-sub-1",
        pop_desc = "True proportion in\npopulation 1",
        sam_sym  = "hat(p)[1]",    sam_name = "p-hat-sub-1",
        sam_desc = "Observed proportion\nin sample 1"
      ),
      list(
        concept  = "Proportion\n(Group 2)",
        pop_sym  = "pi[2]",        pop_name = "pi-sub-2",
        pop_desc = "True proportion in\npopulation 2",
        sam_sym  = "hat(p)[2]",    sam_name = "p-hat-sub-2",
        sam_desc = "Observed proportion\nin sample 2"
      ),
      list(
        concept  = "Null\nValue",
        pop_sym  = "pi[0]",        pop_name = "pi-sub-0",
        pop_desc = "Hypothesized value of pi\nunder H-naught (you set this)",
        sam_sym  = "symbol('--')", sam_name = "  --",
        sam_desc = "No sample equivalent;\nthis lives in H-naught only"
      )
    )

    draw_symbol_table(
      title       = "Symbols for Proportions",
      subtitle    = "Used when your variable has two outcomes  (yes/no, success/failure, etc.)",
      rows        = rows,
      title_color = COL_POP
    )
  }

  # ══════════════════════════════════════════════════════════════════════════
  # PLOT 2 — MEANS
  # ══════════════════════════════════════════════════════════════════════════
  plot_means <- function() {
    rows <- list(
      list(
        concept  = "Sample\nSize",
        pop_sym  = "italic(N)",    pop_name = "Capital N",
        pop_desc = "Total population size",
        sam_sym  = "italic(n)",    sam_name = "Lowercase n",
        sam_desc = "Number of observations\nin your sample"
      ),
      list(
        concept  = "Mean\n(1 group)",
        pop_sym  = "mu",           pop_name = "mu  (mew)",
        pop_desc = "True population mean\ne.g. avg GPA of all UNL students",
        sam_sym  = "bar(x)",       sam_name = "x-bar",
        sam_desc = "Sample average\ne.g. avg GPA of 50 surveyed students"
      ),
      list(
        concept  = "Mean\n(Group 1)",
        pop_sym  = "mu[1]",        pop_name = "mu-sub-1",
        pop_desc = "True mean of\npopulation 1",
        sam_sym  = "bar(x)[1]",    sam_name = "x-bar-sub-1",
        sam_desc = "Sample mean\nof group 1"
      ),
      list(
        concept  = "Mean\n(Group 2)",
        pop_sym  = "mu[2]",        pop_name = "mu-sub-2",
        pop_desc = "True mean of\npopulation 2",
        sam_sym  = "bar(x)[2]",    sam_name = "x-bar-sub-2",
        sam_desc = "Sample mean\nof group 2"
      ),
      list(
        concept  = "Paired\nDifference",
        pop_sym  = "mu[d]",        pop_name = "mu-sub-d",
        pop_desc = "True mean difference\nbetween paired observations",
        sam_sym  = "bar(x)[d]",    sam_name = "x-bar-sub-d",
        sam_desc = "Average of the observed\ndifferences (d = x1 - x2)"
      ),
      list(
        concept  = "Standard\nDeviation",
        pop_sym  = "sigma",        pop_name = "sigma  (sig-ma)",
        pop_desc = "True population spread\n(almost always unknown)",
        sam_sym  = "italic(s)",    sam_name = "s",
        sam_desc = "Sample standard deviation\n(what you calculate)"
      )
    )

    draw_symbol_table(
      title       = "Symbols for Means  (Quantitative Variables)",
      subtitle    = "Used when your variable is numeric  (height, GPA, temperature, etc.)",
      rows        = rows,
      title_color = "#1A5276"
    )
  }

  # ══════════════════════════════════════════════════════════════════════════
  # PLOT 3 — TEST STATISTICS & DECISIONS
  # ══════════════════════════════════════════════════════════════════════════
  plot_tests <- function() {

    TOTAL_H <- 13.5

    p <- ggplot2::ggplot() +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, TOTAL_H), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.margin = ggplot2::margin(10, 10, 10, 10),
        plot.background = ggplot2::element_rect(fill = "white", color = NA)
      )

    # Title
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 11.8, ymax = TOTAL_H,
                        fill = "#6C3483", color = NA) +
      ggplot2::annotate("text",
                        x = 0.5, y = 12.9,
                        label = "Symbols for Test Statistics & Decision Making",
                        color = "white", size = 6.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.5, y = 12.2,
                        label = "How we standardize results and decide whether to reject the Null Hypothesis",
                        color = "#E8DAEF", size = 3.8, hjust = 0.5, fontface = "italic")

    # ── Section A: Hypotheses ─────────────────────────────────────────────
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 9.0, ymax = 11.75,
                        fill = "#EBF5FB", color = NA) +
      ggplot2::annotate("text",
                        x = 0.03, y = 11.45,
                        label = "The Hypotheses", color = "#1A5276",
                        size = 5, fontface = "bold", hjust = 0) +
      ggplot2::annotate("segment",
                        x = 0.03, xend = 0.97, y = 11.2, yend = 11.2,
                        color = "#AED6F1", linewidth = 0.5)

    # H-naught
    p <- p +
      ggplot2::annotate("text",
                        x = 0.08, y = 10.72,
                        label = "H[0]", parse = TRUE,
                        color = COL_POP, size = 11, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.18, y = 11.02,
                        label = "Null Hypothesis  (H-naught)",
                        color = COL_POP, size = 4.5, fontface = "bold", hjust = 0) +
      ggplot2::annotate("text",
                        x = 0.18, y = 10.68,
                        label = "The 'nothing is happening' claim. Always written about a population parameter",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 10.42,
                        label = "(mu, pi, rho, beta).  Example:  H0: mu = 0  or  H0: pi = 0.5",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic")

    # H-A
    p <- p +
      ggplot2::annotate("text",
                        x = 0.08, y = 9.52,
                        label = "H[A]", parse = TRUE,
                        color = "#C0392B", size = 11, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.18, y = 9.82,
                        label = "Alternative Hypothesis  (H-A)",
                        color = "#C0392B", size = 4.5, fontface = "bold", hjust = 0) +
      ggplot2::annotate("text",
                        x = 0.18, y = 9.48,
                        label = "The research claim. Determines the direction of the test:",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 9.22,
                        label = "less than (<),  greater than (>),  or  different from (two-sided, not equal).",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic")

    # ── Section B: Z vs T ─────────────────────────────────────────────────
    p <- p +
      ggplot2::annotate("segment",
                        x = 0, xend = 1, y = 8.95, yend = 8.95,
                        color = "#AAAAAA", linewidth = 0.6) +
      ggplot2::annotate("text",
                        x = 0.03, y = 8.65,
                        label = "Test Statistics  -  Z vs. T", color = "#6C3483",
                        size = 5, fontface = "bold", hjust = 0)

    # Z box
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0.02, xmax = 0.47, ymin = 6.55, ymax = 8.35,
                        fill = "#EBF5FB", color = "#AED6F1", linewidth = 0.6) +
      ggplot2::annotate("text",
                        x = 0.245, y = 7.92,
                        label = "italic(Z)", parse = TRUE,
                        color = COL_POP, size = 13, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.245, y = 7.42,
                        label = "Z-Statistic", color = COL_POP,
                        size = 4.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.245, y = 7.05,
                        label = "Use when the population standard",
                        color = "#444444", size = 3.5, hjust = 0.5, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.245, y = 6.78,
                        label = "deviation (sigma) is KNOWN.",
                        color = "#444444", size = 3.5, hjust = 0.5, fontface = "italic")

    # T box
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0.53, xmax = 0.98, ymin = 6.55, ymax = 8.35,
                        fill = "#EAFAF1", color = "#A9DFBF", linewidth = 0.6) +
      ggplot2::annotate("text",
                        x = 0.755, y = 7.92,
                        label = "italic(T)", parse = TRUE,
                        color = COL_SAM, size = 13, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.755, y = 7.42,
                        label = "T-Statistic", color = COL_SAM,
                        size = 4.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.755, y = 7.05,
                        label = "Use when sigma is UNKNOWN and you",
                        color = "#444444", size = 3.5, hjust = 0.5, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.755, y = 6.78,
                        label = "use s instead.  This is almost always.",
                        color = "#444444", size = 3.5, hjust = 0.5, fontface = "italic")

    # ── Section C: p-value & alpha ────────────────────────────────────────
    p <- p +
      ggplot2::annotate("segment",
                        x = 0, xend = 1, y = 6.45, yend = 6.45,
                        color = "#AAAAAA", linewidth = 0.6) +
      ggplot2::annotate("text",
                        x = 0.03, y = 6.15,
                        label = "The Decision Rule", color = "#6C3483",
                        size = 5, fontface = "bold", hjust = 0)

    # p-value row
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 4.25, ymax = 5.9,
                        fill = COL_ALT, color = NA) +
      ggplot2::annotate("text",
                        x = 0.08, y = 5.22,
                        label = "italic(p)", parse = TRUE,
                        color = "#C0392B", size = 11, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.08, y = 4.68,
                        label = "-value", color = "#C0392B",
                        size = 4, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.18, y = 5.60,
                        label = "p-value  -  Probability value  (Latin p)",
                        color = "#C0392B", size = 4.3, fontface = "bold", hjust = 0) +
      ggplot2::annotate("text",
                        x = 0.18, y = 5.25,
                        label = "The probability of getting a result at least as extreme as ours,",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 4.97,
                        label = "assuming the Null Hypothesis is true.",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 4.65,
                        label = "Smaller p-value  =  stronger evidence against the Null.",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic")

    # alpha row
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 2.55, ymax = 4.2,
                        fill = "white", color = NA) +
      ggplot2::annotate("text",
                        x = 0.08, y = 3.38,
                        label = "alpha", parse = TRUE,
                        color = "#6C3483", size = 11, hjust = 0.5, fontface = "bold") +
      ggplot2::annotate("text",
                        x = 0.18, y = 3.95,
                        label = "alpha  -  Significance Level  (Greek letter)",
                        color = "#6C3483", size = 4.3, fontface = "bold", hjust = 0) +
      ggplot2::annotate("text",
                        x = 0.18, y = 3.60,
                        label = "The threshold we set BEFORE the study. Usually alpha = 0.05.",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 3.30,
                        label = "If p-value <= alpha  -->  Reject H0.",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic") +
      ggplot2::annotate("text",
                        x = 0.18, y = 3.02,
                        label = "If p-value  > alpha  -->  Fail to Reject H0.",
                        color = "#444444", size = 3.6, hjust = 0, fontface = "italic")

    # Golden Rule box
    p <- p +
      ggplot2::annotate("segment",
                        x = 0, xend = 1, y = 2.48, yend = 2.48,
                        color = "#AAAAAA", linewidth = 0.6) +
      ggplot2::annotate("rect",
                        xmin = 0.04, xmax = 0.96, ymin = 0.7, ymax = 2.35,
                        fill = "#FEF9E7", color = "#F9CA24", linewidth = 0.9) +
      ggplot2::annotate("text",
                        x = 0.5, y = 2.02,
                        label = "The Golden Rule of Decisions",
                        color = "#7D6608", size = 4.8, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.5, y = 1.60,
                        label = "Compare  p-value  vs.  alpha",
                        color = "#2C3E50", size = 5.2, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.5, y = 1.15,
                        label = "We NEVER 'accept' H0.  We either Reject it, or Fail to Reject it.",
                        color = "#7D6608", size = 3.6, hjust = 0.5, fontface = "italic")

    # Outer border
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1, ymin = 0.5, ymax = TOTAL_H,
                        fill = NA, color = "#888888", linewidth = 0.7)

    return(p)
  }

  # ══════════════════════════════════════════════════════════════════════════
  # PLOT 4 — REGRESSION & CORRELATION  (unchanged)
  # ══════════════════════════════════════════════════════════════════════════
  plot_regression <- function() {
    rows <- list(
      list(
        concept  = "Sample\nSize",
        pop_sym  = "italic(N)",    pop_name = "Capital N",
        pop_desc = "Total pairs in\npopulation",
        sam_sym  = "italic(n)",    sam_name = "Lowercase n",
        sam_desc = "Number of (x, y)\npairs in your sample"
      ),
      list(
        concept  = "Correlation",
        pop_sym  = "rho",          pop_name = "rho  (row)",
        pop_desc = "True population\ncorrelation coefficient",
        sam_sym  = "italic(r)",    sam_name = "r",
        sam_desc = "Sample correlation\n(-1 to +1)"
      ),
      list(
        concept  = "Intercept",
        pop_sym  = "beta[0]",      pop_name = "beta-sub-0",
        pop_desc = "True population\ny-intercept",
        sam_sym  = "italic(b)[0]", sam_name = "b-sub-0",
        sam_desc = "Estimated intercept\nfrom your sample"
      ),
      list(
        concept  = "Slope",
        pop_sym  = "beta[1]",      pop_name = "beta-sub-1",
        pop_desc = "True population slope\n(effect per 1-unit increase in x)",
        sam_sym  = "italic(b)[1]", sam_name = "b-sub-1",
        sam_desc = "Estimated slope\nfrom your sample"
      ),
      list(
        concept  = "R-Squared",
        pop_sym  = "symbol('--')", pop_name = "  --",
        pop_desc = "No separate\npopulation symbol",
        sam_sym  = "R^2",          sam_name = "R-squared",
        sam_desc = "% of variability in y\nexplained by x"
      ),
      list(
        concept  = "Predicted\nValue",
        pop_sym  = "E(Y)",         pop_name = "E(Y)  (Expected Y)",
        pop_desc = "True expected value\nof Y given X",
        sam_sym  = "hat(y)",       sam_name = "y-hat",
        sam_desc = "Predicted y from\nthe regression line"
      )
    )

    draw_symbol_table(
      title       = "Symbols for Regression & Correlation",
      subtitle    = "Used when exploring the linear relationship between two quantitative variables",
      rows        = rows,
      title_color = "#1A5276"
    )
  }

  # ══════════════════════════════════════════════════════════════════════════
  # PLOT 5 — COMMON MISTAKES
  # ══════════════════════════════════════════════════════════════════════════
  plot_mistakes <- function() {

    WRONG_COL <- "#C0392B"
    RIGHT_COL <- "#1E8449"
    WARN_COL  <- "#E67E22"
    BG_WRONG  <- "#FDEDEC"
    BG_RIGHT  <- "#EAFAF1"
    BG_WARN   <- "#FEF5E7"

    mistakes <- list(
      list(
        title      = "p-value  vs.  p-hat",
        wrong_sym  = "italic(p)",
        wrong_name = "p  (alone) or p-value",
        wrong_desc = "A probability. How likely is\nour result if H0 were true?\nRanges from 0 to 1.",
        right_sym  = "hat(p)",
        right_name = "p-hat",
        right_desc = "A proportion. What fraction\nof our sample had the\noutcome of interest?"
      ),
      list(
        title      = "Hypotheses are about\nParameters, NOT Statistics",
        wrong_sym  = "bar(x)",
        wrong_name = "H0: x-bar = 5   [WRONG]",
        wrong_desc = "x-bar is a sample statistic.\nWe never hypothesize\nabout sample values.",
        right_sym  = "mu",
        right_name = "H0: mu = 5   [CORRECT]",
        right_desc = "mu is the population parameter.\nHypotheses are always\nabout parameters."
      ),
      list(
        title      = "sigma  vs.  s\n(Don't mix these up!)",
        wrong_sym  = "sigma",
        wrong_name = "sigma  (Greek)",
        wrong_desc = "Population SD.\nAlmost always UNKNOWN.\nUsing it leads to a Z-test.",
        right_sym  = "italic(s)",
        right_name = "s  (Latin)",
        right_desc = "Sample SD. What you\ncalculate from data.\nLeads to a T-test."
      ),
      list(
        title      = "mu  vs.  x-bar\n(Parameter vs. Statistic)",
        wrong_sym  = "mu",
        wrong_name = "mu  -  population mean",
        wrong_desc = "What we are TRYING to\nlearn about. We never\nknow the true value.",
        right_sym  = "bar(x)",
        right_name = "x-bar  -  sample mean",
        right_desc = "What we CALCULATE\nfrom our data. Our\nbest estimate of mu."
      )
    )

    n_m     <- length(mistakes)
    row_h   <- 3.2      # increased from 2.6 to give bigger text more room
    top_h   <- 1.6
    col_h   <- 0.65
    total_h <- top_h + col_h + n_m * row_h + 0.6

    p <- ggplot2::ggplot() +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, total_h), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.margin = ggplot2::margin(10, 10, 10, 10),
        plot.background = ggplot2::element_rect(fill = "white", color = NA)
      )

    # Title block
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1,
                        ymin = total_h - top_h, ymax = total_h,
                        fill = WARN_COL, color = NA) +
      ggplot2::annotate("text",
                        x = 0.5, y = total_h - 0.62,
                        label = "Common Symbol Mistakes in STAT 218",
                        color = "white", size = 6.5, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("text",
                        x = 0.5, y = total_h - 1.18,
                        label = "These are the most frequent mix-ups. Learn them early!",
                        color = "#FEF5E7", size = 3.8, hjust = 0.5, fontface = "italic")

    # Column sub-headers
    col_top <- total_h - top_h
    col_bot <- col_top - col_h

    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 0.22, ymin = col_bot, ymax = col_top,
                        fill = BG_WARN, color = NA) +
      ggplot2::annotate("text",
                        x = 0.11, y = (col_top + col_bot) / 2,
                        label = "Mix-Up", color = WARN_COL,
                        size = 4, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("rect",
                        xmin = 0.23, xmax = 0.605, ymin = col_bot, ymax = col_top,
                        fill = BG_WRONG, color = NA) +
      ggplot2::annotate("text",
                        x = 0.418, y = (col_top + col_bot) / 2,
                        label = "Watch Out For...",
                        color = WRONG_COL, size = 4, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("rect",
                        xmin = 0.615, xmax = 1.0, ymin = col_bot, ymax = col_top,
                        fill = BG_RIGHT, color = NA) +
      ggplot2::annotate("text",
                        x = 0.808, y = (col_top + col_bot) / 2,
                        label = "Remember This Instead",
                        color = RIGHT_COL, size = 4, fontface = "bold", hjust = 0.5) +
      ggplot2::annotate("segment",
                        x = 0, xend = 1, y = col_bot, yend = col_bot,
                        color = "#AAAAAA", linewidth = 0.5)

    # Data rows
    for (i in seq_along(mistakes)) {
      m     <- mistakes[[i]]
      y_top <- col_bot - (i - 1) * row_h
      y_bot <- y_top - row_h
      y_mid <- (y_top + y_bot) / 2

      bg <- if (i %% 2 == 0) "#FAFAFA" else "white"
      p <- p +
        ggplot2::annotate("rect",
                          xmin = 0, xmax = 1, ymin = y_bot, ymax = y_top,
                          fill = bg, color = NA) +
        ggplot2::annotate("segment",
                          x = 0, xend = 1, y = y_bot, yend = y_bot,
                          color = "#E0E0E0", linewidth = 0.3)

      # Mix-up label
      p <- p +
        ggplot2::annotate("text",
                          x = 0.11, y = y_mid,
                          label = m$title, color = WARN_COL,
                          size = 5.2, fontface = "bold", hjust = 0.5, lineheight = 0.9)

      # Wrong box: symbol left, name + desc right (bigger text, more gap)
      p <- p +
        ggplot2::annotate("rect",
                          xmin = 0.235, xmax = 0.598,
                          ymin = y_bot + 0.15, ymax = y_top - 0.15,
                          fill = BG_WRONG, color = "#F1948A", linewidth = 0.5) +
        ggplot2::annotate("text",
                          x = 0.305, y = y_mid,
                          label = m$wrong_sym, parse = TRUE,
                          color = WRONG_COL, size = 9, hjust = 0.5, fontface = "bold") +
        ggplot2::annotate("text",
                          x = 0.368, y = y_mid + 0.70,        # name pushed higher
                          label = m$wrong_name,
                          color = WRONG_COL, size = 5.3, fontface = "bold", hjust = 0) +
        ggplot2::annotate("text",
                          x = 0.368, y = y_mid - 0.25,        # desc pulled lower
                          label = m$wrong_desc,
                          color = "#7B241C", size = 5.0, hjust = 0,
                          fontface = "italic", lineheight = 0.88)

      # Right box: symbol left, name + desc right (bigger text, more gap)
      p <- p +
        ggplot2::annotate("rect",
                          xmin = 0.622, xmax = 0.992,
                          ymin = y_bot + 0.15, ymax = y_top - 0.15,
                          fill = BG_RIGHT, color = "#A9DFBF", linewidth = 0.5) +
        ggplot2::annotate("text",
                          x = 0.692, y = y_mid,
                          label = m$right_sym, parse = TRUE,
                          color = RIGHT_COL, size = 9, hjust = 0.5, fontface = "bold") +
        ggplot2::annotate("text",
                          x = 0.755, y = y_mid + 0.70,        # name pushed higher
                          label = m$right_name,
                          color = RIGHT_COL, size = 5.3, fontface = "bold", hjust = 0) +
        ggplot2::annotate("text",
                          x = 0.755, y = y_mid - 0.25,        # desc pulled lower
                          label = m$right_desc,
                          color = "#1D6A39", size = 5.0, hjust = 0,
                          fontface = "italic", lineheight = 0.88)
    }

    # Vertical dividers between columns
    for (xv in c(0.22, 0.61)) {
      p <- p +
        ggplot2::annotate("segment",
                          x = xv, xend = xv,
                          y = 0.45, yend = col_top,
                          color = "#AAAAAA", linewidth = 0.5)
    }

    # Outer border
    p <- p +
      ggplot2::annotate("rect",
                        xmin = 0, xmax = 1,
                        ymin = 0.45, ymax = total_h,
                        fill = NA, color = "#888888", linewidth = 0.7)

    return(p)
  }

  # ── Dispatch ──────────────────────────────────────────────────────────────
  plots_to_show <- switch(topic,
                          "all"         = c("proportions", "means", "tests", "regression", "mistakes"),
                          "proportions" = "proportions",
                          "means"       = "means",
                          "tests"       = "tests",
                          "regression"  = "regression",
                          "mistakes"    = "mistakes"
  )

  for (t in plots_to_show) {
    p <- switch(t,
                "proportions" = plot_proportions(),
                "means"       = plot_means(),
                "tests"       = plot_tests(),
                "regression"  = plot_regression(),
                "mistakes"    = plot_mistakes()
    )
    print(p)
  }

  invisible(NULL)
}
