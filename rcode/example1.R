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

q_sim_plus <- run_swatplus(project_path = path_plus,
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
