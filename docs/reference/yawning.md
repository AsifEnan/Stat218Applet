# Yawning Contagion Experiment

Data from a MythBusters episode testing whether yawning is contagious.
Participants were either exposed to a yawn seed or placed in a control
condition, then observed for whether they yawned. Used in Chapter 5 of
ISI for two-proportion inference and to discuss randomization.

## Usage

``` r
yawning
```

## Format

A data frame with 50 rows and 2 variables:

- yawn_seed:

  Whether the participant saw someone yawn: `"Seeded"` or `"Control"`

- response:

  Whether the participant yawned: `"Yawn"` or `"NoYawn"`

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(yawning)
#> # A tibble: 6 × 2
#>   yawn_seed response
#>   <chr>     <chr>   
#> 1 Seeded    Yawn    
#> 2 Seeded    Yawn    
#> 3 Seeded    Yawn    
#> 4 Seeded    Yawn    
#> 5 Seeded    Yawn    
#> 6 Seeded    Yawn    
test_2prop(
  formula       = response ~ yawn_seed,
  data          = yawning,
  success_level = "Yawn",
  alternative   = "two.sided",
  method        = "simulation"
)
#> ✔ Data extracted from "response" ~ "yawn_seed":
#> • Seeded: 11 successes out of 34
#> • Control: 3 successes out of 16
#> ℹ Success level: "Yawn"
#> 
#> ── 2-Sample Proportions Hypothesis Test (Simulation) ───────────────────────────
#> ℹ Seeded: p1-hat = 0.3235 (successes = 11, n = 34)
#> ℹ Control: p2-hat = 0.1875 (successes = 3, n = 16)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 != 0
#> • Observed Difference (p1-hat - p2-hat): 0.136
#> • SD of Null Distribution: 0.1358
#> • Test Statistic (Z_sim): 1.002
#> • P-Value: 0.48
```
