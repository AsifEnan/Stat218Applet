# Breastfeeding and Child Intelligence

A study comparing General Cognitive Index (GCI) scores between children
who were breastfed and those who were not. Used in Chapter 6 of ISI for
two-mean inference. A good example for discussing confounding and the
distinction between causation and association.

## Usage

``` r
breastfeedintell
```

## Format

A data frame with 322 rows and 2 variables:

- feeding:

  Feeding method: `"Breastfed"` or `"NotBreastfed"`

- gci:

  General Cognitive Index score (higher = better)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(breastfeedintell)
#> # A tibble: 6 × 2
#>   feeding     gci
#>   <chr>     <dbl>
#> 1 Breastfed 127. 
#> 2 Breastfed 125. 
#> 3 Breastfed  99.8
#> 4 Breastfed 105. 
#> 5 Breastfed  97.3
#> 6 Breastfed 131. 
test_2mean(
  formula     = gci ~ feeding,
  data        = breastfeedintell,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "gci" ~ "feeding":
#> • Breastfed: x-bar = 105.3, s = 14.5, n = 237
#> • NotBreastfed: x-bar = 100.9, s = 14, n = 85
#> 
#> ── 2-Sample Means Hypothesis Test (Theory) ─────────────────────────────────────
#> ℹ Breastfed: x-bar = 105.3 | s = 14.5 | n = 237
#> ℹ NotBreastfed: x-bar = 100.9 | s = 14 | n = 85
#> ℹ Null Hypothesis: mu1 - mu2 = 0
#> ℹ Alternative: mu1 - mu2 != 0
#> • Observed Difference (x-bar1 - x-bar2): 4.4
#> • SD of Null Distribution: 1.7869
#> • Test Statistic (T): 2.462
#> • P-Value: 0.0149
ci_2mean(
  formula    = gci ~ feeding,
  data       = breastfeedintell,
  conf_level = 0.95,
  method     = "theory"
)
#> ✔ Data extracted from "gci" ~ "feeding":
#> • Breastfed: x-bar = 105.3, s = 14.5, n = 237
#> • NotBreastfed: x-bar = 100.9, s = 14, n = 85
#> 
#> ── 95% Confidence Interval for Difference in Means (Theory) ────────────────────
#> ℹ Breastfed: x-bar = 105.3 | s = 14.5 | n = 237
#> ℹ NotBreastfed: x-bar = 100.9 | s = 14 | n = 85
#> ℹ Point Estimate (x-bar1 - x-bar2): 4.4
#> ℹ SD of Sampling Distribution: 1.7869
#> • Interval: (0.8699, 7.9302)
```
