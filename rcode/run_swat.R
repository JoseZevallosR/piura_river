#https://chrisschuerz.github.io/SWATrunR/articles/SWATrunR.html#figures
library(SWATrunR)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyr)

# The path where the SWAT demo project will be written
demo_path <- 'D:/Proyectos_GitHub/piura_river/data/TxtInOut6/'

q_sim_plus <- run_swatplus(project_path = demo_path,start_date = '1982-01-01',end_date = '1982-12-31',
                           output = define_output(file = 'channel_sd_day',
                                                  variable = 'flo_out',
                                                  unit = 1),years_skip = 0)
q_sim_plus

q_sim_plus$error_report$message

list.files(demo_path, full.names = TRUE)

file_path <- paste0(demo_path, "topography.hyd")  # Ensure correct path

topography_data <- read.table(file_path, header = FALSE, sep = "", stringsAsFactors = FALSE, fill = TRUE, skip = 2)

# Rename columns manually
colnames(topography_data) <- c("name", "slope", "slp_len", "lat_len", "dist_cha",
                               "depos")  # Adjust as needed

head(topography_data)  # Check the structure again

topography_data$slope[topography_data$slope == 0] <- 0.01

sum(topography_data$slope == 0)
which(topography_data$slope==0)

file_path <- paste0(demo_path, "hydrology.hyd")
# Read the file, skipping metadata
hydrology_data <- read.table(file_path, header = FALSE, sep = "", stringsAsFactors = FALSE, skip = 2)

# Assign column names
colnames(hydrology_data) <- c("name", "lat_ttime", "lat_sed", "can_max", "esco", "epco",
                              "orgn_enrich", "orgp_enrich", "cn3_swf", "bio_mix", "perco",
                              "lat_orgn", "lat_orgp", "pet_co", "latq_co")

# Replace zero values in key columns
hydrology_data$lat_ttime[hydrology_data$lat_ttime == 0] <- 0.01
hydrology_data$lat_sed[hydrology_data$lat_sed == 0] <- 0.01
hydrology_data$lat_orgn[hydrology_data$lat_orgn == 0] <- 0.01
hydrology_data$lat_orgp[hydrology_data$lat_orgp == 0] <- 0.01

# Save the corrected file
write.table(hydrology_data, file = file_path, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")

print("Hydrology file updated! Try rerunning SWAT+.")


file_path <- paste0(demo_path, "soils.sol")
# Read the file, skipping metadata
soil_data <- read.table(file_path, header = FALSE, sep = "", stringsAsFactors = FALSE, skip = 2, fill = TRUE)

# Assign column names
colnames(soil_data) <- c("name", "nly", "hyd_grp", "dp_tot", "anion_excl", "perc_crk",
                         "texture", "dp", "bd", "awc", "soil_k", "carbon", "clay",
                         "silt", "sand", "rock", "alb", "usle_k", "ec", "caco3", "ph")

# Fix low values
soil_data$dp_tot[soil_data$dp_tot < 300] <- 300  # Minimum depth = 300 mm
soil_data$awc[soil_data$awc < 0.05] <- 0.05  # Ensure AWC is at least 0.05
soil_data$soil_k[soil_data$soil_k < 5] <- 5  # Ensure Soil K is at least 5 mm/hr

# Save the corrected file
write.table(soil_data, file = file_path, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")

print("Soil file updated! Try rerunning SWAT+.")

library(data.table)

# Define file path
file_path <- "D:/Proyectos_GitHub/piura_river/data/TxtInOut6/hyd-sed-lte.cha"

# Read file into R
lines <- readLines(file_path)

# Identify the data section (skip header)
data_start <- grep("^hydcha", lines)

# Read data into a dataframe
data <- fread(text = paste(lines[data_start], collapse = "\n"), sep = " ", header = FALSE)

# Find the 'fps' column (assumed to be the 18th column based on your data)
fps_col <- 18  # Adjust if column position is different

# Convert column to numeric
data[[fps_col]] <- as.numeric(data[[fps_col]])

# Replace fps values lower than 0.001
data[[fps_col]][data[[fps_col]] < 0.001] <- 0.001

# Convert data back to text
fixed_lines <- c(lines[1:(data_start - 1)], apply(data, 1, paste, collapse = " "))

# Save the corrected file
writeLines(fixed_lines, file_path)

# Load required package
library(data.table)

# Define file path
file_path <- "D:/Proyectos_GitHub/piura_river/data/TxtInOut6/channel_sd_day.txt"

# Read the data (assuming it's space-separated)
data <- fread(file_path, skip = 2)  # Skip headers

# Identify columns (change if necessary)
flo_out_col <- 42  # Position of "flo_out" (adjust if needed)

# Count rows where flo_out is zero
zero_flo_out <- sum(data[[flo_out_col]] == 0)

cat("🚨 Channels with zero outflow (flo_out):", zero_flo_out, "\n")

# View rows where flo_out is zero
print(data[data[[flo_out_col]] == 0, ])
