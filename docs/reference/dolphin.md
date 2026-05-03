# Dolphin-Assisted Therapy

Results from a randomized experiment testing whether swimming with
dolphins improves outcomes for patients with mild-to-moderate
depression. Participants were assigned to either swim with dolphins or
swim without them (control). Used in Chapter 5 of ISI for two-proportion
inference.

## Usage

``` r
dolphin
```

## Format

A data frame with 30 rows and 2 variables:

- swimming:

  Treatment assignment: `"Dolphin"` or `"Control"`

- response:

  Outcome: `"Improve"` or `"NotImprove"`

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(dolphin)
#> # A tibble: 6 × 2
#>   swimming response
#>   <chr>    <chr>   
#> 1 Dolphin  Improve 
#> 2 Dolphin  Improve 
#> 3 Dolphin  Improve 
#> 4 Dolphin  Improve 
#> 5 Dolphin  Improve 
#> 6 Dolphin  Improve 
test_2prop(
  formula       = response ~ swimming,
  data          = dolphin,
  success_level = "Improve",
  alternative   = "greater",
  method        = "simulation"
)
#> ✔ Data extracted from "response" ~ "swimming":
#> • Dolphin: 10 successes out of 15
#> • Control: 3 successes out of 15
#> ℹ Success level: "Improve"
#> 
#> ── 2-Sample Proportions Hypothesis Test (Simulation) ───────────────────────────
#> ℹ Dolphin: p1-hat = 0.6667 (successes = 10, n = 15)
#> ℹ Control: p2-hat = 0.2 (successes = 3, n = 15)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 > 0
#> • Observed Difference (p1-hat - p2-hat): 0.4667
#> • SD of Null Distribution: 0.1829
#> • Test Statistic (Z_sim): 2.551
#> • P-Value: 0.007
ci_2prop(
  formula       = response ~ swimming,
  data          = dolphin,
  success_level = "Improve",
  conf_level    = 0.95,
  method        = "theory"
)
#> ✔ Data extracted from "response" ~ "swimming":
#> • Dolphin: 10 successes out of 15
#> • Control: 3 successes out of 15
#> ℹ Success level: "Improve"
#> Warning: ! Validity conditions for the theory-based interval may not be met.
#> ℹ All four cells in the 2x2 table must have at least 10 observations.
#> ℹ Minimum cell count found: 3.
#> ℹ Consider using `method = "2SD"` or `method = "simulation"` instead.
#> 
#> ── 95% Confidence Interval for Difference in Proportions (Theory) ──────────────
#> ℹ Dolphin: p-hat1 = 0.6667 (successes = 10, n = 15)
#> ℹ Control: p-hat2 = 0.2 (successes = 3, n = 15)
#> ℹ Point Estimate (p-hat1 - p-hat2): 0.4667
#> ℹ SD of Sampling Distribution: 0.1596
#> • Interval: (0.1538, 0.7795)
#> Warning: ! Validity conditions may not be met -- at least one cell has fewer than 10
#>   observations.
#> ℹ Minimum cell count: 3.
#> ℹ Consider using `method = "2SD"` or `method = "simulation"`.
```
