# Question Wording and Perception

A study examining whether the wording of a survey question – framing it
around a "good year" vs. a "bad year" – affects participants'
perceptions of economic conditions. Used in Chapter 5 of ISI for
two-proportion inference.

## Usage

``` r
goodandbad
```

## Format

A data frame with 29 rows and 2 variables:

- wording:

  Question framing: contains values like `"\"goodyear\""` or
  `"\"badyear\""`

- perception:

  Participant response: `"positive"` or `"negative"`

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(goodandbad)
#> # A tibble: 6 × 2
#>   wording           perception
#>   <chr>             <lgl>     
#> 1 goodyear positive NA        
#> 2 goodyear negative NA        
#> 3 badyear positive  NA        
#> 4 goodyear positive NA        
#> 5 goodyear negative NA        
#> 6 badyear positive  NA        
table(goodandbad$wording, goodandbad$perception)
#> < table of extent 4 x 0 >
```
