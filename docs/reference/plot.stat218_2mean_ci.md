# Plot Method for ci_2mean Results

Plot Method for ci_2mean Results

## Usage

``` r
# S3 method for class 'stat218_2mean_ci'
plot(x, plot_type = "distribution", ...)
```

## Arguments

- x:

  A `stat218_2mean_ci` result object from
  [`ci_2mean()`](https://asifenan.github.io/Stat218Applet/reference/ci_2mean.md).

- plot_type:

  The type of plot for the bootstrap distribution. Must be `"histogram"`
  (default) or `"dotplot"`. Only available when `method = "2SD"` or
  `method = "simulation"`.

- ...:

  Additional arguments (currently unused).
