# Modelado de procesos geoestadísticos {#modelado}

<!-- 
---
title: "Estadística Espacial"
author: "Análisis estadístico de datos con dependencia (GCED)"
date: "Curso 2021/2022"
bibliography: ["packages.bib", "estadistica_espacial.bib"]
link-citations: yes
output: 
  bookdown::html_document2:
    pandoc_args: ["--number-offset", "2,0"]
    toc: yes 
    # mathjax: local            # copia local de MathJax, hay que establecer:
    # self_contained: false     # las dependencias se guardan en ficheros externos 
  bookdown::pdf_document2:
    keep_tex: yes
    toc: yes 
---

Capítulo \@ref(modelado)
bookdown::preview_chapter("03-modelado.Rmd")
knitr::purl("03-modelado.Rmd", documentation = 2)
knitr::spin("03-modelado.R",knit = FALSE)
-->




Como se comentó en la Sección \@ref(objetivos-esquema) la aproximación tradicional (paramétrica) para el modelado de un proceso geoestadístico, es decir, estimar la tendencia $\mu(\mathbf{s})$ y el semivariograma $\gamma(\mathbf{h})$, consiste en los siguientes pasos:

1.  Análisis exploratorio y formulación de un modelo paramétrico (inicial).

2.  Estimación de los parámetros del modelo:

    1.  Estimar y eliminar la tendencia (suponiendo que no es constante).

    2.  Modelar la dependencia (ajustar un modelo de variograma) a partir de los residuos
        (o directamente de las observaciones si la tendencia se supone constante).

3.  Validación del modelo o reformulación del mismo.

4.  Empleo del modelo aceptado.


El procedimiento habitual para el modelado de la dependencia en el paso 2 (también denominado *análisis estructural*) consiste en obtener una estimación inicial del semivariograma utilizando algún tipo de estimador experimental (Sección \@ref(vario-muestrales)) y posteriormente ajustar un modelo paramétrico válido de semivariograma a las estimaciones "piloto" obtenidas en el primer paso (secciones \@ref(modelos-variog) y \@ref(ajuste-variog)).

El principal problema con esta aproximación aparece cuando no se puede asumir que la tendencia es constante, ya que los estimadores muestrales descritos en la siguiente sección solo son adecuados para procesos estacionarios.
En este caso, como la media es constante, entonces:
\begin{equation} 
  E(Z(\mathbf{s}_1) - Z(\mathbf{s}_{2}))^2 = 2\gamma(\mathbf{s}_1 -\mathbf{s}_{2}),
  \ \forall \mathbf{s}_1 ,\mathbf{s}_{2} \in D.
(\#eq:vario-est)
\end{equation}
<!-- \@ref(eq:vario-est) -->
Sin embargo, cuando la tendencia no es constante:
\begin{equation} 
  E(Z(\mathbf{s}_1) - Z(\mathbf{s}_{2}))^2 = 2\gamma(\mathbf{s}_1 - \mathbf{s}_{2}) 
  + \left( \mu(\mathbf{s}_1)-\mu(\mathbf{s}_{2})\right)^2,
(\#eq:vario-nest)
\end{equation}
<!-- \@ref(eq:vario-nest) -->
y no es necesariamente función de $\mathbf{s}_1 -\mathbf{s}_{2}$, ni tiene por qué verificar las propiedades de un variograma.
Por este motivo, estos estimadores no deben ser utilizados mientras que no se elimine la tendencia de los datos.

Si no se puede asumir que la tendencia es constante, para poder estimarla de forma eficiente sería necesario conocer la dependencia (i.e. conocer $\gamma(\cdot)$). 
Este problema circular se suele resolver en la práctica realizando el paso 2 de forma iterativa, como se describe en la Sección \@ref(trend-fit).
Otra alternativa sería asumir normalidad y estimar ambos componentes de forma conjunta empleando alguno de los métodos basados en máxima verosimilitud descritos en la Sección \@ref(ml-fit).

Finalmente, en el paso 3, para verificar si el modelo (de tendencia y variograma) describe adecuadamente la variabilidad espacial de los datos (y para comparar modelos), se emplea normalmente la técnica de validación cruzada, descrita en la Sección \@ref(validacion-cruzada) del siguiente capítulo (en el que también se describe los principales métodos empleados en el paso 4).


## Estimadores muestrales del semivariograma {#vario-muestrales}

<!-- Incluir en el análisis exploratorio de datos? -->

Suponiendo que el proceso es intrísecamente estacionario, a partir de \@ref(eq:vario-est), empleando el método de los momentos, se obtiene el denominado *estimador empírico* (o clásico) del semivariograma (Matheron, 1962):
$$\hat{\gamma}(\mathbf{h}) = \dfrac{1}{2\left| N(\mathbf{h})\right| }
\sum\limits_{N(\mathbf{h})}\left( Z(\mathbf{s}_{i})-Z(\mathbf{s}_{j} )\right) ^2 ,\ \mathbf{h}\in \mathbb{R}^{d},$$
donde:
$$N(\mathbf{h}) = \left\{ (i,j):\mathbf{s}_{i} -\mathbf{s}_{j} \in Tol(\mathbf{h});i,j=1,\ldots,n\right\},$$
$Tol(\mathbf{h})\subset \mathbb{R}^{d}$ es una región de tolerancia en torno a $\mathbf{h}$ y $\left| N(\mathbf{h})\right|$ es el número de pares distintos en $N(\mathbf{h})$.
La región de tolerancia debería ser lo suficientemente grande como para que no aparezcan inestabilidades, por lo que se recomienda (Journel y Huijbregts 1978, p.194) que el numero de aportaciones a la estimación en un salto $\mathbf{h}$ sea por lo menos de treinta (i.e. $\left| N(\mathbf{h})\right| \geq 30$).

De forma análoga, suponiendo estacionariedad de segundo orden, se obtiene el estimador clásico del covariograma:
$$\hat{C} (\mathbf{h}) = \dfrac{1}{\left| N(\mathbf{h})\right| }
\sum\limits_{N(\mathbf{h})}\left( Z(\mathbf{s}_{i})-\bar{Z} \right)
\left( Z(\mathbf{s}_{j})-\bar{Z} \right),\ \mathbf{h}\in \mathbb{R}^{d},$$
siendo $\bar{Z} =\frac{1}{n} \sum_{i=1}^{n}Z(\mathbf{s}_{i})$ la media muestral.
El principal problema con este estimador es la necesidad de estimar la media $\mu$ del proceso, lo que produce que sea sesgado.
Por otra parte, además de que la suposición de estacionariedad de segundo orden es menos general (Sección \@ref(procesos-estacionarios), si el proceso es intrínsecamente estacionario el estimador del variograma es insesgado y también tiene mejores propiedades cuando la estimación se basa en residuos (aunque en este caso ambos estimadores son sesgados).
Más información sobre la distribución y propiedades de estos estimadores se tienen por ejemplo en Cressie (1993, pp. 71-74).
Estos resultados justifican que el modelado de la dependencia espacial se realice a través del semivariograma.

Uno de los problemas con el estimador empírico del semivariograma es su falta de robustez frente a observaciones atípicas. 
Por este motivo se han propuesto numerosas alternativas robustas.
Hawkins y Cressie (1984) sugirieron promediar la raíz cuadrada de las diferencias en valor absoluto^[Si el proceso $Z(\cdot)$ es normal entonces $(Z(\mathbf{s})-Z(\mathbf{s}+\mathbf{h}))^2$ sigue una distribución $2\gamma(\mathbf{h})\chi_1^2$, sin embargo esta distribución es muy asimétrica y la transformación de potencia que hace que se aproxime más a la simetría (normalidad) es la raíz cuarta. Otra ventaja de utilizar la raíz cuadrada de las diferencias es que, en general, están menos correladas que las diferencias al cuadrado (ver e.g. Cressie, 1993, p. 76).] y posteriormente transformar el resultado a la escala original tratando de obtener un estimador aproximadamente insesgado (utilizando del método delta), obteniéndose el estimador:

$$2\tilde{\gamma}(\mathbf{h}) = \left( \dfrac{1}{\left| N(\mathbf{h})\right| }
\sum\limits_{N(\mathbf{h})}\left| Z(\mathbf{s}_{i})-Z(\mathbf{s}_{j}
)\right|^{\frac{1}{2} } \right)^{4} /\left( \text{0.457+}
\dfrac{\text{0.494} }{\left| N(\mathbf{h})\right| } +\dfrac{\text{0.045}
}{\left| N(\mathbf{h})\right|^2 } \right).$$

Los estimadores locales tipo núcleo son herramientas frecuentemente utilizadas en la estimación de curvas y superficies. 
Entre los más conocidos podemos señalar los estimadores tipo Nadaraya-Watson y los polinómicos locales (e.g. Fan y Gijbels,1996). 
Recientemente se han considerado también estas ideas para la estimación del covariograma (e.g. Hall et al., 1994) y del semivariograma.
La expresión general de un estimador no paramétrico de un semivariograma isotrópico es de la forma:
$$\hat{\gamma}(r) = \dfrac{\sum\limits_{i=1}^{n-1}\sum\limits_{j=i+1}^{n}\omega_{ij}
(r)\left( Z(\mathbf{s}_{i})-Z(\mathbf{s}_{j})\right)^2  
}{2\sum\limits_{i=1}^{n-1}\sum\limits_{j=i+1}^{n}\omega_{ij}(r)},$$
donde $\omega_{ij}(r) \geq 0$, $\forall i,j$ y $\sum_{i,j}\omega_{ij}(r) > 0$. 
Dependiendo de la elección de estos pesos obtenemos distintos estimadores:

* $\omega_{ij}(r) = \mathcal{I}_{Tol(r)} \left( \left\| \mathbf{s}_{i} - \mathbf{s}_{j} \right\| \right)$, siendo $Tol(r)\subset \mathbb{R}$ una región de tolerancia en torno a $r$ (y denotando por $\mathcal{I}_{A}(\cdot)$ función indicadora del conjunto $A$), obtenemos el estimador clásico del semivariograma.
* $\omega_{ij}(r)=K\left( \frac{\left\| \mathbf{s}_{i} -\mathbf{s}_{j} \right\| -r}{h} \right)$, es el estimador Nadaraya-Watson (Hall et al., 1994).
* $\omega_{ij}(r)=K\left( \frac{\left\| \mathbf{s}_{i} -\mathbf{s}_{j} \right\| -r}{h} \right) \times$ $\sum\limits_{k}\sum\limits_{l}K\left( \frac{\left\| \mathbf{s}_{k} -\mathbf{s}_{l} \right\| -r}{h} \right)   \left( \left\| \mathbf{s}_{k} -\mathbf{s}_{l} \right\| -r\right) \left( \left\| \mathbf{s}_{k} -\mathbf{s}_{l} \right\| -\left\| \mathbf{s}_{i} -\mathbf{s}_{j} \right\| \right)$ se obtiene el estimador lineal local del semivariograma (García-Soidán et al., 2003).


La función [`variogram()`](https://r-spatial.github.io/gstat/reference/variogram.html) del paquete `gstat`: 
```{reval=FALSE}
variogram(formula, locations = coordinates(data), data, cutoff, width = cutoff/15,
          cressie = FALSE, cloud = FALSE, covariogram = FALSE, ...)
```
permite obtener la nube de semivarianzas (`cloud = TRUE`) y las estimaciones 
empíricas o robustas (`cressie = TRUE`), además de otras posibilidades.

En primer lugar emplearemos el conjunto de datos `s100` del paquete `geoR`, que contiene una simulación de un proceso espacial estacionario (sin tendencia).


```r
# Cargamos los datos y los transformamos a un objeto `sf`
library(sf)
data(s100, package = "geoR")
datos <- st_as_sf(data.frame(s100$coords, z = s100$data), 
                  coords = 1:2, agr = "constant")
```


```r
library(gstat)
vario.cloud <- variogram(z ~ 1, datos, cloud = TRUE, cutoff = 0.6)
vario <- variogram(z ~ 1, datos, cloud = FALSE, cutoff = 0.6)
# Si se quiere tomar el 50% del máximo salto (posible) cutoff = maxlag
# maxlag <- 0.5*sqrt(sum(diff(apply(s100$coord, 2, range))^2)) 
# maxlag <- 0.5*sqrt(sum(diff(matrix(st_bbox(datos), nrow = 2, byrow = TRUE))^2))
names(vario)
```

```
## [1] "np"      "dist"    "gamma"   "dir.hor" "dir.ver" "id"
```

En el resultado, la componente `dist` contiene los saltos, `gamma` las estimaciones del semivariograma (o las semivarianzas) y `np` el número de aportaciones.


```r
rvario.cloud <- variogram(z ~ 1, datos, cloud = TRUE, cressie = TRUE, cutoff = 0.6)
rvario <- variogram(z ~ 1, datos, cloud = FALSE, cressie = TRUE, cutoff = 0.6)
# Representar
oldpar <- par(mfrow = c(1, 2))
# Nube de semivarianzas clásicas
with(vario.cloud,  plot(dist, gamma, xlab = "distance", ylab = "semivariances"))
# Nube de semivarianzas robustas
with(rvario.cloud,  plot(dist, gamma, xlab = "distance", ylab = "semivariances"))
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/vario-rvario-cloud-1.png" alt="Nubes de semivarianzas clásicas (izquierda) y robustas (derecha) del conjunto de datos simulado." width="90%" />
<p class="caption">(\#fig:vario-rvario-cloud)Nubes de semivarianzas clásicas (izquierda) y robustas (derecha) del conjunto de datos simulado.</p>
</div>

```r
par(oldpar)
```


```r
with(vario, plot(dist, gamma, pch = 19, ylim = c(0, 1),
                        xlab = "distance", ylab =  "semivariance"))
with(rvario, points(dist, gamma))
legend("bottomright", c("clásico", "robusto"), pch = c(19, 1))
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/vario-rvario-1.png" alt="Estimaciones clásicas y robustas del semivariograma (datos simulados)." width="70%" />
<p class="caption">(\#fig:vario-rvario)Estimaciones clásicas y robustas del semivariograma (datos simulados).</p>
</div>

Para detectar observaciones atípicas podríamos emplear la nube de semivarianzas (preferiblemente las robustas, ya que tienen una distribución más próxima a la normalidad)^[Estableciendo `identify = TRUE` (o `digitize = TRUE`) en `plot.variogramCloud()` podríamos identificar semivarianzas atípicas (o pares de datos atípicos) de forma interactiva.]:

```r
res <- as.data.frame(rvario.cloud)
boundaries <- attr(rvario, "boundaries")
res$lag <- cut(res$dist, breaks = boundaries, labels = seq_len(length(boundaries)-1))
res$labels <- with(res, paste(left, right, sep="-"))
with(res, car::Boxplot(gamma ~ lag, id = list(labels = labels)))
```

<img src="03-modelado_files/figure-html/unnamed-chunk-4-1.png" width="70%" style="display: block; margin: auto;" />

```
## [1] "87-52" "87-39" "57-52" "57-39"
```
Nos preocuparía especialmente la presencia de datos atípicos en saltos pequeños (indicaría que observaciones cercanas tienen valores muy distintos).

Para un análisis exploratorio de la anisotropía, podemos obtener variogramas direccionales indicando el ángulo y los grados de tolerancia en cada eje:

```r
plot(variogram(z ~ 1, datos, cutoff = 0.6, alpha = c(0, 45, 90, 135)))
```

<img src="03-modelado_files/figure-html/unnamed-chunk-5-1.png" width="70%" style="display: block; margin: auto;" />

Complementariamente, se puede obtener un mapa de semivarianzas discretizadas en dos dimensiones:


```r
variogram.map <- variogram(z ~ 1, datos, cutoff = 0.6, width = 0.6 / 15, map = TRUE)
plot(variogram.map)
```

<img src="03-modelado_files/figure-html/unnamed-chunk-6-1.png" width="70%" style="display: block; margin: auto;" />

Para estudiar si hay dependencia espacial (estadísticamente significativa) se puede emplear la rutina `sm.variogram` del paquete `sm`. 
Estableciendo `model = "independent"` devuelve un p-valor para contrastar la hipótesis nula de independencia
(i.e. se acepta que hay una dependencia espacial si $p \leq \alpha = 0.05$) y un gráfico en el que se muestra el estimador empírico robusto, un estimador suavizado y una región de confianza para el variograma suponiendo que el proceso es independiente (i.e. consideraríamos que hay dependencia espacial si el variograma suavizado no está contenido en esa región).


```r
library(sm)
sm.variogram(s100$coords, s100$data, model = "independent")
```

```
## Test of spatial independence: p =  0.024
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/sm-variogram-1.png" alt="Estimaciones robustas y suavizadas del semivariograma, junto con una región de confianza para el semivariograma suponiendo que el proceso es independiente." width="70%" />
<p class="caption">(\#fig:sm-variogram)Estimaciones robustas y suavizadas del semivariograma, junto con una región de confianza para el semivariograma suponiendo que el proceso es independiente.</p>
</div>

<!-- Además de realizar el contraste, genera un gráfico con el estimador y una envolvente (*envelope*, i.e. valores máximos y mínimos aproximados por simulación), obtenida mediante permutaciones aleatorias de los datos sobre las posiciones espaciales (si las estimaciones están dentro de la envolvente indicaría que aparentemente no hay correlación espacial). -->
También se puede realizar contrastes adicionales estableciendo el parámetro `model` a `"isotropic"` o `"stationary"`.

## Modelos de semivariogramas {#modelos-variog}

Los variogramas deben ser condicionalmente semidefinidos negativos, una propiedad que los estimadores tradicionales normalmente no poseen. 
Tradicionalmente esto se remedia ajustando un modelo paramétrico válido al estimador muestral (Sección \@ref(ajuste-variog)). 
En la Sección \@ref(modelos-parametricos) se presentan algunos de los modelos isotrópicos tradicionalmente utilizados en geoestadística. 
Estos modelos son empleados también en ciertos casos como estructuras básicas a partir de las cuales se construyen modelos más complejos, como modelos anisotrópicos (Sección \@ref(anisotropia)) o los denominados modelos lineales de regionalización (Sección \@ref(vario-lin-reg)). 

### Modelos paramétricos isotrópicos {#modelos-parametricos}

A continuación se presentan algunos de los modelos isotrópicos de semivariograma más utilizados en geoestadística (una revisión más completa se tiene por ejemplo en Chilès y Delfiner, 1999, Sección 2.5.1). 
En la notación utilizada en las parametrizaciones $c_0 \geq 0$ representa el efecto nugget, $c_1 \geq 0$ el umbral parcial (en el caso de variogramas acotados, con $\sigma^2= c_0 + c_1$) y $a>0$ el rango (si existe) o el parámetro de escala. 
En el caso de semivariogramas acotados que alcanzan el umbral asintóticamente (rango infinito), el parámetro $a$ representa el rango práctico, definido como la distancia en la que el valor del semivariograma es el 95% del umbral parcial.
En la Figura \@ref(fig:show-vgms) se tienen algunos ejemplos de las formas de algunos de
estos semivariogramas.

* Modelo esférico:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. ) = \left\{ 
  \begin{array}{ll}
  0 & \text{si} \left\| \mathbf{h}\right\| =0 \\
  c_0 +c_1 \left\{ \dfrac{3}{2} \dfrac{\left\| \mathbf{h}\right\| }{a}
  -\dfrac{1}{2} \left( \dfrac{\left\| \mathbf{h}\right\| }{a} \right)
  3\right\}  & \text{si} 0<\left\| \mathbf{h}\right\| \leq a \\
  c_0 +c_1  & \text{si} \left\| \mathbf{h}\right\| >a
  \end{array}
  \right.$$ 
  válido en $\mathbb{R}^{d}$, $d=1,2,3$.

* Modelo exponencial:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + c_1 \left( 1-\exp \left( -\dfrac{3\left\|
  \mathbf{h}\right\| }{a} \right) \right)  & \text{si}\  \mathbf{h}\neq
  \mathbf{0}
  \end{array}
  \right.$$ 
  válido en $\mathbb{R}^{d}$, $\forall d \geq 1$.

* Modelo racional cuadrático:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + c_1 \dfrac{\left\| \mathbf{h}\right\|^2
  }{\frac{1}{19} a^2 +\left\| \mathbf{h}\right\|^2 }  & \text{si}\ 
  \mathbf{h}\neq \mathbf{0}
  \end{array}
  \right.$$ 
  válido en $\mathbb{R}^{d}$, $\forall d \geq 1$.

* Modelo potencial:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + a\left\| \mathbf{h}\right\|^{\lambda }  & \text{si}\ 
  \mathbf{h}\neq \mathbf{0}
  \end{array}
  \right.$$ 
  con $0\leq \lambda <2$ y válido en $\mathbb{R}^{d}$, $\forall d \geq 1$.
  En el caso de $\lambda =1$ se obtiene el conocido modelo lineal.

* Modelo exponencial-potencial:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + c_1 \left( 1-\exp \left( -3\left( \dfrac{\left\|
  \mathbf{h}\right\| }{a} \right)^{\lambda } \right) \right)  & \text{si}\ 
  \mathbf{h}\neq \mathbf{0}
  \end{array}
  \right.$$ 
  con $0\leq \lambda \leq 2$ y válido en $\mathbb{R}^{d}$, $\forall d \geq 1$. 
  Cuando $\lambda =2$ es denominado modelo gausiano;
  este modelo sin embargo no debería ser utilizado en la predicción
  espacial debido a las inestabilidades numéricas que produce en los
  algoritmos kriging (especialmente cuando el efecto nugget es grande; ver
  e.g. Wackernagel, 1998, pp. 120-123). 
  El modelo exponencial se obtiene también como caso particular cuando $\lambda =1$.

* Modelo oscilatorio:
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + c_1 \left( 1-\dfrac{a}{\left\| \mathbf{h}\right\| }
  \text{sen} \left( \dfrac{\left\| \mathbf{h}\right\| }{a} \right) \right) 
  & \text{si}\  \mathbf{h}\neq \mathbf{0}
  \end{array}
  \right.$$ 
  válido en $\mathbb{R}^{d}$, $d=1,2,3$. 
  Este modelo con forma de onda (hay correlaciones negativas) alcanza su valor máximo ( $c_0 +1.218c_1$) cuando $\left\| \mathbf{h}\right\| \simeq 4.5a$, siendo $a$ el parámetro de escala.


* Modelo de Matérn (o K-Bessel):
  $$\gamma(\mathbf{h}\left| \boldsymbol{\theta}\right. )\ =\ \left\{ 
  \begin{array}{ll}
  0 & \text{si}\  \mathbf{h}=\mathbf{0} \\
  c_0 + c_1 \left( 1-\dfrac{1}{2^{\nu -1} \gamma(\nu )} \left(
  \dfrac{\left\| \mathbf{h}\right\| }{a} \right)^{\nu } K_{\nu } \left(
  \dfrac{\left\| \mathbf{h}\right\| }{a} \right) \right)  & \text{si}\ 
  \mathbf{h}\neq \mathbf{0}
  \end{array}
  \right.$$ 
  siendo $\nu \geq 0$ (un parámetro de suavizado) y $K_{\nu }$ la función de Bessel modificada de tercera clase de orden $\nu$ (ver e.g. Abramowitz y Stegun, 1965, pp. 374-379). 
  Este modelo es válido en $\mathbb{R}^{d}$, $\forall d \geq 1$. El modelo exponencial se obtiene como caso particular cuando $\nu =\frac{1}{2}$ y en el límite $\nu \rightarrow \infty$ el modelo gausiano.

En `gstat` se emplea la función `vgm()` (*Variogram Model*) para definir un modelo de variograma:

```r
vgm(psill = NA, model, range = NA, nugget, add.to, anis, kappa = 0.5, ...)
```

* `psill`: umbral parcial ($c_1$). 
* `model`: cadena de texto que identifica el modelo (e.g. `"Exp"`, `"Sph"`, `"Gau"`, `"Mat"`...).
* `range`: rango o parámetro de escala (proporcional a $a$).
* `nugget`: efecto nugget ($c_0$).
* `kappa`: parametro de suavizado ($\nu$ en el modelo de Matérn).
* `add.to`: permite combinar modelos (Sección \@ref(vario-lin-reg)).
* `anis`: parámetros de anisotropía (Sección \@ref(anisotropia)).

Lo habitual es definir un modelo para posteriormente estimar sus parámetros utilizando los empleados en la definición como valores iniciales. También se puede llamar a esta función con el modelo como primer y único argumento, indicando que los parámetros son desconocidos (para que tome los valores por defecto en el ajuste). Por defecto considerará que el nugget es nulo (y no se estimará), únicamente  se considerará un efecto nugget si se especifica, aunque sea `nugget = NA`. 
Si se ejecuta sin argumentos devuelve un listado de todos los modelos:

```r
vgm()
```

```
##    short                                      long
## 1    Nug                              Nug (nugget)
## 2    Exp                         Exp (exponential)
## 3    Sph                           Sph (spherical)
## 4    Gau                            Gau (gaussian)
## 5    Exc        Exclass (Exponential class/stable)
## 6    Mat                              Mat (Matern)
## 7    Ste Mat (Matern, M. Stein's parameterization)
## 8    Cir                            Cir (circular)
## 9    Lin                              Lin (linear)
## 10   Bes                              Bes (bessel)
## 11   Pen                      Pen (pentaspherical)
## 12   Per                            Per (periodic)
## 13   Wav                                Wav (wave)
## 14   Hol                                Hol (hole)
## 15   Log                         Log (logarithmic)
## 16   Pow                               Pow (power)
## 17   Spl                              Spl (spline)
## 18   Leg                            Leg (Legendre)
## 19   Err                   Err (Measurement error)
## 20   Int                           Int (Intercept)
```
La función `show.vgms()` genera gráficos con los distintos modelos (por defecto los 17 primeros):

```r
show.vgms()
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/show-vgms-1.png" alt="Representaciones de los modelos paramétricos isotrópicos de semivariogramas implementados en el paquete `gstat`." width="70%" />
<p class="caption">(\#fig:show-vgms)Representaciones de los modelos paramétricos isotrópicos de semivariogramas implementados en el paquete `gstat`.</p>
</div>


```r
show.vgms(kappa.range = c(0.1, 0.5, 1, 5, 10), max = 10)
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/show-matern-1.png" alt="Modelo de Matérn con distintos valores del parámetro de suavizado." width="70%" />
<p class="caption">(\#fig:show-matern)Modelo de Matérn con distintos valores del parámetro de suavizado.</p>
</div>


```r
v1 <- vgm(psill = 1, model = "Exp", range = 0.5, nugget = 0)
v1
```

```
##   model psill range
## 1   Nug     0   0.0
## 2   Exp     1   0.5
```

```r
plot(v1, cutoff = 3)
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/vgm-exp-1.png" alt="Ejemplo de modelo exponencial." width="70%" />
<p class="caption">(\#fig:vgm-exp)Ejemplo de modelo exponencial.</p>
</div>

### Modelado de anisotropía {#anisotropia}

La hipótesis de isotropía simplifica notablemente el modelado de la dependencia espacial por lo que la mayoría de los modelos (básicos) de semivariogramas considerados en geoestadística son isotrópicos (Sección \@ref(modelos-parametricos)). 
Sin embargo, en muchos casos no se puede asumir que la dependencia es igual en cualquier dirección (uno de los ejemplos más claros es el caso espacio-temporal, donde en principio no es razonable pensar que un salto espacial es equivalente a un salto temporal). 
En esos casos se suelen considerar ligeras variaciones de la hipótesis de isotropía para modelar la dependencia espacial. 
En esta sección se comentan brevemente las distintas aproximaciones tradicionalmente consideradas en geoestadística (para más detalles ver e.g. Chilès y Delfiner, 1999, Sección 2.5.2, o Goovaerts, 1997, Sección 4.2.2), otras aproximaciones adicionales se tratarán en el Capítulo 7 (caso espacio-temporal).

Cuando el variograma es función de la dirección además de la magnitud del salto, se dice que el variograma es anisotrópico (no isotrópico). 
Los tipos de anisotropía habitualmente considerados son:

* *Anisotropía geométrica*: cuando el umbral permanece constante mientras que el rango varía con la dirección.
* *Anisotropía zonal*: cuando el umbral del semivariograma varía con la dirección (también se denomina anisotropía estratificada).
* *Anisotropía mixta*: combinación de las anteriores.

La anisotropía geométrica se puede corregir mediante una transformación lineal del vector de salto $\mathbf{h}$:
$$\gamma(\mathbf{h})=\gamma^{0} \left( \left\| \mathbf{A}\mathbf{h}\right\| \right) ,\forall \mathbf{h}\in \mathbb{R}^{d},$$
siendo $\mathbf{A}$ una matriz cuadrada $d\times d$ y $\gamma^{0} (\cdot)$ un semivariograma isotrópico^[Esta idea (que el espacio euclídeo no es apropiado para medir distancias entre posiciones espaciales pero una transformación lineal de él sí) ha sido también generalizada para el caso de deformaciones no lineales del espacio. Por ejemplo, Sampson y Guttorp (1992) consideraron transformaciones no lineales obtenidas mediante técnicas de escalamiento óptimo multidimensional.]. 
En este caso se dice que el variograma es *geométricamente anisotrópico*. 
Por ejemplo, en el caso bidimensional, se suele considerar una matriz de la forma:
$$\mathbf{A}=\left( 
\begin{array}{cc}
1  & 0 \\
0 & a_2/a_1 
\end{array}
\right) \left( 
\begin{array}{cc}
\cos \phi  & \sin\phi  \\
\text{-} \sin\phi  & \cos \phi 
\end{array}
\right),$$
que se corresponde con las direcciones principales de anisotropía $\phi$ y $\phi + \frac{\pi }{\text{2}}$ (normalmente se toma $\phi$ igual a la dirección de máximo rango).
Esto puede extenderse fácilmente para el caso tridimensional (ver e.g. Chilès y Delfiner, 1999, pp. 94-95).

En `gstat` se puede definir^[Sin embargo no permite ajustar los parámetros de anisotropía, algo que se puede hacer con las herramientas implementadas en el paquete `geoR` (ver Sección \@ref(geor-ajuste)).] anisotropía mediante el argumento `anis` de la función `vgm()`.
En dos dimensiones es un vector con dos componentes `anis = c(alpha, ratio)`, `alpha` es el ángulo para la dirección principal de variabilidad (en grados, medido en el sentido del reloj partiendo de la dirección norte, i.e. `phi = (90 - alpha)*pi/180`) y `ratio` la relación entre el rango mínimo y máximo ($0 \leq ratio = a_2/a_1 \leq 1$).

Ejemplo:

```r
v <- vgm(1, "Exp", 5, anis = c(30, 0.1))
str(v)
```

```
## Classes 'variogramModel' and 'data.frame':	1 obs. of  9 variables:
##  $ model: Factor w/ 20 levels "Nug","Exp","Sph",..: 2
##  $ psill: num 1
##  $ range: num 5
##  $ kappa: num 0.5
##  $ ang1 : num 30
##  $ ang2 : num 0
##  $ ang3 : num 0
##  $ anis1: num 0.1
##  $ anis2: num 1
```

```r
plot_ellipse_2d <- function(xc = 0, yc = 0, l1 = 10, l2 = 1, phi = pi/3, 
                            by = 0.01, asp = 1, ...) {
    # xc, yc: centro
    # l1, l2: longitud semiejes
    # phi: angulo del eje 1 respecto al eje x
    t <- seq(0, 2*pi, by)
    x <- xc + l1*cos(t)*cos(phi) - l2*sin(t)*sin(phi)
    y <- yc + l1*cos(t)*sin(phi) + l2*sin(t)*cos(phi)
    plot(x, y, type = "l", asp = asp, ...)
}

with(v, plot_ellipse_2d(l1 = range, l2 = range*anis1, 
                        phi = (90 - ang1)*pi/180))
abline(h = 0, lty = 2)
abline(v = 0, lty = 2)
```

<img src="03-modelado_files/figure-html/unnamed-chunk-9-1.png" width="70%" style="display: block; margin: auto;" />

En el caso de la anisotropía zonal se suele considerar una combinación de un semivariograma isotrópico más otros "zonales" que depende solamente de la distancia en ciertas direcciones (o componentes del vector de salto). 
Por ejemplo, en el caso bidimensional, si $\phi$ es la dirección de mayor varianza se suele considerar una combinación de la forma:
$$\gamma(\mathbf{h})=\gamma_1 (\left\| \mathbf{h}\right\|)+\gamma_2(h_{\phi }),$$
siendo $\gamma_1 (\cdot)$ y $\gamma_2 (\cdot)$ semivariogramas isotrópicos, y $h_{\phi } =\cos (\phi)h_1 +\sin(\phi)h_2$ el salto en la dirección $\phi$, para $\mathbf{h}=(h_1 ,h_2)\in \mathbb{R} ^{2}$.
Es importante destacar que este tipo de anisotropías pueden causar la aparición de problemas al realizar predicción espacial (ver e.g. Myers y Journel, 1990; y Rouhani y Myers, 1990), como por ejemplo dar lugar a sistemas kriging no válidos con ciertas configuraciones de los datos.
Hay que tener un especial cuidado cuando el covariograma es expresado como suma de covariogramas unidimensionales, en cuyo caso el resultado puede ser únicamente condicionalmente semidefinido positivo sobre un dominio multidimensional.
Este tipo de modelos son casos particulares del modelo lineal de regionalización descrito en la siguiente sección.

Una variante de la anisotropía zonal es el caso de covariogramas separables (también denominados factorizables) en componentes del vector de salto. 
Por ejemplo, un covariograma completamente separable en $\mathbb{R}^2$ es de la forma $C(h_1, h_2)= C_1(h_1)C_2(h_2)$, siendo $C_1(\cdot)$ y $C_2(\cdot)$ covariogramas en $\mathbb{R}^{1}$. 
En este caso se puede pensar que el proceso espacial se obtiene como producto de procesos unidimensionales independientes definidos sobre cada uno de los ejes de coordenadas.
Este tipo de modelos se utilizan habitualmente en geoestadística espacio-temporal (aunque no permiten modelar interacciones).


### El modelo lineal de regionalización {#vario-lin-reg}

A partir de las propiedades 1 y 2 del semivariograma mostradas en la Sección \@ref(propiedades-elementales), se obtienen los denominados *modelos lineales de regionalización* (también *modelos anidados* o *nested models*):
$$\gamma(\mathbf{h}) = \sum\limits_{k=0}^{q}b_{k} \gamma_{k}(\mathbf{h}),$$
siendo $b_k \ge 0$ y $\gamma_{k}(\mathbf{h})$ modelos básicos de semivariogramas, $k=1, \ldots, q$.
La denominación de "modelos lineales" surge porque estos modelos se obtienen al suponer que el proceso espacial es una combinación lineal procesos espaciales intrínsecamente estacionarios mutuamente independientes.

Los modelos básicos suelen incluir un efecto nugget y algunos de los modelos mostrados en la sección anterior con efecto nugget nulo y umbral unidad. 
Además, cada modelo básico puede incorporar algún tipo de anisotropía (Sección \@ref(anisotropia)), típicamente anisotropía geométrica:
$$\gamma_{k}(\mathbf{h})\equiv \gamma_{k}^{} \left( \left\| \mathbf{A}_{k} \mathbf{h}\right\| \right)$$ 
siendo $\mathbf{A}_{k} ,k=0,\ldots,q$ matrices $d\times d$. 
De esta forma los modelos pueden ser lo suficientemente flexibles como para modelar la mayoría de situaciones que se pueden presentar en la práctica. 
Sin embargo, es difícil establecer un procedimiento automático (o semi-automático) para la selección y el ajuste de este tipo de modelos.
Esto provoca que el proceso normalmente se realice en la práctica de forma interactiva por el usuario y utilizando principalmente herramientas gráficas^[Ver por ejemplo Goovaerts (1997, Sección 4.2.4) para detalles sobre el uso en la práctica de éste tipo de modelos.]; siendo por tanto poco recomendables para algunos casos. 
En primer lugar hay que especificar el número y tipo de estructuras básicas, y en segundo lugar (aunque se suele hacer en la práctica de forma simultánea) está el problema de la estimación de los parámetros, donde puede ser especialmente complicado la determinación de los rangos y los parámetros de anisotropía de los distintos componentes (es de esperar que aparezcan problemas en la optimización).

En `gstat` se pueden definir modelos de este tipo empleando el parámetro `add.to` de la función `vgm()`.

```r
v2 <- vgm(psill = 1, model = "Gau", range = 0.5)
v12 <- vgm(psill = 1, model = "Gau", range = 0.5, add.to = v1)
v12
```

```
##   model psill range
## 1   Nug     0   0.0
## 2   Exp     1   0.5
## 3   Gau     1   0.5
```

```r
# Cuidado con plot.variogramModel() si se pretende añadir elementos
plot(variogramLine(v12, maxdist = 3), type = "l", ylim = c(0, 2.25))
lines(variogramLine(v1, maxdist = 3), col = "red", lty = 2)
lines(variogramLine(v2, maxdist = 3), col = "blue", lty = 3)
legend("bottomright", c("Exponencial", "Gaussiano", "Anidado"), lty = c(2, 3, 1), 
       col = c("red", "blue", "black"), cex = 0.75)
```

<img src="03-modelado_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />


## Ajuste de un modelo válido {#ajuste-variog}

Como ya se comentó anteriormente, en general los estimadores del variograma no pueden ser usados directamente en la predicción espacial;
no son condicionalmente semidefinidos negativos y eso puede causar por ejemplo sistemas kriging inválidos o estimaciones negativas de la varianza kriging. 
Este problema normalmente se remedia buscando un modelo paramétrico válido que describa adecuadamente la dependencia espacial presente en los datos.
Supongamos que $P=\left\{ 2\gamma(\mathbf{h};\boldsymbol{\theta}):\boldsymbol{\theta}\in \Theta \right\}$, donde $2\gamma(\mathbf{h};\boldsymbol{\theta})$ es un variograma válido en $\mathbb{R}^{d}$ (normalmente isotrópico), es la familia parametrizada de variogramas escogida. 
Se trata de encontrar el mejor elemento de $P$, para lo que se han propuesto diversos criterios de bondad de ajuste (ver e.g. Cressie, 1993, Sección 2.6). 
Entre ellos hay que destacar los basados en mínimos cuadrados y en máxima verosimilitud, descritos a continuación.


### Estimación por mínimos cuadrados {#ls-fit}

Supongamos que $2\gamma(\mathbf{h};\boldsymbol{\theta}_0)$ es el variograma teórico y que $\hat{\gamma}_{i} =\hat{\gamma}(\mathbf{h}_{i})$, $i = 1,\ldots,K$, son las estimaciones del semivariograma obtenidas utilizando algún tipo de estimador piloto (e.g. alguno de los mostrados en la Sección 4.1.1).
Normalmente, siguiendo las recomendaciones sugeridas por Journel y Huijbregts (1978, p. 194), solamente se consideran en el ajuste saltos menores o iguales que la mitad del máximo salto (i.e. $\left\| \mathbf{h}_{i} \right\| \leq \frac{1}{2} \max \left\{ \left\| \mathbf{s}_{k} -\mathbf{s}_{l} \right\| \right\}$); y, si se utiliza el estimador empírico (o uno similar), de forma que el número de aportaciones a cada estimación sea por lo menos de treinta (i.e. $\left| N(\mathbf{h}_{i})\right| \geq 30$).
Habitualmente (e.g. Cressie, 1993, p. 96-97) la estimación por mínimos cuadrados de $\boldsymbol{\theta}_0$ se obtiene al minimizar:
\begin{equation} 
  \left( \hat{\boldsymbol{\gamma}} - \boldsymbol{\gamma}(\boldsymbol{\theta})\right)^{\top } \mathbf{V}(\boldsymbol{\theta})\left( \hat{\boldsymbol{\gamma}} - \boldsymbol{\gamma}(\boldsymbol{\theta})\right),
  (\#eq:ls-obj)
\end{equation}
<!-- \@ref(eq:ls-obj) -->
siendo $\hat{\boldsymbol{\gamma}} =(\hat{\gamma}(\mathbf{h}_1),\ldots,\hat{\gamma}
(\mathbf{h}_{K}))^\top$, $\boldsymbol{\gamma}(\boldsymbol{\theta})=(\gamma(\mathbf{h}_1 ;\boldsymbol{\theta}),\ldots,\gamma(\mathbf{h}_{K} ;\boldsymbol{\theta}))^\top$
y $\mathbf{V}(\boldsymbol{\theta})$ una matriz $K\times K$ semidefinida positiva que puede
depender de $\boldsymbol{\theta}$, considerando alguno de los siguientes casos:

* Mínimos cuadrados ordinarios (OLS): $\mathbf{V}(\boldsymbol{\theta}) = \mathbf{I}_{K}$, 
    la matriz identidad $K\times K$.

* Mínimos cuadrados ponderados (WLS): $\mathbf{V}(\boldsymbol{\theta}) = \text{diag}(w_1 (\boldsymbol{\theta}),\ldots,w_{K}(\boldsymbol{\theta}))$, 
    con $w_{i}(\boldsymbol{\theta})\geq 0$, $i=1,\ldots,K$. 
Normalmente se suele tomar estos pesos inversamente proporcionales a $Var(\hat{\gamma}(\mathbf{h}_{i}))$.

* Mínimos cuadrados generalizados (GLS):  $\mathbf{V}(\boldsymbol{\theta})=\boldsymbol{\Sigma}_{\hat{\boldsymbol{\gamma}}} (\boldsymbol{\theta})^{-1}$, 
    la inversa de la matriz de covarianzas (asintótica) de $\hat{\boldsymbol{\gamma}}$ obtenida suponiendo que el variograma teórico es $2\gamma(\mathbf{h};\boldsymbol{\theta})$.

Es importante señalar que al utilizar el criterio GLS el cálculo de la matriz de covarianzas $\boldsymbol{\Sigma}_{\hat{\boldsymbol{\gamma}}} (\boldsymbol{\theta})$ generalmente no resulta fácil (por ejemplo en Cressie 1993, p. 96, se tienen las expresiones para el estimador empírico y el estimador robusto, suponiendo normalidad). 
Esto produce que la minimización de la función objetivo \@ref(eq:ls-obj) sea computacionalmente prohibitiva en muchos casos. 
El método de mínimos cuadrados ponderados puede verse como un compromiso entre la eficiencia del método de GLS y la simplicidad del método de OLS. 
Además, suponiendo normalidad y que el variograma teórico es $2\gamma(\mathbf{h};\boldsymbol{\theta})$, Cressie (1985) probó que:
$$Var(\hat{\gamma}(\mathbf{h}_{i}))\simeq 2\dfrac{\gamma(\mathbf{h}_{i}
;\boldsymbol{\theta})^2 }{\left| N(\mathbf{h}_{i})\right| },$$
en el caso del estimador empírico; y para el estimador robusto:
$$Var(\tilde{\gamma}(\mathbf{h}_{i}))\simeq 2.885\dfrac{\gamma
(\mathbf{h}_{i} ;\boldsymbol{\theta})^2 }{\left| N(\mathbf{h}_{i})\right| },$$
siendo esta aproximación incluso mejor que en el caso anterior.
Proponiendo en estos casos la minimización de:
$$\sum\limits_{i=1}^{K} w_{i}(\boldsymbol{\theta}) \left( \hat{\gamma}(\mathbf{h}_{i}) - \gamma(\mathbf{h}_{i};\boldsymbol{\theta}) \right)^2,$$
siendo $w_{i}(\boldsymbol{\theta}) = \left| N(\mathbf{h}_{i})\right| /\gamma(\mathbf{h}_{i} ;\boldsymbol{\theta})^2$, como aproximación al criterio WLS. 

Estos métodos de ajuste tiene unas propiedades interesantes, cuanto mayor sea $\left| N(\mathbf{h}_{i})\right|$ mayor peso recibe el residuo en el salto $\mathbf{h}_{i}$ y además, cuanto más pequeño sea el valor del variograma teórico mayor peso recibe también el residuo correspondiente.
Por este motivo, los saltos próximos al origen típicamente reciben mayor peso con lo que se consigue un buen ajuste del modelo de variograma cerca del origen (esto es especialmente importante; ver e.g. Stein, 1988, y comentarios en la Sección \@ref(consideraciones-kriging)). 
Adicionalmente estos métodos pueden ser implementados fácilmente en la práctica (de forma similar al OLS).

Aunque para obtener las expresiones (o aproximaciones) de las varianzas y covarianzas de las estimaciones piloto se supone habitualmente que la distribución de los datos es normal, se puede probar fácilmente que los procedimientos de ajuste obtenidos son también válidos para el caso de datos normales transformados (ver e.g. Cressie, 1993, p. 98). 
Esta es una de las principales ventajas de los métodos WLS o GLS frente a otras alternativas (como los métodos basados en máxima verosimilitud); como utilizan solamente la estructura de segundo orden (asintótica) del estimador del variograma, no es necesario hacer suposiciones sobre la distribución completa de los datos^[La distribución y eficiencia asintótica de los estimadores mínimo cuadráticos ha sido estudiada por Lahiri et al. (2003), demostrando su consistencia y normalidad asintótica bajo condiciones muy generales.]. 

Como comentario final, en la función objetivo \@ref(eq:ls-obj) de los criterios WLS y GLS anteriores, la matriz de pesos utilizada en el ajuste $\mathbf{V}(\boldsymbol{\theta})$ depende también del parámetro sobre el que se realiza la minimización (y al minimizar \@ref(eq:ls-obj) en cierto sentido se están maximizando también las varianzas), por lo que puede ser preferible utilizar un algoritmo iterativo.
Por ejemplo comenzar con pesos OLS (o WLS con $w_{i} = \left| N(\mathbf{h}_{i})\right| / \| \mathbf{h}_{i} \|^2$) y posteriormente en cada etapa $k$ obtener una nueva aproximación $\hat{\boldsymbol{\theta}}_0^{(k)}$ al minimizar:
$$\left( \hat{\boldsymbol{\gamma}} - \boldsymbol{\gamma}(\boldsymbol{\theta})\right)^{\top } \mathbf{V}(\hat{\boldsymbol{\theta}}_0^{(k-1)})\left( \hat{\boldsymbol{\gamma}} - \boldsymbol{\gamma}(\boldsymbol{\theta})\right),$$
repitiendo este proceso hasta convergencia (realmente muchos de los algoritmos diseñados para el ajuste por mínimos cuadrados proceden de esta forma).

En `gstat` el ajuste OLS y WLS se realiza mediante la función:

```r
fit.variogram(object, model, fit.sills = TRUE, fit.ranges = TRUE,
              fit.method = 7, fit.kappa = FALSE, ...)
```

* `object`: semivariograma empírico, obtenido con la función `variogram()`. 
* `model`: modelo de semivariograma, generado con la función `vgm()`.
* `fit.sills`, `fit.ranges`, `fit.kappa`: determinan si se ajustan los correspondientes parámetros (`TRUE`) o se mantienen fijos (`FALSE`).
* `fit.method`: selección de los pesos en el criterio WLS.

    - `fit.method = 6`: $w_{i} = 1$, OLS.
    - `fit.method = 1`: $w_{i} = \left| N(\mathbf{h}_{i})\right|$.
    - `fit.method = 7`: $w_{i} = \left| N(\mathbf{h}_{i})\right| / \| \mathbf{h}_{i} \|^2$.
    - `fit.method = 2`: $w_{i} = \left| N(\mathbf{h}_{i})\right| /\gamma(\mathbf{h}_{i} ;\boldsymbol{\theta})^2$.
              
Los parámetros iniciales se fijan a los establecidos en `model`. Si alguno es desconocido (`NA`), le asigna un valor por defecto:

* el rango se establece a 1/3 de la distancia máxima del variograma empírico,
* al umbral parcial se le asigna el promedio de los últimos 5 valores del variograma empírico,
* y el efecto nugget (siempre que haya sido establecido explícitamente con `nugget = NA`) se toma como la media de los tres primeros valores del variograma empírico.

Como ejemplo, a continuación se ajusta un modelo exponencial al variograma empírico calculado en la Sección \@ref(vario-muestrales), mediante OLS y WLS con diferentes pesos:


```r
modelo <- vgm(model = "Exp", nugget = NA) # Valores iniciales por defecto, incluyendo nugget
# modelo <- vgm(psill = 0.6, model = "Exp", range = 0.2, nugget = 0.0) # Valores iniciales
fit.ols <- fit.variogram(vario, model = modelo, fit.method = 6)
# fit.npairs <- fit.variogram(vario, model = modelo, fit.method = 1) # Warning: No convergence
fit.npairs <- fit.variogram(vario, model = fit.ols, fit.method = 1)
```

```
## Warning in fit.variogram(vario, model = fit.ols, fit.method = 1): No convergence
## after 200 iterations: try different initial values?
```

```r
fit.lin <- fit.variogram(vario, model = modelo, fit.method = 7)
fit <- fit.variogram(vario, model = fit.lin, fit.method = 2) 
# Representar:
# Cuidado con plot.variogramModel() si se pretende añadir elementos
plot(vario$dist, vario$gamma, xlab = "distance", ylab =  "semivariance", 
     pch = 19, ylim = c(0, 1))
lines(variogramLine(fit.ols, maxdist = 0.6), lty = 2)
lines(variogramLine(fit.npairs, maxdist = 0.6), lty = 3)
lines(variogramLine(fit.lin, maxdist = 0.6), lty = 4)
lines(variogramLine(fit, maxdist = 0.6))
legend("bottomright", c("ols", "npairs", "default (linear)", "cressie"), lty = c(2, 3, 4, 1))
```

<img src="03-modelado_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />

En general, se recomendaría emplear pesos inversamente proporcionales a la varianza (`fit.method = 2`).
Si quisiésemos comparar el ajuste de distintos modelos (con el mismo criterio de ajuste) se podría considerar el valor mínimo de la función objetivo WLS, almacenado como un atributo del resultado (aunque la recomendación sería emplear validación cruzada, Sección \@ref(validacion-cruzada)):


```r
attr(fit, "SSErr")
```

```
## [1] 52.83535
```

Imprimiendo el resultado del ajuste obtenemos las estimaciones de los parámetros, que podríamos interpretar (ver Sección \@ref(caracteristicas-variograma) y Sección \@ref(efecto-variog-kriging)).


```r
fit
```

```
##   model   psill     range
## 1   Nug 0.13495 0.0000000
## 2   Exp 1.15982 0.6403818
```

```r
nugget <- fit$psill[1]
sill <- nugget + fit$psill[2]
range <- 3*fit$range[2] # Parámetro de escala en model = "Exp"
```

NOTA: Cuidado, en el caso del modelo exponencial, el parámetro que aparece como `range` es un parámetro de escala proporcional al verdadero rango práctico (tres veces ese valor).


```r
plot(vario$dist, vario$gamma, xlab = "distance", ylab =  "semivariance", 
     xlim = c(0, range*1.1), ylim = c(0, sill*1.1))
lines(variogramLine(fit, maxdist = range*1.1))
abline(v = 0, lty = 3)
abline(v = range, lty = 3)
abline(h = nugget, lty = 3)
abline(h = sill, lty = 3)
```

<img src="03-modelado_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" />


En `gstat` el ajuste con el criterio GLS se podría realizar mediante la función:

```r
fit.variogram.gls(formula, data, model, maxiter = 30, eps = .01, 
      trace = TRUE, ignoreInitial = TRUE, cutoff = Inf, plot = FALSE)
```
Sin embargo, actualmente solo admite datos tipo `Spatial*` del paquete `sp` y además es habitual que aparezcan problemas computacionales, por lo que no se recomendaría su uso.

```r
fit.variogram.gls(z ~ 1, as(datos, "Spatial"), modelo, 
                  maxiter = 2, cutoff = 0.6, plot = TRUE)
# Error in if (any(model$range < 0)) { :  missing value where TRUE/FALSE needed
```


### Modelado del variograma en procesos no estacionarios {#trend-fit}

Como ya se comentó en la introducción de este capítulo, si no se puede asumir que la tendencia es constante no es apropiado utilizar directamente los estimadores del semivariograma mostrados en la Sección \@ref(vario-muestrales).
Por ejemplo, considerando el modelo lineal \@ref(eq:modelolineal) de la Sección \@ref(modelos-clasicos-espaciales) (el modelo del *kriging universal*, Sección \@ref(kuniversal); que emplearemos en el resto de este capítulo), tendríamos que:
$$E(Z(\mathbf{s}_1)-Z(\mathbf{s}_{2}))^2 =2\gamma(\mathbf{s}_1
-\mathbf{s}_{2}) + \left( \sum\limits_{j=0}^{p}\beta_{j}  \left( X_{j}
(\mathbf{s}_1)-X_{j}(\mathbf{s}_{2})\right) \right)^2.$$
Muchas veces, cuando las estimaciones experimentales del semivariograma aparentan no estar acotadas (e.g. Figura \@ref(fig:aquifer-var-trend) izquierda), es debido a que la tendencia no está especificada correctamente.

El procedimiento habitual en geoestadística es eliminar la tendencia y estimar el variograma a partir de los residuos. Por ejemplo, en este caso, podríamos considerar los residuos de un ajuste OLS de la tendencia:
$$\mathbf{r}_{ols} =\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}}_{ols} =\left( \mathbf{I}_{n}
- (\mathbf{X}^{\top}\mathbf{X})^{-1}\mathbf{X}^{\top} \right)\mathbf{Z}.$$
Esto se puede hacer con la función `variogram()` del paquete `gstat` especificando la fórmula del modelo como primer argumento (ver Figura \@ref(fig:aquifer-var-trend) derecha).

Como ejemplo consideraremos los datos del acuífero Wolfcamp:

```r
load("datos/aquifer.RData")
library(sf)
aquifer$head <- aquifer$head/100 # en cientos de pies
aquifer_sf <- st_as_sf(aquifer, coords = c("lon", "lat"), remove = FALSE, agr = "constant")
# maxlag <- 0.5*sqrt(sum(diff(matrix(st_bbox(aquifer_sf), nrow = 2, byrow = TRUE))^2))

vario.est <- variogram(head ~ 1, aquifer_sf, cutoff = 150)
vario.resid <- variogram(head ~ lon + lat, aquifer_sf, cutoff = 150)    
oldpar <- par(mfrow = c(1, 2))
# plot(vario.est) # no compatible con mfrow
with(vario.est,  plot(dist, gamma, xlab = "distance", ylab =  "semivariance"))
# plot(vario.resid)
with(vario.resid,  plot(dist, gamma, xlab = "distance", ylab =  "semivariance"))
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/aquifer-var-trend-1.png" alt="Semivariograma empírico obtenido asumiendo media constante (izquierda) y a partir de los residuos de un ajuste lineal de la tendencia (derecha), empleando los datos del acuífero Wolfcamp." width="90%" />
<p class="caption">(\#fig:aquifer-var-trend)Semivariograma empírico obtenido asumiendo media constante (izquierda) y a partir de los residuos de un ajuste lineal de la tendencia (derecha), empleando los datos del acuífero Wolfcamp.</p>
</div>

```r
par(oldpar)
```

El ajuste por WLS se puede realizar también con la función `fit.variogram()`:


```r
modelo <- vgm(model = "Sph", nugget = NA) # Valores iniciales por defecto
# modelo <- vgm(psill = 3, model = "Sph", range = 75, nugget = 0) 
fit.resid <- fit.variogram(vario.resid, modelo, fit.method = 2)
fit.resid
```

```
##   model    psill    range
## 1   Nug 1.095133  0.00000
## 2   Sph 3.044034 63.39438
```

```r
# Cuidado con plot.variogramModel() si se pretende añadir elementos
# plot(fit.resid, cutoff = 150, ylim = c(0, 4.5))
# with(vario.resid,  points(dist, gamma))
with(vario.resid, plot(dist, gamma, xlab = "distance", ylab =  "semivariance", 
                       xlim = c(0, 150), ylim = c(0, 5)))
lines(variogramLine(fit.resid, maxdist = 150))
```

<div class="figure" style="text-align: center">
<img src="03-modelado_files/figure-html/aquifer-var-fit-1.png" alt="Ajuste de un modelo esférico de semivariograma a las estimaciones empíricas obtenidas a partir de los residuos de un ajuste lineal de la tendencia, empleando los datos del acuífero Wolfcamp." width="70%" />
<p class="caption">(\#fig:aquifer-var-fit)Ajuste de un modelo esférico de semivariograma a las estimaciones empíricas obtenidas a partir de los residuos de un ajuste lineal de la tendencia, empleando los datos del acuífero Wolfcamp.</p>
</div>

Sin embargo, para poder estimar la tendencia de forma eficiente sería necesario conocer la dependencia (i.e. conocer $\gamma(\cdot)$), que dependería a su vez de la estimación de la tendencia. 
Para solventar este problema circular, Neuman y Jacobson (1984) propusieron una aproximación iterativa, empezar con el estimador OLS de $\boldsymbol{\theta}$, estimar el variograma a partir de los residuos, ajustar un modelo de variograma válido, calcular el estimador GLS basado en el modelo ajustado y así sucesivamente hasta convergencia. 
En la práctica este procedimiento suele converger en pocas iteraciones (normalmente menos de 5).
Sin embargo, en el paquete `gstat` solo se realiza una iteración (se reestimará la tendencia empleando GLS al calcular las predicciones kriging). 

En el caso de variogramas no acotados, el proceso $\varepsilon(\cdot)$ no sería estacionario de segundo orden, no está disponible la matriz $\boldsymbol{\Sigma}$ y en principio sería imposible emplear GLS para estimar la tendencia. 
Sin embargo, normalmente se suele trabajar en un dominio acotado $D$ y podemos encontrar una constante positiva $A$ tal que $C^{\ast }(\mathbf{h})= A-\gamma(\mathbf{h})\geq 0,\forall \mathbf{h}\in D$ (y por tanto esta función es un covariograma válido en ese dominio).
La función $C^{\ast }(\mathbf{h})$ se suele denominar *pseudo-covariograma* (o covarianza localmente equivalente; ver e.g. Chilès y Delfiner, 1999, Sección 4.6.2). 
Si utilizamos $C^{\ast }(\mathbf{h})$ en lugar del covariograma en la estimación de la media (o en las ecuaciones del predictor del KU), la constante *A* se cancela y obtenemos los mismos resultados (sin embargo las varianzas si que dependen de esta constante).

<!-- 
En R, por ejemplo, podríamos volver a reestimar la tendencia mediante GLS y calcular los nuevos residuos mediante la función `gls()` del paquete `nlme`, que realmente emplea estimación por máxima verosimilitud.

```r
gls(model, data, correlation, weights, method, control, ...)
```
-->

Adicionalmente, habría que tener en cuenta también que la variabilidad de los residuos no es la de los errores teóricos (algo que normalmente se ignora).
Para ilustrar este problema supongamos que el proceso de error $\varepsilon(\cdot)$ es estacionario de segundo orden con covariograma conocido $C(\cdot)$ de forma que podemos calcular el estimador lineal óptimo de $\boldsymbol{\beta}$:
$$\hat{\boldsymbol{\beta}}_{gls} =(\mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1} \mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{Z} = \mathbf{P}_{gls}\mathbf{Z},$$
siendo $\mathbf{P}_{gls}$ la matriz de proyección.
Empleando este estimador obtenemos el vector de residuos:
$$\mathbf{r} =\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}}_{gls} =\left( \mathbf{I}_{n} - \mathbf{P}_{gls} \right)\mathbf{Z},$$
cuya matriz de varianzas-covarianzas resulta ser:
$$\begin{aligned}
Var(\mathbf{r}) &=(\mathbf{I}_{n} -\mathbf{P}_{gls})\boldsymbol{\Sigma}(\mathbf{I}_{n}
-\mathbf{P}_{gls})^\top  \\
& = \boldsymbol{\Sigma} - \mathbf{X}(\mathbf{X}^\top\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1}
\mathbf{X}^\top.
\end{aligned}$$
De donde se deduce que si utilizamos directamente los residuos, incluso procediendo de la forma más eficiente, se introduce un sesgo en la estimación de la dependencia espacial.
Explícitamente, si denotamos por $\hat{\mu}(\mathbf{s})$ la estimación GLS de la tendencia, puede verse que:
$$\begin{aligned}
C_{\mathbf{r}}(\mathbf{s}_{i} ,\mathbf{s}_{j}) &= Cov\left(Z(\mathbf{s}_{i})-\hat{\mu}(\mathbf{s}_{i}), Z(\mathbf{s}_{j} ) - \hat{\mu}(\mathbf{s}_{j})\right) \\
&= C(\mathbf{s}_{i} -\mathbf{s}_{j}) - Cov(\hat{\mu}(\mathbf{s}_{i} ), \hat{\mu}(\mathbf{s}_{j})),
\end{aligned}$$
y expresado en función del semivariograma:
$$\gamma_{\mathbf{r}}(\mathbf{s}_{i} ,\mathbf{s}_{j}) = \gamma
(\mathbf{s}_{i} -\mathbf{s}_{j})-\frac{1}{2} Var(\hat{\mu}
(\mathbf{s}_{i})-\hat{\mu}(\mathbf{s}_{j})).$$

Por tanto al utilizar alguno de los estimadores mostrados anteriormente con los residuos estimados obtenemos estimaciones sesgadas del semivariograma teórico.
Matheron (1971, pp. 152-155) ya notó que, por lo general, el sesgo del estimador del semivariograma es pequeño en los saltos próximos al origen, pero más sustancial en saltos grandes^[Para un caso particular, Cressie (1993, pp. 166-167) observó que los residuos basados en el estimador GLS dan lugar a un estimador del variograma con sesgo negativo y cuadrático en h.]. 
Parece ser que este problema provocó una desilusión con el kriging universal y la iniciativa hacia el kriging con funciones intrínsecamente estacionarias (ver e.g. Matheron, 1973; Cressie, 1993, Sección 5.4; o Chilès y Delfiner, 1999, cap. 4).

En cuanto a las consecuencias de que el estimador del variograma no sea insesgado en el kriging universal, hay que tener en cuenta que:

* Al ajustar un modelo de variograma por mínimos cuadrados ponderados o generalizados (Sección \@ref(ls-fit)), automáticamente los saltos pequeños reciben mayor peso en el ajuste.
* Además si la predicción espacial se lleva a cabo con un criterio de vecindad, el variograma sólo es evaluado en saltos pequeños, donde se tiene una buena estimación y un buen ajuste.
* También hay que tener en cuenta el resultado de Stein (1988), i.e. para una predicción eficiente generalmente sólo es necesario capturar la conducta del variograma cerca del origen

Por lo anterior, el desencanto con el kriging universal ha sido prematuro, el efecto del sesgo del estimador del variograma sobre el predictor del kriging universal es pequeño. 
Sin embargo la varianza del kriging universal se ve más afectada y es menor de lo que debería ser (para más detalles ver Cressie, 1993, pp. 296-299). 
Adicionalmente se han propuesto alternativas a los métodos de ajuste basados en mínimos cuadrados que tienen en cuenta el sesgo en la estimación del variograma (e.g. Beckers y Bogaert, 1998; Fernandez-Casal y Francisco-Fernandez, 2014, función [`npsp::np.svariso.corr()`](https://rubenfcasal.github.io/npsp/reference/np.svar.html)).

Otra alternativa sería asumir normalidad y estimar ambos componentes de forma conjunta empleando alguno de los métodos basados en máxima verosimilitud descritos en la siguiente sección (que también tienen problemas de sesgo).

### Estimación por máxima verosimilitud {#ml-fit}

La estimación por máxima verosimilitud (*maximum likelihood*, ML) es un método muy conocido en inferencia estadística paramétrica, aunque su uso en geoestadística ha sido relativamente reciente (a partir de mediados de los 80).
Además la estimación ML tiene una conexión directa con la estimación Bayesiana (e.g. Handcock y Wallis, 1994) y el empleo de estas herramientas en estadística espacial ha experimentado un notable aumento en los últimos años (e.g. [Wikle et al., 2019](https://spacetimewithr.org/); [Moraga, 2020](https://www.paulamoraga.com/book-geospatial/)).

Si suponemos que la distribución de los datos es normal: 
$$\mathbf{Z}\sim \mathcal{N}(\mathbf{X}\boldsymbol{\beta},\boldsymbol{\Sigma}),$$
donde $\boldsymbol{\Sigma}=\boldsymbol{\Sigma}(\boldsymbol{\theta})$ (utilizando la notación de secciones anteriores), se puede deducir fácilmente la expresión de la función de verosimilitud y obtener las estimaciones de los parámetros buscando los valores que la maximizan.

En este caso, la función de densidad de los datos es:
$$f(\mathbf{z})=(2\pi )^{-\frac{n}{2} } \left| \boldsymbol{\Sigma} \right|^{-\frac{1}{2} }
\exp \left\{ -\dfrac{1}{2}(\mathbf{z}-\mathbf{X}\boldsymbol{\beta})^\top \boldsymbol{\Sigma}^{-1}(\mathbf{z}-\mathbf{X}\boldsymbol{\beta})\right\}.$$
Además en la mayoría de los casos podemos reparametrizar el covariograma^[Por ejemplo en el caso de los semivariogramas mostrados en la Sección \@ref(modelos-parametricos), si $c_0$ es el efecto nugget y $c_1$ el umbral parcial, en lugar de éstos parámetros se considerarían la varianza (umbral) $\sigma^2 =c_0 +c_1$ y la proporción de nugget en el umbral total $c_0^{\ast} =c_0 /(c_0 +c_1)$ (lo que equivale a suponer en las expresiones del covariograma que $c_1 = 1 - c_0$ y $0 \leq c_0 \leq 1$).] de forma que:
$$\boldsymbol{\Sigma}=\sigma^2 \mathbf{V}(\boldsymbol{\theta}),$$
siendo $\sigma^2$ la varianza desconocida (o umbral total), y se obtiene que la expresión del logaritmo negativo de la función de verosimilitud (*negative log likelihood*, NLL) es:
$$\begin{aligned}
\mathcal{L}(\boldsymbol{\theta},\boldsymbol{\beta},\sigma^2 \left| \mathbf{Z} \right.) & = \dfrac{n}{2} \ln (2\pi) + \dfrac{n}{2} \ln(\sigma^2) + \dfrac{1}{2} \ln \left| \mathbf{V}(\boldsymbol{\theta}) \right|  \\
& + \ \dfrac{1}{2\sigma^2 }(\mathbf{Z}-\mathbf{X}\boldsymbol{\beta})^\top \mathbf{V}(\boldsymbol{\theta})^{-1}(\mathbf{Z}-\mathbf{X}\boldsymbol{\beta}),
\end{aligned}$$ 
donde $\left| \mathbf{V}(\boldsymbol{\theta})\right|$ denota el determinante de la matriz $\mathbf{V}(\boldsymbol{\theta})$.
Las estimaciones de los parámetros $(\boldsymbol{\theta}, \boldsymbol{\beta}, \sigma^2)$ se obtendrán minimizando el NLL. 
Un resultado bien conocido es que el mínimo se obtiene, independientemente de $\boldsymbol{\theta}$, para:
\begin{equation} 
  \begin{aligned}
  \hat{\boldsymbol{\beta}} & =(\mathbf{X}^\top\mathbf{V}(\boldsymbol{\theta})^{-1} \mathbf{X})^{-1} \mathbf{X}^\top\mathbf{V}(\boldsymbol{\theta})^{-1} \mathbf{Z}, \\
  \hat{\sigma }^2 & =\dfrac{1}{n}(\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}})^\top
  \mathbf{V}(\boldsymbol{\theta})^{-1}(\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}}).
  \end{aligned}
  (\#eq:estimadores-ml)
\end{equation} <!-- \@ref(eq:estimadores-ml) -->
Por tanto la función a minimizar respecto a $\boldsymbol{\theta}$ es:
$$\mathcal{L}(\boldsymbol{\theta}\left| \mathbf{Z}\right. )=\mathcal{L}(\hat{\boldsymbol{\beta}} ,\boldsymbol{\theta},\hat{\sigma }^2 \left|
\mathbf{Z}\right. ) = \dfrac{n}{2} \ln (2\pi ) + \dfrac{n}{2} \ln (\hat{\sigma
}^2) + \dfrac{1}{2} \ln \left| \mathbf{V}(\boldsymbol{\theta})\right| +\dfrac{n}{2}.$$
Para ello es necesario utilizar algoritmos de minimización no lineal multidimensional. 
Además está el problema de la posible multimodalidad de esta función (ver e.g. Mardia y Watkins, 1989), por tanto habría que asegurarse de que el algoritmo elegido no converge a un mínimo local. 
Si $\hat{\boldsymbol{\theta}}$ es la estimación de $\boldsymbol{\theta}$ obtenida al resolver este problema, sustituyendo en \@ref(eq:estimadores-ml) se obtienen las estimaciones del resto de parámetros^[El comportamiento asintótico (bajo dominio creciente) de estos estimadores ha sido estudiado por Mardia y Marshal (1984), dando condiciones (no muy fáciles de chequear en la práctica) para su consistencia y normalidad asintótica (ver también Cressie, 1993, Sección 7.3.1).].

Uno de los principales problemas de la estimación ML es que los estimadores de $\sigma^2$ y $\boldsymbol{\theta}$ pueden tener un sesgo considerable (especialmente cuando la tendencia no es constante), algo que es bastante conocido en la estimación de la varianza con datos independientes. 
Este problema se puede resolver (por lo menos en parte) utilizando una variante de este método.

El método de máxima verosimilitud restringida (*restricted maximum likelihood*, REML) se basa en la idea de filtrar los datos de forma que la distribución conjunta no dependa de $\boldsymbol{\beta}$. 
Se trata de maximizar la verosimilitud de $m=n-p-1$ contrastes de error linealmente independientes:
$$\mathbf{Y}=\boldsymbol{\Lambda}\mathbf{Z},$$
siendo $\boldsymbol{\Lambda}$ una matriz $m\times n$ de rango $m$ y tal que $\boldsymbol{\Lambda}\mathbf{X}=\mathbf{0}$ (i.e. $E(\mathbf{Y}) = \mathbf{0}$).
Estas combinaciones lineales también se denominan habitualmente *incrementos generalizados* y, asumiendo normalidad, su distribución no depende de $\boldsymbol{\beta}$:
$$\mathbf{Y}\sim \mathcal{N}(\mathbf{0},\boldsymbol{\Lambda}\boldsymbol{\Sigma}\boldsymbol{\Lambda}^\top).$$
De forma análoga al caso anterior podríamos obtener la correspondiente función de verosimilitud. Además, Harville (1974) demostró que las verosimilitudes de distintos incrementos generalizados son iguales salvo una constante y que se pueden obtener expresiones simplificadas
seleccionando la matriz $\boldsymbol{\Lambda}$ de forma que $\boldsymbol{\Lambda}^\top \boldsymbol{\Lambda}=\mathbf{I}_{n} -\mathbf{X}(\mathbf{X^\top}\mathbf{X})^{-1} \mathbf{X}^\top$ y $\boldsymbol{\Lambda}\boldsymbol{\Lambda}^\top =\mathbf{I}_{m}$, obteniéndose la siguiente expresión para el NLL:

$$\begin{aligned}
\mathcal{L}(\boldsymbol{\theta}\left| \mathbf{Y}\right. ) 
& = \dfrac{m}{2} \ln (2\pi ) + \dfrac{m}{2} \ln (\hat{\sigma}_{Y}^2) -\dfrac{1}{2} \left| \mathbf{X}^\top\mathbf{X}\right|  \\
& + \ \dfrac{1}{2} \left| \mathbf{X}^\top\mathbf{V}(\boldsymbol{\theta})^{-1}
\mathbf{X}\right| +\dfrac{1}{2} \ln \left| \mathbf{V}(\boldsymbol{\theta})\right|
+\dfrac{m}{2} ,\end{aligned}$$ 
siendo:
$$\hat{\sigma }_{Y}^2 =\dfrac{1}{m}(\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}}
)^\top \mathbf{V}(\boldsymbol{\theta})^{-1}(\mathbf{Z}-\mathbf{X}\hat{\boldsymbol{\beta}}).$$

En general se da por hecho que la estimación REML mejora, a veces significativamente, los resultados obtenidos con la estimación ML (sobre todo si $p$ es grande comparado con $n$). 
En numerosos estudios de simulación (e.g. Zimmerman y Zimmerman, 1991; Fernández-Casal et al., 2003b) se ha observado que el sesgo en las estimaciones de los parámetros del variograma es en general menor.
<!-- 
aunque no se han estudiado todavía las propiedades asintóticas teóricas de estos estimadores?
-->

En `gstat` el ajuste mediante REML se podría realizar empleando la función:

```r
fit.variogram.reml(formula, locations, data, model, degree = 0, ...)
```
Sin embargo, aparentemente ***el método no está bien implementado*** (emplea `formula` para un ajuste OLS y después, en el código C interno, considera una tendencia polinómica en las coordenadas determinada por `degree`), actualmente solo admite datos tipo `Spatial*` del paquete `sp` y además es habitual que aparezcan problemas computacionales, por lo que no se recomendaría su uso. 

```r
model <- vgm(psill = 3, model = "Sph", range = 75, nugget = 0)
fit.variogram.reml(head ~ 1, data = as(aquifer_sf, "Spatial"), model = model, degree = 1)
```

```
##   model      psill range
## 1   Nug -0.7976219     0
## 2   Sph 12.5397527    75
```
Como aparece en la ayuda de esta función, es preferible usar el paquete `geoR` (ver Sección \@ref(geor-ajuste) del apéndice; también se podría emplear el paquete `nlme`), empleando la función `geoR::likfit()` para el ajuste y posteriormente `as.vgm.variomodel()` para convertir el modelo ajustado a un objeto de `gstat`.


```r
geor.models <- c(Exp = "exponential", Sph = "spherical", Cir = "circular", 
             Gau = "gaussian", Mat = "matern", Pow = "power", Nug = "nugget", 
             Lin = "linear")
pars.ini <- c(psill = 3, range = 75, nugget = 0, kappa = 0.5)
res <- geoR::likfit(coords = st_coordinates(aquifer_sf), data = aquifer_sf$head,
             lik.method = "REML", trend = "1st", cov.model = geor.models["Sph"], 
             ini.cov.pars = pars.ini[1:2], nugget = pars.ini[3], kappa = pars.ini[4])
```

```
## kappa not used for the spherical correlation function
## ---------------------------------------------------------------
## likfit: likelihood maximisation using the function optim.
## likfit: Use control() to pass additional
##          arguments for the maximisation function.
##         For further details see documentation for optim.
## likfit: It is highly advisable to run this function several
##         times with different initial values for the parameters.
## likfit: WARNING: This step can be time demanding!
## ---------------------------------------------------------------
## likfit: end of numerical maximisation.
```

```r
summary(res)
```

```
## Summary of the parameter estimation
## -----------------------------------
## Estimation method: restricted maximum likelihood 
## 
## Parameters of the mean component (trend):
##   beta0   beta1   beta2 
## 26.7704 -0.0701 -0.0634 
## 
## Parameters of the spatial component:
##    correlation function: spherical
##       (estimated) variance parameter sigmasq (partial sill) =  4.545
##       (estimated) cor. fct. parameter phi (range parameter)  =  79.16
##    anisotropy parameters:
##       (fixed) anisotropy angle = 0  ( 0 degrees )
##       (fixed) anisotropy ratio = 1
## 
## Parameter of the error component:
##       (estimated) nugget =  1.191
## 
## Transformation parameter:
##       (fixed) Box-Cox parameter = 1 (no transformation)
## 
## Practical Range with cor=0.05 for asymptotic range: 79.16084
## 
## Maximised Likelihood:
##    log.L n.params      AIC      BIC 
## "-160.4"      "6"  "332.7"  "347.4" 
## 
## non spatial model:
##    log.L n.params      AIC      BIC 
## "-174.5"      "4"  "357.1"  "366.8" 
## 
## Call:
## geoR::likfit(coords = st_coordinates(aquifer_sf), data = aquifer_sf$head, 
##     trend = "1st", ini.cov.pars = pars.ini[1:2], nugget = pars.ini[3], 
##     kappa = pars.ini[4], cov.model = geor.models["Sph"], lik.method = "REML")
```

```r
as.vgm.variomodel(res)
```

```
##   model    psill    range
## 1   Nug 1.191129  0.00000
## 2   Sph 4.544502 79.16084
```


<!-- 
Pendiente:
Estimación con geoR (y nlme?) y conversión del modelo resultante a vgm de gstat
En teoría en el paquete nlme está eficientemente implementado (también se podría emplear el paquete mgcv...)
-->


## Comentarios sobre los distintos métodos

Podemos afirmar que los métodos de estimación basados en mínimos cuadrados son los utilizados con mayor frecuencia en geoestadística. 
Por el contrario la estimación por máxima verosimilitud ha sido objeto de debate, con numerosos comentarios en la literatura a favor (e.g. Pardo-Igúzquiza, 1998) y en contra (e.g. Ripley, 1988) de este tipo de métodos.

Una ventaja de los métodos de máxima verosimilitud es que permiten estimar de forma conjunta $\boldsymbol{\beta}$ y $\boldsymbol{\theta}$ directamente de los datos (y no es necesario calcular estimaciones piloto del variograma). 
Los problemas numéricos relacionados con este tipo de estimación se pueden resolver en la práctica utilizando por ejemplo algoritmos genéticos;
aunque el tiempo de computación aumenta notablemente cuando el número de datos es grande (algo que también ocurre con el método GLS). 
Sin embargo, uno de los principales inconvenientes normalmente achacados a estos métodos es que la hipótesis de normalidad es difícil (o más bien imposible) de chequear en la práctica a partir de una única realización parcial del proceso. 
Otro problema que también se debe tener en cuenta al utilizar estos métodos es su falta de robustez cuando hay valores atípicos (outliers) en los datos.

No obstante es de esperar que las estimaciones obtenidas con los métodos de máxima verosimilitud sean más eficientes cuando la distribución de los datos se aproxima a la normalidad y el modelo paramétrico está  especificado correctamente (especialmente con la estimación REML); aunque no está claro si esta mejora es realmente significativa comparada con otros métodos más sencillos como el de WLS. 
De hecho, bajo la hipótesis de normalidad, Zimmerman y Zimmerman (1991) observaron, al comparar mediante simulación las estimaciones obtenidas utilizando
distintos métodos (entre ellos ML, REML, OLS, WLS y GLS), que el método de WLS era a veces el mejor procedimiento y nunca resultaba malo (considerando el sesgo, el error en media cuadrática y la cobertura del intervalo de predicción al 95%). 
Además, los métodos de mínimos cuadrados sólo utilizan la estructura asintótica de segundo orden del estimador piloto (no es necesario hacer suposiciones sobre la distribución completa de los datos), por lo que resultan ser más robustos que los de máxima verosimilitud cuando no se conoce por completo la distribución de $Z$ (e.g. Carroll y Ruppert, 1982) y son adecuados incluso cuando la distribución de los datos no es normal (aunque en ese caso pueden no ser los óptimos). 
Los comentarios anteriores, además de su fácil implementación, justifican que el método WLS sea el preferible para muchos autores.

Por otra parte, si se asume un modelo paramétrico habrá que asegurarse en la práctica de que esa suposición es adecuada. 
Diblasi y Bowman (2001) propusieron un método basado en la estimación no paramétrica para contrastar si el variograma teórico de un proceso estacionario es constante (i.e. si no hay dependencia espacial; ver Figura \@ref(fig:sm-variogram)). 
Posteriormente Maglione y Diblasi (2004) propusieron contrastes de hipótesis para verificar si un determinado modelo paramétrico semivariograma es apropiado (ver también Bowman y Crujeiras, 2013). 
Para evitar posibles problemas relacionados con la mala especificación del modelo de variograma se puede pensar en su estimación de forma no paramétrica
(Capítulo XX; ver paquete [`npsp`](https://rubenfcasal.github.io/post/geoestadistica-no-parametrica-con-el-paquete-npsp)). 
En este caso los métodos de mínimos cuadrados serán claramente preferibles a los basados en máxima verosimilitud.

Para comparar el ajuste obtenido con distintos modelos se pueden considerar los correspondientes valores finales de la función objetivo utilizada; por ejemplo los valores WLS (o GLS) correspondientes a su ajuste al estimador piloto o los valores del NLL si se utiliza alguno de los métodos de máxima verosimilitud (en este caso también se pueden emplear criterios para la selección de modelos que tengan en cuenta el número de parámetros, como AIC -*Aikaike Information Criterion*- o BIC -*Bayesian Information Criterion*). 
Sin embargo en muchas ocasiones el objetivo final es la predicción, por lo que se suele utilizar la técnica de validación cruzada descrita en la Sección \@ref(validacion-cruzada).


<!-- 
## Referencias

Pendiente: añadir bibliografía bibtex y referencias paquetes
-->

