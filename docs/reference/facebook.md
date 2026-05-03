# Facebook Friends and Network Density

Number of Facebook friends and network density scores for 40 users.
Network density measures how interconnected a user's friend network is.
Used in Chapter 10 of ISI for regression and correlation.

## Usage

``` r
facebook
```

## Format

A data frame with 40 rows and 2 variables:

- friends:

  Number of Facebook friends

- density:

  Network density score

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(facebook)
#> # A tibble: 6 × 2
#>   friends density
#>     <dbl>   <dbl>
#> 1    0.3    -2.14
#> 2    1.09   -1.09
#> 3    0.39   -0.72
#> 4    1.2    -0.53
#> 5    0.8    -0.43
#> 6    1.71   -0.26
explore_2vars(formula = density ~ friends, data = facebook)

test_correlation(
  formula     = density ~ friends,
  data        = facebook,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "density" ~ "friends":
#> • n = 40
#> • Observed correlation (r) = 0.3655
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 40
#> • Observed Correlation (r): 0.3655
#> • SD of Null Distribution: 0.1382
#> • Test Statistic (T): 2.4207
#> • Degrees of Freedom: 38
#> • P-Value: 0.0204
```
