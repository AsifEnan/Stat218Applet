# Plot Detailed Mathematical Steps and Interpretations

Displays a step-by-step panel walking through the math, standardized
statistic, p-value, and written conclusion for a completed statistical
analysis. Call this on any result object produced by the Stat218Applet
functions (e.g., `test_1prop`, `test_1mean`, etc.).

## Usage

``` r
plot_steps(x, ...)
```

## Arguments

- x:

  A result object of any `stat218_*` class.

- ...:

  Additional arguments passed to the specific method.

## Note

The significance level `alpha` is passed via `...` and handled by each
individual method.
