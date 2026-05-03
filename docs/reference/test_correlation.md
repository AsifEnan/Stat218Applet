# Correlation Hypothesis Test

Tests whether the linear association between two quantitative variables
is statistically significant – that is, whether the true population
correlation coefficient (\\\rho\\, pronounced "rho") is different from
zero.

This function accepts input in **two ways**:

- **Summary Statistics:** You already know the observed correlation
  coefficient and the sample size (common in textbook problems where
  results are summarized for you). Pass `r_obs` and `n` directly.

- **Raw Data:** You have an actual dataset loaded into R. Pass `formula`
  and `data` instead, using a two-sided formula of the form
  `response ~ explanatory`, and the function will compute the
  correlation for you automatically.

## Usage

``` r
test_correlation(
  r_obs = NULL,
  n = NULL,
  formula = NULL,
  data = NULL,
  alternative = "two.sided",
  method = "theory",
  sim_reps = 1000
)
```

## Arguments

- r_obs:

  The observed sample correlation coefficient (a number between -1 and
  1). For example, if the correlation between height and weight in your
  sample was 0.72, use `r_obs = 0.72`. **Only used when NOT providing
  `formula` and `data`.**

- n:

  A whole number representing the total number of paired observations in
  your sample. For example, if you measured 40 pairs of (x, y) values,
  use `n = 40`. **Only used when NOT providing `formula` and `data`.**

- formula:

  A two-sided formula of the form `response ~ explanatory` identifying
  the two numeric variables to correlate. For example,
  `formula = heart_rate ~ body_temp` where both columns exist in `data`.
  **Only used when NOT providing `r_obs` and `n`.**

- data:

  A data frame containing the variables named in `formula`. **Only used
  when NOT providing `r_obs` and `n`.**

- alternative:

  The direction of the alternative hypothesis (H\\\_a\\). Must be one
  of:

  `"two.sided"`

  :   H\\\_a\\: \\\rho \neq 0\\ (default) – use when testing whether the
      correlation is *different from* zero in either direction.

  `"greater"`

  :   H\\\_a\\: \\\rho \> 0\\ – use when testing whether there is a
      *positive* linear association.

  `"less"`

  :   H\\\_a\\: \\\rho \< 0\\ – use when testing whether there is a
      *negative* linear association.

- method:

  The method used to calculate the p-value. Must be one of:

  `"theory"`

  :   (default) Converts the observed correlation to a T-statistic and
      uses a T-distribution with \\df = n - 2\\ to compute the p-value.
      Appropriate when both variables are roughly normally distributed
      and the relationship appears linear.

  `"simulation"`

  :   Uses a randomization test. The response variable is repeatedly
      shuffled to break any existing relationship, and the correlation
      is recomputed each time to build a null distribution centered at
      \\\rho = 0\\. Requires raw data via `formula` and `data`.

- sim_reps:

  The number of shuffles to perform when `method = "simulation"`.
  Default is `1000`. Increasing to `5000` or `10000` gives a more stable
  p-value estimate.

## Value

An S3 object of class `stat218_test_correlation` containing all computed
values. You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary including the observed correlation, test
  statistic, degrees of freedom, and p-value.

- `plot(result)`:

  Plots the null distribution (simulated or theoretical T-curve) with
  orange shaded tail(s), p-value annotation, and the SD of the Null
  Distribution labeled on the plot.

- `plot_steps(result)`:

  Displays a detailed three-panel step-by-step interpretation with
  proper fraction notation – great for checking your work or studying
  before an exam.

## Details

### The Core Idea

In a correlation test, we are asking: *"Is the linear association we
observed between two variables in our sample strong enough to conclude
that a real relationship exists in the population, or could it have
happened by random chance even if \\\rho = 0\\?"*

The null hypothesis is always H\\\_0\\: \\\rho = 0\\ – no linear
association between the two variables in the population.

### Theory Method

When `method = "theory"`, the observed correlation \\r\\ is converted to
a T-statistic using the formula: \$\$t = r \cdot \sqrt{\frac{n - 2}{1 -
r^2}}\$\$ This T-statistic follows a T-distribution with \\df = n - 2\\
under the null hypothesis.

### Simulation Method (Randomization Test)

When `method = "simulation"`, the response variable is shuffled
repeatedly to destroy any real relationship while keeping the
explanatory variable fixed. Each shuffle produces a simulated
correlation under the null hypothesis of \\\rho = 0\\. The proportion of
simulated correlations as extreme as the observed one is the p-value.
Requires raw data via `formula` and `data`.

### Validity Conditions (Theory Method)

The theory-based method is appropriate when:

- Both variables are roughly normally distributed (or \\n\\ is large)

- The relationship between the two variables appears linear (check a
  scatterplot first using
  [`explore_2vars()`](https://asifenan.github.io/Stat218Applet/reference/explore_2vars.md))

- There are no severe outliers

## Examples

``` r
# --- Summary Statistics Path (two-sided, theory) ---
# Observed correlation of 0.54 from 40 pairs of observations.
result <- test_correlation(
  r_obs       = 0.54,
  n           = 40,
  alternative = "two.sided",
  method      = "theory"
)
print(result)
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 40
#> • Observed Correlation (r): 0.54
#> • SD of Null Distribution: 0.1382
#> • Test Statistic (T): 3.955
#> • Degrees of Freedom: 38
#> • P-Value: 3e-04
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Raw Data Path (theory) ---
# Using the tempheart dataset: does heart rate correlate with body temperature?
result2 <- test_correlation(
  formula     = heart_rate ~ body_temp,
  data        = tempheart,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Data extracted from "heart_rate" ~ "body_temp":
#> • n = 130
#> • Observed correlation (r) = 0.2537
print(result2)
#> 
#> ── Correlation Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 130
#> • Observed Correlation (r): 0.2537
#> • SD of Null Distribution: 0.1396
#> • Test Statistic (T): 2.9668
#> • Degrees of Freedom: 128
#> • P-Value: 0.0036
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Raw Data Path (simulation) ---
result3 <- test_correlation(
  formula     = heart_rate ~ body_temp,
  data        = tempheart,
  alternative = "two.sided",
  method      = "simulation",
  sim_reps    = 5000
)
#> ✔ Data extracted from "heart_rate" ~ "body_temp":
#> • n = 130
#> • Observed correlation (r) = 0.2537
print(result3)
#> 
#> ── Correlation Hypothesis Test (Simulation) ────────────────────────────────────
#> ℹ Null Hypothesis: rho = 0
#> ℹ Alternative: rho != 0
#> • Sample Size (n): 130
#> • Observed Correlation (r): 0.2537
#> • SD of Null Distribution: 0.0869
#> • Test Statistic (T): 2.9668
#> • Degrees of Freedom: 128
#> • P-Value: 0.0032
if (FALSE) { # \dontrun{
plot(result3)
} # }
```
