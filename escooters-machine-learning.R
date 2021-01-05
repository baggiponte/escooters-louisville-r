# Load Packages ####

# for reproducibility
set.seed(42)

library(tidymodels)
library(tidyverse)

# for skimming data
library(skimr)

# for downsampling
library(themis)

# for visualising importance of predictors
library(vip)

# Load Data ####

url = 'https://raw.githubusercontent.com/baggiponte/escooters-louisville/main/data/escooters_od.csv'

trips <-
  # read the data
  read_csv(url, col_types = cols(
    StartTime = col_datetime(format = '%Y-%m-%d %H:%M:%S')
  )) %>%
  # remove unneded cols
  select(-TripID, -EndTime) %>%
  # remove the outliers
  filter(
    # Duration between 0 and 30 minutes
    Duration > 0 & Duration <= 30 &
      # Distance between 0 and 5km
      Distance > 0 & Distance <= 5000
  ) %>%
  # manipulate cols:
  mutate(
    # turn into factors
    StartNH = as.factor(StartNH),
    EndNH = as.factor(EndNH),
    # first covid death reported is on March 21st, 2020
    Covid = as.factor(ifelse(StartTime > '2020-03-20 23:59:59', 1, 0))
  ) %>%
  # reduce the number of levels in the factor features
  mutate(
    # select those with p > 10e-02
    StartNH = fct_lump(StartNH, 5),
    EndNH = fct_lump(EndNH, 5)
  ) %>%
  select(-Duration, -Distance,
         -EndLongitude, -EndLatitude
  ) %>%
  as_tibble()

skim(trips)

# Split in Train and test ####

trips_split <- initial_split(trips, strata = EndNH)

trips_train <- training(trips_split)
trips_test <- testing(trips_split)

## test proportions
trips_train %>%
  count(EndNH) %>%
  mutate(prop = n/sum(n)) %>%
  arrange(desc(prop))

trips_test %>%
  count(EndNH) %>%
  mutate(prop = n/sum(n)) %>%
  arrange(desc(prop))

# Define the recipe ####

trips_recipe <- trips_train %>%
  recipe(EndNH ~ .) %>%
  # problem: step_date does not extract times!
  step_mutate(HourNum = format(strptime(StartTime,'%Y-%m-%d %H:%M:%S'),'%H')) %>%
  # turn it into a factor
  step_string2factor(HourNum) %>%
  # create factors out of StartTime
  step_date(StartTime, features = c('dow', 'month', 'year')) %>%
  # create holiday dummy:
  step_holiday(StartTime, holidays = timeDate::listHolidays("US")) %>%
  # remove StartTime col
  step_rm(StartTime) %>%
  # turn factor-features into binary dummies (i.e. one per column: 1-0):
  step_dummy(all_nominal(), -all_outcomes()) %>%
  # remove predictors with zero variance:
  step_zv(all_predictors()) %>%
  # downsample the data
  themis::step_downsample(EndNH, under_ratio = 1)

# Logistic Regression Specification ####
show_engines('multinom_reg')

## 'classification' is the default mode
logistic_model <- multinom_reg(penalty = 0) %>%
  set_engine('glmnet') # this is actually the default

## Create a workflow ####

logistic_workflow <- workflow() %>%
  add_recipe(trips_recipe) %>%
  add_model(logistic_model)

logistic_workflow

## Model Fitting

logistic_fit <- logistic_workflow %>%
  fit(data = trips_train)

logistic_fit %>%
  pull_workflow_fit() %>%
  tidy() %>%
  select(-penalty)

### Visualise contributions
logistic_fit %>%
  pull_workflow_fit() %>%
  vip()
