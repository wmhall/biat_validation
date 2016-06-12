library(dplyr)
library(readr)
library(purrr)
library(tidyr)
library(ggplot2)

source("R/fxwins.R")

file_names <- 
  c("ees_iat_clean.csv", "gss_iat_clean.csv")

#read in rts

rt_raw <- 
list.files(path = "data/preprocessed/", 
           pattern = paste(file_names, collapse = "|"), 
           full.names = T) %>% 
  map(read_csv) %>% bind_rows( .id = "study") %>% 
  mutate(study = ifelse(study == 1, "ees", "gss"))


#clean rts 

rt_clean <- 
rt_raw %>% 
  map_at(., "latency", ~ fxwins(.)) %>% 
  as_data_frame()

rt_clean %>%  
  ggplot(., aes(x = subject, y = latency)) + 
  geom_point() + facet_wrap(~study, scale = "free_x")  +
  stat_summary(fun.y = mean, colour = "red", 
               geom = "point", size = 5)


# compute d scores --------------------------------------------------------

means <- 
rt_clean %>% 
  group_by(subject, blockcode, block_type) %>% 
  summarise(mean_lat = mean(latency)) %>% 
  spread(blockcode, mean_lat) %>% 
  mutate(mean_diff = pair2 - pair1) %>% 
  select(-pair1, -pair2)

d_scores <- 
  rt_clean %>% 
  group_by(subject, block_type) %>% 
  summarise(sd_lat = sd(latency)) %>% 
  left_join(means, .) %>%
  mutate(d_score = mean_diff/ sd_lat) %>%
  select(subject, block_type, d_score) %>% 
  spread(block_type, d_score) %>% 
  right_join(., unique(select(rt_clean, subject, study)),
             by = "subject")

#calculate split half reliability

d_scores %>% 
  group_by(study) %>% 
  do(broom::tidy(cor.test(.$test1, .$test2)))


# look at error rates -----------------------------------------------------

error_rates <- 
rt_clean %>% 
  group_by(study, subject) %>% 
  summarise(perc_correct = mean(correct))

error_rates %>% 
  ggplot(., aes(x = subject, y = perc_correct)) +
  facet_wrap(~study, scale = "free_x") + geom_point() 


# look for people with outlying rts ---------------------------------------

outlier_rts <- 
rt_clean %>% 
  filter(latency == 400 | latency == 2000) %>% 
  group_by(subject) %>% 
  summarise(n_outliers = n()) %>%
  left_join(., unique(select(rt_clean, subject, study)))

outlier_rts %>% 
  ggplot(., aes(x = n_outliers)) + geom_histogram() +
  facet_wrap(~study, scale = "free_x") 


#fit models testing for mean differences in performance

fms <- 
plyr::join_all(list(rt_clean, error_rates, outlier_rts)) %>% 
  as_data_frame() %>% 
  mutate(n_outliers = ifelse(is.na(n_outliers), 0, 
                             n_outliers)) %>% 
  gather(var_name, score, latency, perc_correct, n_outliers) %>%
  nest(-var_name) %>%
  mutate(fm = map(data, ~lm(lm(score ~ 1 + study, data = .))), 
         fm_tidy = map(fm, ~ broom::tidy(., conf.int =T )))
  
fms_with_predictions <- 
  fms %>% 
  mutate(pred_grid = 
           map(data, ~ expand(.,study)), 
         predictions = 
           map2(fm, pred_grid, 
                ~data.frame(predict(.x, .y, 
                         interval = "confidence"))))


fms_with_predictions %>% 
  select(var_name, pred_grid, predictions) %>% 
  unnest() %>% 
  ggplot(., aes(x = study, y = fit, fill = study)) + 
  facet_wrap(~ var_name, scales = "free_y") +
  geom_bar(stat = "identity") + 
  geom_errorbar(aes(ymax = upr, ymin = lwr), width = .25)


fms_with_predictions %>% 
  select(var_name, predictions) %>% 
  unnest()

fms_with_predictions$predictions[[1]] %>% class

fms_with_predictions %>% 
  select(var_name, fm_tidy) %>% 
  unnest()