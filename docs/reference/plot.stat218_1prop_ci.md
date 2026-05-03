# Plot Method for ci_1prop Results

Plot Method for ci_1prop Results

## Usage

``` r
# S3 method for class 'stat218_1prop_ci'
plot(x, plot_type = "histogram", ...)
```

## Arguments

- x:

  A `stat218_1prop_ci` result object from
  [`ci_1prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_1prop.md).

- plot_type:

  The type of plot for the bootstrap distribution. Must be `"histogram"`
  (default) or `"dotplot"`. Only available when `method = "2SD"` or
  `method = "simulation"`.

- ...:

  Additional arguments (currently unused).
