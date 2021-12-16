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
#' # Análisis de datos geoestadísticos sin tendencia
#' 
#' 
#' Carga de datos y creación del objeto `sf`:
#' 
library(sf)
data(s100, package = "geoR")
# library(geoR)
# summary(s100)
# plot(s100)

datos <- st_as_sf(data.frame(s100$coords, z = s100$data), 
                  coords = 1:2, agr = "constant")

#' 
#' ## Análisis exploratorio
#' 
#' Análisis descriptivo unidimensional:
#'
z <- datos$z
summary(z)
hist(z, main = "", freq = FALSE)
lines(density(z), col = 'blue')

#' 
#' Distribución espacial:
#' 
plot(datos, pch = 20, cex = 3, breaks = "quantile", nbreaks = 4)

#'
#' Gráficos de dispersión de la respuesta frente a coordenadas:
#+ fig.dim = c(12, 6), out.width = "100%"
coord <- st_coordinates(datos)
old.par <- par(mfrow = c(1, 2), omd = c(0.05, 0.95, 0.01, 0.95))
plot(coord[, 1], z, xlab = "x", ylab = "z")
lines(lowess(coord[, 1], z), lty = 2, lwd = 2, col = 'blue')
plot(coord[, 2], z, xlab = "y", ylab = "z")
lines(lowess(coord[, 2], z), lty = 2, lwd = 2, col = 'blue')
par(old.par)

#' 
#' ## Modelado de la dependencia
#' 
#' Asumiremos tendencia constante.
#' 
#' Estimaciones empíricas del semivariograma:
#' 
library(gstat)
# maxlag <- 0.5*sqrt(sum(diff(matrix(st_bbox(datos), nrow = 2, byrow = TRUE))^2))
maxlag <- 0.6
vario <- variogram(z ~ 1, datos, cloud = FALSE, cutoff = maxlag)
#' 
#' Ajuste por WLS de un modelo válido:
#' 
modelo <- vgm(model = "Exp", nugget = NA)
fit <- fit.variogram(vario, model = modelo, fit.method = 2) 
#'
#'  Parámetros estimados
fit
nugget <- fit$psill[1]
sill <- nugget + fit$psill[2]
range <- 3*fit$range[2] # Parámetro de escala en model = "Exp"
#'
#'  Error ajuste (para comparar el ajuste de distintos modelos)
attr(fit, "SSErr")
#' 
#' Para representar las estimaciones empíricas junto con un único ajuste, se 
#' podría emplear plot.gstatVariogram()
#' 
plot(vario, fit)
#' Para añadir más elementos mejor hacerlo "a mano":

plot(vario$dist, vario$gamma, xlab = "distance", ylab =  "semivariance", 
     xlim = c(0, range*1.1), ylim = c(0, sill*1.1))
lines(variogramLine(fit, maxdist = range*1.1))
abline(v = 0, lty = 3)
abline(v = range, lty = 3)
abline(h = nugget, lty = 3)
abline(h = sill, lty = 3)

#' 
#' ## Predicción espacial (KO)
#' 
#' Rejilla de predicción
#' (consideramos un buffer de radio 0.1 en torno a las posiciones espaciales)
#'  
#' En lugar de emplear una rejilla `sf`
# grid <- st_make_grid(datos, n = c(30, 30), what = "centers")
#' 
#' por comodidad es preferible emplear una rejilla `stars`
library(stars)
grid <- st_geometry(datos) %>% st_buffer(0.1) %>% st_bbox() %>%  
  st_as_stars(nx = 30, ny = 30) # %>% st_crop(poligono) 

#' 
#' Kriging ordinario
pred <- krige(formula = z ~ 1, locations = datos, model = fit, 
              newdata = grid)

#' 
#' Representar
plot(pred["var1.pred"], breaks = "equal", col = hcl.colors(64), key.pos = 4,
     main = "Predicciones kriging")


plot(pred["var1.var"], breaks = "equal", col = hcl.colors(64), key.pos = 4,
     main = "Varianzas kriging")

#' 
#' Representar con ggplot2
#+ fig.dim = c(12, 7), out.width = "100%"
library(ggplot2)
library(gridExtra)
p1 <- ggplot() + geom_stars(data = pred, aes(fill = var1.pred, x = x, y = y)) + 
    scale_fill_viridis_c() + geom_sf(data = datos) +
    coord_sf(lims_method = "geometry_bbox")
p2 <- ggplot() + geom_stars(data = pred, aes(fill = var1.var, x = x, y = y)) + 
    scale_fill_viridis_c() + geom_sf(data = datos) +
    coord_sf(lims_method = "geometry_bbox")
grid.arrange(p1, p2, ncol = 2)  
  


