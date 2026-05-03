# Formatted Simple Linear Regression and ANOVA Tables

Fits a simple linear regression model and produces a publication-quality
formatted table using the `gt` package. Two table types are available:

- **Regression Table** (`table_type = "regression"`, the default):
  Displays the intercept and slope with their standard errors,
  t-statistics, p-values, and a confidence interval for the slope.
  Includes an automatically generated plain-English interpretation of
  the confidence interval.

- **ANOVA Table** (`table_type = "anova"`): Displays the analysis of
  variance decomposition of the regression model – Model (Regression),
  Error (Residuals), and Total rows – with sums of squares, degrees of
  freedom, mean squares, the F-statistic, and p-value. Includes \\R^2\\
  in the footer.

This function accepts input via `formula` and `data` only – raw data is
required to fit the model.

## Usage

``` r
table_regression(formula, data, table_type = "regression", conf_level = 0.95)
```

## Arguments

- formula:

  A two-sided formula of the form `response ~ explanatory` identifying
  the response (y) and explanatory (x) variables in your dataset. For
  example, `formula = mpg ~ wt` where both columns exist in `data`.

- data:

  A data frame containing the variables named in `formula`.

- table_type:

  A character string controlling which table is produced. Must be one
  of:

  `"regression"`

  :   (default) Produces a coefficients table with the intercept and
      slope, standard errors, t-statistics, p-values, and a confidence
      interval for the slope. A plain-English interpretation of the
      slope confidence interval is shown in the table footer.

  `"anova"`

  :   Produces an ANOVA decomposition table showing the Model
      (Regression), Error (Residuals), and Total rows with sums of
      squares, degrees of freedom, mean squares, the F-statistic, and
      p-value. \\R^2\\ is shown in the table footer.

- conf_level:

  The confidence level for the slope confidence interval shown in the
  regression table. Must be a number strictly between 0 and

  1.  Default is `0.95` (95% confidence interval). Only used when
      `table_type = "regression"`.

## Value

A `gt` table object. The table can be further customized using standard
`gt` functions, or saved to HTML, PDF, or Word using
[`gt::gtsave()`](https://gt.rstudio.com/reference/gtsave.html).

## Details

### Regression Table

The regression table displays the fitted model \$\$\hat{y} = b_0 + b_1
x\$\$ with the following columns:

- **Term**: Intercept (\\b_0\\) and the explanatory variable name
  (\\b_1\\)

- **Coefficient**: The estimated value of each term

- **SE**: Standard error of the estimate

- **t-stat**: The standardized test statistic (\\t = b_1 / SE\_{b_1}\\)

- **p-value**: Two-sided p-value for testing H\\\_0\\: \\\beta = 0\\

- **Lower / Upper**: Confidence interval bounds for each term

The footer provides a plain-English interpretation of the slope
confidence interval, automatically adjusting wording based on whether
the interval is entirely positive, entirely negative, or straddles zero.

### ANOVA Table

The ANOVA table decomposes the total variability in the response
variable into two sources:

- **Model (Regression)**: Variability explained by the linear
  relationship with the explanatory variable (\\SS\_{Model}\\, \\df =
  1\\)

- **Error (Residuals)**: Variability left unexplained by the model
  (\\SS\_{Error}\\, \\df = n - 2\\)

- **Total**: Total variability in the response (\\SS\_{Total}\\, \\df =
  n - 1\\)

The F-statistic is \\F = MS\_{Model} / MS\_{Error}\\ and tests the same
null hypothesis as the slope t-test: H\\\_0\\: \\\beta_1 = 0\\. \\R^2 =
SS\_{Model} / SS\_{Total}\\ is shown in the footer.

### Connection Between the Two Tables

For simple linear regression with one explanatory variable, the F-test
in the ANOVA table and the two-sided t-test for the slope in the
regression table are mathematically equivalent: \\F = t^2\\ and both
produce the same p-value.

## Examples

``` r
# --- Regression table, mtcars ---
# Does car weight predict fuel efficiency?
table_regression(
  formula = mpg ~ wt,
  data    = mtcars
)


  


Simple Linear Regression Output
```
