# Haircut Costs by Sex

Haircut costs reported by male and female college students. Used in both
Chapter 2 (one-mean) and Chapter 6 (two-mean) of ISI. A consistently
engaging dataset that generates real class discussion about whether men
and women pay different amounts for haircuts.

## Usage

``` r
haircuts
```

## Format

A data frame with 50 rows and 2 variables:

- sex:

  `"Male"` or `"Female"`

- cost:

  Cost of the most recent haircut (dollars)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(haircuts)
#> # A tibble: 6 × 2
#>   sex     cost
#>   <chr>  <dbl>
#> 1 Female    50
#> 2 Male      20
#> 3 Female    60
#> 4 Male      75
#> 5 Female   150
#> 6 Male      23
# One-mean: is the average haircut cost different from $50?
test_1mean(
  formula     = ~ cost,
  data        = haircuts,
  null_mu     = 50,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from variable "cost":
#> • Sample Mean (x-bar): 45.68
#> • Sample SD (s): 39.9492
#> • Sample Size (n): 50
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 1-Sample Mean Hypothesis Test (Theory) ──────────────────────────────────────
#> ℹ Observed Mean (x-bar): 45.68
#> ℹ Standard Deviation (s): 39.9492 | n: 50
#> ℹ Null Hypothesis (mu0): 50
#> ℹ Alternative: two.sided
#> • SD of Null Distribution: 5.6497
#> • Test Statistic (T): -0.765
#> • P-Value: 0.4481
# Two-mean: do men and women pay different amounts?
test_2mean(
  formula     = cost ~ sex,
  data        = haircuts,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "cost" ~ "sex":
#> • Female: x-bar = 54.0541, s = 41.6139, n = 37
#> • Male: x-bar = 21.8462, s = 22.1354, n = 13
#> Warning: ! Validity conditions for the theory-based test may not be met.
#> ℹ At least one group has fewer than 20 observations:
#> • Female: n = 37
#> • Male: n = 13
#> ℹ Proceed only if the distributions within both groups are roughly symmetric.
#> ℹ Otherwise consider using `method = "simulation"`.
#> 
#> ── 2-Sample Means Hypothesis Test (Theory) ─────────────────────────────────────
#> ℹ Female: x-bar = 54.0541 | s = 41.6139 | n = 37
#> ℹ Male: x-bar = 21.8462 | s = 22.1354 | n = 13
#> ℹ Null Hypothesis: mu1 - mu2 = 0
#> ℹ Alternative: mu1 - mu2 != 0
#> • Observed Difference (x-bar1 - x-bar2): 32.2079
#> • SD of Null Distribution: 9.192
#> • Test Statistic (T): 3.504
#> • P-Value: 0.0011
#> Warning: ! Validity conditions may not be met -- at least one group has fewer than 20
#>   observations.
#> ℹ Verify that distributions within both groups are roughly symmetric.
#> ℹ Consider using `method = "simulation"` if raw data is available.
```
