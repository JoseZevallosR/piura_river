library(DEoptim)
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


q_obs <- load_demo(dataset = 'observation')

objective_function <- function(par) {
  library(dplyr)
  # Create a named vector for par_comb
  par_comb <- c(
    "cn2.hru | change = abschg | plant == 'corn'" = par[1],
    "lat_ttime.hru | change = absval" = par[2],
    "lat_len.hru | change = abschg" = par[3],
    "epco.hru | change = absval" = par[4],
    "esco.hru | change = absval" = par[5],
    "perco.hru | change = absval" = par[6]
  )
  
  print(par_comb)  # Debugging step
  
  # Run SWAT+ simulation
  q_sim <- tryCatch(
    {
      run_swatplus(
        project_path = path_plus,
        start_date = '2003-01-01',
        end_date = '2012-12-31',
        output = define_output(file = 'channel_sd_day', variable = 'flo_out', unit = 1),
        parameter = par_comb
      )
    },
    error = function(e) {
      message("Error in SWAT+ simulation: ", e$message)
      return(NULL)
    }
  )
  
  if (is.null(q_sim)) {
    warning("SWAT+ simulation returned NULL.")
    return(Inf)
  }
  
  print(str(q_sim))  # Inspect the structure of q_sim
  
  # Extract simulated data
  if (!"run_1" %in% colnames(q_sim[["simulation"]][["flo_out"]])) {
    warning("'run_1' column is missing in simulation output.")
    return(Inf)
  }
  simulated <- q_sim[["simulation"]][["flo_out"]][["run_1"]]
  
  # Filter observed data
  q_obs_filtered <- q_obs %>%
    filter(date >= as.Date("2003-01-01") & date <= as.Date("2012-12-31"))
  
  if (nrow(q_obs_filtered) != length(simulated)) {
    warning("Mismatch in lengths of observed and simulated data.")
    return(Inf)
  }
  
  observed <- q_obs_filtered$discharge
  rmse <- sqrt(mean((simulated - observed)^2, na.rm = TRUE))
  
  print(paste("RMSE:", rmse))
  return(rmse)
}

lower_bounds <- c(-15, 0.05, 10, 0.3, 0.2, 0.1)  # Example expanded bounds
upper_bounds <- c(15, 1.5, 70, 1.2, 0.8, 0.7)
# Register parallel backend (use all available cores minus one)
cl <- makeCluster(detectCores() - 1)
clusterExport(cl, c("q_obs", "path_plus", "define_output", "run_swatplus","lower_bounds","upper_bounds"))
registerDoParallel(cl)

clusterEvalQ(cl, {
  library(dplyr)
  library(hydroGOF)
  # Load any other libraries used in the objective function
})

result <- DEoptim(
  fn = objective_function,
  lower = lower_bounds,
  upper = upper_bounds,
  control = DEoptim.control(
    trace = TRUE,
    itermax = 200,
    NP = 10 * length(lower_bounds),  # Larger population size
    CR = 0.9,
    F = 0.9,
    parallelType = 2
  )
)


stopCluster(cl)

clusterEvalQ(cl, ls())


# test_par <- c(-5, 0.5, 30, 0.8, 0.5, 0.4)  # Example parameter vector
# objective_function(test_par)
# 
# clusterExport(cl, c("q_obs", "path_plus", "define_output", "run_swatplus", "test_par"))
# clusterEvalQ(cl, {
#   library(dplyr)
#   library(hydroGOF)
# })
# 
# test_par <- c(-5, 0.5, 30, 0.8, 0.5, 0.4)
# results <- parLapply(cl, list(test_par), objective_function)
# print(results)

# result$optim$bestmem
# par1       par2       par3       par4       par5       par6 
# -7.5231119  1.3536654 46.9701171  0.3014053  0.2476362  0.5957911