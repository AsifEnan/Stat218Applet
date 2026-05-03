# Exercise Intensity and Mood Change

Change in mood score after exercise at varying intensity levels for 32
participants. Used in Chapter 10 of ISI for regression and correlation.
Explores whether higher exercise intensity is associated with greater
mood improvement.

## Usage

``` r
exercisemood
```

## Format

A data frame with 32 rows and 2 variables:

- exercise_intensity:

  Exercise intensity level (numeric)

- change_mood:

  Change in mood score after exercise (positive = mood improved,
  negative = mood worsened)

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(exercisemood)
#> # A tibble: 6 × 2
#>   exercise_intensity change_mood
#>                <dbl>       <dbl>
#> 1               72.2         -31
#> 2               76.1         -26
#> 3               68.3         -24
#> 4               61.6         -24
#> 5               59.5         -24
#> 6               73.9         -20
explore_2vars(
  formula  = change_mood ~ exercise_intensity,
  data     = exercisemood,
  fit_line = TRUE
)
#> `geom_smooth()` using formula = 'y ~ x'

test_regression(
  formula     = change_mood ~ exercise_intensity,
  data        = exercisemood,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Regression of "change_mood" ~ "exercise_intensity":
#> • n = 32
#> • Observed Slope (b1) = 0.1368
#> • Standard Error (SE) = 0.1313
#> 
#> ── Regression Slope Hypothesis Test (Theory) ───────────────────────────────────
#> ℹ Null Hypothesis: beta_1 = 0
#> ℹ Alternative: beta_1 != 0
#> • Sample Size (n): 32
#> • Observed Slope (b1): 0.1368
#> • Standard Error (SE): 0.1313
#> • SD of Null Distribution: 0.1313
#> • Test Statistic (T): 1.042
#> • Degrees of Freedom: 30
#> • P-Value: 0.3057
```
