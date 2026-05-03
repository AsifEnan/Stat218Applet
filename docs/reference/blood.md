# Blood Donor Response by Year

Survey responses about blood donation collected in two years (2002 and
2004). Used in Chapter 5 of ISI to compare donation rates across years
using two-proportion inference.

## Usage

``` r
blood
```

## Format

A data frame with 2698 rows and 2 variables:

- year:

  Year the survey was conducted: `2002` or `2004`

- response:

  Participant response: `"donated"` or `"did.not"`

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(blood)
#> # A tibble: 6 × 2
#>    year response
#>   <dbl> <chr>   
#> 1  2002 donated 
#> 2  2002 donated 
#> 3  2002 donated 
#> 4  2002 donated 
#> 5  2002 donated 
#> 6  2002 donated 
test_2prop(
  formula       = response ~ year,
  data          = blood,
  success_level = "donated",
  alternative   = "two.sided",
  method        = "theory"
)
#> ✔ Data extracted from "response" ~ "year":
#> • 2002: 210 successes out of 1362
#> • 2004: 230 successes out of 1336
#> ℹ Success level: "donated"
#> 
#> ── 2-Sample Proportions Hypothesis Test (Theory) ───────────────────────────────
#> ℹ 2002: p1-hat = 0.1542 (successes = 210, n = 1362)
#> ℹ 2004: p2-hat = 0.1722 (successes = 230, n = 1336)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 != 0
#> • Observed Difference (p1-hat - p2-hat): -0.018
#> • SD of Null Distribution: 0.0142
#> • Test Statistic (Z): -1.263
#> • P-Value: 0.2065
```
