# Dutch vs. First-Price Auction Bids

Bids placed by the same participants in two auction formats – a Dutch
(descending price) auction and a first-price sealed-bid auction. Because
the same person bid in both formats, this is a paired design. Used in
Chapter 7 of ISI for paired inference.

## Usage

``` r
auction
```

## Format

A data frame with 88 rows and 2 variables:

- dutch:

  Bid amount in the Dutch auction

- fp:

  Bid amount in the first-price sealed-bid auction

## Source

<http://www.isi-stats.com/isi/>

## Examples

``` r
head(auction)
#> # A tibble: 6 × 2
#>   dutch    fp
#>   <dbl> <dbl>
#> 1    25  26.2
#> 2    24  25.2
#> 3    26  27  
#> 4    20  20.8
#> 5    20  20.8
#> 6    15  15.2
test_paired(
  formula     = fp ~ dutch,
  data        = auction,
  alternative = "two.sided",
  method      = "theory"
)
#> ✔ Differences computed as "fp" minus "dutch".
#> • Number of pairs (n_d): 88
#> 
#> ── Paired Data Hypothesis Test (Theory) ────────────────────────────────────────
#> ℹ Mean Difference (x-bar_d): -0.3835
#> ℹ SD of Differences (s_d): 0.6752
#> ℹ Number of Pairs (n_d): 88
#> ℹ Null Hypothesis: mu_d = 0
#> ℹ Alternative: mu_d != 0
#> • SD of Null Distribution: 0.072
#> • Test Statistic (T): -5.328
#> • P-Value: 0
ci_paired(
  formula    = fp ~ dutch,
  data       = auction,
  conf_level = 0.95,
  method     = "theory"
)
#> ✔ Differences computed as "fp" minus "dutch".
#> • Number of pairs (n_d): 88
#> 
#> ── 95% Confidence Interval for Mean Difference (Theory) ────────────────────────
#> ℹ Point Estimate (x-bar_d): -0.3835
#> ℹ SD of Differences (s_d): 0.6752
#> ℹ Number of Pairs (n_d): 88
#> ℹ SD of Sampling Distribution: 0.072
#> • Interval: (-0.5266, -0.2405)
```
