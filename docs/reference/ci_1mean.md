# 1-Sample Mean Confidence Interval

Constructs a confidence interval for a single population mean (\\\mu\\)
using one of three methods: the 2SD simulation method, a general
simulation method, or a theory-based approach.

This function accepts input in **two ways**:

- **Summary Statistics:** You already know the sample mean, standard
  deviation, and sample size. Pass `x_bar`, `sd_val`, and `n` directly.

- **Raw Data:** You have an actual dataset loaded into R. Pass `formula`
  and `data` instead, and the function computes all summary statistics
  automatically.

## Usage

``` r
ci_1mean(
  x_bar = NULL,
  n = NULL,
  sd_val = NULL,
  sd_type = "sample",
  formula = NULL,
  data = NULL,
  conf_level = 0.95,
  method = "2SD",
  sim_reps = 1000
)
```

## Arguments

- x_bar:

  The observed sample mean-the average value from your sample. **Only
  used when NOT providing `formula` and `data`.**

- n:

  A whole number representing the total sample size. **Only used when
  NOT providing `formula` and `data`.**

- sd_val:

  The standard deviation. Whether this is a population or sample SD is
  determined by `sd_type`. **Only used when NOT providing `formula` and
  `data`.**

- sd_type:

  A character string specifying whether the standard deviation is from
  the population or the sample. Must be one of:

  `"sample"`

  :   (default) The SD was calculated from your sample data. When
      `method = "theory"`, a T-test multiplier is used.

  `"population"`

  :   The true population SD (\\\sigma\\) is known. When
      `method = "theory"`, a Z multiplier is used.

  When raw data is provided via `formula` and `data`, this is always set
  to `"sample"` automatically.

- formula:

  A one-sided formula of the form `~ variable` identifying the numeric
  variable in your dataset. For example, `formula = ~ Height`. **Only
  used when NOT providing `x_bar`, `n`, and `sd_val`.**

- data:

  A data frame (loaded from a `.csv`, `.txt`, or `.xlsx` file)
  containing the variable named in `formula`. **Only used when NOT
  providing summary statistics.**

- conf_level:

  The desired confidence level as a decimal. Default is `0.95` for a 95%
  confidence interval. Common choices are `0.90`, `0.95`, and `0.99`.
  Note that `method = "2SD"` only works at `0.95`.

- method:

  The method used to construct the confidence interval. Must be one of:

  `"2SD"`

  :   (default) The 2SD Simulation Method. A parametric bootstrap
      distribution is generated centered at `x_bar`, and the interval is
      constructed as \\\bar{x} \pm 2 \times SD(\bar{x})\\. This method
      is only valid for 95% confidence intervals. If you need a
      different confidence level, use `method = "simulation"`.

  `"simulation"`

  :   The Bootstrap Simulation Method. Same parametric bootstrap as 2SD,
      but uses the middle `conf_level`% of the simulated distribution to
      find the bounds. Works for any confidence level.

  `"theory"`

  :   The Theory-Based Method. Uses the formula \\SE = s/\sqrt{n}\\ (or
      \\\sigma/\sqrt{n}\\) and the appropriate Z\* or t\* multiplier.
      Works for any confidence level. Requires validity conditions to be
      met.

- sim_reps:

  The number of bootstrap samples when `method = "2SD"` or
  `method = "simulation"`. Default is `1000`. Increasing to `5000` gives
  a more stable interval.

## Value

An S3 object of class `stat218_1mean_ci` containing all computed values.
You can use the following methods on the result:

- `print(result)`:

  Displays a clean summary of the interval.

- `plot(result)`:

  Shows the bootstrap or theoretical distribution with the confidence
  interval shaded and labeled, plus a forest plot of the interval below.

- `plot_steps(result)`:

  Displays a detailed three-panel step-by-step construction of the
  interval.

## Details

### The Core Idea

A confidence interval gives a range of plausible values for the true
population mean \\\mu\\. Rather than giving a single point estimate
(which is almost certainly not exactly right), a confidence interval
acknowledges uncertainty and says: *"We are X% confident the true mean
falls somewhere in this range."*

### The 2SD Method

The book introduces this as the primary simulation-based approach for
95% confidence intervals. We simulate the sampling distribution of the
sample mean by drawing many bootstrap samples, then use \\\bar{x} \pm 2
\times SD\\ of that distribution as our interval. The multiplier of 2 is
an approximation of the true 1.96 used in theory.

### Theory Method

Uses the formula SE = s/\\\sqrt{n}\\ (or \\\sigma\\/\\\sqrt{n}\\ if the
population SD is known), multiplied by the appropriate critical value
from the Z or T distribution. Requires:

- \\n \geq 20\\, **or**

- The underlying distribution is roughly symmetric.

## Examples

``` r
# --- Summary Statistics (2SD method, default) ---
result <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35)
print(result)
#> 
#> ── 95% Confidence Interval (2sd) ───────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 72.4
#> ℹ Standard Deviation (s): 8.1 | n: 35
#> ℹ SD of Sampling Distribution: 1.3492
#> • Interval: (69.7016, 75.0984)
if (FALSE) { # \dontrun{
plot(result)
plot_steps(result)
} # }

# --- Summary Statistics (theory, T-interval) ---
result2 <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35,
                    sd_type = "sample", conf_level = 0.95,
                    method = "theory")
print(result2)
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 72.4
#> ℹ Standard Deviation (s): 8.1 | n: 35
#> ℹ SD of Sampling Distribution: 1.3691
#> • Interval: (69.6176, 75.1824)
if (FALSE) { # \dontrun{
plot(result2)
plot_steps(result2)
} # }

# --- Summary Statistics (simulation, 90% CI) ---
result3 <- ci_1mean(x_bar = 72.4, sd_val = 8.1, n = 35,
                    conf_level = 0.90, method = "simulation")
print(result3)
#> 
#> ── 90% Confidence Interval (Simulation) ────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 72.4
#> ℹ Standard Deviation (s): 8.1 | n: 35
#> ℹ SD of Sampling Distribution: 1.3892
#> • Interval: (70.1753, 74.7819)
if (FALSE) { # \dontrun{
plot(result3)
plot_steps(result3)
} # }

# --- Raw Data (2SD method) ---
result4 <- ci_1mean(formula = ~ mpg, data = mtcars, method = "2SD")
#> ✔ Data extracted from variable "mpg":
#> • Sample Mean (x-bar): 20.0906
#> • Sample SD (s): 6.0269
#> • Sample Size (n): 32
#> ℹ `sd_type` automatically set to "sample" from raw data.
print(result4)
#> 
#> ── 95% Confidence Interval (2sd) ───────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 20.0906
#> ℹ Standard Deviation (s): 6.0269 | n: 32
#> ℹ SD of Sampling Distribution: 1.0951
#> • Interval: (17.9005, 22.2807)
if (FALSE) { # \dontrun{
plot(result4)
plot_steps(result4)
} # }

# --- Raw Data (theory, T-interval) ---
result5 <- ci_1mean(formula = ~ mpg, data = mtcars, method = "theory")
#> ✔ Data extracted from variable "mpg":
#> • Sample Mean (x-bar): 20.0906
#> • Sample SD (s): 6.0269
#> • Sample Size (n): 32
#> ℹ `sd_type` automatically set to "sample" from raw data.
print(result5)
#> 
#> ── 95% Confidence Interval (Theory) ────────────────────────────────────────────
#> ℹ Point Estimate (x-bar): 20.0906
#> ℹ Standard Deviation (s): 6.0269 | n: 32
#> ℹ SD of Sampling Distribution: 1.0654
#> • Interval: (17.9177, 22.2636)
if (FALSE) { # \dontrun{
plot(result5)
plot_steps(result5)
} # }
```
