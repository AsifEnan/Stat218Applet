# Foot Length and Height

Foot length and height measurements from a sample of 20 individuals. A
simple, intuitive dataset for introducing regression and correlation in
Chapter 10 of ISI. Students can easily reason about the expected
direction of the relationship before running the analysis.

## Usage

``` r
footheight
```

## Format

A data frame with 20 rows and 2 variables:

- footlength:

  Foot length (cm)

- height:

  Height (inches)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(footheight)
#> # A tibble: 6 × 2
#>   footlength height
#>        <dbl>  <dbl>
#> 1         32     74
#> 2         24     66
#> 3         29     77
#> 4         30     67
#> 5         24     56
#> 6         26     65
explore_2vars(formula = height ~ footlength, data = footheight)

test_regression(
  formula     = height ~ footlength,
  data        = footheight,
  alternative = "greater",
  method      = "theory"
)
#> ✔ Regression of "height" ~ "footlength":
#> • n = 20
#> • Observed Slope (b1) = 1.0333
#> • Standard Error (SE) = 0.2406
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 > 0
#> • Sample Size (n): 20
#> • Observed Slope (b1): 1.0333
#> • Standard Error (SE): 0.2406
#> • SD of Null Distribution: 0.2406
#> • Test Statistic (T): 4.2942
#> • Degrees of Freedom: 18
#> • P-Value: 2e-04
```
