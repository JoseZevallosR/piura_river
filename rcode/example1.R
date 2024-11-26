#https://chrisschuerz.github.io/SWATrunR/articles/SWATrunR.html#figures
library(SWATrunR)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyr)

# The path where the SWAT demo project will be written
demo_path <- 'D:/Proyectos_GitHub/piura_river/data'

# Loading a SWAT+ demo project
path_plus <- load_demo(dataset = 'project',
                       path = demo_path,
                       version = 'plus')

# Loading a SWAT2012 demo project
path_2012 <- load_demo(dataset = 'project',
                       path = demo_path,
                       version = '2012')

q_obs <- load_demo(dataset = 'observation')

q_obs

plot(q_obs, type = 'l')

q_sim_plus <- run_swatplus(project_path = path_plus,start_date = '2003-01-01',end_date = '2012-12-31',
                           output = define_output(file = 'channel_sd_day',
                                                  variable = 'flo_out',
                                                  unit = 1))

# Prepare the SWAT+ simulation output
q_plus <- q_sim_plus$simulation$flo_out %>%
  rename(q_plus = run_1) # Rename the output to q_plus

# Prepare the table for plotting
q_plot <- q_obs %>%
  rename(q_obs = discharge) %>% # Rename the discharge columnt to q_obs
  filter(year(date) %in% 2003:2012) %>% # Filter for years between 2003 and 2012
  left_join(., q_plus, by = 'date') %>% # Join with the q_plus table by date
  pivot_longer(., cols = -date, names_to = 'variable', values_to = 'discharge') # Make a long table for plotting

ggplot(data = q_plot) +
  geom_line(aes(x = date, y = discharge, col = variable, lty = variable)) +
  scale_color_manual(values = c('tomato3', 'black', 'steelblue3')) +
  scale_linetype_manual(values = c('dotted', 'solid', 'dashed')) +
  theme_bw()

par_comb <- c("cn2.hru | change = abschg | plant == 'corn'" = -5,
              'lat_ttime.hru | change = absval' = 0.5,
              'lat_len.hru | change = abschg' = 30,
              'epco.hru | change = absval' = 0.8,
              'esco.hru | change = absval' = 0.5,
              'perco.hru | change = absval' = 0.4,
              "k.sol | change = pctchg | hsg == 'C'" = 25,
              'awc.sol | change = pctchg' = -10,
              'alpha.aqu | change = absval' = 0.35)

q_sim_1 <- run_swatplus(project_path = path_plus,start_date = '2003-01-01',end_date = '2012-12-31',
                           output = define_output(file = 'channel_sd_day',
                                                  variable = 'flo_out',
                                                  unit = 1),
                        parameter = par_comb)

q_sim_1$parameter$values
q_sim_1$parameter$definition

# Adding a column that indicates the par change to q_sim1
q_sim_1 <- mutate(q_sim_1$simulation$flo_out, par_change = 'yes')

# Preparing the plot table
q_plot <- q_sim_plus$simulation$flo_out %>%
  mutate(., par_change = 'no') %>% # Also add par change column to q_sim_plus
  bind_rows(., q_sim_1) %>%
  rename(discharge = run_1)

ggplot(data = q_plot) +
  geom_line(aes(x = date, y = discharge, col = par_change, linetype = par_change)) +
  scale_color_manual(values = c('tomato3', 'steelblue3')) +
  scale_linetype_manual(values = c('solid', 'dashed')) +
  theme_bw()
