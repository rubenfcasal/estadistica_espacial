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
plot(datos, pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)

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
# por defecto considera 15 saltos (width = cutoff/15)
plot(vario, plot.numbers = TRUE)
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
  
#' 
#' ## Validación cruzada
#' 

system.time(cv <- krige.cv(formula = z ~ 1, locations = datos, 
                           model = fit))
str(cv)

set.seed(1)
system.time(cv <- krige.cv(formula = z ~ 1, locations = datos, 
                           model = fit, nfold = 10))
#' 
#' Para seleccionar modelos podemos considerar distintas medidas:

summary_cv <- function(cv.data, na.rm = FALSE, 
                       tol = sqrt(.Machine$double.eps)) {
  err <- cv.data$residual      # Errores
  obs <- cv.data$observed 
  z <- cv.data$zscore    
  if(na.rm) {
    is.a <- !is.na(err)
    err <- err[is.a]
    obs <- obs[is.a]
    z <- z[is.a]
  }  
  perr <- 100*err/pmax(obs, tol)  # Errores porcentuales
  return(c(
    # Medidas de error tradicionales  
    me = mean(err),           # Error medio
    rmse = sqrt(mean(err^2)), # Raíz del error cuadrático medio 
    mae = mean(abs(err)),     # Error absoluto medio
    mpe = mean(perr),         # Error porcentual medio
    mape = mean(abs(perr)),   # Error porcentual absoluto medio
    r.squared = 1 - sum(err^2)/sum((obs - mean(obs))^2), # Pseudo R-cuadrado
    # Medidas de error adicionales
    dme = mean(z),            # Error estandarizado medio
    dmse = sqrt(mean(z^2))    # Error error cuadrático medio adimensional
  ))
}

summary_cv(cv)

#' 
#' Para detectar datos atípicos, o problemas con el modelo, podemos generar distintos
#' gráficos:

plot(observed ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Observado")
abline(a = 0, b = 1, col = "blue")

plot(cv["residual"], pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)

plot(cv["zscore"], pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)

hist(cv$zscore, freq = FALSE)
lines(density(cv$zscore), col = "blue")

qqnorm(cv$zscore)
qqline(cv$zscore, col = "blue")

car::Boxplot(cv$zscore, ylab = "Residuos estandarizados")

plot(zscore ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Residuos estandarizados")
