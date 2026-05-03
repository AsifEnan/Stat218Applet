# R/data.R
# Documentation for all datasets bundled in the Stat218Applet package.
# All datasets are sourced from the Introduction to Statistical Investigations
# (ISI) textbook by Tintle, Chance, Cobb, Rossman, Roy, Swanson, and VanderStoep.
# Column names reflect janitor::clean_names() applied during data preparation.

# ── Preliminaries ─────────────────────────────────────────────────────────────

#' Organ Donor Default Choice
#'
#' @description
#' Data from the Preliminaries of ISI. Researchers studied whether the
#' default option on a donor registration form (opt-in, opt-out, or neutral)
#' affects whether people choose to become organ donors. A classic example
#' for introducing the logic of statistical significance and the role of
#' study design.
#'
#' @format A data frame with 161 rows and 2 variables:
#' \describe{
#'   \item{default}{The default condition presented on the form:
#'     \code{"opt-in"}, \code{"opt-out"}, or \code{"neutral"}}
#'   \item{choice}{The participant's registration decision:
#'     \code{"donor"} or \code{"not"}}
#' }
#' @note Because \code{default} has three levels, filter to two groups
#'   before using with \code{test_2prop()} or \code{ci_2prop()}.
#'   For example:
#'   \code{organdonor_sub <- organdonor[organdonor$default != "neutral", ]}
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(organdonor)
#' table(organdonor$default, organdonor$choice)
#'
#' # Filter to two groups before running a two-proportion test
#' two_groups <- organdonor[organdonor$default != "neutral", ]
#' test_2prop(
#'   formula       = choice ~ default,
#'   data          = two_groups,
#'   success_level = "donor",
#'   alternative   = "two.sided",
#'   method        = "theory"
#' )
"organdonor"

#' Old Faithful Wait Times by Year
#'
#' @description
#' Wait times between eruptions of the Old Faithful geyser in Yellowstone
#' National Park, recorded across multiple years (1978 onward). Useful for
#' regression and correlation analyses examining whether wait times have
#' changed over time (Chapter 10 of ISI). Note that R's built-in
#' \code{faithful} dataset covers a similar topic but with a different
#' structure (eruption duration vs. wait time).
#'
#' @format A data frame with 202 rows and 2 variables:
#' \describe{
#'   \item{year}{Year of observation (numeric)}
#'   \item{time}{Wait time between eruptions (minutes)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(oldfaithful)
#' explore_2vars(formula = time ~ year, data = oldfaithful)
#' test_correlation(
#'   formula     = time ~ year,
#'   data        = oldfaithful,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"oldfaithful"

#' Old Faithful Eruption Type and Wait Times
#'
#' @description
#' Wait times between eruptions of the Old Faithful geyser, categorized
#' by eruption type. Used in Chapter 6 of ISI to compare wait times
#' between short and long eruptions using two-mean inference. This is
#' the richer version of the dataset -- it includes the grouping variable
#' that \code{oldfaithful} lacks.
#'
#' @format A data frame with 222 rows and 2 variables:
#' \describe{
#'   \item{eruption_type}{Type of preceding eruption:
#'     \code{"short"} or \code{"long"}}
#'   \item{time_between}{Wait time until the next eruption (minutes)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(oldfaithful2)
#' explore_2vars(formula = time_between ~ eruption_type, data = oldfaithful2)
#' test_2mean(
#'   formula     = time_between ~ eruption_type,
#'   data        = oldfaithful2,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"oldfaithful2"

# ── Chapter 2 -- One Mean ──────────────────────────────────────────────────────

#' Time Interval Estimates (Sample)
#'
#' @description
#' Students were asked to estimate a 10-second time interval without
#' counting. Used in Chapter 2 of ISI to introduce one-mean inference --
#' specifically, to test whether students systematically over- or
#' underestimate a 10-second interval.
#'
#' @format A data frame with 48 rows and 1 variable:
#' \describe{
#'   \item{estimate}{Estimated time interval in seconds}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(timeestimate)
#' test_1mean(
#'   formula     = ~ estimate,
#'   data        = timeestimate,
#'   null_mu     = 10,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_1mean(
#'   formula    = ~ estimate,
#'   data       = timeestimate,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"timeestimate"

#' Time Interval Estimates (Population)
#'
#' @description
#' The full population of time interval estimates from a large-scale
#' version of the time estimation activity. Paired with \code{timeestimate},
#' this dataset is used in Chapter 2 of ISI to illustrate the distinction
#' between a sample and its population -- a foundational concept for
#' understanding sampling variability.
#'
#' @format A data frame with 6215 rows and 1 variable:
#' \describe{
#'   \item{estimate}{Estimated time interval in seconds}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(timepopulation)
#' # Compare sample mean vs population mean
#' mean(timeestimate$estimate)
#' mean(timepopulation$estimate)
"timepopulation"

#' Student Sleep Hours
#'
#' @description
#' Self-reported nightly sleep hours from a sample of college students.
#' Used in Chapter 2 of ISI for one-mean hypothesis tests and confidence
#' intervals. A relatable dataset that resonates with students.
#'
#' @format A data frame with 22 rows and 1 variable:
#' \describe{
#'   \item{sleep_hrs}{Hours of sleep per night (self-reported)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(sleeptimes)
#' test_1mean(
#'   formula     = ~ sleep_hrs,
#'   data        = sleeptimes,
#'   null_mu     = 8,
#'   alternative = "less",
#'   method      = "theory"
#' )
#' ci_1mean(
#'   formula = ~ sleep_hrs,
#'   data    = sleeptimes,
#'   method  = "2SD"
#' )
"sleeptimes"

#' Haircut Costs by Sex
#'
#' @description
#' Haircut costs reported by male and female college students. Used in
#' both Chapter 2 (one-mean) and Chapter 6 (two-mean) of ISI. A
#' consistently engaging dataset that generates real class discussion
#' about whether men and women pay different amounts for haircuts.
#'
#' @format A data frame with 50 rows and 2 variables:
#' \describe{
#'   \item{sex}{\code{"Male"} or \code{"Female"}}
#'   \item{cost}{Cost of the most recent haircut (dollars)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(haircuts)
#' # One-mean: is the average haircut cost different from $50?
#' test_1mean(
#'   formula     = ~ cost,
#'   data        = haircuts,
#'   null_mu     = 50,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' # Two-mean: do men and women pay different amounts?
#' test_2mean(
#'   formula     = cost ~ sex,
#'   data        = haircuts,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"haircuts"

# ── Chapter 3 -- One Mean (continued) ─────────────────────────────────────────

#' Used Honda Civic Prices
#'
#' @description
#' Sale prices of used Honda Civics from an online listing. Used in
#' Chapter 3 of ISI to practice one-mean inference with a real-world
#' quantitative variable. Students often use this dataset to test claims
#' about whether the average used Civic costs more or less than a
#' specific benchmark price.
#'
#' @format A data frame with 102 rows and 1 variable:
#' \describe{
#'   \item{price}{Sale price of the vehicle (dollars)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(usedcars)
#' test_1mean(
#'   formula     = ~ price,
#'   data        = usedcars,
#'   null_mu     = 15000,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_1mean(
#'   formula    = ~ price,
#'   data       = usedcars,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"usedcars"

# ── Chapter 5 -- Two Proportions ───────────────────────────────────────────────

#' Question Wording and Perception
#'
#' @description
#' A study examining whether the wording of a survey question -- framing
#' it around a "good year" vs. a "bad year" -- affects participants'
#' perceptions of economic conditions. Used in Chapter 5 of ISI for
#' two-proportion inference.
#'
#' @format A data frame with 29 rows and 2 variables:
#' \describe{
#'   \item{wording}{Question framing: contains values like
#'     \code{"\"goodyear\""} or \code{"\"badyear\""}}
#'   \item{perception}{Participant response:
#'     \code{"positive"} or \code{"negative"}}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(goodandbad)
#' table(goodandbad$wording, goodandbad$perception)
"goodandbad"

#' Nurse Gilbert Shift and Patient Deaths
#'
#' @description
#' Data from the criminal trial of nurse Kristen Gilbert, who was accused
#' of causing patient deaths. Each row records whether Gilbert was working
#' and whether a patient died during a shift. Used in Chapter 5 of ISI
#' as a compelling real-world example of two-proportion inference -- was
#' the death rate significantly higher on Gilbert's shifts?
#'
#' @format A data frame with 1641 rows and 2 variables:
#' \describe{
#'   \item{gilbert_worked}{Whether Gilbert was on shift:
#'     \code{"Yes"} or \code{"No"}}
#'   \item{patient}{Patient outcome:
#'     \code{"Death"} or \code{"NoDeath"}}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(gilbert)
#' test_2prop(
#'   formula       = patient ~ gilbert_worked,
#'   data          = gilbert,
#'   success_level = "Death",
#'   alternative   = "greater",
#'   method        = "theory"
#' )
#' ci_2prop(
#'   formula       = patient ~ gilbert_worked,
#'   data          = gilbert,
#'   success_level = "Death",
#'   conf_level    = 0.95,
#'   method        = "theory"
#' )
"gilbert"

#' Dolphin-Assisted Therapy
#'
#' @description
#' Results from a randomized experiment testing whether swimming with
#' dolphins improves outcomes for patients with mild-to-moderate
#' depression. Participants were assigned to either swim with dolphins
#' or swim without them (control). Used in Chapter 5 of ISI for
#' two-proportion inference.
#'
#' @format A data frame with 30 rows and 2 variables:
#' \describe{
#'   \item{swimming}{Treatment assignment:
#'     \code{"Dolphin"} or \code{"Control"}}
#'   \item{response}{Outcome:
#'     \code{"Improve"} or \code{"NotImprove"}}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(dolphin)
#' test_2prop(
#'   formula       = response ~ swimming,
#'   data          = dolphin,
#'   success_level = "Improve",
#'   alternative   = "greater",
#'   method        = "simulation"
#' )
#' ci_2prop(
#'   formula       = response ~ swimming,
#'   data          = dolphin,
#'   success_level = "Improve",
#'   conf_level    = 0.95,
#'   method        = "theory"
#' )
"dolphin"

#' Yawning Contagion Experiment
#'
#' @description
#' Data from a MythBusters episode testing whether yawning is contagious.
#' Participants were either exposed to a yawn seed or placed in a control
#' condition, then observed for whether they yawned. Used in Chapter 5 of
#' ISI for two-proportion inference and to discuss randomization.
#'
#' @format A data frame with 50 rows and 2 variables:
#' \describe{
#'   \item{yawn_seed}{Whether the participant saw someone yawn:
#'     \code{"Seeded"} or \code{"Control"}}
#'   \item{response}{Whether the participant yawned:
#'     \code{"Yawn"} or \code{"NoYawn"}}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(yawning)
#' test_2prop(
#'   formula       = response ~ yawn_seed,
#'   data          = yawning,
#'   success_level = "Yawn",
#'   alternative   = "two.sided",
#'   method        = "simulation"
#' )
"yawning"

#' Parental and Child Smoking Status
#'
#' @description
#' A large survey examining the association between parental smoking
#' habits and whether their children smoke. Used in Chapter 5 of ISI
#' for two-proportion inference with a large, real-world dataset.
#'
#' @format A data frame with 4167 rows and 2 variables:
#' \describe{
#'   \item{parents}{Parental smoking status:
#'     \code{"smokers"} or \code{"nonsmokers"}}
#'   \item{child}{Child's sex in the study:
#'     \code{"boy"} or \code{"girl"}}
#' }
#' @note Use \code{table(smoking$parents, smoking$child)} to explore the
#'   cross-tabulation before running inference.
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(smoking)
#' table(smoking$parents, smoking$child)
"smoking"

#' Blood Donor Response by Year
#'
#' @description
#' Survey responses about blood donation collected in two years (2002
#' and 2004). Used in Chapter 5 of ISI to compare donation rates across
#' years using two-proportion inference.
#'
#' @format A data frame with 2698 rows and 2 variables:
#' \describe{
#'   \item{year}{Year the survey was conducted: \code{2002} or \code{2004}}
#'   \item{response}{Participant response:
#'     \code{"donated"} or \code{"did.not"}}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(blood)
#' test_2prop(
#'   formula       = response ~ year,
#'   data          = blood,
#'   success_level = "donated",
#'   alternative   = "two.sided",
#'   method        = "theory"
#' )
"blood"

# ── Chapter 6 -- Two Means ─────────────────────────────────────────────────────

#' Bike Frame Type and Ride Times
#'
#' @description
#' Ride times for cyclists using two different bike frame types --
#' carbon and steel. Used in Chapter 6 of ISI for two-mean hypothesis
#' tests and confidence intervals. This is a randomized experiment,
#' making causal conclusions appropriate.
#'
#' @format A data frame with 56 rows and 2 variables:
#' \describe{
#'   \item{frame}{Bike frame type: \code{"carbon"} or \code{"steel"}}
#'   \item{time}{Ride time (minutes)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(biketimes)
#' explore_2vars(formula = time ~ frame, data = biketimes)
#' test_2mean(
#'   formula     = time ~ frame,
#'   data        = biketimes,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_2mean(
#'   formula    = time ~ frame,
#'   data       = biketimes,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"biketimes"

#' Sleep Deprivation and Reaction Time
#'
#' @description
#' Change in reaction time scores for participants assigned to either
#' a sleep-deprived condition or an unrestricted sleep condition. Used in
#' Chapter 6 of ISI as a core example for two-mean inference. Positive
#' values indicate improvement; negative values indicate worsening.
#'
#' @format A data frame with 21 rows and 2 variables:
#' \describe{
#'   \item{sleep}{Sleep condition:
#'     \code{"deprived"} or \code{"unrestricted"}}
#'   \item{time}{Change in reaction time score (higher = better)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(sleep)
#' test_2mean(
#'   formula     = time ~ sleep,
#'   data        = sleep,
#'   alternative = "less",
#'   method      = "theory"
#' )
"sleep"

#' Breastfeeding and Child Intelligence
#'
#' @description
#' A study comparing General Cognitive Index (GCI) scores between
#' children who were breastfed and those who were not. Used in Chapter 6
#' of ISI for two-mean inference. A good example for discussing
#' confounding and the distinction between causation and association.
#'
#' @format A data frame with 322 rows and 2 variables:
#' \describe{
#'   \item{feeding}{Feeding method:
#'     \code{"Breastfed"} or \code{"NotBreastfed"}}
#'   \item{gci}{General Cognitive Index score (higher = better)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(breastfeedintell)
#' test_2mean(
#'   formula     = gci ~ feeding,
#'   data        = breastfeedintell,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_2mean(
#'   formula    = gci ~ feeding,
#'   data       = breastfeedintell,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"breastfeedintell"

#' Number of Close Friends by Sex
#'
#' @description
#' Survey data on the number of close friends reported by male and female
#' respondents. Used in Chapter 6 of ISI for two-mean inference with a
#' large real-world sample. A useful example for discussing skewness and
#' validity conditions.
#'
#' @format A data frame with 1467 rows and 2 variables:
#' \describe{
#'   \item{sex}{\code{"Men"} or \code{"Women"}}
#'   \item{friends}{Number of close friends reported}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(closefriends)
#' test_2mean(
#'   formula     = friends ~ sex,
#'   data        = closefriends,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"closefriends"

# ── Chapter 7 -- Paired Data ───────────────────────────────────────────────────

#' First Base Running Times
#'
#' @description
#' Times for baseball players running to first base using a narrow turn
#' vs. a wide turn. Each player ran both ways, making this a classic
#' paired design. Used in Chapter 7 of ISI for paired inference.
#'
#' @format A data frame with 22 rows and 2 variables:
#' \describe{
#'   \item{narrow}{Time with a narrow turn (seconds)}
#'   \item{wide}{Time with a wide turn (seconds)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(firstbase)
#' test_paired(
#'   formula     = wide ~ narrow,
#'   data        = firstbase,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_paired(
#'   formula    = wide ~ narrow,
#'   data       = firstbase,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"firstbase"

#' Jumping Jacks vs. Bicycle Calories Burned
#'
#' @description
#' Calories burned by participants doing jumping jacks versus riding a
#' stationary bicycle. Each participant completed both exercises, making
#' this a paired design. Used in Chapter 7 of ISI to introduce the
#' paired T-test.
#'
#' @format A data frame with 22 rows and 2 variables:
#' \describe{
#'   \item{jj}{Calories burned doing jumping jacks}
#'   \item{bicycle}{Calories burned riding a stationary bicycle}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(jjvsbicycle)
#' test_paired(
#'   formula     = bicycle ~ jj,
#'   data        = jjvsbicycle,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"jjvsbicycle"

#' M&Ms Eaten from Small vs. Large Bowl
#'
#' @description
#' Number of M&Ms eaten by participants when served from a small versus
#' a large bowl. Each participant experienced both conditions, making
#' this a paired design. Used in Chapter 7 of ISI for paired inference.
#' A fun example illustrating how container size affects consumption.
#'
#' @format A data frame with 17 rows and 2 variables:
#' \describe{
#'   \item{small}{Number of M&Ms eaten from the small bowl}
#'   \item{large}{Number of M&Ms eaten from the large bowl}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(bowlsmms)
#' test_paired(
#'   formula     = large ~ small,
#'   data        = bowlsmms,
#'   alternative = "greater",
#'   method      = "theory"
#' )
"bowlsmms"

#' Dutch vs. First-Price Auction Bids
#'
#' @description
#' Bids placed by the same participants in two auction formats -- a Dutch
#' (descending price) auction and a first-price sealed-bid auction.
#' Because the same person bid in both formats, this is a paired design.
#' Used in Chapter 7 of ISI for paired inference.
#'
#' @format A data frame with 88 rows and 2 variables:
#' \describe{
#'   \item{dutch}{Bid amount in the Dutch auction}
#'   \item{fp}{Bid amount in the first-price sealed-bid auction}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(auction)
#' test_paired(
#'   formula     = fp ~ dutch,
#'   data        = auction,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#' ci_paired(
#'   formula    = fp ~ dutch,
#'   data       = auction,
#'   conf_level = 0.95,
#'   method     = "theory"
#' )
"auction"

# ── Chapter 10 -- Regression and Correlation ───────────────────────────────────

#' Body Temperature and Heart Rate
#'
#' @description
#' Body temperature and resting heart rate measurements from 130
#' individuals. A classic dataset used in Chapter 10 of ISI for regression
#' and correlation. Also widely used for one-mean inference on body
#' temperature (testing whether the true mean is 98.6 degrees F).
#'
#' @format A data frame with 130 rows and 2 variables:
#' \describe{
#'   \item{body_temp}{Body temperature (degrees Fahrenheit)}
#'   \item{heart_rate}{Resting heart rate (beats per minute)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(tempheart)
#'
#' # One-mean: is the average body temperature really 98.6 F?
#' test_1mean(
#'   formula     = ~ body_temp,
#'   data        = tempheart,
#'   null_mu     = 98.6,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
#'
#' # Correlation
#' explore_2vars(formula = heart_rate ~ body_temp, data = tempheart)
#' test_correlation(
#'   formula     = heart_rate ~ body_temp,
#'   data        = tempheart,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"tempheart"

#' Study Hours and GPA
#'
#' @description
#' Weekly study hours and GPA for a sample of 42 college students. Used
#' in Chapter 10 of ISI for simple linear regression and correlation.
#' Students often expect a positive relationship -- this dataset lets
#' them test that expectation formally.
#'
#' @format A data frame with 42 rows and 2 variables:
#' \describe{
#'   \item{hours}{Weekly study hours}
#'   \item{gpa}{Grade point average (0.0 to 4.0 scale)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(gpa)
#' explore_2vars(formula = gpa ~ hours, data = gpa, fit_line = TRUE)
#' test_regression(
#'   formula     = gpa ~ hours,
#'   data        = gpa,
#'   alternative = "greater",
#'   method      = "theory"
#' )
#' table_regression(formula = gpa ~ hours, data = gpa)
"gpa"

#' Facebook Friends and Network Density
#'
#' @description
#' Number of Facebook friends and network density scores for 40 users.
#' Network density measures how interconnected a user's friend network is.
#' Used in Chapter 10 of ISI for regression and correlation.
#'
#' @format A data frame with 40 rows and 2 variables:
#' \describe{
#'   \item{friends}{Number of Facebook friends}
#'   \item{density}{Network density score}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(facebook)
#' explore_2vars(formula = density ~ friends, data = facebook)
#' test_correlation(
#'   formula     = density ~ friends,
#'   data        = facebook,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"facebook"

#' Vietnam Draft Lottery
#'
#' @description
#' Draft numbers assigned in the 1969 Vietnam War lottery, matched to
#' sequential birth date (day of year 1-366). If the lottery was truly
#' random, there should be no correlation between birth date and draft
#' number. Used in Chapter 10 of ISI to test that randomness claim via
#' correlation inference.
#'
#' @format A data frame with 366 rows and 2 variables:
#' \describe{
#'   \item{sequential_date}{Day of the year (1 = January 1,
#'     366 = December 31)}
#'   \item{draft_number}{Assigned draft number (1 = called first,
#'     366 = called last)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(draftlottery)
#' explore_2vars(
#'   formula  = draft_number ~ sequential_date,
#'   data     = draftlottery,
#'   fit_line = TRUE
#' )
#' test_correlation(
#'   formula     = draft_number ~ sequential_date,
#'   data        = draftlottery,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"draftlottery"

#' Exercise Intensity and Mood Change
#'
#' @description
#' Change in mood score after exercise at varying intensity levels for 32
#' participants. Used in Chapter 10 of ISI for regression and correlation.
#' Explores whether higher exercise intensity is associated with greater
#' mood improvement.
#'
#' @format A data frame with 32 rows and 2 variables:
#' \describe{
#'   \item{exercise_intensity}{Exercise intensity level (numeric)}
#'   \item{change_mood}{Change in mood score after exercise (positive =
#'     mood improved, negative = mood worsened)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(exercisemood)
#' explore_2vars(
#'   formula  = change_mood ~ exercise_intensity,
#'   data     = exercisemood,
#'   fit_line = TRUE
#' )
#' test_regression(
#'   formula     = change_mood ~ exercise_intensity,
#'   data        = exercisemood,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"exercisemood"

#' Foot Length and Height
#'
#' @description
#' Foot length and height measurements from a sample of 20 individuals.
#' A simple, intuitive dataset for introducing regression and correlation
#' in Chapter 10 of ISI. Students can easily reason about the expected
#' direction of the relationship before running the analysis.
#'
#' @format A data frame with 20 rows and 2 variables:
#' \describe{
#'   \item{footlength}{Foot length (cm)}
#'   \item{height}{Height (inches)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(footheight)
#' explore_2vars(formula = height ~ footlength, data = footheight)
#' test_regression(
#'   formula     = height ~ footlength,
#'   data        = footheight,
#'   alternative = "greater",
#'   method      = "theory"
#' )
"footheight"

#' Alcohol Consumption and Smoking Status
#'
#' @description
#' Self-reported weekly alcohol consumption and smoking status from a
#' large health survey of 863 respondents. Useful for exploring the
#' association between a quantitative variable (drinks per week) and a
#' binary coded variable (ever smoked). Chapter 5 and 10 of ISI.
#'
#' @format A data frame with 863 rows and 2 variables:
#' \describe{
#'   \item{alcohol_drinks}{Number of alcoholic drinks consumed per week}
#'   \item{smoked}{Whether the respondent has ever smoked:
#'     \code{0} = No, \code{1} = Yes}
#' }
#' @note The \code{smoked} variable is coded numerically (0/1). Convert
#'   to a character variable for use with two-proportion functions:
#'   \code{alcoholsmoke$smoked_f <- ifelse(alcoholsmoke$smoked == 1, "Yes", "No")}
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(alcoholsmoke)
#' alcoholsmoke$smoked_f <- ifelse(alcoholsmoke$smoked == 1, "Yes", "No")
#' test_1prop(
#'   formula       = ~ smoked_f,
#'   data          = alcoholsmoke,
#'   success_level = "Yes",
#'   null_pi       = 0.25,
#'   alternative   = "two.sided",
#'   method        = "theory"
#' )
"alcoholsmoke"

#' Hand Width and Perceived Weight
#'
#' @description
#' Hand width measurements and perceived weight ratings from a study on
#' sensory perception. Used in Chapter 10 of ISI for regression and
#' correlation. Explores whether people with wider hands perceive objects
#' as heavier.
#'
#' @format A data frame with 46 rows and 2 variables:
#' \describe{
#'   \item{hand_width}{Hand width (cm)}
#'   \item{perceived_weight}{Perceived weight rating (higher = heavier)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(handwidth)
#' explore_2vars(formula = perceived_weight ~ hand_width, data = handwidth)
#' test_correlation(
#'   formula     = perceived_weight ~ hand_width,
#'   data        = handwidth,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"handwidth"

#' Exam Time and Scores
#'
#' @description
#' Time spent on an exam and the resulting score for 30 students. Used
#' in Chapter 10 of ISI to explore whether spending more time on an exam
#' is associated with a higher (or lower) score. Results often surprise
#' students and prompt good discussion about confounding.
#'
#' @format A data frame with 30 rows and 2 variables:
#' \describe{
#'   \item{time}{Time spent on the exam (minutes)}
#'   \item{score}{Exam score (points)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(examtimesscores)
#' explore_2vars(
#'   formula  = score ~ time,
#'   data     = examtimesscores,
#'   fit_line = TRUE
#' )
#' test_regression(
#'   formula     = score ~ time,
#'   data        = examtimesscores,
#'   alternative = "two.sided",
#'   method      = "theory"
#' )
"examtimesscores"

#' Dinner Plate Size Over Time
#'
#' @description
#' Average dinner plate diameter recorded across different years, from
#' 1950 onward. Used in Chapter 10 of ISI to discuss trends over time
#' and simple linear regression. Plates have gotten larger over the
#' decades -- but is the trend statistically significant?
#'
#' @format A data frame with 20 rows and 2 variables:
#' \describe{
#'   \item{year}{Year of measurement}
#'   \item{size}{Average plate diameter (inches)}
#' }
#' @source \url{http://www.isi-stats.com/isi/}
#' @examples
#' head(platesize)
#' explore_2vars(formula = size ~ year, data = platesize, fit_line = TRUE)
#' test_regression(
#'   formula     = size ~ year,
#'   data        = platesize,
#'   alternative = "greater",
#'   method      = "theory"
#' )
#' table_regression(formula = size ~ year, data = platesize)
"platesize"
#
