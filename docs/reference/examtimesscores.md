# Exam Time and Scores

Time spent on an exam and the resulting score for 30 students. Used in
Chapter 10 of ISI to explore whether spending more time on an exam is
associated with a higher (or lower) score. Results often surprise
students and prompt good discussion about confounding.

## Usage

``` r
examtimesscores
```

## Format

A data frame with 30 rows and 2 variables:

- time:

  Time spent on the exam (minutes)

- score:

  Exam score (points)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(examtimesscores)
#> # A tibble: 6 × 2
#>    time score
#>   <dbl> <dbl>
#> 1    30   100
#> 2    41    84
#> 3    41    94
#> 4    43    90
#> 5    47    88
#> 6    48    99
explore_2vars(
  formula  = score ~ time,
  data     = examtimesscores,
  fit_line = TRUE
)
#> `geom_smooth()` using formula = 'y ~ x'

test_regression(
  formula     = score ~ time,
  data        = examtimesscores,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Regression of "score" ~ "time":
#> • n = 30
#> • Observed Slope (b1) = -0.0996
#> • Standard Error (SE) = 0.1494
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 != 0
#> • Sample Size (n): 30
#> • Observed Slope (b1): -0.0996
#> • Standard Error (SE): 0.1494
#> • SD of Null Distribution: 0.1494
#> • Test Statistic (T): -0.6667
#> • Degrees of Freedom: 28
#> • P-Value: 0.5105
```
