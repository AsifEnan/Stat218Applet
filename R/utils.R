#' Plot Detailed Mathematical Steps and Interpretations
#'
#' @description
#' Displays a step-by-step panel walking through the math, standardized
#' statistic, p-value, and written conclusion for a completed statistical
#' analysis. Call this on any result object produced by the Stat218Applet
#' functions (e.g., \code{test_1prop}, \code{test_1mean}, etc.).
#'
#' @param x A result object of any \code{stat218_*} class.
#' @note The significance level \code{alpha} is passed via \code{...} and
#'   handled by each individual method.
#' @param ... Additional arguments passed to the specific method.
#'
#' @import ggplot2
#' @import ggtext
#' @import patchwork
#' @importFrom cli cli_abort cli_inform
#' @importFrom gt gt tab_header cols_label tab_style cell_fill cell_text cells_column_labels cells_body tab_spanner
#' @importFrom latex2exp TeX
#' @importFrom stats coef complete.cases confint cor dnorm dt lm na.omit pnorm pt qnorm qt quantile rbinom rnorm sd
#' @importFrom utils tail
#'
#' @export
plot_steps <- function(x, ...) {
  UseMethod("plot_steps")
}
