# Simple Linear Regression Hypothesis Test (Slope)

Tests whether the slope of a simple linear regression model is
statistically significantly different from zero – that is, whether the
explanatory variable has a real linear effect on the response variable
in the population.

This function accepts input in **two ways**:

- **Summary Statistics:** You already know the observed slope, its
  standard error, and the sample size (common in textbook problems where
  regression output is summarized for you). Pass `slope`, `se`, and `n`
  directly.

- **Raw Data:** You have an actual dataset loaded into R. Pass `formula`
  and `data` instead, using a two-sided formula of the form
  `response ~ explanatory`, and the function will fit the regression
  model and extract all values automatically.

## Usage

``` r
test_regression(
  slope = NULL,
  se = NULL,
  n = NULL,
  formula = NULL,
  data = NULL,
  alternative = "two.sided",
  method = "theory",
  sim_reps = 1000
)
```

## Arguments

- slope:

  The observed sample slope (\\b_1\\) from the fitted regression model.
  For example, if the slope of the regression line relating study hours
  to GPA was 0.12, use `slope = 0.12`. **Only used when NOT providing
  `formula` and `data`.**

- se:

  The standard error of the slope (\\SE\_{b_1}\\) from the regression
  output. This measures how much the slope estimate would vary across
  repeated samples. For example, `se = 0.034`. **Only used when NOT
  providing `formula` and `data`.**

- n:

  A whole number representing the total number of paired observations
  used to fit the model. For example, if you used 42 data points, use
  `n = 42`. **Only used when NOT providing `formula` and `data`.**

- formula:

  A two-sided formula of the form `response ~ explanatory` identifying
  the response (y) and explanatory (x) variables in your dataset. For
  example, `formula = gpa ~ hours` where both columns exist in `data`.
  The function fits the regression model automatically. **Only used when
  NOT providing `slope`, `se`, and `n`.**

- data:

  A data frame containing the variables named in `formula`. **Only used
  when NOT providing `slope`, `se`, and `n`.**

- alternative:

  The direction of the alternative hypothesis (H\\\_a\\). Must be one
  of:

  `"two.sided"`

  :   H\\\_a\\: \\\beta_1 \neq 0\\ (default) – use when testing whether
      the slope is *different from* zero in either direction.

  `"greater"`

  :   H\\\_a\\: \\\beta_1 \> 0\\ – use when testing whether the slope is
      *positive* (response increases as explanatory increases).

  `"less"`

  :   H\\\_a\\: \\\beta_1 \< 0\\ – use when testing whether the slope is
      *negative* (response decreases as explanatory increases).

- method:

  The method used to calculate the p-value. Must be one of:

  `"theory"`

  :   (default) Uses the T-statistic \\t = b_1 / SE\_{b_1}\\ and a
      T-distribution with \\df = n - 2\\ to compute the p-value.
      Appropriate when the residuals of the regression model are roughly
      normally distributed and the relationship appears linear.

  `"simulation"`

  :   Uses a randomization test. The response variable is repeatedly
      shuffled to break any linear relationship, and the slope is
      recomputed each time to build a null distribution centered at
      \\\beta_1 = 0\\. Requires raw data via `formula` and `data`.

- sim_reps:

  The number of shuffles to perform when `method = "simulation"`.
  Default is `1000`. Increasing to `5000` or `10000` gives a more stable
  p-value estimate.

## Value

An S3 object of class `stat218_test_regression` containing all computed
values. You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary including the observed slope, standard error,
  test statistic, degrees of freedom, and p-value.

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

In a regression slope test, we are asking: *"Is the slope we estimated
from our sample large enough to conclude that a real linear relationship
exists in the population, or could a slope this large have occurred just
by random chance even if \\\beta_1 = 0\\?"*

The null hypothesis is always H\\\_0\\: \\\beta_1 = 0\\ – no linear
relationship between the explanatory and response variable in the
population.

### Theory Method

When `method = "theory"`, the T-statistic is: \$\$t = \frac{b_1 -
0}{SE\_{b_1}}\$\$ This follows a T-distribution with \\df = n - 2\\
under the null hypothesis. The standard error \\SE\_{b_1}\\ measures how
much the slope estimate varies across repeated samples.

### Simulation Method (Randomization Test)

When `method = "simulation"`, the response variable is shuffled
repeatedly to destroy any linear relationship while keeping the
explanatory variable fixed. Each shuffle produces a simulated slope
under the null hypothesis. The proportion of simulated slopes as extreme
as the observed slope is the p-value. Requires raw data via `formula`
and `data`.

### Validity Conditions (Theory Method)

The theory-based method is appropriate when:

- The relationship between the two variables is linear (check a
  scatterplot first using
  [`explore_2vars()`](https://asifenan.github.io/Stat218Applet/reference/explore_2vars.md))

- The residuals from the fitted model are roughly normally distributed

- The sample size is at least 20, or the residuals are clearly normal

## Examples

``` r
# --- Summary Statistics Path (two-sided, theory) ---
# Regression output shows slope = 0.12, SE = 0.034, n = 42
result <- test_regression(
  slope       = 0.12,
  se          = 0.034,
  n           = 42,
  alternative = "two.sided",
  method      = "theory"
)
print(result)
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 != 0
#> • Sample Size (n): 42
#> • Observed Slope (b1): 0.12
#> • Standard Error (SE): 0.034
#> • SD of Null Distribution: 0.034
#> • Test Statistic (T): 3.5294
#> • Degrees of Freedom: 40
#> • P-Value: 0.0011
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Raw Data Path (theory) ---
# Using the gpa dataset: does study hours predict GPA?
result2 <- test_regression(
  formula     = gpa ~ hours,
  data        = gpa,
  alternative = "greater",
  method      = "theory"
)
#> ✔ Regression of "gpa" ~ "hours":
#> • n = 42
#> • Observed Slope (b1) = -0.0059
#> • Standard Error (SE) = 0.0031
print(result2)
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 > 0
#> • Sample Size (n): 42
#> • Observed Slope (b1): -0.0059
#> • Standard Error (SE): 0.0031
#> • SD of Null Distribution: 0.0031
#> • Test Statistic (T): -1.9166
#> • Degrees of Freedom: 40
#> • P-Value: 0.9688
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Raw Data Path (simulation) ---
result3 <- test_regression(
  formula     = gpa ~ hours,
  data        = gpa,
  alternative = "greater",
  method      = "simulation",
  sim_reps    = 5000
)
#> ✔ Regression of "gpa" ~ "hours":
#> • n = 42
#> • Observed Slope (b1) = -0.0059
#> • Standard Error (SE) = 0.0031
print(result3)
#> 
#> ── Regression Slope Hypothesis Test (Simulation) ───────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 > 0
#> • Sample Size (n): 42
#> • Observed Slope (b1): -0.0059
#> • Standard Error (SE): 0.0031
#> • SD of Null Distribution: 0.0031
#> • Test Statistic (T): -1.8793
#> • Degrees of Freedom: 40
#> • P-Value: 0.97
if (FALSE) { # \dontrun{
plot(result3)
} # }
```
