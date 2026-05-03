# Vietnam Draft Lottery

Draft numbers assigned in the 1969 Vietnam War lottery, matched to
sequential birth date (day of year 1-366). If the lottery was truly
random, there should be no correlation between birth date and draft
number. Used in Chapter 10 of ISI to test that randomness claim via
correlation inference.

## Usage

``` r
draftlottery
```

## Format

A data frame with 366 rows and 2 variables:

- sequential_date:

  Day of the year (1 = January 1, 366 = December 31)

- draft_number:

  Assigned draft number (1 = called first, 366 = called last)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(draftlottery)
#> # A tibble: 6 × 2
#>   sequential_date draft_number
#>             <dbl>        <dbl>
#> 1               1          305
#> 2               2          159
#> 3               3          251
#> 4               4          215
#> 5               5          101
#> 6               6          224
explore_2vars(
  formula  = draft_number ~ sequential_date,
  data     = draftlottery,
  fit_line = TRUE
)
#> `geom_smooth()` using formula = 'y ~ x'

test_correlation(
  formula     = draft_number ~ sequential_date,
  data        = draftlottery,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "draft_number" ~ "sequential_date":
#> • n = 366
#> • Observed correlation (r) = -0.226
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 366
#> • Observed Correlation (r): -0.226
#> • SD of Null Distribution: 0.14
#> • Test Statistic (T): -4.4272
#> • Degrees of Freedom: 364
#> • P-Value: 0
```
