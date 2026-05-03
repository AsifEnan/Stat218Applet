# Jumping Jacks vs. Bicycle Calories Burned

Calories burned by participants doing jumping jacks versus riding a
stationary bicycle. Each participant completed both exercises, making
this a paired design. Used in Chapter 7 of ISI to introduce the paired
T-test.

## Usage

``` r
jjvsbicycle
```

## Format

A data frame with 22 rows and 2 variables:

- jj:

  Calories burned doing jumping jacks

- bicycle:

  Calories burned riding a stationary bicycle

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(jjvsbicycle)
#> # A tibble: 6 × 2
#>      jj bicycle
#>   <dbl>   <dbl>
#> 1   118     118
#> 2   146     124
#> 3   134      92
#> 4    94      80
#> 5   146     111
#> 6   114     112
test_paired(
  formula     = bicycle ~ jj,
  data        = jjvsbicycle,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Differences computed as "bicycle" minus "jj".
#> • Number of pairs (n_d): 22
#> 
#> ── Paired Data Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Mean Difference (x-bar_d): -11.9545
#> ℹ SD of Differences (s_d): 20.0985
#> ℹ Number of Pairs (n_d): 22
#> ℹ Null Hypothesis: mu_d = 0
#> ℹ Alternative: mu_d != 0
#> • SD of Null Distribution: 4.285
#> • Test Statistic (T): -2.79
#> • P-Value: 0.011
```
