# Sleep Deprivation and Reaction Time

Change in reaction time scores for participants assigned to either a
sleep-deprived condition or an unrestricted sleep condition. Used in
Chapter 6 of ISI as a core example for two-mean inference. Positive
values indicate improvement; negative values indicate worsening.

## Usage

``` r
sleep
```

## Format

A data frame with 21 rows and 2 variables:

- sleep:

  Sleep condition: `"deprived"` or `"unrestricted"`

- time:

  Change in reaction time score (higher = better)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(sleep)
#> # A tibble: 6 × 2
#>   sleep         time
#>   <chr>        <dbl>
#> 1 unrestricted  -7  
#> 2 unrestricted  11.6
#> 3 unrestricted  12.1
#> 4 unrestricted  12.6
#> 5 unrestricted  14.5
#> 6 unrestricted  18.6
test_2mean(
  formula     = time ~ sleep,
  data        = sleep,
  alternative = "less",
  method      = "theory"
)
#> ✔ Data extracted from "time" ~ "sleep":
#> • unrestricted: x-bar = 19.82, s = 14.7253, n = 10
#> • deprived: x-bar = 3.9, s = 12.1719, n = 11
#> Warning: ! Validity conditions for the theory-based test may not be met.
#> ℹ At least one group has fewer than 20 observations:
#> • unrestricted: n = 10
#> • deprived: n = 11
#> ℹ Proceed only if the distributions within both groups are roughly symmetric.
#> ℹ Otherwise consider using `method = "simulation"`.
#> 
#> ── 2-Sample Means Hypothesis Test (Theory) ─────────────────────────────────────
#> ℹ unrestricted: x-bar = 19.82 | s = 14.7253 | n = 10
#> ℹ deprived: x-bar = 3.9 | s = 12.1719 | n = 11
#> ℹ Null Hypothesis: mu1 - mu2 = 0
#> ℹ Alternative: mu1 - mu2 < 0
#> • Observed Difference (x-bar1 - x-bar2): 15.92
#> • SD of Null Distribution: 5.9289
#> • Test Statistic (T): 2.685
#> • P-Value: 0.9923
#> Warning: ! Validity conditions may not be met -- at least one group has fewer than 20
#>   observations.
#> ℹ Verify that distributions within both groups are roughly symmetric.
#> ℹ Consider using `method = "simulation"` if raw data is available.
```
