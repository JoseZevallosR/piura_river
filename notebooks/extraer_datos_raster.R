library(raster)
library(sp)
library(tidyverse)
# Define la ruta de la carpeta que contiene los archivos .tif
ruta_carpeta <- "D:\\AA UTP Cursos\\Hidrologia\\Datos\\Temperatura\\TMAX"


# Lista de archivos .tif en la carpeta
archivos_tif <- list.files(path = ruta_carpeta, pattern = "\\.tif$", full.names = TRUE)

# Coordenadas de las ubicaciones
ubicaciones <- data.frame(
  name = c("chalaco", "chusis", "huamarca", "huancabamba", "miraflores"),
  lon = c(-79.7917, -80.8333, -79.525, -79.717, -80.617),
  lat = c(-5.0369, -5.5167, -5.566, -5.25, -5.167),
  elev = c(50, 10, 2180, 1952, 30)
)

# Convertir a un objeto SpatialPoints
puntos <- SpatialPoints(ubicaciones[, c("lon", "lat")], proj4string = CRS("+proj=longlat +datum=WGS84"))

# Crear un data frame para almacenar los resultados
resultados <- data.frame()

# Iterar sobre los archivos .tif y extraer valores de temperatura para cada ubicación
for (archivo in archivos_tif) {
  # Cargar el archivo raster
  raster_tmax <- raster(archivo)
  
  # Extraer los valores de temperatura para cada punto
  valores <- extract(raster_tmax, puntos)
  
  # Extraer la fecha del nombre del archivo
  fecha <- gsub("Tmax_|\\.tif", "", basename(archivo))
  
  # Crear un data frame temporal para almacenar los resultados
  temp_df <- data.frame(name = ubicaciones$name, fecha = fecha, Tmax = valores)
  
  # Añadir los resultados al data frame final
  resultados <- rbind(resultados, temp_df)
}

# Mostrar los resultados
print(resultados)

# Reorganizar el data frame
resultados_formato <- resultados %>%
  pivot_wider(names_from = name, values_from = Tmax)

# Mostrar el resultado
print(resultados_formato)

write.csv(file = "tmax_piura.csv",resultados_formato,row.names = FALSE)
