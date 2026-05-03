# 1-Sample Proportion Confidence Interval

Constructs a confidence interval for a single population proportion
(\\\pi\\) using one of three methods: the 2SD simulation method, a
general simulation method, or a theory-based approach.

This function accepts input in **two ways**:

- **Summary Statistics:** You already know the number of successes and
  the sample size. Pass `successes` and `n` directly.

- **Raw Data:** You have an actual dataset loaded into R. Pass
  `formula`, `data`, and `success_level` instead, and the function
  counts the successes for you automatically.

## Usage

``` r
ci_1prop(
  successes = NULL,
  n = NULL,
  formula = NULL,
  data = NULL,
  success_level = NULL,
  conf_level = 0.95,
  method = "2SD",
  sim_reps = 1000
)
```

## Arguments

- successes:

  A whole number representing the count of successes observed in your
  sample. For example, if 42 out of 80 students passed,
  `successes = 42`. **Only used when NOT providing `formula` and
  `data`.**

- n:

  A whole number representing the total sample size. **Only used when
  NOT providing `formula` and `data`.**

- formula:

  A one-sided formula of the form `~ variable` identifying the
  categorical variable in your dataset. For example,
  `formula = ~ Passed`. **Only used when NOT providing `successes` and
  `n`.**

- data:

  A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
  containing the variable named in `formula`. **Only used when NOT
  providing summary statistics.**

- success_level:

  A character string specifying which value of your categorical variable
  counts as a "success". For example, if your variable contains `"Yes"`
  and `"No"`, use `success_level = "Yes"`. **Required when using
  `formula` and `data`.**

- conf_level:

  The desired confidence level as a decimal. Default is `0.95` for a 95%
  confidence interval. Common choices are `0.90`, `0.95`, and `0.99`.
  Note that `method = "2SD"` only works at `0.95`.

- method:

  The method used to construct the confidence interval. Must be one of:

  `"2SD"`

  :   (default) The 2SD Simulation Method. A bootstrap distribution is
      generated centered at `p_hat` by drawing repeated samples of size
      `n` from a population with proportion `p_hat`. The interval is
      \\\hat{p} \pm 2 \times SD(\hat{p})\\. Only valid for 95%
      confidence. Use `method = "simulation"` for other confidence
      levels.

  `"simulation"`

  :   The Bootstrap Simulation Method. Same bootstrap as 2SD, but uses
      the middle `conf_level`% of the simulated distribution to find
      bounds directly. Works for any confidence level.

  `"theory"`

  :   The Theory-Based Method. Uses the formula \\SE =
      \sqrt{\hat{p}(1-\hat{p})/n}\\ and the appropriate Z\* multiplier.
      Works for any confidence level. Requires validity conditions: at
      least 10 expected successes and 10 expected failures in the
      sample.

- sim_reps:

  The number of bootstrap samples when `method = "2SD"` or
  `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
  a more stable interval.

## Value

An S3 object of class `stat218_1prop_ci` containing all computed values.
You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary of the interval.

- `plot(result)`:

  Shows the bootstrap or theoretical distribution with the confidence
  interval shaded and labeled, plus a forest plot of the interval below.
  Use `plot(result, plot_type = "dotplot")` for a dot plot of the
  bootstrap distribution (simulation methods only).

- `plot_steps(result)`:

  Displays a detailed three-panel step-by-step construction of the
  interval.

## Details

### The Core Idea

A confidence interval gives a range of plausible values for the true
population proportion \\\pi\\. Rather than reporting just \\\hat{p}\\,
we acknowledge sampling variability and say: *"We are X% confident the
true proportion falls somewhere in this range."*

### The 2SD Method

The book's primary simulation-based approach for 95% confidence
intervals. We simulate the sampling distribution of \\\hat{p}\\ by
drawing many bootstrap samples from a population where the true
proportion equals our observed \\\hat{p}\\. The interval is constructed
as \\\hat{p} \pm 2 \times SD\\ of that distribution. The multiplier of 2
is an approximation of the true 1.96 used in theory.

### Theory Method

Uses the formula \\SE = \sqrt{\hat{p}(1-\hat{p})/n}\\ and the
appropriate Z\* multiplier. Requires:

- At least 10 successes in the sample (\\n \cdot \hat{p} \geq 10\\)

- At least 10 failures in the sample (\\n \cdot (1-\hat{p}) \geq 10\\)

## Note

To display the bootstrap distribution as a dotplot instead of a
histogram, use `plot(result, plot_type = "dotplot")` after running this
function. Only available for `method = "2SD"` or
`method = "simulation"`.

## Examples

``` r
# --- Summary Statistics (2SD method, default) ---
result <- ci_1prop(successes = 42, n = 80)
print(result)
#> 
#> ── 95% Confidence Interval (2sd) ───────────────────────────────────────────────
#> ℹ Point Estimate (p-hat): 0.525 (42 successes out of n = 80)
#> ℹ SD of Sampling Distribution: 0.0547
#> • Interval: (0.4155, 0.6345)
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Summary Statistics (theory, 95% CI) ---
result2 <- ci_1prop(successes = 42, n = 80,
                    conf_level = 0.95, method = "theory")
print(result2)
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (p-hat): 0.525 (42 successes out of n = 80)
#> ℹ SD of Sampling Distribution: 0.0558
#> • Interval: (0.4156, 0.6344)
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Summary Statistics (simulation, 90% CI) ---
result3 <- ci_1prop(successes = 42, n = 80,
                    conf_level = 0.90, method = "simulation")
print(result3)
#> 
#> ── 90% Confidence Interval (Simulation) ────────────────────────────────────────
#> ℹ Point Estimate (p-hat): 0.525 (42 successes out of n = 80)
#> ℹ SD of Sampling Distribution: 0.0565
#> • Interval: (0.425, 0.625)
if (FALSE) { # \dontrun{
plot(result3)
plot_steps(result3)
} # }

# --- Raw Data (2SD method) ---
car_data <- mtcars
car_data$transmission <- ifelse(mtcars$am == 1, "Manual", "Automatic")
result4 <- ci_1prop(formula = ~ transmission, data = car_data,
                    success_level = "Manual", method = "2SD")
#> ✔ Data extracted from variable "transmission":
#> • Success level: "Manual"
#> • Successes: 13 | Sample size (n): 32
print(result4)
#> 
#> ── 95% Confidence Interval (2sd) ───────────────────────────────────────────────
#> ℹ Point Estimate (p-hat): 0.4062 (13 successes out of n = 32)
#> ℹ SD of Sampling Distribution: 0.0856
#> • Interval: (0.2351, 0.5774)
if (FALSE) { # \dontrun{
plot(result4)
plot_steps(result4)
} # }

# --- Raw Data (theory) ---
result5 <- ci_1prop(formula = ~ transmission, data = car_data,
                    success_level = "Manual", method = "theory")
#> ✔ Data extracted from variable "transmission":
#> • Success level: "Manual"
#> • Successes: 13 | Sample size (n): 32
print(result5)
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (p-hat): 0.4062 (13 successes out of n = 32)
#> ℹ SD of Sampling Distribution: 0.0868
#> • Interval: (0.2361, 0.5764)
if (FALSE) { # \dontrun{
plot(result5)
plot_steps(result5)
} # }
```
