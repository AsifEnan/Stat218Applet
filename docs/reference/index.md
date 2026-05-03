# Package index

## Hypothesis Tests

Functions for testing claims about population parameters. Each function
accepts either summary statistics or raw data via formula and data, and
returns an S3 object with print(), plot(), and plot_steps() methods.

- [`test_1prop()`](https://asifenan.github.io/Stat218Applet/reference/test_1prop.md)
  : 1-Sample Proportion Hypothesis Test
- [`test_1mean()`](https://asifenan.github.io/Stat218Applet/reference/test_1mean.md)
  : 1-Sample Mean Hypothesis Test
- [`test_2prop()`](https://asifenan.github.io/Stat218Applet/reference/test_2prop.md)
  : 2-Sample Proportions Hypothesis Test
- [`test_2mean()`](https://asifenan.github.io/Stat218Applet/reference/test_2mean.md)
  : 2-Sample Means Hypothesis Test
- [`test_paired()`](https://asifenan.github.io/Stat218Applet/reference/test_paired.md)
  : Paired Data Hypothesis Test
- [`test_correlation()`](https://asifenan.github.io/Stat218Applet/reference/test_correlation.md)
  : Correlation Hypothesis Test
- [`test_regression()`](https://asifenan.github.io/Stat218Applet/reference/test_regression.md)
  : Simple Linear Regression Hypothesis Test (Slope)

## Confidence Intervals

Functions for constructing confidence intervals. All support three
methods – 2SD (default, 95% only), simulation (any confidence level),
and theory (formula-based).

- [`ci_1prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_1prop.md)
  : 1-Sample Proportion Confidence Interval
- [`ci_1mean()`](https://asifenan.github.io/Stat218Applet/reference/ci_1mean.md)
  : 1-Sample Mean Confidence Interval
- [`ci_2prop()`](https://asifenan.github.io/Stat218Applet/reference/ci_2prop.md)
  : 2-Sample Proportions Confidence Interval
- [`ci_2mean()`](https://asifenan.github.io/Stat218Applet/reference/ci_2mean.md)
  : 2-Sample Means Confidence Interval
- [`ci_paired()`](https://asifenan.github.io/Stat218Applet/reference/ci_paired.md)
  : Paired Data Confidence Interval

## Helper Functions

Tools for exploring data, reading regression output, and looking up
statistical symbols before running formal inference.

- [`explore_2vars()`](https://asifenan.github.io/Stat218Applet/reference/explore_2vars.md)
  : Explore the Relationship Between Two Variables
- [`table_regression()`](https://asifenan.github.io/Stat218Applet/reference/table_regression.md)
  : Formatted Simple Linear Regression and ANOVA Tables
- [`show_symbols()`](https://asifenan.github.io/Stat218Applet/reference/show_symbols.md)
  : Show Statistical Symbol Reference Plots
- [`plot_steps()`](https://asifenan.github.io/Stat218Applet/reference/plot_steps.md)
  : Plot Detailed Mathematical Steps and Interpretations

## Datasets

32 datasets drawn from the Introduction to Statistical Investigations
(ISI) textbook by Tintle et al., covering Chapters P, 2, 3, 5, 6, 7, and
10.

- [`organdonor`](https://asifenan.github.io/Stat218Applet/reference/organdonor.md)
  : Organ Donor Default Choice
- [`oldfaithful`](https://asifenan.github.io/Stat218Applet/reference/oldfaithful.md)
  : Old Faithful Wait Times by Year
- [`oldfaithful2`](https://asifenan.github.io/Stat218Applet/reference/oldfaithful2.md)
  : Old Faithful Eruption Type and Wait Times
- [`timeestimate`](https://asifenan.github.io/Stat218Applet/reference/timeestimate.md)
  : Time Interval Estimates (Sample)
- [`timepopulation`](https://asifenan.github.io/Stat218Applet/reference/timepopulation.md)
  : Time Interval Estimates (Population)
- [`sleeptimes`](https://asifenan.github.io/Stat218Applet/reference/sleeptimes.md)
  : Student Sleep Hours
- [`haircuts`](https://asifenan.github.io/Stat218Applet/reference/haircuts.md)
  : Haircut Costs by Sex
- [`usedcars`](https://asifenan.github.io/Stat218Applet/reference/usedcars.md)
  : Used Honda Civic Prices
- [`goodandbad`](https://asifenan.github.io/Stat218Applet/reference/goodandbad.md)
  : Question Wording and Perception
- [`gilbert`](https://asifenan.github.io/Stat218Applet/reference/gilbert.md)
  : Nurse Gilbert Shift and Patient Deaths
- [`dolphin`](https://asifenan.github.io/Stat218Applet/reference/dolphin.md)
  : Dolphin-Assisted Therapy
- [`yawning`](https://asifenan.github.io/Stat218Applet/reference/yawning.md)
  : Yawning Contagion Experiment
- [`smoking`](https://asifenan.github.io/Stat218Applet/reference/smoking.md)
  : Parental and Child Smoking Status
- [`blood`](https://asifenan.github.io/Stat218Applet/reference/blood.md)
  : Blood Donor Response by Year
- [`biketimes`](https://asifenan.github.io/Stat218Applet/reference/biketimes.md)
  : Bike Frame Type and Ride Times
- [`sleep`](https://asifenan.github.io/Stat218Applet/reference/sleep.md)
  : Sleep Deprivation and Reaction Time
- [`breastfeedintell`](https://asifenan.github.io/Stat218Applet/reference/breastfeedintell.md)
  : Breastfeeding and Child Intelligence
- [`closefriends`](https://asifenan.github.io/Stat218Applet/reference/closefriends.md)
  : Number of Close Friends by Sex
- [`firstbase`](https://asifenan.github.io/Stat218Applet/reference/firstbase.md)
  : First Base Running Times
- [`jjvsbicycle`](https://asifenan.github.io/Stat218Applet/reference/jjvsbicycle.md)
  : Jumping Jacks vs. Bicycle Calories Burned
- [`bowlsmms`](https://asifenan.github.io/Stat218Applet/reference/bowlsmms.md)
  : M&Ms Eaten from Small vs. Large Bowl
- [`auction`](https://asifenan.github.io/Stat218Applet/reference/auction.md)
  : Dutch vs. First-Price Auction Bids
- [`tempheart`](https://asifenan.github.io/Stat218Applet/reference/tempheart.md)
  : Body Temperature and Heart Rate
- [`gpa`](https://asifenan.github.io/Stat218Applet/reference/gpa.md) :
  Study Hours and GPA
- [`facebook`](https://asifenan.github.io/Stat218Applet/reference/facebook.md)
  : Facebook Friends and Network Density
- [`draftlottery`](https://asifenan.github.io/Stat218Applet/reference/draftlottery.md)
  : Vietnam Draft Lottery
- [`exercisemood`](https://asifenan.github.io/Stat218Applet/reference/exercisemood.md)
  : Exercise Intensity and Mood Change
- [`footheight`](https://asifenan.github.io/Stat218Applet/reference/footheight.md)
  : Foot Length and Height
- [`alcoholsmoke`](https://asifenan.github.io/Stat218Applet/reference/alcoholsmoke.md)
  : Alcohol Consumption and Smoking Status
- [`handwidth`](https://asifenan.github.io/Stat218Applet/reference/handwidth.md)
  : Hand Width and Perceived Weight
- [`examtimesscores`](https://asifenan.github.io/Stat218Applet/reference/examtimesscores.md)
  : Exam Time and Scores
- [`platesize`](https://asifenan.github.io/Stat218Applet/reference/platesize.md)
  : Dinner Plate Size Over Time

## Internal Methods

S3 plot methods dispatched automatically – use plot() on any result
object.

- [`plot(`*`<stat218_1prop_ci>`*`)`](https://asifenan.github.io/Stat218Applet/reference/plot.stat218_1prop_ci.md)
  : Plot Method for ci_1prop Results
- [`plot(`*`<stat218_2mean_ci>`*`)`](https://asifenan.github.io/Stat218Applet/reference/plot.stat218_2mean_ci.md)
  : Plot Method for ci_2mean Results
