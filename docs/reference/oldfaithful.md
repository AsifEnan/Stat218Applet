# Old Faithful Wait Times by Year

Wait times between eruptions of the Old Faithful geyser in Yellowstone
National Park, recorded across multiple years (1978 onward). Useful for
regression and correlation analyses examining whether wait times have
changed over time (Chapter 10 of ISI). Note that R's built-in `faithful`
dataset covers a similar topic but with a different structure (eruption
duration vs. wait time).

## Usage

``` r
oldfaithful
```

## Format

A data frame with 202 rows and 2 variables:

- year:

  Year of observation (numeric)

- time:

  Wait time between eruptions (minutes)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(oldfaithful)
#> # A tibble: 6 × 2
#>    year  time
#>   <dbl> <dbl>
#> 1  1978    78
#> 2  1978    74
#> 3  1978    68
#> 4  1978    76
#> 5  1978    80
#> 6  1978    84
explore_2vars(formula = time ~ year, data = oldfaithful)

test_correlation(
  formula     = time ~ year,
  data        = oldfaithful,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "time" ~ "year":
#> • n = 202
#> • Observed correlation (r) = 0.6746
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 202
#> • Observed Correlation (r): 0.6746
#> • SD of Null Distribution: 0.1398
#> • Test Statistic (T): 12.9256
#> • Degrees of Freedom: 200
#> • P-Value: 0
```
