# Student Sleep Hours

Self-reported nightly sleep hours from a sample of college students.
Used in Chapter 2 of ISI for one-mean hypothesis tests and confidence
intervals. A relatable dataset that resonates with students.

## Usage

``` r
sleeptimes
```

## Format

A data frame with 22 rows and 1 variable:

- sleep_hrs:

  Hours of sleep per night (self-reported)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(sleeptimes)
#> # A tibble: 6 × 1
#>   sleep_hrs
#>       <dbl>
#> 1       7  
#> 2       5.5
#> 3       8  
#> 4       7  
#> 5       7.5
#> 6       6  
test_1mean(
  formula     = ~ sleep_hrs,
  data        = sleeptimes,
  null_mu     = 8,
  alternative = "less",
  method      = "theory"
)
#> ✔ Data extracted from variable "sleep_hrs":
#> • Sample Mean (x-bar): 6.7045
#> • Sample SD (s): 1.2971
#> • Sample Size (n): 22
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 1-Sample Mean Hypothesis Test (Theory) ──────────────────────────────────────
#> ℹ Observed Mean (x-bar): 6.7045
#> ℹ Standard Deviation (s): 1.2971 | n: 22
#> ℹ Null Hypothesis (mu0): 8
#> ℹ Alternative: less
#> • SD of Null Distribution: 0.2765
#> • Test Statistic (T): -4.685
#> • P-Value: 1e-04
ci_1mean(
  formula = ~ sleep_hrs,
  data    = sleeptimes,
  method  = "2SD"
)
#> ✔ Data extracted from variable "sleep_hrs":
#> • Sample Mean (x-bar): 6.7045
#> • Sample SD (s): 1.2971
#> • Sample Size (n): 22
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 95% Confidence Interval (2sd) ───────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 6.7045
#> ℹ Standard Deviation (s): 1.2971 | n: 22
#> ℹ SD of Sampling Distribution: 0.2682
#> • Interval: (6.1681, 7.241)
```
