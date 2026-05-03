# Parental and Child Smoking Status

A large survey examining the association between parental smoking habits
and whether their children smoke. Used in Chapter 5 of ISI for
two-proportion inference with a large, real-world dataset.

## Usage

``` r
smoking
```

## Format

A data frame with 4167 rows and 2 variables:

- parents:

  Parental smoking status: `"smokers"` or `"nonsmokers"`

- child:

  Child's sex in the study: `"boy"` or `"girl"`

## Source

<http://www.isi-stats.com/isi/>

## Note

Use `table(smoking$parents, smoking$child)` to explore the
cross-tabulation before running inference.

## Examples

``` r
head(smoking)
#> # A tibble: 6 × 2
#>   parents child
#>   <chr>   <chr>
#> 1 smokers girl 
#> 2 smokers girl 
#> 3 smokers girl 
#> 4 smokers girl 
#> 5 smokers girl 
#> 6 smokers girl 
table(smoking$parents, smoking$child)
#>             
#>               boy girl
#>   nonsmokers 1975 1627
#>   smokers     255  310
```
