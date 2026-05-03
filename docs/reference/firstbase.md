# First Base Running Times

Times for baseball players running to first base using a narrow turn vs.
a wide turn. Each player ran both ways, making this a classic paired
design. Used in Chapter 7 of ISI for paired inference.

## Usage

``` r
firstbase
```

## Format

A data frame with 22 rows and 2 variables:

- narrow:

  Time with a narrow turn (seconds)

- wide:

  Time with a wide turn (seconds)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(firstbase)
#> # A tibble: 6 × 2
#>   narrow  wide
#>    <dbl> <dbl>
#> 1   5.5   5.55
#> 2   5.7   5.75
#> 3   5.6   5.5 
#> 4   5.5   5.4 
#> 5   5.85  5.7 
#> 6   5.55  5.6 
test_paired(
  formula     = wide ~ narrow,
  data        = firstbase,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Differences computed as "wide" minus "narrow".
#> • Number of pairs (n_d): 22
#> 
#> ── Paired Data Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Mean Difference (x-bar_d): -0.075
#> ℹ SD of Differences (s_d): 0.0883
#> ℹ Number of Pairs (n_d): 22
#> ℹ Null Hypothesis: mu_d = 0
#> ℹ Alternative: mu_d != 0
#> • SD of Null Distribution: 0.0188
#> • Test Statistic (T): -3.984
#> • P-Value: 7e-04
ci_paired(
  formula    = wide ~ narrow,
  data       = firstbase,
  conf_level = 0.95,
  method     = "theory"
)
#> ✔ Differences computed as "wide" minus "narrow".
#> • Number of pairs (n_d): 22
#> 
#> ── 95% Confidence Interval for Mean Difference (Theory) ────────────────────────
#> ℹ Point Estimate (x-bar_d): -0.075
#> ℹ SD of Differences (s_d): 0.0883
#> ℹ Number of Pairs (n_d): 22
#> ℹ SD of Sampling Distribution: 0.0188
#> • Interval: (-0.1142, -0.0358)
```
