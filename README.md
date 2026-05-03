
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Stat218Applet

<!-- badges: start -->

<!-- badges: end -->

**Stat218Applet** is an R package for introductory statistics courses.
It provides simulation-based and theory-based inference functions that
follow the *Introduction to Statistical Investigations* (ISI) textbook
by Tintle et al. The package is designed to give students hands-on
experience with R and RStudio while working through the same concepts
covered in class.

Every function returns an S3 object that supports three methods:
`print()` for a clean summary, `plot()` for a visualization of the null
distribution or confidence interval, and `plot_steps()` for a detailed
step-by-step breakdown. All functions accept either summary statistics
or raw data via `formula` and `data`.

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

| Function             | Tests                                           |
|----------------------|-------------------------------------------------|
| `test_1prop()`       | Single population proportion (H₀: π = π₀)       |
| `test_1mean()`       | Single population mean (H₀: μ = μ₀)             |
| `test_2prop()`       | Difference in two proportions (H₀: π₁ − π₂ = 0) |
| `test_2mean()`       | Difference in two means (H₀: μ₁ − μ₂ = 0)       |
| `test_paired()`      | Mean of paired differences (H₀: μ_d = 0)        |
| `test_correlation()` | Population correlation (H₀: ρ = 0)              |
| `test_regression()`  | Regression slope (H₀: β₁ = 0)                   |

### Confidence Intervals

| Function      | Estimates                            |
|---------------|--------------------------------------|
| `ci_1prop()`  | Interval for a single proportion π   |
| `ci_1mean()`  | Interval for a single mean μ         |
| `ci_2prop()`  | Interval for the difference π₁ − π₂  |
| `ci_2mean()`  | Interval for the difference μ₁ − μ₂  |
| `ci_paired()` | Interval for the mean difference μ_d |

All CI functions support three methods: `"2SD"` (default, 95% only),
`"simulation"` (any confidence level), and `"theory"` (formula-based).

### Helper Functions

| Function | Purpose |
|----|----|
| `explore_2vars()` | Scatterplot or boxplot for two variables before running inference |
| `table_regression()` | Formatted regression or ANOVA table using `gt` |
| `show_symbols()` | Symbol reference table for proportions, means, and regression |

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

- Type `?function_name` (e.g. `?test_1mean`) for full documentation on
  any function
- Full vignette and function reference:
  <https://asifenan.github.io/Stat218Applet/>
