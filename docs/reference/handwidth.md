# Hand Width and Perceived Weight

Hand width measurements and perceived weight ratings from a study on
sensory perception. Used in Chapter 10 of ISI for regression and
correlation. Explores whether people with wider hands perceive objects
as heavier.

## Usage

``` r
handwidth
```

## Format

A data frame with 46 rows and 2 variables:

- hand_width:

  Hand width (cm)

- perceived_weight:

  Perceived weight rating (higher = heavier)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(handwidth)
#> # A tibble: 6 × 2
#>   hand_width perceived_weight
#>        <dbl>            <dbl>
#> 1        7.4             75.2
#> 2        7.4             83.6
#> 3        7.4             86.2
#> 4        7.4             92.6
#> 5        7.4             98.1
#> 6        7.4             99.2
explore_2vars(formula = perceived_weight ~ hand_width, data = handwidth)

test_correlation(
  formula     = perceived_weight ~ hand_width,
  data        = handwidth,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "perceived_weight" ~ "hand_width":
#> • n = 46
#> • Observed correlation (r) = -0.3037
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 46
#> • Observed Correlation (r): -0.3037
#> • SD of Null Distribution: 0.1384
#> • Test Statistic (T): -2.1143
#> • Degrees of Freedom: 44
#> • P-Value: 0.0402
```
