# Number of Close Friends by Sex

Survey data on the number of close friends reported by male and female
respondents. Used in Chapter 6 of ISI for two-mean inference with a
large real-world sample. A useful example for discussing skewness and
validity conditions.

## Usage

``` r
closefriends
```

## Format

A data frame with 1467 rows and 2 variables:

- sex:

  `"Men"` or `"Women"`

- friends:

  Number of close friends reported

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(closefriends)
#> # A tibble: 6 × 2
#>   sex   friends
#>   <chr>   <dbl>
#> 1 Men         0
#> 2 Men         0
#> 3 Men         0
#> 4 Men         0
#> 5 Men         0
#> 6 Men         0
test_2mean(
  formula     = friends ~ sex,
  data        = closefriends,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "friends" ~ "sex":
#> • Men: x-bar = 1.8609, s = 1.7771, n = 654
#> • Women: x-bar = 2.0886, s = 1.7601, n = 813
#> 
#> ── 2-Sample Means Hypothesis Test (Theory) ─────────────────────────────────────
#> ℹ Men: x-bar = 1.8609 | s = 1.7771 | n = 654
#> ℹ Women: x-bar = 2.0886 | s = 1.7601 | n = 813
#> ℹ Null Hypothesis: mu1 - mu2 = 0
#> ℹ Alternative: mu1 - mu2 != 0
#> • Observed Difference (x-bar1 - x-bar2): -0.2277
#> • SD of Null Distribution: 0.093
#> • Test Statistic (T): -2.45
#> • P-Value: 0.0144
```
