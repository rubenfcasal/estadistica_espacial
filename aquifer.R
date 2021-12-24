#' ---
#' title: "Estadística Espacial (AEDD, GCED, UDC) "
#' author: "Ejemplo de análisis geoestadístico (de datos con tendencia)"
#' date: "Curso 2021/2022"
#' output:
#'   html_document:
#'      toc: yes
#'      toc_float: yes
#'   pdf_document:
#'      toc: yes
#' ---
#'
#' <!--
#' knitr::purl("aquifer_notas.Rmd", documentation = 2)
#' knitr::spin("aquifer_notas.R",knit = FALSE)
#' -->
#'
#' El objetivo es realizar un análisis geoestadístico del conjunto de datos `aquifer` (considerando como variable de interés `aquifer$head`), siguiendo el procedimiento descrito en la [Sección 1.4](https://rubenfcasal.github.io/estadistica_espacial/objetivos-esquema.html) (y en la introducción del [Capítulo 3](https://rubenfcasal.github.io/estadistica_espacial/modelado.html)).
#'
#'
#' # Carga de datos y creación del objeto `sf`:
#'
#' En este caso, cómo es habitual, los datos están almacenados en un `data.frame` y la recomendación es emplear `st_as_sf()` para convertirlos a un objeto `sf` ([Sección 2.2](https://rubenfcasal.github.io/estadistica_espacial/sf-intro.html)):

load("datos/aquifer.RData")
library(sf)
aquifer$head <- aquifer$head/100 # en cientos de pies (escala más manejable...)
aquifer_sf <- st_as_sf(aquifer, coords = c("lon", "lat"), remove = FALSE, agr = "constant")

#'
#' Por comodidad se establece `remove = FALSE` para mantener las coordenadas como posibles variables explicativas (el objeto con las observaciones debe contener todas las variables explicativas incluidas en el modelo de tendencia; también el objeto con las posiciones de predicción).
#'
#' En caso necesario también habría que establecer el CRS ([Sección 2.2.1](https://rubenfcasal.github.io/estadistica_espacial/sf-intro.html#crs)) e incluso podría ser necesario transformar los datos a coordenadas proyectadas mediante `st_transform()`([Sección 2.4.2](https://rubenfcasal.github.io/estadistica_espacial/operaciones-datos.html#operaciones-con-geometr%C3%ADas)).
#'
#'
#' # Análisis exploratorio
#'
#' El primer paso es comenzar por un análisis exploratorio de los datos ([Sección 2.5](https://rubenfcasal.github.io/estadistica_espacial/sp-eda.html)).
#' Nos centraremos en el modelado de los datos, pero seguramente interesaría analizar si hay datos atípicos...
#'
#' Estaríamos interesados en la simetría y normalidad de la respuesta (o del error).
#' Podríamos empezar por realizar un análisis descriptivo unidimensional:

z <- aquifer_sf$head
summary(z)
hist(z, xlab = "piezometric-head", main = "", freq = FALSE)
lines(density(z), col = 'blue')

#'
#' Nos interesaría estudiar si la media es constante o hay una tendencia espacial (analizar la variabilidad de gran escala).
#' Podríamos analizar la distribución espacial de los datos:

plot(aquifer_sf["head"], pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)

#'
#' y generar gráficos de dispersión de la respuesta frente a coordenadas (o frente a otras posibles variables explicativas):

x <- aquifer_sf$lon
y <- aquifer_sf$lat
old.par <- par(mfrow = c(1, 2), omd = c(0.05, 0.95, 0.01, 0.95))
plot(x, z)
lines(lowess(x, z), lty = 2, lwd = 2, col = 'blue')
plot(y, z)
lines(lowess(y, z), lty = 2, lwd = 2, col = 'blue')
par(old.par)

#'
#' Como resultado de este análisis se propondría un modelo inicial para la tendencia
#' (incluyendo el caso de media constante, de la forma `respuesta ~ 1`, que se correspondería con el kriging ordinario).
#' En este caso parece razonable considerar (como punto de partida) un modelo lineal `head ~ lon + lat` para la tendencia (modelo del kriging universal).
#'
#' Podríamos empezar por ajustar el modelo por OLS (cuidado con los resultados de inferencia, ya que en principio no sería razonable asumir que las observaciones son independientes y por ejemplo la varianza estaría subestimada) y analizar los residuos...

trend.ols <- lm(head ~ lon + lat, data = aquifer_sf)
summary(trend.ols)
z <- residuals(trend.ols)
summary(z)
hist(z, xlab = "ols residuals", main = "", freq = FALSE)
lines(density(z), col = 'blue')

#'
#' El análisis de la variabilidad de pequeña escala se realizaría a través de las semivarianzas (clásicas o robustas, [Sección 3.1](https://rubenfcasal.github.io/estadistica_espacial/vario-muestrales.html)), pero solo consideraremos los estimadores muestrales, para el modelado de la dependencia espacial.
#'
#'
#' # Modelado de la dependencia
#'
#' ## Estimación experimental del variograma
#'
#' Como se muestra en la [Sección 3.1](https://rubenfcasal.github.io/estadistica_espacial/vario-muestrales.html), las estimaciones empíricas del semivariograma se obtienen con la función [`variogram()`](https://r-spatial.github.io/gstat/reference/variogram.html).
#'
#' En el caso de tendencia no constante la estimación del variograma se haría a partir de los residuos [Sección 3.3.2](https://rubenfcasal.github.io/estadistica_espacial/ajuste-variog.html#trend-fit), especificando la fórmula del modelo de tendencia como primer argumento de la función `variogram()` (si la tendencia es constante, la fórmula sería del tipo `respuesta ~ 1`, y la estimación del variograma se obtendría directamente de las observaciones).

library(gstat)
# maxlag <- 0.5*sqrt(sum(diff(matrix(st_bbox(aquifer_sf), nrow = 2, byrow = TRUE))^2))
maxlag <- 150
vario <- variogram(head ~ lon + lat, aquifer_sf, cutoff = maxlag)
# por defecto considera 15 saltos (width = cutoff/15)

#'
#' Habría que determinar el número de saltos (por defecto 15, `width = cutoff/15`) y el salto máximo (por defecto 1/3 del máximo salto posible) para la estimación del variograma (nos interesaría que fuese lo mejor posible cerca del origen).
#' Para seguir las recomendaciones de Journel y Huijbregts (1978), de considerar a lo sumo hasta la mitad del máximo salto posible (podría ser preferible menor) y saltos con aportaciones de al menos 30 pares de datos (se puede relajar cerca del origen), podemos representar las estimaciones junto con el número de aportaciones:

plot(vario, plot.numbers = TRUE)

#'
#' Si hay datos atípicos sería preferible emplear una versión robusta de este estimador.
#' Además, estamos asumiendo isotropía, aunque lo ideal sería asegurarse de que es una hipótesis razonable (ver comentarios al final de la [Sección 3.1](https://rubenfcasal.github.io/estadistica_espacial/vario-muestrales.html) y [Sección 3.3.2](https://rubenfcasal.github.io/estadistica_espacial/modelos-variog.html#anisotropia)).
#'
#' ## Ajuste de un modelo válido
#'
#' El paso final en el modelado es el ajuste por WLS de un modelo válido ([Sección 3.3.1](https://rubenfcasal.github.io/estadistica_espacial/ajuste-variog.html#ls-fit), la recomendación es emplear pesos inversamente proporcionales a la varianza `fit.method = 2`).
#' En este caso un modelo de variograma esférico parece razonable:

modelo <- vgm(model = "Sph", nugget = NA) # Valores iniciales por defecto
# modelo <- vgm(psill = 3, model = "Sph", range = 75, nugget = 0) # Valores iniciales
fit <- fit.variogram(vario, modelo, fit.method = 2)

#'
#' NOTA: Si aparecen problemas de convergencia se puede probar a cambiar los valores iniciales de los parámetros.
#'
#' Imprimiendo el resultado del ajuste obtenemos las estimaciones de los parámetros, que podríamos interpretar (ver [Sección 1.3.1](https://rubenfcasal.github.io/estadistica_espacial/procesos-estacionarios.html) y [Sección 4.5.2](https://rubenfcasal.github.io/estadistica_espacial/consideraciones-kriging.html#efecto-variog-kriging)):

fit
nugget <- fit$psill[1]
sill <- nugget + fit$psill[2]
range <- fit$range[2]

#'
#' NOTA: Cuidado, en el caso de un variograma exponencial, el parámetro que aparece como `range` es un parámetro de escala proporcional al verdadero rango práctico (tres veces ese valor).
#'
#' Si quisiésemos comparar el ajuste de distintos modelos se podría considerar el valor mínimo de la función objetivo WLS, almacenado como un atributo del resultado (aunque la recomendación sería emplear validación cruzada):

attr(fit, "SSErr")

#'
#' En cualquier caso la recomendación es analizar gráficamente el ajuste de los modelos.
#' Para representar las estimaciones empíricas junto con un único ajuste, se
#' podría emplear `plot.gstatVariogram()`:

# Cuidado con plot.variogramModel() si se pretende añadir elementos
# plot(fit, cutoff = maxlag, ylim = c(0, 4.5))
# with(vario,  points(dist, gamma))
plot(vario, fit)

#'
#' Para añadir más elementos mejor hacerlo "a mano":

plot(vario$dist, vario$gamma, xlab = "distance", ylab =  "semivariance",
     xlim = c(0, max(range*1.1, maxlag)), ylim = c(0, sill*1.1))
lines(variogramLine(fit, maxdist = max(range*1.1, maxlag)))
abline(v = 0, lty = 3)
abline(v = range, lty = 3)
abline(h = nugget, lty = 3)
abline(h = sill, lty = 3)

#'
#' # Predicción espacial (KU)
#'
#' Para generar la rejilla de predicción consideramos un buffer de radio 40 en torno a las posiciones espaciales:

buffer <- aquifer_sf %>% st_geometry() %>% st_buffer(40)

#'
#' En lugar de emplear una rejilla `sf`:

grid <- buffer %>% st_make_grid(n = c(50, 50), what = "centers") %>% st_intersection(buffer)

#'
#' por comodidad es preferible emplear una rejilla `stars`:

library(stars)
grid <- buffer %>%  st_as_stars(nx = 50, ny = 50)

#'
#' Si suponemos un modelo (no constante) para la tendencia, es necesario añadir los valores de las variables explicativas a la rejilla de predicción:

coord <- st_coordinates(grid)
grid$lon <- coord$x
grid$lat <- coord$y

#'
#' Además, en este caso recortamos la rejilla para filtrar predicciones alejadas de las observaciones:

grid <- grid %>% st_crop(buffer)

#'
#' Obtenemos las predicciones mediante kriging universal ([Sección 4.3](https://rubenfcasal.github.io/estadistica_espacial/kuniversal.html) y [Sección 4.4](https://rubenfcasal.github.io/estadistica_espacial/kriging-gstat.html)):

pred <- krige(formula = head ~ lon + lat, locations = aquifer_sf, model = fit,
              newdata = grid)

#'
#' ***ERROR en krige***: cambia las coordenadas del objeto stars

summary(st_coordinates(grid))
summary(st_coordinates(pred))

#'
#' Posible solución: añadir el resultado a `grid`:

grid$var1.pred <- pred$var1.pred
grid$var1.var <- pred$var1.var

#'
#' Finalmente representamos las predicciones y las varianzas kriging:

plot(grid["var1.pred"], breaks = "equal", col = sf.colors(64), key.pos = 4,
     main = "Predicciones kriging")

plot(grid["var1.var"], breaks = "equal", col = sf.colors(64), key.pos = 4,
     main = "Varianzas kriging")

#'
#' También podríamos emplear el paquete `ggplot2`:

library(ggplot2)
library(gridExtra)
p1 <- ggplot() + geom_stars(data = grid, aes(fill = var1.pred, x = x, y = y)) +
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
p2 <- ggplot() + geom_stars(data = grid, aes(fill = var1.var, x = x, y = y)) +
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
grid.arrange(p1, p2, ncol = 2)

#'
#' # Validación cruzada
#'
#' Para realizar una diagnosis del modelo de tendencia y variograma (y para seleccionar parámetros o comparar modelos) podemos emplear la técnica de validación cruzada [Sección 4.6](https://rubenfcasal.github.io/estadistica_espacial/validacion-cruzada.html), mediante la función `krige.cv()`.
#'
#' Por defecto emplea LOOCV y puede requerir de mucho tiempo de computación (no está implementado eficientemente en `gtsat`):
#'

system.time(cv <- krige.cv(formula = head ~ lon + lat, locations = aquifer_sf,
                           model = fit))
str(cv)

#'
#' Si el número de observaciones es grande puede ser preferible emplear k-fold CV (y como la partición en grupos es aleatoria se recomendaría fijar previamente la semilla de aleatorización):

set.seed(1)
system.time(cv <- krige.cv(formula = head ~ lon + lat, locations = aquifer_sf,
                           model = fit, nfold = 10))

#'
#' Para seleccionar modelos podemos considerar distintas medidas, implementadas en la siguiente función:

summary_cv <- function(cv.data, na.rm = FALSE,
                       tol = sqrt(.Machine$double.eps)) {
  err <- cv.data$residual      # Errores
  obs <- cv.data$observed
  z <- cv.data$zscore
  w <- 1/pmax(cv.data$var1.var, tol) # Ponderación según varianza kriging
  if(na.rm) {
    is.a <- !is.na(err)
    err <- err[is.a]
    obs <- obs[is.a]
    z <- z[is.a]
    w <- w[is.a]
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
    # Medidas de error que tienen en cuenta la varianza kriging
    dme = mean(z),            # Error estandarizado medio
    dmse = sqrt(mean(z^2)),    # Error cuadrático medio adimensional
    rwmse = sqrt(weighted.mean(err^2, w)) # Raíz del ECM ponderado
  ))
}

summary_cv(cv)

#'
#' Las tres últimas medidas tienen en cuenta la estimación de la varianza kriging.
#' El valor del error cuadrático medio adimensional debería ser próximo a 1 si hay concordancia entre las varianzas kriging y las varianzas observadas.
#'
#' Para detectar datos atípicos, o problemas con el modelo, podemos generar distintos gráficos.
#' Por ejemplo, gráficos de dispersión de valores observados o residuos estándarizados frente a predicciones:

old_par <- par(mfrow = c(1, 2))
plot(observed ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Observado")
abline(a = 0, b = 1, col = "blue")

plot(zscore ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Residuo estandarizado")
abline(h = c(-3, -2, 0, 2, 3), lty = 3)
par(old_par)

#'
#' Gráficos con la distribución espacial de los residuos:

plot(cv["residual"], pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)

plot(cv["zscore"], pch = 20, cex = 2)

#'
#' Además de los gráficos estándar para analizar la distribución de los residuos estándarizados o detectar atípicos:

# Histograma
old_par <- par(mfrow = c(1, 3))
hist(cv$zscore, freq = FALSE)
lines(density(cv$zscore), col = "blue")
# Gráfico de normalidad
qqnorm(cv$zscore)
qqline(cv$zscore, col = "blue")
# Boxplot
car::Boxplot(cv$zscore, ylab = "Residuos estandarizados")
par(old_par)
