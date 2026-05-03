# Body Temperature and Heart Rate

Body temperature and resting heart rate measurements from 130
individuals. A classic dataset used in Chapter 10 of ISI for regression
and correlation. Also widely used for one-mean inference on body
temperature (testing whether the true mean is 98.6 degrees F).

## Usage

``` r
tempheart
```

## Format

A data frame with 130 rows and 2 variables:

- body_temp:

  Body temperature (degrees Fahrenheit)

- heart_rate:

  Resting heart rate (beats per minute)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(tempheart)
#> # A tibble: 6 × 2
#>   body_temp heart_rate
#>       <dbl>      <dbl>
#> 1      96.3         70
#> 2      96.7         71
#> 3      96.9         74
#> 4      97           80
#> 5      97.1         73
#> 6      97.1         75

# One-mean: is the average body temperature really 98.6 F?
test_1mean(
  formula     = ~ body_temp,
  data        = tempheart,
  null_mu     = 98.6,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from variable "body_temp":
#> • Sample Mean (x-bar): 98.2492
#> • Sample SD (s): 0.7332
#> • Sample Size (n): 130
#> ℹ `sd_type` automatically set to "sample" from raw data.
#> 
#> ── 1-Sample Mean Hypothesis Test (Theory) ──────────────────────────────────────
#> ℹ Observed Mean (x-bar): 98.2492
#> ℹ Standard Deviation (s): 0.7332 | n: 130
#> ℹ Null Hypothesis (mu0): 98.6
#> ℹ Alternative: two.sided
#> • SD of Null Distribution: 0.0643
#> • Test Statistic (T): -5.455
#> • P-Value: 0

# Correlation
explore_2vars(formula = heart_rate ~ body_temp, data = tempheart)

test_correlation(
  formula     = heart_rate ~ body_temp,
  data        = tempheart,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "heart_rate" ~ "body_temp":
#> • n = 130
#> • Observed correlation (r) = 0.2537
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 130
#> • Observed Correlation (r): 0.2537
#> • SD of Null Distribution: 0.1396
#> • Test Statistic (T): 2.9668
#> • Degrees of Freedom: 128
#> • P-Value: 0.0036
```
