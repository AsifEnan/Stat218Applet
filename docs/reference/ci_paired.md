# Paired Data Confidence Interval

Constructs a confidence interval for the true mean difference between
paired measurements (\\\mu_d\\) using one of three methods: the 2SD
simulation method, a general simulation method, or a theory-based
T-interval.

Paired data arises when each subject contributes **two related
measurements** – for example, a before/after reading, a left/right
measurement, or two treatments applied to the same subject. Because the
two measurements within each pair are linked, we work with the
**differences** rather than treating the two groups independently.

This function accepts input in **three ways**:

- **Summary Statistics:** You already know the mean difference, standard
  deviation of differences, and number of pairs. Pass `x_bar_d`, `sd_d`,
  and `n_d` directly. Note that `method = "2SD"` and
  `method = "simulation"` are not available with summary statistics.

- **Single Differences Column:** You have a dataset with one column
  containing the pre-computed differences. Use `formula = ~ Differences`
  with your data frame.

- **Two Columns (Before/After):** You have a dataset with two separate
  columns – one for each measurement. Use `formula = After ~ Before` and
  the function computes differences as After minus Before for each pair
  automatically.

## Usage

``` r
ci_paired(
  x_bar_d = NULL,
  sd_d = NULL,
  n_d = NULL,
  formula = NULL,
  data = NULL,
  name = "Differences",
  conf_level = 0.95,
  method = "2SD",
  sim_reps = 1000
)
```

## Arguments

- x_bar_d:

  The observed sample mean of the differences. **Only used when NOT
  providing `formula` and `data`.**

- sd_d:

  The standard deviation of the differences across all pairs. **Only
  used when NOT providing `formula` and `data`.**

- n_d:

  A whole number representing the total number of pairs. **Only used
  when NOT providing `formula` and `data`.**

- formula:

  A formula specifying the data structure. Two formats are accepted:

  `~ Differences`

  :   A one-sided formula when your dataset contains a single column of
      pre-computed differences.

  `After ~ Before`

  :   A two-sided formula when your dataset has two separate measurement
      columns. Differences are computed as After minus Before.

  **Only used when NOT providing `x_bar_d`, `sd_d`, and `n_d`.**

- data:

  A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
  containing the variable(s) named in `formula`. **Only used when NOT
  providing summary statistics.**

- name:

  A short descriptive label for what the differences represent. Used in
  plot axis labels. For example, `name = "After - Before"`. Defaults to
  `"Differences"`.

- conf_level:

  The desired confidence level as a decimal. Default is `0.95` for a 95%
  confidence interval. Common choices are `0.90`, `0.95`, and `0.99`.
  Note that `method = "2SD"` only works at `0.95`.

- method:

  The method used to construct the confidence interval. Must be one of:

  `"2SD"`

  :   (default) The 2SD Simulation Method. Uses a sign-flipping
      bootstrap centered at the observed mean difference. For each
      repetition, a coin is flipped for every pair – heads flips the
      sign of that pair's difference, tails leaves it as is. The
      interval is \\\bar{x}\_d \pm 2 \times SD\\. Can only be used with
      95% confidence interval. Requires raw data.

  `"simulation"`

  :   The Bootstrap Simulation Method. Same sign-flipping bootstrap as
      2SD, but uses the middle `conf_level`% of the simulated
      distribution to find bounds. Works for any confidence level.
      Requires raw data.

  `"theory"`

  :   The Theory-Based T-Interval. Uses the formula SE = s_d / sqrt(n_d)
      and the appropriate t\* multiplier. Works for any confidence level
      and with both summary statistics and raw data. Degrees of freedom
      = n_d - 1, handled automatically.

- sim_reps:

  The number of sign-flipping repetitions when `method = "2SD"` or
  `method = "simulation"`. Default is `1000`.

## Value

An S3 object of class `stat218_ci_paired` containing all computed
values. You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary of the interval.

- `plot(result)`:

  Shows the bootstrap or theoretical distribution with the confidence
  interval shaded and labeled, plus a forest plot of the interval below.

- `plot_steps(result)`:

  Displays a detailed three-panel step-by-step construction of the
  interval with proper fraction notation.

## Details

### The Core Idea

A paired confidence interval gives a range of plausible values for the
true mean difference \\\mu_d\\. An interval entirely above zero suggests
the "After" measurement tends to be higher; entirely below zero suggests
it tends to be lower; an interval containing zero is consistent with no
systematic difference.

### Why Paired and Not Two-Sample?

Because the two measurements within each pair are linked to the same
subject, treating them as independent groups ignores that connection. By
working with differences, we control for subject-to-subject variability
and gain statistical power.

### The 2SD Method (Sign-Flipping Bootstrap)

Under the null hypothesis for a CI, we center the bootstrap at the
observed mean difference. For each repetition, a coin is flipped for
every pair – heads flips the sign of that pair's difference (simulating
the idea that the two measurements are interchangeable), tails leaves it
as is. The SD of the resulting distribution estimates the SE, and the
interval is \\\bar{x}\_d \pm 2 \times SD\\.

### Theory Method

Uses the formula SE = s_d / sqrt(n_d) with the t\* multiplier from the
T-distribution with df = n_d - 1. This is the most reliable approach
when validity conditions are met.

### Validity Conditions

The theory-based T-interval is most reliable when:

- The number of pairs \\n_d \geq 20\\, **or**

- The distribution of the differences is roughly symmetric.

## Examples

``` r
# --- Summary Statistics (theory, default) ---
result <- ci_paired(x_bar_d = 4.2, sd_d = 6.8, n_d = 25,
                    name = "Post - Pre", method = "theory")
print(result)
#> 
#> ── 95% Confidence Interval for Mean Difference (Theory) ────────────────────────
#> ℹ Point Estimate (x-bar_d): 4.2
#> ℹ SD of Differences (s_d): 6.8
#> ℹ Number of Pairs (n_d): 25
#> ℹ SD of Sampling Distribution: 1.36
#> • Interval: (1.3931, 7.0069)
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Summary Statistics (theory, 90% CI) ---
result2 <- ci_paired(x_bar_d = 4.2, sd_d = 6.8, n_d = 25,
                     name = "Post - Pre", conf_level = 0.90,
                     method = "theory")
print(result2)
#> 
#> ── 90% Confidence Interval for Mean Difference (Theory) ────────────────────────
#> ℹ Point Estimate (x-bar_d): 4.2
#> ℹ SD of Differences (s_d): 6.8
#> ℹ Number of Pairs (n_d): 25
#> ℹ SD of Sampling Distribution: 1.36
#> • Interval: (1.8732, 6.5268)
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Single Differences Column (2SD method) ---
if (FALSE) { # \dontrun{
result3 <- ci_paired(formula = ~ extra,
                     data = sleep[sleep$group == 1, ],
                     name = "Extra Sleep (hours)", method = "2SD")
print(result3)
} # }
if (FALSE) { # \dontrun{
plot(result3)
plot_steps(result3)
} # }

# --- Two Columns Before/After (simulation, 90% CI) ---
study_data <- data.frame(
  Before = c(72, 68, 75, 80, 65, 70, 78, 82, 69, 74),
  After  = c(78, 72, 80, 84, 70, 75, 82, 85, 73, 79)
)
result4 <- ci_paired(formula = After ~ Before, data = study_data,
                     name = "After - Before", conf_level = 0.90,
                     method = "simulation")
#> ✔ Differences computed as "After" minus "Before".
#> • Number of pairs (n_d): 10
print(result4)
#> 
#> ── 90% Confidence Interval for Mean Difference (Simulation) ────────────────────
#> ℹ Point Estimate (x-bar_d): 4.5
#> ℹ SD of Differences (s_d): 0.8498
#> ℹ Number of Pairs (n_d): 10
#> ℹ SD of Sampling Distribution: 0.2484
#> • Interval: (4.1, 4.9)
if (FALSE) { # \dontrun{
plot(result4)
plot_steps(result4)
} # }

# --- Two Columns Before/After (theory) ---
result5 <- ci_paired(formula = After ~ Before, data = study_data,
                     name = "After - Before", method = "theory")
#> ✔ Differences computed as "After" minus "Before".
#> • Number of pairs (n_d): 10
#> Warning: ! Validity conditions for the theory-based T-interval may not be met.
#> ℹ There are only 10 pairs, which is fewer than 20.
#> ℹ Proceed only if the distribution of differences is roughly symmetric.
#> ℹ Otherwise consider using `method = "2SD"` or `method = "simulation"` if raw
#>   data is available.
print(result5)
#> 
#> ── 95% Confidence Interval for Mean Difference (Theory) ────────────────────────
#> ℹ Point Estimate (x-bar_d): 4.5
#> ℹ SD of Differences (s_d): 0.8498
#> ℹ Number of Pairs (n_d): 10
#> ℹ SD of Sampling Distribution: 0.2687
#> • Interval: (3.8921, 5.1079)
#> Warning: ! Validity conditions may not be met -- fewer than 20 pairs (n_d = 10).
#> ℹ Verify that the distribution of differences is roughly symmetric.
#> ℹ Consider using `method = "2SD"` or `method = "simulation"` if raw data is
#>   available.
if (FALSE) { # \dontrun{
plot(result5)
plot_steps(result5)
} # }
```
