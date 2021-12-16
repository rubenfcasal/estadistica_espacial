#' ---
#' title: "Estadística Espacial"
#' author: "Análisis estadístico de datos con dependencia (GCED)"
#' date: "Curso 2021/2022"
#' output:
#'   html_document:
#'      toc: yes
#'      toc_float: yes
#' ---
#'
#' # Análisis de datos geoestadísticos con tendencia
#' 
#' 
#' Carga de datos y creación del objeto `sf`:
#' 
load("datos/aquifer.RData")
library(sf)
aquifer$head <- aquifer$head/100 # en cientos de pies
aquifer_sf <- st_as_sf(aquifer, coords = c("lon", "lat"), remove = FALSE, agr = "constant")
# remove = FALSE mantiene las coordenadas como posibles variables explicativas
#' 
#' ## Análisis exploratorio
#' 
#' Análisis descriptivo unidimensional:
#' 
z <- aquifer_sf$head
summary(z)
hist(z, xlab = "piezometric-head", main = "", freq = FALSE)
lines(density(z), col = 'blue')

#' 
#' Distribución espacial:
#' 
plot(aquifer_sf["head"], pch = 20, cex = 3, breaks = "quantile", nbreaks = 4)

#'
#' Gráficos de dispersión de la respuesta frente a coordenadas:
#+ fig.dim = c(12, 6), out.width = "100%"
x <- aquifer_sf$lon
y <- aquifer_sf$lat
old.par <- par(mfrow = c(1, 2), omd = c(0.05, 0.95, 0.01, 0.95))
plot(x, z)
lines(lowess(x, z), lty = 2, lwd = 2, col = 'blue')
plot(y, z)
lines(lowess(y, z), lty = 2, lwd = 2, col = 'blue')
par(old.par)

#'
#' Consideraremos el modelo lineal `head ~ lat + lon` para la tendencia:
#'

trend.ols <- lm(head ~ lat + lon, data = aquifer_sf)
summary(trend.ols)
z <- residuals(trend.ols)
summary(z)
hist(z, xlab = "ols residuals", main = "", freq = FALSE)
lines(density(z), col = 'blue')

#' 
#' ## Modelado de la dependencia
#' 
#' Estimaciones empíricas del semivariograma:
#' 
library(gstat)
# maxlag <- 0.5*sqrt(sum(diff(matrix(st_bbox(aquifer_sf), nrow = 2, byrow = TRUE))^2))
maxlag <- 150
vario <- variogram(head ~ lon + lat, aquifer_sf, cutoff = maxlag)    
#' 
#' Ajuste por WLS de un modelo válido:
#' 
modelo <- vgm(model = "Sph", nugget = NA) # Valores iniciales por defecto
# modelo <- vgm(psill = 3, model = "Sph", range = 75, nugget = 0) 
fit <- fit.variogram(vario, modelo, fit.method = 2)
#'
#'  Parámetros estimados
fit
nugget <- fit$psill[1]
sill <- nugget + fit$psill[2]
range <- fit$range[2]
#'
#'  Error ajuste (para comparar el ajuste de distintos modelos)
attr(fit, "SSErr")

#' 
#' Representación del ajuste:
#' 
# Cuidado con plot.variogramModel() si se pretende añadir elementos
# plot(fit, cutoff = maxlag, ylim = c(0, 4.5))
# with(vario,  points(dist, gamma))
#' Para representar las estimaciones empíricas junto con un único ajuste, se 
#' podría emplear plot.gstatVariogram()
plot(vario, fit)
#' Para añadir más elementos mejor hacerlo "a mano":
with(vario, plot(dist, gamma, xlab = "distance", ylab =  "semivariance", 
                       xlim = c(0, maxlag), ylim = c(0, 5)))
lines(variogramLine(fit, maxdist = maxlag))
nugget <- fit$psill[1]
sill <- nugget + fit$psill[2]
range <- fit$range[2]
abline(v = 0, lty = 3)
abline(v = range, lty = 3)
abline(h = nugget, lty = 3)
abline(h = sill, lty = 3)

#' 
#' ## Predicción espacial (KU)
#' 
#' Rejilla de predicción
#' (consideramos un buffer de radio 40 en torno a las posiciones espaciales)

buffer <- aquifer_sf %>% st_geometry() %>% st_buffer(40)

#' En lugar de emplear una rejilla `sf`
# grid <- buffer %>% st_make_grid(n = c(50, 50), what = "centers") %>% st_intersection(buffer)
#' 
#' por comodidad es preferible emplear una rejilla `stars`
library(stars)
grid <- buffer %>%  st_as_stars(nx = 50, ny = 50) %>% st_crop(buffer) 

#' Añadir variables explicativas al grid
coord <- st_coordinates(grid)
grid$lon <- coord$x
grid$lat <- coord$y

#' 
#' Recortar
grid <- grid %>% st_crop(buffer) 

#' 
#' Kriging universal
pred <- krige(formula = head ~ lon + lat, locations = aquifer_sf, model = fit, 
              newdata = grid)

#' 
#' ***ERROR en krige***: cambia las coordenadas del objeto stars
summary(st_coordinates(grid))
summary(st_coordinates(pred))

#' Posible solución: añadir el resultado a grid
grid$var1.pred <- pred$var1.pred
grid$var1.var <- pred$var1.var

#' 
#' Representar
plot(grid["var1.pred"], breaks = "equal", col = hcl.colors(64), key.pos = 4,
     main = "Predicciones kriging")


plot(grid["var1.var"], breaks = "equal", col = hcl.colors(64), key.pos = 4,
     main = "Varianzas kriging")

#' 
#' Representar con ggplot2
#+ fig.dim = c(12, 7), out.width = "100%"
library(ggplot2)
library(gridExtra)
p1 <- ggplot() + geom_stars(data = grid, aes(fill = var1.pred, x = x, y = y)) + 
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
p2 <- ggplot() + geom_stars(data = grid, aes(fill = var1.var, x = x, y = y)) + 
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
grid.arrange(p1, p2, ncol = 2)  