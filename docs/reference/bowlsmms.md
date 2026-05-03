# M&Ms Eaten from Small vs. Large Bowl

Number of M&Ms eaten by participants when served from a small versus a
large bowl. Each participant experienced both conditions, making this a
paired design. Used in Chapter 7 of ISI for paired inference. A fun
example illustrating how container size affects consumption.

## Usage

``` r
bowlsmms
```

## Format

A data frame with 17 rows and 2 variables:

- small:

  Number of M&Ms eaten from the small bowl

- large:

  Number of M&Ms eaten from the large bowl

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(bowlsmms)
#> # A tibble: 6 × 2
#>   small large
#>   <dbl> <dbl>
#> 1    33    41
#> 2    24    92
#> 3    35    61
#> 4    24    19
#> 5    40    21
#> 6    33    35
test_paired(
  formula     = large ~ small,
  data        = bowlsmms,
  alternative = "greater",
  method      = "theory"
)
#> ✔ Differences computed as "large" minus "small".
#> • Number of pairs (n_d): 17
#> Warning: ! Validity conditions for the theory-based T-test may not be met.
#> ℹ There are only 17 pairs, which is fewer than 20.
#> ℹ Proceed only if the distribution of differences is roughly symmetric.
#> ℹ Otherwise consider using `method = "simulation"` if raw data is available.
#> 
#> ── Paired Data Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Mean Difference (x-bar_d): 10.8824
#> ℹ SD of Differences (s_d): 36.3006
#> ℹ Number of Pairs (n_d): 17
#> ℹ Null Hypothesis: mu_d = 0
#> ℹ Alternative: mu_d > 0
#> • SD of Null Distribution: 8.8042
#> • Test Statistic (T): 1.236
#> • P-Value: 0.1171
#> Warning: ! Validity conditions may not be met -- fewer than 20 pairs (n_d = 17).
#> ℹ Verify that the distribution of differences is roughly symmetric.
#> ℹ Consider using `method = "simulation"` if raw data is available.
```
