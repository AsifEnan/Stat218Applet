# Used Honda Civic Prices

Sale prices of used Honda Civics from an online listing. Used in Chapter
3 of ISI to practice one-mean inference with a real-world quantitative
variable. Students often use this dataset to test claims about whether
the average used Civic costs more or less than a specific benchmark
price.

## Usage

``` r
usedcars
```

## Format

A data frame with 102 rows and 1 variable:

- price:

  Sale price of the vehicle (dollars)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(usedcars)
#> # A tibble: 6 × 1
#>   price
#>   <dbl>
#> 1 21990
#> 2 21990
#> 3 21987
#> 4 20955
#> 5 20955
#> 6 19995
test_1mean(
  formula     = ~ price,
  data        = usedcars,
  null_mu     = 15000,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from variable "price":
#> • Sample Mean (x-bar): 13292.3333
#> • Sample SD (s): 4534.5675
#> • Sample Size (n): 102
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 1-Sample Mean Hypothesis Test (Theory) ──────────────────────────────────────
#> ℹ Observed Mean (x-bar): 13292.3333
#> ℹ Standard Deviation (s): 4534.5675 | n: 102
#> ℹ Null Hypothesis (mu0): 15000
#> ℹ Alternative: two.sided
#> • SD of Null Distribution: 448.9891
#> • Test Statistic (T): -3.803
#> • P-Value: 2e-04
ci_1mean(
  formula    = ~ price,
  data       = usedcars,
  conf_level = 0.95,
  method     = "theory"
)
#> ✔ Data extracted from variable "price":
#> • Sample Mean (x-bar): 13292.3333
#> • Sample SD (s): 4534.5675
#> • Sample Size (n): 102
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 13292.3333
#> ℹ Standard Deviation (s): 4534.5675 | n: 102
#> ℹ SD of Sampling Distribution: 448.9891
#> • Interval: (12401.6598, 14183.0069)
```
