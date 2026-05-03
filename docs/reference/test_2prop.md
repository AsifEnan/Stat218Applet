# 2-Sample Proportions Hypothesis Test

Tests whether two population proportions are equal (\\\pi_1 = \pi_2\\)
using either a simulation-based approach (Randomization Test) or a
theory-based Z-test using a pooled proportion.

This function accepts input in **two ways**:

- **Summary Statistics:** You already know the number of successes and
  sample sizes for both groups (common in textbook homework problems).
  Pass `success_1`, `n_1`, `success_2`, and `n_2` directly.

- **Raw Data:** You have an actual dataset loaded into R (common in
  activities and projects). Pass `formula`, `data`, and `success_level`
  instead, and the function will extract the group counts for you.

## Usage

``` r
test_2prop(
  success_1 = NULL,
  n_1 = NULL,
  success_2 = NULL,
  n_2 = NULL,
  group_names = NULL,
  formula = NULL,
  data = NULL,
  success_level = NULL,
  alternative = "two.sided",
  method = "theory",
  sim_reps = 1000
)
```

## Arguments

- success_1:

  A whole number representing the count of successes in Group 1. For
  example, if 45 out of 100 patients in the treatment group recovered,
  `success_1 = 45`. **Only used when NOT providing `formula` and
  `data`.**

- n_1:

  A whole number representing the total sample size of Group 1. **Only
  used when NOT providing `formula` and `data`.**

- success_2:

  A whole number representing the count of successes in Group 2. For
  example, if 25 out of 100 patients in the placebo group recovered,
  `success_2 = 25`. **Only used when NOT providing `formula` and
  `data`.**

- n_2:

  A whole number representing the total sample size of Group 2. **Only
  used when NOT providing `formula` and `data`.**

- group_names:

  A character vector of length 2 giving meaningful names to the two
  groups. For example, `group_names = c("Treatment", "Placebo")`.
  Defaults to `c("Group 1", "Group 2")`. When using raw data, group
  names are extracted automatically from the grouping variable. **Only
  used when NOT providing `formula` and `data`.**

- formula:

  A two-sided formula of the form `Response ~ Group` that identifies the
  response (categorical outcome) variable and the grouping variable in
  your dataset. For example, `formula = Recovered ~ Treatment` where
  `Recovered` is the outcome and `Treatment` defines the two groups.
  **Only used when NOT providing summary statistics.**

- data:

  A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file) that
  contains the variables named in `formula`. **Only used when NOT
  providing summary statistics.**

- success_level:

  A character string specifying which value of the response variable
  counts as a "success". For example, if the response variable contains
  `"Yes"` and `"No"`, use `success_level = "Yes"`. This argument is
  **required** when using `formula` and `data`.

- alternative:

  The direction of the alternative hypothesis (H\\\_a\\). Must be one
  of:

  `"two.sided"`

  :   H\\\_a\\: \\\pi_1 - \pi_2 \neq 0\\ (default) – use when testing if
      the two proportions are simply *different*.

  `"greater"`

  :   H\\\_a\\: \\\pi_1 - \pi_2 \> 0\\ – use when testing if Group 1's
      proportion is *greater than* Group 2's.

  `"less"`

  :   H\\\_a\\: \\\pi_1 - \pi_2 \< 0\\ – use when testing if Group 1's
      proportion is *less than* Group 2's.

- method:

  The method used to calculate the p-value. Must be one of:

  `"theory"`

  :   (default) Uses the traditional two-proportion Z-test with a pooled
      proportion. Appropriate when all four cells in the 2x2 contingency
      table have at least 10 observations.

  `"simulation"`

  :   Uses a Randomization Test (Shuffling the Deck). All successes and
      failures are pooled together and repeatedly re-dealt into the two
      group sizes, simulating the null hypothesis of no difference. More
      flexible than theory when cell counts are small.

- sim_reps:

  The number of randomization shuffles when `method = "simulation"`.
  Default is `1000`. Increasing to `5000` gives a more stable p-value
  estimate.

## Value

An S3 object of class `stat218_2prop` containing all computed values.
You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary including both sample proportions, the
  observed difference, SD of null distribution, test statistic, and
  p-value.

- `plot(result)`:

  Shows a beautified 2x2 contingency table alongside the null
  distribution plot with shaded p-value region(s) and SD of Null
  Distribution annotated.

- `plot_steps(result)`:

  Displays a detailed three-panel step-by-step interpretation with
  proper fraction notation.

## Details

### The Core Idea

In a two-sample proportion test, we ask: *"Is the difference in
proportions we observed between two groups consistent with random
chance, or is there real evidence that the two population proportions
are different?"*

The null hypothesis always takes the form H\\\_0\\: \\\pi_1 - \pi_2 =
0\\, meaning we assume no difference between the two population
proportions.

### Simulation Method (Randomization Test)

We simulate the null hypothesis by pooling all successes and failures
together and repeatedly shuffling them back into the two group sizes.
Each shuffle gives a new simulated difference in proportions. The SD of
that simulated null distribution goes in the denominator of the test
statistic. The p-value is the proportion of shuffles that produced a
difference as extreme as or more extreme than what we observed.

### Theory Method (Pooled Z-Test)

Because the null hypothesis assumes \\\pi_1 = \pi_2\\, we estimate the
common proportion using a **pooled proportion**: \$\$\hat{p} =
\frac{\text{success}\_1 + \text{success}\_2}{n_1 + n_2}\$\$ This pooled
proportion is then used to compute the SD of the null distribution:
\$\$SD\_{null} = \sqrt{\hat{p}(1-\hat{p})\left(\frac{1}{n_1} +
\frac{1}{n_2}\right)}\$\$

### Validity Conditions for Theory Method

The theory-based Z-test is reliable when **all four cells** in the 2x2
contingency table have at least 10 observations:

- Successes in Group 1 \\\geq 10\\

- Failures in Group 1 \\\geq 10\\

- Successes in Group 2 \\\geq 10\\

- Failures in Group 2 \\\geq 10\\

A warning is issued automatically if any cell falls below 10.

## Examples

``` r
# --- Summary Statistics Path (two-sided, theory) ---
# A clinical trial: 45 of 100 in treatment recovered vs 25 of 100 placebo.
result <- test_2prop(
  success_1 = 45, n_1 = 100,
  success_2 = 25, n_2 = 100,
  group_names = c("Treatment", "Placebo"),
  alternative = "two.sided", method = "theory"
)
print(result)
#> 
#> ── 2-Sample Proportions Hypothesis Test (Theory) ───────────────────────────────
#> ℹ Treatment: p1-hat = 0.45 (successes = 45, n = 100)
#> ℹ Placebo: p2-hat = 0.25 (successes = 25, n = 100)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 != 0
#> • Observed Difference (p1-hat - p2-hat): 0.2
#> • SD of Null Distribution: 0.0675
#> • Test Statistic (Z): 2.965
#> • P-Value: 0.003
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Summary Statistics Path (one-sided, simulation) ---
# Testing if Group A has a higher success rate than Group B.
result2 <- test_2prop(
  success_1 = 38, n_1 = 80,
  success_2 = 29, n_2 = 80,
  group_names = c("Group A", "Group B"),
  alternative = "greater", method = "simulation"
)
print(result2)
#> 
#> ── 2-Sample Proportions Hypothesis Test (Simulation) ───────────────────────────
#> ℹ Group A: p1-hat = 0.475 (successes = 38, n = 80)
#> ℹ Group B: p2-hat = 0.3625 (successes = 29, n = 80)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 > 0
#> • Observed Difference (p1-hat - p2-hat): 0.1125
#> • SD of Null Distribution: 0.0794
#> • Test Statistic (Z_sim): 1.418
#> • P-Value: 0.077
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Raw Data Path (two-sided, theory) ---
# Using mtcars: does the proportion of manual cars differ by engine type?
car_data <- mtcars
car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
car_data$engine <- ifelse(mtcars$vs == 1, "Straight", "V-shaped")
result3 <- test_2prop(
  formula = transmission ~ engine, data = car_data,
  success_level = "Manual", alternative = "two.sided",
  method = "theory"
)
#> ✔ Data extracted from "transmission" ~ "engine":
#> • V-shaped: 6 successes out of 18
#> • Straight: 7 successes out of 14
#> ℹ Success level: "Manual"
#> Warning: ! Validity conditions for the theory-based Z-test may not be met.
#> ℹ All four cells in the 2x2 table must have at least 10 observations.
#> ℹ Minimum cell count found: 6
#> ℹ Consider using `method = "simulation"` for a more reliable p-value.
print(result3)
#> 
#> ── 2-Sample Proportions Hypothesis Test (Theory) ───────────────────────────────
#> ℹ V-shaped: p1-hat = 0.3333 (successes = 6, n = 18)
#> ℹ Straight: p2-hat = 0.5 (successes = 7, n = 14)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 != 0
#> • Observed Difference (p1-hat - p2-hat): -0.1667
#> • SD of Null Distribution: 0.175
#> • Test Statistic (Z): -0.952
#> • P-Value: 0.3409
#> Warning: ! Validity conditions for the theory-based Z-test may not be met.
#> ℹ All four cells in the 2x2 table must have at least 10 observations.
#> ℹ Minimum cell count found: 6.
#> ℹ Consider using `method = "simulation"` for a more reliable result.
if (FALSE) { # \dontrun{
plot(result3)
plot_steps(result3)
} # }

# --- Raw Data Path (one-sided, simulation) ---
result4 <- test_2prop(
  formula = transmission ~ engine, data = car_data,
  success_level = "Manual", alternative = "greater",
  method = "simulation"
)
#> ✔ Data extracted from "transmission" ~ "engine":
#> • V-shaped: 6 successes out of 18
#> • Straight: 7 successes out of 14
#> ℹ Success level: "Manual"
print(result4)
#> 
#> ── 2-Sample Proportions Hypothesis Test (Simulation) ───────────────────────────
#> ℹ V-shaped: p1-hat = 0.3333 (successes = 6, n = 18)
#> ℹ Straight: p2-hat = 0.5 (successes = 7, n = 14)
#> ℹ Null Hypothesis: pi1 - pi2 = 0
#> ℹ Alternative: pi1 - pi2 > 0
#> • Observed Difference (p1-hat - p2-hat): -0.1667
#> • SD of Null Distribution: 0.1817
#> • Test Statistic (Z_sim): -0.917
#> • P-Value: 0.902
if (FALSE) { # \dontrun{
plot(result4)
plot_steps(result4)
} # }
```
