# Stat218Applet

**Stat218Applet** is an R package for introductory statistics courses.
It provides simulation-based and theory-based inference functions that
follow the *Introduction to Statistical Investigations* (ISI) textbook
by Tintle et al. The package is designed to give students hands-on
experience with R and RStudio while working through the same concepts
covered in class.

Every function returns an S3 object that supports three methods:
[`print()`](https://rdrr.io/r/base/print.html) for a clean summary,
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for a
visualization of the null distribution or confidence interval, and
[`plot_steps()`](https://asifenan.github.io/Stat218Applet/reference/plot_steps.md)
for a detailed step-by-step breakdown. All functions accept either
summary statistics or raw data via `formula` and `data`.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("AsifEnan/Stat218Applet")
```

## Quick Demo

``` r
library(Stat218Applet)

# One-proportion test using summary statistics
result <- test_1prop(
  successes   = 15,
  n           = 16,
  null_pi     = 0.5,
  alternative = "greater",
  method      = "theory"
)

print(result)       # Clean summary output
plot(result)        # Null distribution with shaded p-value
plot_steps(result)  # Step-by-step breakdown
```

## Available Functions

### Hypothesis Tests

| Function | Tests |
|----|----|
| [`test_1prop()`](https://asifenan.github.io/Stat218Applet/reference/test_1prop.md) | Single population proportion (H₀: π = π₀) |
| [`test_1mean()`](https://asifenan.github.io/Stat218Applet/reference/test_1mean.md) | Single population mean (H₀: μ = μ₀) |
| [`test_2prop()`](https://asifenan.github.io/Stat218Applet/reference/test_2prop.md) | Difference in two proportions (H₀: π₁ − π₂ = 0) |
| [`test_2mean()`](https://asifenan.github.io/Stat218Applet/reference/test_2mean.md) | Difference in two means (H₀: μ₁ − μ₂ = 0) |
| [`test_paired()`](https://asifenan.github.io/Stat218Applet/reference/test_paired.md) | Mean of paired differences (H₀: μ_d = 0) |
| [`test_correlation()`](https://asifenan.github.io/Stat218Applet/reference/test_correlation.md) | Population correlation (H₀: ρ = 0) |
| [`test_regression()`](https://asifenan.github.io/Stat218Applet/reference/test_regression.md) | Regression slope (H₀: β₁ = 0) |

### Confidence Intervals

| Function | Estimates |
|----|----|
| [`ci_1prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_1prop.md) | Interval for a single proportion π |
| [`ci_1mean()`](https://asifenan.github.io/Stat218Applet/reference/ci_1mean.md) | Interval for a single mean μ |
| [`ci_2prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_2prop.md) | Interval for the difference π₁ − π₂ |
| [`ci_2mean()`](https://asifenan.github.io/Stat218Applet/reference/ci_2mean.md) | Interval for the difference μ₁ − μ₂ |
| [`ci_paired()`](https://asifenan.github.io/Stat218Applet/reference/ci_paired.md) | Interval for the mean difference μ_d |

All CI functions support three methods: `"2SD"` (default, 95% only),
`"simulation"` (any confidence level), and `"theory"` (formula-based).

### Helper Functions

| Function | Purpose |
|----|----|
| [`explore_2vars()`](https://asifenan.github.io/Stat218Applet/reference/explore_2vars.md) | Scatterplot or boxplot for two variables before running inference |
| [`table_regression()`](https://asifenan.github.io/Stat218Applet/reference/table_regression.md) | Formatted regression or ANOVA table using `gt` |
| [`show_symbols()`](https://asifenan.github.io/Stat218Applet/reference/show_symbols.md) | Symbol reference table for proportions, means, and regression |

## Bundled Datasets

The package includes 32 datasets drawn from the ISI textbook, covering
Chapters P, 2, 3, 5, 6, 7, and 10. A selection is shown below.

| Dataset           | Chapter   | Used for                    |
|-------------------|-----------|-----------------------------|
| `dolphin`         | Ch. P     | One-proportion test         |
| `yawning`         | Ch. 5     | Two-proportion test         |
| `organdonor`      | Ch. 5     | Two-proportion test         |
| `haircuts`        | Ch. 2 / 6 | One-mean and two-mean tests |
| `closefriends`    | Ch. 6     | Two-mean test               |
| `oldfaithful2`    | Ch. 6     | Two-mean test               |
| `firstbase`       | Ch. 7     | Paired test                 |
| `jjvsbicycle`     | Ch. 7     | Paired test                 |
| `handwidth`       | Ch. 10    | Correlation and regression  |
| `examtimesscores` | Ch. 10    | Regression                  |
| `platesize`       | Ch. 10    | Regression                  |

Type `?dataset_name` in RStudio for full documentation on any dataset.

## Getting Help

- Type `?function_name`
  (e.g. [`?test_1mean`](https://asifenan.github.io/Stat218Applet/reference/test_1mean.md))
  for full documentation on any function
- Full vignette and function reference:
  <https://asifenan.github.io/Stat218Applet/>
