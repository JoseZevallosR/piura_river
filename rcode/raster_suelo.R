# Definir la ruta donde se escribirá el proyecto de demostración de SWAT
demo_path <- 'D:/Proyectos_GitHub/piura_river/data'

# Cargar librerías necesarias
library(raster)   # Para manejar datos raster
library(dplyr)    # Para manipulación de datos

# Establecer el directorio de trabajo al definido en demo_path
setwd(demo_path)

# Cargar el archivo raster del suelo
suelo <- raster("SOIL.b1.tif")

# Obtener los valores únicos del raster 'suelo'
ids_suelo <- unique(suelo[])
print(ids_suelo)  # Mostrar los valores únicos del raster 'suelo'

# Cargar el archivo CSV con las equivalencias del suelo
equivalencias <- read.csv('Soil_lookup.csv')

# Mostrar las primeras filas del archivo de equivalencias
head(equivalencias)

# Obtener los IDs únicos presentes en la tabla de equivalencias
ids_equivalencias <- unique(equivalencias$SOIL_ID)
print(ids_equivalencias)  # Mostrar los IDs únicos en equivalencias

# Identificar los IDs que faltan en la tabla de equivalencias
ids_faltantes <- setdiff(ids_suelo, ids_equivalencias)

# Crear una nueva tabla con los IDs faltantes y asignarles nombres genéricos
nuevos_ids <- data.frame(
  SOIL_ID = ids_faltantes,
  SNAM = paste0("DSOLMap_", ids_faltantes)  # Generar nombres genéricos basados en el ID
)

# Combinar la tabla original de equivalencias con la nueva tabla de IDs faltantes
equivalencias_actualizada <- bind_rows(equivalencias, nuevos_ids)

# Mostrar la tabla actualizada con todos los IDs
print(equivalencias_actualizada)

# Guardar la tabla actualizada en un nuevo archivo CSV
write.csv(equivalencias_actualizada, 'Soil_lookup2.csv', row.names = FALSE)

