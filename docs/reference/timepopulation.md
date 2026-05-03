# Time Interval Estimates (Population)

The full population of time interval estimates from a large-scale
version of the time estimation activity. Paired with `timeestimate`,
this dataset is used in Chapter 2 of ISI to illustrate the distinction
between a sample and its population – a foundational concept for
understanding sampling variability.

## Usage

``` r
timepopulation
```

## Format

A data frame with 6215 rows and 1 variable:

- estimate:

  Estimated time interval in seconds

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(timepopulation)
#> # A tibble: 6 × 1
#>   estimate
#>      <dbl>
#> 1        5
#> 2        8
#> 3        2
#> 4        9
#> 5       10
#> 6        5
# Compare sample mean vs population mean
mean(timeestimate$estimate)
#> [1] 13.70833
mean(timepopulation$estimate)
#> [1] 10.00161
```
