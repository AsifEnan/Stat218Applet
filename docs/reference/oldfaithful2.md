# Old Faithful Eruption Type and Wait Times

Wait times between eruptions of the Old Faithful geyser, categorized by
eruption type. Used in Chapter 6 of ISI to compare wait times between
short and long eruptions using two-mean inference. This is the richer
version of the dataset – it includes the grouping variable that
`oldfaithful` lacks.

## Usage

``` r
oldfaithful2
```

## Format

A data frame with 222 rows and 2 variables:

- eruption_type:

  Type of preceding eruption: `"short"` or `"long"`

- time_between:

  Wait time until the next eruption (minutes)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(oldfaithful2)
#> # A tibble: 6 × 2
#>   eruption_type time_between
#>   <chr>                <dbl>
#> 1 short                   55
#> 2 short                   58
#> 3 short                   56
#> 4 short                   50
#> 5 short                   51
#> 6 short                   60
explore_2vars(formula = time_between ~ eruption_type, data = oldfaithful2)

test_2mean(
  formula     = time_between ~ eruption_type,
  data        = oldfaithful2,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "time_between" ~ "eruption_type":
#> • short: x-bar = 56.25, s = 8.4571, n = 76
#> • long: x-bar = 78.6918, s = 6.2517, n = 146
#> 
#> ── 2-Sample Means Hypothesis Test (Theory) ─────────────────────────────────────
#> ℹ short: x-bar = 56.25 | s = 8.4571 | n = 76
#> ℹ long: x-bar = 78.6918 | s = 6.2517 | n = 146
#> ℹ Null Hypothesis: mu1 - mu2 = 0
#> ℹ Alternative: mu1 - mu2 != 0
#> • Observed Difference (x-bar1 - x-bar2): -22.4418
#> • SD of Null Distribution: 1.0995
#> • Test Statistic (T): -20.412
#> • P-Value: 0
```
