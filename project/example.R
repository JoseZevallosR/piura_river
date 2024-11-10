# If the package remotes is not installed run first:
install.packages("remotes")
remotes::install_github("chrisschuerz/SWATrunR")

library(SWATrunR)

# The path where the SWAT demo project will be written
demo_path <- "~/GitHub/piura_river/project"

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
