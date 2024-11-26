#############################################################################
## Set up objective function to minimize
#############################################################################

library(PerformanceAnalytics)
library(DEoptim)
library(doSNOW)
library(parallel)

# Load data
load("10y_returns.rda")
load("random_portfolios.rda")

# Select relevant data
rng <- 1:30
R <- R[, rng]
rp <- rp[1:300, rng]

# Calculate higher moments
m3 <- PerformanceAnalytics:::M3.MM(R)
m4 <- PerformanceAnalytics:::M4.MM(R)

# Parameters
mu <- colMeans(R)
sigma <- cov(R)
N <- ncol(R)
lower <- rep(0, N)
upper <- rep(1, N)

# Objective function
obj <- function(w) {
  if (sum(w) == 0) w <- w + 1e-2
  w <- w / sum(w)
  CVaR <- ES(weights = w, method = "modified",
             portfolio_method = "component", mu = mu, sigma = sigma, m3 = m3, m4 = m4)
  tmp1 <- CVaR$MES
  tmp2 <- max(CVaR$pct_contrib_MES - 0.05, 0)
  out <- tmp1 + 1e3 * tmp2
  return(out)
}

#############################################################################
## Call DEoptim on one CPU
#############################################################################

# Control parameters for single-core execution
controlDE <- list(NP = nrow(rp), initialpop = rp, trace = 1, itermax = 5,
                  reltol = 1e-6, steptol = 150, c = 0.4, strategy = 6,
                  parallelType = 0)

# Execute optimization on one core
set.seed(1234)
timeONECORE <- system.time(out1 <- DEoptim(fn = obj, lower = lower, upper = upper,
                                           control = controlDE))
out1$optim$iter
out1$optim$bestval

#############################################################################
## Call DEoptim on multiple CPUs using the parallel package
#############################################################################

# Control parameters for multi-core execution with parallel package
controlDE1 <- list(NP = nrow(rp), initialpop = rp, trace = 1, itermax = 5,
                   reltol = 1e-6, steptol = 150, c = 0.4, strategy = 6,
                   parallelType = 1,
                   packages = list("PerformanceAnalytics"),
                   parVar = list("mu", "sigma", "m3", "m4"))

set.seed(1234)

# Execute optimization on all cores using parallel package
timeALLCORES1 <- system.time(out2 <- DEoptim(fn = obj, lower = lower, upper = upper,
                                             control = controlDE1))

#############################################################################
## Call DEoptim on multiple CPUs using the foreach package
#############################################################################

# Detect number of available cores
nC <- detectCores()

# Set up cluster
cl <- makeSOCKcluster(nC)

# Load required packages on each cluster node
clusterEvalQ(cl, library(PerformanceAnalytics))

# Export necessary objects to each node
clusterExport(cl, list("mu", "sigma", "m3", "m4"))

# Register cluster for foreach
registerDoSNOW(cl)

# Control parameters for multi-core execution with foreach package
controlDE <- list(NP = nrow(rp), initialpop = rp, trace = 1, itermax = 5,
                  reltol = 1e-6, steptol = 150, c = 0.4, strategy = 6,
                  parallelType = 2)

# Execute optimization on all cores using foreach package
set.seed(1234)
timeALLCORES2 <- system.time(out2 <- DEoptim(fn = obj, lower = lower, upper = upper,
                                             control = controlDE))

# Stop cluster
stopCluster(cl)

# Compare timings
timeONECORE
timeALLCORES1
timeALLCORES2
