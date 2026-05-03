# Nurse Gilbert Shift and Patient Deaths

Data from the criminal trial of nurse Kristen Gilbert, who was accused
of causing patient deaths. Each row records whether Gilbert was working
and whether a patient died during a shift. Used in Chapter 5 of ISI as a
compelling real-world example of two-proportion inference – was the
death rate significantly higher on Gilbert's shifts?

## Usage

``` r
gilbert
```

## Format

A data frame with 1641 rows and 2 variables:

- gilbert_worked:

  Whether Gilbert was on shift: `"Yes"` or `"No"`

- patient:

  Patient outcome: `"Death"` or `"NoDeath"`

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(gilbert)
#> # A tibble: 6 × 2
#>   gilbert_worked patient
#>   <chr>          <chr>  
#> 1 Yes            Death  
#> 2 Yes            Death  
#> 3 Yes            Death  
#> 4 Yes            Death  
#> 5 Yes            Death  
#> 6 Yes            Death  
test_2prop(
  formula       = patient ~ gilbert_worked,
  data          = gilbert,
  success_level = "Death",
  alternative   = "greater",
  method        = "theory"
)
#> ✔ Data extracted from "patient" ~ "gilbert_worked":
#> • Yes: 40 successes out of 257
#> • No: 34 successes out of 1384
#> ℹ Success level: "Death"
#> 
#> ── 2-Sample Proportions Hypothesis Test (Theory) ───────────────────────────────
#> ℹ Yes: p1-hat = 0.1556 (successes = 40, n = 257)
#> ℹ No: p2-hat = 0.0246 (successes = 34, n = 1384)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 > 0
#> • Observed Difference (p1-hat - p2-hat): 0.1311
#> • SD of Null Distribution: 0.0141
#> • Test Statistic (Z): 9.3
#> • P-Value: 0
ci_2prop(
  formula       = patient ~ gilbert_worked,
  data          = gilbert,
  success_level = "Death",
  conf_level    = 0.95,
  method        = "theory"
)
#> ✔ Data extracted from "patient" ~ "gilbert_worked":
#> • Yes: 40 successes out of 257
#> • No: 34 successes out of 1384
#> ℹ Success level: "Death"
#> 
#> ── 95% Confidence Interval for Difference in Proportions (Theory) ──────────────
#> ℹ Yes: p-hat1 = 0.1556 (successes = 40, n = 257)
#> ℹ No: p-hat2 = 0.0246 (successes = 34, n = 1384)
#> ℹ Point Estimate (p-hat1 - p-hat2): 0.1311
#> ℹ SD of Sampling Distribution: 0.023
#> • Interval: (0.086, 0.1761)
```
