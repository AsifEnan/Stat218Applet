## code to prepare `DATASET` dataset goes here

# data-raw/prepare_data.R
# this script  reads, cleans, and bundles all ISI datasets
# into the Stat218Applet package as .rda files.

library(readr)
library(janitor)
library(usethis)


data_dir <- "data-raw/isi_txt"

# ── Helper ────────────────────────────────────────────────────────────────────
read_isi_tsv   <- function(f) clean_names(read_tsv(file.path(data_dir, f),
                                                   show_col_types = FALSE))
read_isi_table <- function(f) clean_names(read_table(file.path(data_dir, f),
                                                     show_col_types = FALSE))

# ── Preliminaries ─────────────────────────────────────────────────────────────

# organdonor: Organ donor default choice study (Example P.1)
# Default = opt-in or opt-out default; Choice = donor or not
organdonor <- read_isi_tsv("organdonor.txt")

# oldfaithful: Old Faithful wait times by year (regression/correlation context)
# year = year of observation; time = wait time between eruptions (minutes)
oldfaithful <- read_isi_tsv("OldFaithful.txt")

# oldfaithful2: Old Faithful eruption type and wait times (one/two-mean context)
# eruption_type = "short" or "long"; time_between = wait time (minutes)
oldfaithful2 <- read_isi_tsv("OldFaithful2.txt")

# ── Chapter 2 — One Mean ──────────────────────────────────────────────────────

# timeestimate: Students estimated a time interval (one mean, test/CI)
# estimate = estimated time in seconds
timeestimate <- read_isi_tsv("TimeEstimate.txt")

# timepopulation: Full population of time estimates
# estimate = estimated time in seconds
timepopulation <- read_isi_tsv("TimePopulation.txt")

# sleeptimes: Student sleep hours (one mean, test/CI)
# sleep_hrs = hours of sleep per night
sleeptimes <- read_isi_tsv("SleepTimes.txt")

# haircuts: Haircut costs by sex (one mean / two mean)
# sex = Male or Female; cost = cost of haircut in dollars
haircuts <- read_isi_tsv("Haircuts.txt")

# ── Chapter 3 — One Mean (continued) ─────────────────────────────────────────

# usedcars: Prices of used Honda Civics (one mean, test/CI)
# price = sale price in dollars
usedcars <- read_isi_tsv("UsedCars.txt")

# ── Chapter 5 — Two Proportions ───────────────────────────────────────────────

# goodandbad: Perception of question wording (two proportions)
# wording = "Good" or "Bad" framing; perception = response
goodandbad <- read_isi_tsv("GoodandBad.txt")

# gilbert: Nurse Gilbert death/shift data (two proportions)
# gilbert_worked = whether Gilbert was on shift; patient = outcome
gilbert <- read_isi_tsv("Gilbert.txt")

# dolphin: Dolphin-assisted therapy swimming response (two proportions)
# swimming = treatment group; response = Improve or NoChange
dolphin <- read_isi_table("Dolphin.txt")

# yawning: Yawning contagion experiment (two proportions)
# yawn_seed = Seeded or NotSeeded; response = Yawn or NoYawn
yawning <- read_isi_table("Yawning.txt")

# smoking: Parental smoking and child smoking status (two proportions)
# parents = parental smoking status; child = child smoking status
smoking <- read_isi_tsv("Smoking.txt")

# blood: Blood donor response by year (one/two proportions over time)
# year = year of study; response = donor response category
blood <- read_isi_tsv("Blood.txt")

# ── Chapter 6 — Two Means ─────────────────────────────────────────────────────

# biketimes: Bike frame type and ride times (two means)
# frame = bike frame type; time = ride time in minutes
biketimes <- read_isi_tsv("BikeTimes.txt")

# sleep: Sleep deprivation and reaction time (two means)
# sleep = sleep condition; time = reaction time in milliseconds
sleep <- read_isi_tsv("Sleep.txt")

# breastfeedintell: Breastfeeding and child intelligence (two means)
# feeding = breastfed or not; gci = general cognitive index score
breastfeedintell <- read_isi_tsv("BreastFeedIntell.txt")

# closefriends: Number of close friends by sex (two means)
# sex = Male or Female; friends = number of close friends
closefriends <- read_isi_tsv("CloseFriends.txt")

# ── Chapter 7 — Paired Data ───────────────────────────────────────────────────

# firstbase: First base running times, narrow vs wide turn (paired)
# narrow = time with narrow turn (sec); wide = time with wide turn (sec)
firstbase <- read_isi_tsv("FirstBase.txt")

# jjvsbicycle: Jump rope vs bicycle exercise calories (paired)
# jj = jumping jacks calories; bicycle = bicycle calories
jjvsbicycle <- read_isi_tsv("JJvsBicycle.txt")

# bowlsmms: M&Ms eaten from small vs large bowl (paired)
# small = count from small bowl; large = count from large bowl
bowlsmms <- read_isi_tsv("BowlsMMs.txt")

# auction: Dutch vs first-price auction bids (paired)
# dutch = Dutch auction bid; fp = first-price auction bid
auction <- read_isi_tsv("Auction.txt")

# ── Chapter 9 / 10 — Regression and Correlation ───────────────────────────────

# tempheart: Body temperature and heart rate (regression/correlation)
# body_temp = body temperature in Fahrenheit; heart_rate = beats per minute
tempheart <- read_isi_tsv("TempHeart.txt")

# gpa: Study hours and GPA (regression/correlation)
# hours = weekly study hours; gpa = grade point average
gpa <- read_isi_tsv("GPA.txt")

# facebook: Facebook friends and network density (regression/correlation)
# friends = number of Facebook friends; density = network density
facebook <- read_isi_tsv("Facebook.txt")

# draftlottery: Vietnam draft lottery numbers by date (regression/correlation)
# sequential_date = day of year; draft_number = assigned draft number
draftlottery <- read_isi_tsv("DraftLottery.txt")

# exercisemood: Exercise intensity and mood change (regression/correlation)
# exercise_intensity = intensity level; change_mood = change in mood score
exercisemood <- read_isi_tsv("ExerciseMood.txt")

# footheight: Foot length and height (regression/correlation)
# footlength = foot length in cm; height = height in inches
footheight <- read_isi_table("FootHeight.txt")

# alcoholsmoke: Alcohol consumption and smoking status (two proportions / regression)
# alcohol_drinks = number of drinks; smoked = Yes or No
alcoholsmoke <- read_isi_tsv("AlcoholSmoke.txt")

# handwidth: Hand width and perceived weight (regression/correlation)
# hand_width = hand width in cm; perceived_weight = perceived weight rating
handwidth <- read_isi_tsv("Handwidth.txt")

# examtimesscores: Exam time and scores (regression/correlation)
# time = time spent on exam (minutes); score = exam score
examtimesscores <- read_isi_tsv("ExamTimesScores.txt")

# platesize: Plate size over years (regression/correlation)
# year = year; size = plate diameter in inches
platesize <- read_isi_tsv("PlateSize.txt")

# ── Save all datasets as .rda files ───────────────────────────────────────────
# Each dataset gets its own .rda file in data/
# overwrite = TRUE so re-running this script always refreshes the files

use_data(organdonor,       overwrite = TRUE)
use_data(oldfaithful,      overwrite = TRUE)
use_data(oldfaithful2,     overwrite = TRUE)
use_data(timeestimate,     overwrite = TRUE)
use_data(timepopulation,   overwrite = TRUE)
use_data(sleeptimes,       overwrite = TRUE)
use_data(haircuts,         overwrite = TRUE)
use_data(usedcars,         overwrite = TRUE)
use_data(goodandbad,       overwrite = TRUE)
use_data(gilbert,          overwrite = TRUE)
use_data(dolphin,          overwrite = TRUE)
use_data(yawning,          overwrite = TRUE)
use_data(smoking,          overwrite = TRUE)
use_data(blood,            overwrite = TRUE)
use_data(biketimes,        overwrite = TRUE)
use_data(sleep,            overwrite = TRUE)
use_data(breastfeedintell, overwrite = TRUE)
use_data(closefriends,     overwrite = TRUE)
use_data(firstbase,        overwrite = TRUE)
use_data(jjvsbicycle,      overwrite = TRUE)
use_data(bowlsmms,         overwrite = TRUE)
use_data(auction,          overwrite = TRUE)
use_data(tempheart,        overwrite = TRUE)
use_data(gpa,              overwrite = TRUE)
use_data(facebook,         overwrite = TRUE)
use_data(draftlottery,     overwrite = TRUE)
use_data(exercisemood,     overwrite = TRUE)
use_data(footheight,       overwrite = TRUE)
use_data(alcoholsmoke,     overwrite = TRUE)
use_data(handwidth,        overwrite = TRUE)
use_data(examtimesscores,  overwrite = TRUE)
use_data(platesize,        overwrite = TRUE)

message("Done! All ", 32, " datasets saved to data/")
