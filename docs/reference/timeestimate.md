# Time Interval Estimates (Sample)

Students were asked to estimate a 10-second time interval without
counting. Used in Chapter 2 of ISI to introduce one-mean inference –
specifically, to test whether students systematically over- or
underestimate a 10-second interval.

## Usage

``` r
timeestimate
```

## Format

A data frame with 48 rows and 1 variable:

- estimate:

  Estimated time interval in seconds

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(timeestimate)
#> # A tibble: 6 × 1
#>   estimate
#>      <dbl>
#> 1       10
#> 2       12
#> 3        6
#> 4       13
#> 5       15
#> 6       10
test_1mean(
  formula     = ~ estimate,
  data        = timeestimate,
  null_mu     = 10,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from variable "estimate":
#> • Sample Mean (x-bar): 13.7083
#> • Sample SD (s): 6.5003
#> • Sample Size (n): 48
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 1-Sample Mean Hypothesis Test (Theory) ──────────────────────────────────────
#> ℹ Observed Mean (x-bar): 13.7083
#> ℹ Standard Deviation (s): 6.5003 | n: 48
#> ℹ Null Hypothesis (mu0): 10
#> ℹ Alternative: two.sided
#> • SD of Null Distribution: 0.9382
#> • Test Statistic (T): 3.952
#> • P-Value: 3e-04
ci_1mean(
  formula    = ~ estimate,
  data       = timeestimate,
  conf_level = 0.95,
  method     = "theory"
)
#> ✔ Data extracted from variable "estimate":
#> • Sample Mean (x-bar): 13.7083
#> • Sample SD (s): 6.5003
#> • Sample Size (n): 48
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 13.7083
#> ℹ Standard Deviation (s): 6.5003 | n: 48
#> ℹ SD of Sampling Distribution: 0.9382
#> • Interval: (11.8209, 15.5958)
```
