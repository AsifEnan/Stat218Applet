# Alcohol Consumption and Smoking Status

Self-reported weekly alcohol consumption and smoking status from a large
health survey of 863 respondents. Useful for exploring the association
between a quantitative variable (drinks per week) and a binary coded
variable (ever smoked). Chapter 5 and 10 of ISI.

## Usage

``` r
alcoholsmoke
```

## Format

A data frame with 863 rows and 2 variables:

- alcohol_drinks:

  Number of alcoholic drinks consumed per week

- smoked:

  Whether the respondent has ever smoked: `0` = No, `1` = Yes

## Source

<http://www.isi-stats.com/isi/>

## Note

The `smoked` variable is coded numerically (0/1). Convert to a character
variable for use with two-proportion functions:
`alcoholsmoke$smoked_f <- ifelse(alcoholsmoke$smoked == 1, "Yes", "No")`

## Examples

``` r
head(alcoholsmoke)
#> # A tibble: 6 × 2
#>   alcohol_drinks smoked
#>            <dbl>  <dbl>
#> 1              0      0
#> 2              2      0
#> 3              0      0
#> 4              3      0
#> 5              3      0
#> 6              0      0
alcoholsmoke$smoked_f <- ifelse(alcoholsmoke$smoked == 1, "Yes", "No")
test_1prop(
  formula       = ~ smoked_f,
  data          = alcoholsmoke,
  success_level = "Yes",
  null_pi       = 0.25,
  alternative   = "two.sided",
  method        = "theory"
)
#> ✔ Data extracted from variable "smoked_f":
#> • Success level : "Yes"
#> • Successes: 22 | Sample size (n): 863
#> 
#> ── 1-Sample Proportion Test (Theory) ───────────────────────────────────────────
#> ℹ Sample Proportion (p-hat): 0.0255 (22/863)
#> ℹ Null Hypothesis (pi0): 0.25
#> ℹ Alternative: two.sided
#> • SD of Null Distribution: 0.0147
#> • Test Statistic (Z): -15.231
#> • P-Value: 0
```
