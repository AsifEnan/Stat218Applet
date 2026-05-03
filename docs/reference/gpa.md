# Study Hours and GPA

Weekly study hours and GPA for a sample of 42 college students. Used in
Chapter 10 of ISI for simple linear regression and correlation. Students
often expect a positive relationship – this dataset lets them test that
expectation formally.

## Usage

``` r
gpa
```

## Format

A data frame with 42 rows and 2 variables:

- hours:

  Weekly study hours

- gpa:

  Grade point average (0.0 to 4.0 scale)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(gpa)
#> # A tibble: 6 × 2
#>   hours   gpa
#>   <dbl> <dbl>
#> 1   7.7  3.17
#> 2  18.9  3.28
#> 3  19.4  3.72
#> 4  34.7  3.38
#> 5  42.8  3.17
#> 6  42.8  2.87
explore_2vars(formula = gpa ~ hours, data = gpa, fit_line = TRUE)
#> `geom_smooth()` using formula = 'y ~ x'

test_regression(
  formula     = gpa ~ hours,
  data        = gpa,
  alternative = "greater",
  method      = "theory"
)
#> ✔ Regression of "gpa" ~ "hours":
#> • n = 42
#> • Observed Slope (b1) = -0.0059
#> • Standard Error (SE) = 0.0031
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 > 0
#> • Sample Size (n): 42
#> • Observed Slope (b1): -0.0059
#> • Standard Error (SE): 0.0031
#> • SD of Null Distribution: 0.0031
#> • Test Statistic (T): -1.9166
#> • Degrees of Freedom: 40
#> • P-Value: 0.9688
table_regression(formula = gpa ~ hours, data = gpa)


  


Simple Linear Regression Output
```
