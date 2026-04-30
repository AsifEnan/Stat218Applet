#' Explore Bivariate Data (Correlation and Simple Linear Regression)
#'
#' @param x Numeric vector for the explanatory variable
#' @param y Numeric vector for the response variable
#' @param group Optional categorical vector for grouping
#' @param x_name Character string for the X-axis label
#' @param y_name Character string for the Y-axis label
#' @param fit_line Logical; FALSE for Correlation mode, TRUE for Regression mode
#'
#' @return A ggplot2 or patchwork object
#' @export
explore_2vars <- function(x, y, group = NULL, x_name = "X", y_name = "Y", fit_line = FALSE) {

  # 1. Clean the data
  if (is.null(group)) {
    valid_data <- complete.cases(x, y)
    df <- data.frame(x = x[valid_data], y = y[valid_data])
  } else {
    valid_data <- complete.cases(x, y, group)
    df <- data.frame(x = x[valid_data], y = y[valid_data], group = as.factor(group[valid_data]))
  }

  # Helper function to explicitly interpret r
  interpret_r <- function(r_val) {
    dir <- ifelse(r_val > 0, "Positive", "Negative")
    abs_r <- abs(r_val)
    str <- ifelse(abs_r >= 0.7, "Strong", ifelse(abs_r >= 0.4, "Moderate", "Weak"))
    return(paste0("Form: Linear | Direction: ", dir, " | Strength: ", str, " (correlation coefficient, r = ", round(r_val, 3), ")"))
  }

  # 2. Base Scatterplot Setup
  if (is.null(group)) {
    p_top <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_point(size = 3, color = "#2C3E50", alpha = 0.7)
  } else {
    p_top <- ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, color = group)) +
      ggplot2::geom_point(size = 3, alpha = 0.7) +
      ggplot2::labs(color = "Group")
  }

  p_top <- p_top + ggplot2::theme_minimal() +
    ggplot2::labs(x = x_name, y = y_name) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 16, face = "bold"),
                   plot.subtitle = ggplot2::element_text(size = 12, color = "#555555"))

  # 3. Mode Routing
  if (fit_line == FALSE) {
    # ==========================================
    # CORRELATION MODE (Crosshairs & Captions)
    # ==========================================
    x_bar <- mean(df$x)
    y_bar <- mean(df$y)
    r_overall <- cor(df$x, df$y)

    p_top <- p_top +
      ggplot2::geom_vline(xintercept = x_bar, linetype = "dashed", color = "gray50") +
      ggplot2::geom_hline(yintercept = y_bar, linetype = "dashed", color = "gray50") +
      ggplot2::labs(title = "Scatterplot & Correlation Analysis", subtitle = interpret_r(r_overall))

    if (!is.null(group)) {
      group_caps <- c()
      for (g in levels(df$group)) {
        sub_df <- df[df$group == g, ]
        r_g <- round(cor(sub_df$x, sub_df$y), 3)
        group_caps <- c(group_caps, paste0(g, ": correlation coefficient, r = ", r_g))
      }
      cap_text <- paste("Group Correlations:", paste(group_caps, collapse = "  |  "))
      p_top <- p_top + ggplot2::labs(caption = cap_text) +
        ggplot2::theme(plot.caption = ggplot2::element_text(size = 12, hjust = 0, face = "bold", color = "#2C3E50"))
    }

    return(p_top)

  } else {
    # ==========================================
    # REGRESSION MODE (2-Tier Patchwork & Native plotmath)
    # ==========================================

    if (is.null(group)) {
      r2 <- round(summary(lm(y ~ x, data = df))$r.squared, 3)
      sub_text <- paste0(r2 * 100, "% of the variability in ", y_name, " is explained by its linear relationship with ", x_name, ".")
      p_top <- p_top +
        ggplot2::geom_smooth(method = "lm", se = FALSE, color = "#C0392B", linewidth = 1.2) +
        ggplot2::labs(title = "Simple Linear Regression Analysis", subtitle = sub_text)
    } else {
      p_top <- p_top +
        ggplot2::geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
        ggplot2::labs(title = "Simple Linear Regression Analysis", subtitle = "Multiple lines of best fit and equations applied by group.")
    }

    # Build Bottom Tier using native R plotmath strings
    math_labels <- data.frame(x = numeric(), y = numeric(), label = character(), stringsAsFactors = FALSE)
    curr_y <- 0
    y_step <- 1.5 # Controls the vertical gap between lines

    if (is.null(group)) {
      mod <- lm(y ~ x, data = df)
      b0 <- round(coef(mod)[1], 3)
      b1 <- round(coef(mod)[2], 3)
      r2 <- round(summary(mod)$r.squared, 3)
      r_val <- round(cor(df$x, df$y), 3)

      # Build the specific equation string dynamically to handle the math minus sign
      if (b1 < 0) {
        spec_eq <- paste0('widehat("', y_name, '") == ', b0, ' - ', abs(b1), ' * ("', x_name, '")')
      } else {
        spec_eq <- paste0('widehat("', y_name, '") == ', b0, ' + ', abs(b1), ' * ("', x_name, '")')
      }

      math_labels <- rbind(math_labels, data.frame(x = 0, y = curr_y, label = "bold('Overall Linear Model')"))
      curr_y <- curr_y - y_step
      math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = "hat(y) == b[0] + b[1]*x"))
      curr_y <- curr_y - y_step
      math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = spec_eq))
      curr_y <- curr_y - y_step
      # Use ~ for wide visual spaces in plotmath
      math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = paste0("r == ", r_val, " ~~~~~~~~~ R^2 == ", r2)))

    } else {
      for (g in levels(df$group)) {
        sub_df <- df[df$group == g, ]
        mod_g <- lm(y ~ x, data = sub_df)
        b0_g <- round(coef(mod_g)[1], 3)
        b1_g <- round(coef(mod_g)[2], 3)
        r2_g <- round(summary(mod_g)$r.squared, 3)
        r_g <- round(cor(sub_df$x, sub_df$y), 3)

        if (b1_g < 0) {
          spec_eq <- paste0('widehat("', y_name, '") == ', b0_g, ' - ', abs(b1_g), ' * ("', x_name, '")')
        } else {
          spec_eq <- paste0('widehat("', y_name, '") == ', b0_g, ' + ', abs(b1_g), ' * ("', x_name, '")')
        }

        math_labels <- rbind(math_labels, data.frame(x = 0, y = curr_y, label = paste0("bold('Group: ", g, "')")))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = "hat(y) == b[0] + b[1]*x"))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = spec_eq))
        curr_y <- curr_y - y_step
        math_labels <- rbind(math_labels, data.frame(x = 0.05, y = curr_y, label = paste0("r == ", r_g, " ~~~~~~~~~ R^2 == ", r2_g)))
        curr_y <- curr_y - 2.5 # Extra large gap between different groups
      }
    }

    # Adjust ylim dynamically so the text never gets cut off at the bottom
    p_bottom <- ggplot2::ggplot(math_labels, ggplot2::aes(x = x, y = y, label = label)) +
      ggplot2::geom_text(parse = TRUE, size = 5, hjust = 0) +
      ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(curr_y - 1, 1), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(plot.margin = ggplot2::margin(t = 10, r = 20, b = 20, l = 40))

    return(p_top / p_bottom + patchwork::plot_layout(heights = c(3, 1.8)))
  }
}
