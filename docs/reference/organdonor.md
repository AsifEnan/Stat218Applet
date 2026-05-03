# Organ Donor Default Choice

Data from the Preliminaries of ISI. Researchers studied whether the
default option on a donor registration form (opt-in, opt-out, or
neutral) affects whether people choose to become organ donors. A classic
example for introducing the logic of statistical significance and the
role of study design.

## Usage

``` r
organdonor
```

## Format

A data frame with 161 rows and 2 variables:

- default:

  The default condition presented on the form: `"opt-in"`, `"opt-out"`,
  or `"neutral"`

- choice:

  The participant's registration decision: `"donor"` or `"not"`

## Source

<http://www.isi-stats.com/isi/>

## Note

Because `default` has three levels, filter to two groups before using
with
[`test_2prop()`](https://asifenan.github.io/Stat218Applet/reference/test_2prop.md)
or
[`ci_2prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_2prop.md).
For example:
`organdonor_sub <- organdonor[organdonor$default != "neutral", ]`

## Examples

``` r
head(organdonor)
#> # A tibble: 6 × 2
#>   default choice
#>   <chr>   <chr> 
#> 1 opt-in  donor 
#> 2 opt-in  donor 
#> 3 opt-in  donor 
#> 4 opt-in  donor 
#> 5 opt-in  donor 
#> 6 opt-in  donor 
table(organdonor$default, organdonor$choice)
#>          
#>           donor not
#>   neutral    44  12
#>   opt-in     23  32
#>   opt-out    41   9

# Filter to two groups before running a two-proportion test
two_groups <- organdonor[organdonor$default != "neutral", ]
test_2prop(
  formula       = choice ~ default,
  data          = two_groups,
  success_level = "donor",
  alternative   = "two.sided",
  method        = "theory"
)
#> ✔ Data extracted from "choice" ~ "default":
#> • opt-in: 23 successes out of 55
#> • opt-out: 41 successes out of 50
#> ℹ Success level: "donor"
#> Warning: ! Validity conditions for the theory-based Z-test may not be met.
#> ℹ All four cells in the 2x2 table must have at least 10 observations.
#> ℹ Minimum cell count found: 9
#> ℹ Consider using `method = "simulation"` for a more reliable p-value.
#> 
#> ── 2-Sample Proportions Hypothesis Test (Theory) ───────────────────────────────
#> ℹ opt-in: p1-hat = 0.4182 (successes = 23, n = 55)
#> ℹ opt-out: p2-hat = 0.82 (successes = 41, n = 50)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 != 0
#> • Observed Difference (p1-hat - p2-hat): -0.4018
#> • SD of Null Distribution: 0.0953
#> • Test Statistic (Z): -4.215
#> • P-Value: 0
#> Warning: ! Validity conditions for the theory-based Z-test may not be met.
#> ℹ All four cells in the 2x2 table must have at least 10 observations.
#> ℹ Minimum cell count found: 9.
#> ℹ Consider using `method = "simulation"` for a more reliable result.
```
