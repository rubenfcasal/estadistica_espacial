# Predicción Kriging  {#kriging}

<!-- 
---
title: "Estadística Espacial"
author: "Análisis estadístico de datos con dependencia (GCED)"
date: "Curso 2021/2022"
bibliography: ["packages.bib", "estadistica_espacial.bib"]
link-citations: yes
output: 
  bookdown::html_document2:
    pandoc_args: ["--number-offset", "3,0"]
    toc: yes 
    # mathjax: local            # copia local de MathJax, hay que establecer:
    # self_contained: false     # las dependencias se guardan en ficheros externos 
  bookdown::pdf_document2:
    keep_tex: yes
    toc: yes 
---

Capítulo \@ref(kriging)
bookdown::preview_chapter("04-kriging.Rmd")
knitr::purl("04-kriging.Rmd", documentation = 2)
knitr::spin("04-kriging.R",knit = FALSE)

PENDIENTE:
Revisar referencias páginas Chilès y Delfiner 1999 -> 2012
-->




En este capítulo se comentan brevemente los métodos más conocidos de predicción espacial denominados métodos kriging^[Podríamos definir los métodos kriging como algoritmos de predicción de mínimo error en media cuadrática que tienen en cuenta la estructura de segundo orden del proceso] (ver Sección \@ref(geoestadistica) para un resumen del origen de esta terminología), centrándonos únicamente en el caso de predicción lineal puntual univariante (el caso multivariante se trata en el Capítulo \@ref(multivar)). 
Una revisión más completa de estos métodos se tiene por ejemplo en Cressie (1993, Capítulo 3 y secciones 5.1, 5.4 y 5.9.1) o Chilès y Delfiner (2012, capítulos 3, 4 y 6).

## Introducción {#introduccion}

Si denotamos por $\mathbf{Z}=\left( Z(\mathbf{s}_{1}), \ldots, z(\mathbf{s}_{n} )\right)^\top$ valores observados del proceso, los distintos métodos kriging proporcionan un predictor $p(\mathbf{Z},\mathbf{s}_{0})$ de $Z(\mathbf{s}_{0})$ verificando que:

* es lineal:
  $$p(\mathbf{Z},\mathbf{s}_{0}) = \lambda_{0} + \sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}),$$
  
* es uniformemente insesgado, para cualquier $\mu(\cdot)$:
  $$E(p(\mathbf{Z},\mathbf{s}_{0}))=\mu(\mathbf{s}_{0}),$$
  
* y minimiza el error en media cuadrática de predicción (*mean squared prediction error*, MSPE):
  $$E\left( \left( p(\mathbf{Z},\mathbf{s}_{0})-Z(\mathbf{s}_{0})\right)^2 \right).$$

En este capítulo, al hablar de predicción óptima, nos referiremos a que se verifican estas dos últimas condiciones.

Dependiendo de las suposiciones acerca de la función de tendencia $\mu(\cdot)$, se distingue principalmente entre tres métodos kriging:

1. *Kriging simple* (KS): se supone que la media es conocida (algunos autores suponen también que es constante o incluso cero). 
  Además se asume que el covariograma existe y es conocido.
  
2. *Kriging ordinario* (KO): se supone que la media es constante (i.e. $E(Z(\mathbf{s}))=\mu ,\forall \mathbf{s}\in D$) y desconocida. 
  Además se asume que por lo menos existe el variograma y es conocido.
  
3. *Kriging universal* (KU; también denominado kriging con modelo de tendencia): se supone que la media es desconocida y no constante, pero
que es una combinación lineal (desconocida) de $p+1$ funciones (o variables explicativas) conocidas $\left\{ X_{j} (\cdot):j=0, \ldots,p\right\}$:
  $$\mu(\mathbf{s})=\sum\limits_{j=0}^{p}X_{j} (\mathbf{s})\beta_{j}$$
  donde $\boldsymbol{\beta}=(\beta_{0}, \ldots, \beta_{p} )^\top \in \mathbb{R}^{p+1}$ es un vector desconocido. 
  Se asume también que por lo menos existe el variograma y es conocido^[Siempre que una de las funciones explicativas sea idénticamente 1, e.g. $X_{0} (\cdot)\equiv 1$, en caso contrario las ecuaciones kriging sólo pueden expresarse en función del covariograma (Sección \@ref(ku-covariograma)).].

Por simplicidad el kriging ordinario se tratará en este capítulo como un caso particular del kriging universal (aunque en la práctica se suele pensar en el KO como un método distinto al KU, principalmente por los inconvenientes que presenta este último; ver Sección \@ref(trend-fit)).
Adicionalmente en la Sección \@ref(kriging-residual) se tratará una extensión del KU denominada *kriging residual* o *kriging con tendencia externa*.

La suposición de que el variograma (o el covariograma) sólo dependa del salto es conveniente para facilitar el modelado de la dependencia espacial, pero para la predicción espacial no es necesaria esta consideración. 
Por tanto en las expresiones de las ecuaciones de los distintos métodos kriging se utilizará la notación más general no estacionaria:
$$C(\mathbf{s}_{1}, \mathbf{s}_{2}) = Cov(Z(\mathbf{s}_{1}), Z(\mathbf{s}_{2})),$$
$$2\gamma(\mathbf{s}_{1}, \mathbf{s}_{2}) = Var(Z(\mathbf{s}_{1}) - Z(\mathbf{s}_{2})),$$
en lugar de suponer que son funciones de $\mathbf{s}_{1}-\mathbf{s}_{2}$.

## Kriging con media conocida: kriging simple {#ksimple}

Supongamos que el proceso $Z(\cdot)$ admite una descomposición de la forma:
$$Z(\mathbf{s})=\mu(\mathbf{s})+\varepsilon(\mathbf{s}),$$
siendo $\mu(\cdot)$ la función de tendencia conocida y $\varepsilon(\cdot)$ un proceso espacial de media cero con covariograma conocido $C(\mathbf{s}_{1}, \mathbf{s}_{2}) =Cov(\varepsilon(\mathbf{s}_{1}), \varepsilon(\mathbf{s}_{2}))$ (no necesariamente estacionario, aunque en la práctica se suele suponer que $\varepsilon(\cdot)$ es un proceso estacionario de segundo orden).
El predictor lineal óptimo minimiza el MSPE, que puede expresarse como:
$$\begin{aligned}
E\left[ \left( p(\mathbf{Z},\mathbf{s}_{0}) - Z(\mathbf{s}_{0})\right)^2 \right]  
& = Var\left( p(\mathbf{Z},\mathbf{s}_{0}) - Z(\mathbf{s}_{0})\right) 
+ \left[ E\left( p(\mathbf{Z},\mathbf{s}_{0}) - Z(\mathbf{s}_{0})\right) \right]^{2}  \\
& = Var\left( Z(\mathbf{s}_{0})-\sum\limits_{i=1}^{n}\lambda_{i}
Z(\mathbf{s}_{i}) \right) +\left( \mu(\mathbf{s}_{0}
)-\sum\limits_{i=1}^{n}\lambda_{i} \mu(\mathbf{s}_{i}) -\lambda_{0}
\right)^{2},
\end{aligned}$$
de donde se deduce que:
$$\lambda_{0} =\mu(\mathbf{s}_{0})-\sum\limits_{i=1}^{n}\lambda_{i} \mu(\mathbf{s}_{i}),$$
(por tanto el sesgo es nulo).
Entonces el predictor es de la forma:
$$p(\mathbf{Z}, \mathbf{s}_{0}) = \mu(\mathbf{s}_{0}) + \sum\limits_{i=1}^{n}\lambda_{i} (Z(\mathbf{s}_{i}) -\mu(\mathbf{s}_{i})),$$
(por tanto se puede pensar que se trata de la estimación lineal homogénea de un proceso de media cero) y el MSPE es igual a:
$$\begin{aligned}
E\left[ \left( p(\mathbf{Z},\mathbf{s}_{0})-Z(\mathbf{s}_{0})\right)^2 \right]  & = E\left[ \left( \sum\limits_{i=1}^{n}\lambda_{i} \varepsilon(\mathbf{s}_{i}) -\varepsilon(\mathbf{s}_{0})\right)^2 \right]  \\
& = \sum\limits_{i=1}^{n}\sum\limits_{j=1}^{n}\lambda_{i} \lambda_{j}
C(\mathbf{s}_{i},\mathbf{s}_{j} ) -2 \sum\limits_{i=1}^{n}\lambda_{i}
C(\mathbf{s}_{i},\mathbf{s}_{0}) +C(\mathbf{s}_{0},\mathbf{s}_{0}).\end{aligned}$$
Para minimizar esta función se igualan a cero las derivadas parciales respecto a los pesos, obteniéndose las ecuaciones del kriging simple:
$$\sum\limits_{j=1}^{n}\lambda_{j} C(\mathbf{s}_{i},\mathbf{s}_{j} )
- C(\mathbf{s}_{i},\mathbf{s}_{0})=0, \ \
i=1, \ldots, n,$$
que pueden expresarse en forma matricial como:
$$\boldsymbol{\Sigma}\boldsymbol{\lambda}=\mathbf{c},$$
siendo $\boldsymbol{\lambda} = \left(\lambda_{1}, \ldots, \lambda_{n}\right)^\top$, $\mathbf{c}=\left( C(\mathbf{s}_{1},\mathbf{s}_{0}), \ldots,C(\mathbf{s}_{n}, \mathbf{s}_{0})\right)^\top$ y $\boldsymbol{\Sigma}$ la matriz $n\times n$ de varianzas-covarianzas de los datos (i.e. $\boldsymbol{\Sigma}_{ij} =C(\mathbf{s}_{i},\mathbf{s}_{j} )$). 
Combinando las expresiones para $\lambda_{0}$ y $\boldsymbol{\lambda}$, se obtiene el predictor del kriging simple:
$$p_{KS}(\mathbf{Z}, \mathbf{s}_{0}) = \mu(\mathbf{s}_{0}) + \mathbf{c^\top }\boldsymbol{\Sigma}^{-1} (\mathbf{Z}-\boldsymbol{\mu}),$$
donde $\boldsymbol{\mu}=\left( \mu(\mathbf{s}_{1}), \ldots,\mu(\mathbf{s}_{n} )\right)^\top$, y el correspondiente valor mínimo del MSPE, también denominado *varianza kriging*:
$$\sigma_{KS}^{2} (\mathbf{s}_{0})=C(\mathbf{s}_{0},\mathbf{s}_{0}
)-\mathbf{c^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c}.$$
Una de las principales utilidades de la varianza kriging es la construcción de intervalos de confianza (normalmente basados en la hipótesis de normalidad).

Para que exista una única solución del sistema la matriz $\boldsymbol{\Sigma}$ debe ser no singular. 
Una condición suficiente para que esto ocurra es que el covariograma $C(\cdot ,\cdot)$ sea una función definida positiva (hay que tener cuidado con la anisotropía zonal, ver Sección \@ref(anisotropia)) y las posiciones de los datos sean distintas.
En la práctica suele interesar la predicción en múltiples posiciones.
Teniendo en cuenta que la matriz del sistema no depende de la posición
de predicción^[Además, tanto los pesos kriging como la varianza kriging no dependen de los datos observados, solamente de las posiciones y del covariograma (lo que por ejemplo, entre otras cosas, facilita el diseño de la configuración espacial de muestreo).], el procedimiento recomendado sería calcular la factorización Cholesky de la matriz $\boldsymbol{\Sigma}$ y posteriormente emplear esta factorización para resolver el sistema en cada posición de predicción $\mathbf{s}_{0}$.

## Kriging con media desconocida: kriging universal y kriging residual {#kuniversal}

Como ya se comentó, el kriging universal se basa en el siguiente modelo:
$$Z(\mathbf{s}) = \sum\limits_{j=0}^{p}X_{j}(\mathbf{s})\beta_{j} + \varepsilon(\mathbf{s}),$$
donde $\boldsymbol{\beta}=(\beta_{0}, \ldots, \beta_{p})^\top \in \mathbb{R}^{p+1}$ es un vector desconocido, $\left\{ X_{j}(\cdot):j=0, \ldots,p\right\}$ son funciones conocidas y $\varepsilon(\cdot)$ un proceso espacial de media cero con variograma conocido $2\gamma(\mathbf{s}_{1},\mathbf{s}_{2}) = Var(\varepsilon(\mathbf{s}_{1})-\varepsilon(\mathbf{s}_{2}))$ (aunque en la práctica se suele suponer estacionario). 
Supondremos también que $X_{0} (\cdot)\equiv 1$, de esta forma además en el caso particular de $p=0$, se corresponderá con el modelo del kriging ordinario (ver Sección \@ref(introduccion)) muy utilizado en la práctica.
Utilizando una notación matricial podemos escribir:
$$\mathbf{Z}=\mathbf{X}\boldsymbol{\beta}+\boldsymbol{\varepsilon},$$
siendo $\boldsymbol{\varepsilon}=\left( \varepsilon(\mathbf{s}_{1}), \ldots, \varepsilon(\mathbf{s}_{n} )\right)^\top$ y $\mathbf{X}$ una matriz $n\times (p+1)$ con $\mathbf{X}_{ij} =X_{j-1} (\mathbf{s}_{i})$, y:
$$Z(\mathbf{s}_{0})=\mathbf{x}_0^\top\boldsymbol{\beta}+\varepsilon(\mathbf{s}_{0}),$$
con $\mathbf{x}_0=\left(X_{0}(\mathbf{s}_{0}), \ldots, X_{p}(\mathbf{s}_{0})\right)^\top$.

En este caso, como un predictor lineal verifica que:
$$E\left( \sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}) +\lambda_{0} \right) = \boldsymbol{\lambda}^\top \mathbf{X}\boldsymbol{\beta}+\lambda_{0},$$\
siendo $\boldsymbol{\lambda}=\left( \lambda_{1}, \ldots,\lambda_{n} \right)^\top$, una condición necesaria y suficiente para que el predictor sea uniformemente insesgado, i.e. $E(p(\mathbf{Z},\mathbf{s}_{0}))=E(Z(\mathbf{s}_{0}))=\mathbf{x}_0^\top\boldsymbol{\beta}$, $\forall \boldsymbol{\beta}\in \mathbb{R}^{p+1}$, es que $\lambda_{0} =0$ y:
\begin{equation}
  \boldsymbol{\lambda}^\top \mathbf{X} = \mathbf{x}_0^\top.
  (\#eq:resticciones-ku)
\end{equation} <!-- \@ref(eq:resticciones-ku) -->
Además como $X_{0} (\cdot)\equiv 1$, una de estas restricciones es:
\begin{equation}
  \sum\limits_{i=1}^{n}\lambda_{i} = 1,
  (\#eq:resticcion-ko)
\end{equation} <!-- \@ref(eq:resticcion-ko) -->
que es la única condición que deben verificar los pesos en el caso del kriging ordinario.

Por tanto el predictor del kriging universal será de la forma:
$$p(\mathbf{Z},\mathbf{s}_{0})=\sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}),$$
verificando \@ref(eq:resticciones-ku) y tal que minimiza el MSPE. 
Entonces se trata de minimizar:
\begin{equation}
  E\left( Z(\mathbf{s}_{0})-\sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}) \right)^{2} - 2\sum\limits_{j=0}^{p}m_{j} \left( \sum\limits_{i=1}^{n} \lambda_{i} X_{j} (\mathbf{s}_{i})- X_{j}(\mathbf{s}_{0}) \right)
  (\#eq:objetivo-ku)
\end{equation} <!-- \@ref(eq:objetivo-ku) -->
respecto a $\left\{ \lambda_{i} :i=1, \ldots,n\right\}$ y $\left\{ m_{j} :j=0, \ldots,p\right\}$, multiplicadores de Lagrange que garantizan \@ref(eq:resticciones-ku). 
Teniendo en cuenta que el predictor es insesgado y que los pesos verifican \@ref(eq:resticcion-ko), entonces:
$$\begin{aligned}
\left( \sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}) - Z(\mathbf{s}_{0})\right)^2  
& = \left( \sum\limits_{i=1}^{n}\lambda_{i} \varepsilon(\mathbf{s}_{i}) - \varepsilon(\mathbf{s}_{0})\right)^2  \\
& = -\dfrac{1}{2} \sum\limits_{i=1}^{n}\sum\limits_{j=1}^{n}\lambda_{i}\lambda_{j} \left( \varepsilon(\mathbf{s}_{i}) - \varepsilon(\mathbf{s}_{j} )\right)^{2}  + \sum\limits_{i=1}^{n}\lambda_{i} \left( \varepsilon(\mathbf{s}_{i}) - \varepsilon(\mathbf{s}_{0}) \right)^{2},
\end{aligned}$$
y podemos escribir \@ref(eq:objetivo-ku) como:
$$-\sum\limits_{i=1}^{n}\sum\limits_{j=1}^{n}\lambda_{i} \lambda_{j}
\gamma(\mathbf{s}_{i},\mathbf{s}_{j} ) +2 \sum\limits_{i=1}^{n}\lambda
_{i} \gamma(\mathbf{s}_{i},\mathbf{s}_{0}) -2\sum\limits_{j=0}^{p}m_{j}
\left( \sum\limits_{i=1}^{n}\lambda_{i} X_{j} (\mathbf{s}_{i})-X_{j}
(\mathbf{s}_{0}) \right)$$ Derivando respecto a
$\left\{ \lambda_{i} :i=1, \ldots,n\right\}$ y
$\left\{ m_{j} :j=0, \ldots,p\right\}$ e igualando a cero se obtienen las
$n+p+1$ ecuaciones del kriging universal que, expresadas en forma
matricial, resultan ser:
$$\boldsymbol{\Gamma}_{U} \boldsymbol{\lambda}_{U} =\boldsymbol{\gamma}_{U},$$
con:
$$\boldsymbol{\Gamma}_{U} = \left( \begin{array}{lc}
\boldsymbol{\Gamma} & \mathbf{X} \\
\mathbf{X^\top } & \mathbf{0}
\end{array} \right) ,\ 
\boldsymbol{\lambda}_{U} = \left( \begin{array}{c}
\boldsymbol{\lambda} \\
\mathbf{m}
\end{array} \right) ,\ 
\boldsymbol{\gamma}_{U} =\left( \begin{array}{c}
\boldsymbol{\gamma} \\
\mathbf{x}_0
\end{array} \right),$$
donde $\boldsymbol{\gamma}=\left( \gamma(\mathbf{s}_{1},\mathbf{s}_{0}), \ldots, \gamma(\mathbf{s}_{n} ,\mathbf{s}_{0})\right)^\top$, $\mathbf{m}=\left(m_{0}, \ldots,m_{p} \right)^\top$ y $\boldsymbol{\Gamma}$ es una matriz $n\times n$ con $\boldsymbol{\Gamma}_{ij} = \gamma(\mathbf{s}_{i}, \mathbf{s}_{j})$. 
Además el MSPE mínimo, o varianza kriging:
$$\sigma_{KU}^{2} (\mathbf{s}_{0})=2\sum\limits_{i=1}^{n}\lambda_{i} 
\gamma(\mathbf{s}_{0},\mathbf{s}_{i}
)-\sum\limits_{i=1}^{n}\sum\limits_{j=1}^{n}\lambda_{i}  \lambda_{j}
\gamma(\mathbf{s}_{i},\mathbf{s}_{j} )$$ 
se puede obtener como:
$$\begin{aligned}
\sigma_{KU}^{2} (\mathbf{s}_{0})
& =\sum\limits_{i=1}^{n}\lambda_{i} \gamma(\mathbf{s}_{0},\mathbf{s}_{i})+\sum\limits_{j=0}^{p}m_{j} X_{j}
(\mathbf{s}_{0}) \\
& =\boldsymbol{\lambda}_{U}^\top \boldsymbol{\gamma}_{U}.
\end{aligned}$$
En el caso particular del kriging ordinario ($p=0$), la expresión de la varianza kriging resulta ser:
$$\sigma_{KO}^{2} (\mathbf{s}_{0})=\sum\limits_{i=1}^{n}\lambda_{i} 
\gamma(\mathbf{s}_{0},\mathbf{s}_{i})+m_{0}.$$

### Ecuaciones en función del covariograma {#ku-covariograma}

Cuando existe el covariograma $C(\mathbf{s}_{1},\mathbf{s}_{2}) = Cov(\varepsilon(\mathbf{s}_{1}), \varepsilon(\mathbf{s}_{2}))$ del proceso $\varepsilon(\cdot)$ y es conocido (una suposición más fuerte), podemos expresar las ecuaciones del kriging universal (o del KO) en función de $C(\cdot,\cdot)$. 
Además, si ninguna de las funciones explicativas es idénticamente 1, las ecuaciones del kriging universal sólo pueden expresarse en función del covariograma. 

El proceso sería análogo al caso anterior, el sistema del kriging universal equivalente es:
$$\boldsymbol{\Sigma}_{U} \boldsymbol{\lambda}_{U} = \mathbf{c}_{U},$$
donde:
$$\boldsymbol{\Sigma}_{U} =\left( 
\begin{array}{lc}
\boldsymbol{\Sigma} & \mathbf{X} \\
\mathbf{X^\top } & \mathbf{0}
\end{array}
\right) ,\ 
\boldsymbol{\lambda}_{U} =\left( \begin{array}{c}
\boldsymbol{\lambda} \\
\mathbf{m}
\end{array} \right) ,\ 
\mathbf{c}_{U} =\left( \begin{array}{c}
\mathbf{c} \\
\mathbf{x}_0
\end{array} \right),$$
y la varianza kriging es:
$$\begin{aligned}
\sigma_{KU}^{2} (\mathbf{s}_{0}) 
& = C(\mathbf{s}_{0},\mathbf{s}_{0}) - \sum\limits_{i=1}^{n}\lambda_{i}  C(\mathbf{s}_{0},\mathbf{s}_{i}) + \sum\limits_{j=0}^{p}m_{j} X_{j}(\mathbf{s}_{0}) \\
& = C(\mathbf{s}_{0}, \mathbf{s}_{0}) - \boldsymbol{\lambda}_{U} \mathbf{c}_{U}.
\end{aligned}$$

Muchos de los algoritmos utilizados para la solución de los sistema kriging están diseñados y optimizados para covariogramas (e.g. Chilès y Delfiner, 2012, p. 170). 
En el caso de variogramas no acotados se podrían emplear pseudo-covarianzas (ver Sección \@ref(trend-fit)).
<!-- 
Puede verse que la solución del sistema del KU es la misma cambiando $\gamma(\cdot, \cdot)$ por $c + \gamma(\cdot ,\cdot)$, para cualquier $c \in \mathbb{R}$. 
-->

### Kriging residual {#kriging-residual}

Otra forma, que puede ser más interesante, de obtener las ecuaciones del KU es a partir del predictor del kriging simple. 
Suponiendo que $\boldsymbol{\beta}$ es conocido en el modelo del KU, el predictor del kriging simple es:
$$\begin{aligned}
p_{KS} (\mathbf{Z},\mathbf{s}_{0})
& = \mathbf{x}_0^{\top}\boldsymbol{\beta} + \mathbf{c}^{\top} \boldsymbol{\Sigma}^{-1} \left( \mathbf{Z} - \mathbf{X}\boldsymbol{\beta} \right) \\
& =\mathbf{c^\top }\boldsymbol{\Sigma}^{-1}
\mathbf{Z}+(\mathbf{x}_0-\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c})^\top \boldsymbol{\beta}.
\end{aligned}$$

Cuando $\boldsymbol{\beta}$ no es conocido es lógico pensar en utilizar en su lugar su estimador lineal óptimo
$$\hat{\boldsymbol{\beta}}_{gls} =(\mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1} \mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{Z},$$ 
obteniéndose el predictor:
$$p^{\ast}(\mathbf{Z},\mathbf{s}_{0}) = \mathbf{c^\top }\boldsymbol{\Sigma}^{-1}\mathbf{Z} + (\mathbf{x}_0-\mathbf{X}^\top\boldsymbol{\Sigma}^{-1} \mathbf{c})^\top \hat{\boldsymbol{\beta}}_{gls}.$$
Puede verse (Goldberger, 1962) que este predictor, lineal e insesgado, es óptimo (en el sentido de que minimiza el MSPE sobre todos los predictores lineales e insesgados) y por tanto coincide con el predictor del kriging universal.
Además, teniendo en cuenta que el error $\left( p_{KS} (\mathbf{Z},\mathbf{s}_{0})-Z(\mathbf{s}_{0})\right)$ tiene covarianza nula con cualquier combinación lineal de $\mathbf{Z}$ (ver e.g. Chilès y Delfiner, 2012, p. 161), esta relación también se extiende a la varianza kriging:
$$\sigma_{KU}^{2} (\mathbf{s}_{0})=\sigma_{KS}^{2} (\mathbf{s}_{0}
)+(\mathbf{x}_0-\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c})^\top \left(
\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{X}\right)^{-1}
(\mathbf{x}_0-\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c}),$$
donde el segundo termino cuantifica la precisión en la estimación de la media.
Estas expresiones son conocidas como la relación de aditividad entre el KS y el KU.

Los resultados anteriores permiten pensar en la predicción lineal con media desconocida como un proceso de dos etapas: en la primera estimar la media desconocida, y en la segunda realizar la predicción lineal óptima con media supuestamente conocida.
En el caso de una tendencia lineal obtenemos el predictor de KU, mientras que en el caso general se obtiene el denominado predictor del *kriging residual* (o *kriging con tendencia externa*).


## Kriging con el paquete **gstat** {#kriging-gstat}

Los métodos kriging (KS, KO y KU) están implementados en la función `krige()` del paquete `gstat`. 
Normalmente la sintaxis empleada es:

```r
krige(formula, locations, newdata, model, ..., beta)
```

* `formula`: fórmula que define la tendencia como un modelo lineal de la respuesta en función de las variables explicativas (para KO será de la forma `z ~ 1`). 
* `locations`: objeto `sf` o `Spatial*` que contiene las observaciones espaciales (incluyendo las variables explicativas). 
* `newdata`: objeto `sf`, `stars` o `Spatial*`, que contiene las posiciones de predicción (incluyendo las variables explicativas). 
* `model`: modelo de semivariograma (generado con la función `vgm()` o `fit.variogram()`).
* `beta`: vector con los coeficientes de tendencia (incluida la intersección) si se supone conocida (se empleará para KS, en lugar de las estimaciones GLS empleadas en KO y KU).

Esta función, además de kriging univariante puntual con vecindario global, también implementa kriging por bloques, cokriging (predicción multivariante), predicción local y simulación condicional.
Para predicción (o simulación) local se pueden establecer los siguientes parámetros adicionales (ver Sección \@ref(eleccion-vecindario)):

* `maxdist`: solo se utilizarán las observaciones a una distancia de la posición de predicción menor de este valor. 
* `nmax`, `nmin` (opcionales): número máximo y mínimo de observaciones más cercanas. Si el número de observaciones más cercanas dentro de la distancia `maxdist` es menor que `nmin`, se generará un valor faltante.
* `omax` (opcional): número máximo de observaciones por octante (3D) o cuadrante (2D).

Los parámetros (opcionales) para simulación condicional (ver e.g. Fernández-Casal y Cao, 2020, [Sección 7.5](https://rubenfcasal.github.io/simbook/simulaci%C3%B3n-condicional-e-incondicional.html)) son:

* `nsim`: número de generaciones. Si se establece un valor distinto de cero, se emplea simulación condicional en lugar de predicción kriging. 
* `indicators`: valor lógico que determina el método de simulación. Por defecto (`FALSE`) emplea simulación condicional gaussiana, en caso contrario (`TRUE`) simula una variable indicadora.

Como ejemplo consideraremos los datos del acuífero Wolfcamp con el modelo del kriging universal ajustado en la Sección \@ref(trend-fit) (en [s100](s100.html) se tiene un ejemplo adicional empleando KO).


```r
load("datos/aquifer.RData")
library(sf)
```

```
## Linking to GEOS 3.9.1, GDAL 3.4.3, PROJ 7.2.1; sf_use_s2() is TRUE
```

```r
aquifer$head <- aquifer$head/100 # en cientos de pies...
aquifer_sf <- st_as_sf(aquifer, coords = c("lon", "lat"), remove = FALSE, agr = "constant")
library(gstat)
vario <- variogram(head ~ lon + lat, aquifer_sf, cutoff = 150)
fit <- fit.variogram(vario, vgm(model = "Sph", nugget = NA), fit.method = 2)
```

Como se mostró en el Ejemplo \@ref(exm:aquifer2), para generar la rejilla de predicción podemos utilizar la función `st_as_stars()` del paquete `stars` considerando un buffer de radio 40 en torno a las posiciones espaciales:


```r
buffer <- aquifer_sf %>% st_geometry() %>% st_buffer(40)
library(stars)
```

```
## Loading required package: abind
```

```r
grid <- buffer %>%  st_as_stars(nx = 50, ny = 50)
```

Como suponemos un modelo (no constante) para la tendencia, es necesario añadir los valores de las variables explicativas a la rejilla de predicción:


```r
coord <- st_coordinates(grid)
grid$lon <- coord$x
grid$lat <- coord$y
```

Además, en este caso recortamos la rejilla para filtrar predicciones alejadas de las observaciones:


```r
grid <- grid %>% st_crop(buffer)
```

Obtenemos las predicciones mediante kriging universal (Sección \@ref(kuniversal)):


```r
pred <- krige(formula = head ~ lon + lat, locations = aquifer_sf, model = fit,
              newdata = grid)
```

```
## [using universal kriging]
```

Aparentemente hay un ***ERROR en krige()*** y cambia las coordenadas del objeto `stars`:


```r
summary(st_coordinates(grid))
```

```
##        x                 y         
##  Min.   :-181.86   Min.   :-28.03  
##  1st Qu.:-100.73   1st Qu.: 33.25  
##  Median : -16.22   Median : 97.09  
##  Mean   : -16.22   Mean   : 97.09  
##  3rd Qu.:  68.29   3rd Qu.:160.93  
##  Max.   : 149.42   Max.   :222.21
```

```r
summary(st_coordinates(pred))
```

```
##        x                 y         
##  Min.   :-181.86   Min.   : 53.83  
##  1st Qu.:-100.73   1st Qu.:115.11  
##  Median : -16.22   Median :178.95  
##  Mean   : -16.22   Mean   :178.95  
##  3rd Qu.:  68.29   3rd Qu.:242.79  
##  Max.   : 149.42   Max.   :304.08
```

Para evitar este problema podemos añadir los resultado al objeto `grid` y emplearlo en lugar de `pred`:


```r
grid$var1.pred <- pred$var1.pred
grid$var1.var <- pred$var1.var
```

Podemos representar las predicciones y las varianzas kriging empleando `plot.stars()`:


```r
plot(grid["var1.pred"], breaks = "equal", col = sf.colors(64), key.pos = 4,
     main = "Predicciones kriging")
```



\begin{center}\includegraphics[width=0.7\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-10-1} \end{center}

```r
plot(grid["var1.var"], breaks = "equal", col = sf.colors(64), key.pos = 4,
     main = "Varianzas kriging")
```



\begin{center}\includegraphics[width=0.7\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-10-2} \end{center}

<!-- Error: breaks = "pretty" -->

También podríamos emplear el paquete `ggplot2`:


```r
library(ggplot2)
library(gridExtra)
p1 <- ggplot() + geom_stars(data = grid, aes(fill = var1.pred, x = x, y = y)) +
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
p2 <- ggplot() + geom_stars(data = grid, aes(fill = var1.var, x = x, y = y)) +
    scale_fill_viridis_c() + geom_sf(data = aquifer_sf) +
    coord_sf(lims_method = "geometry_bbox")
grid.arrange(p1, p2, ncol = 2)
```



\begin{center}\includegraphics[width=1\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-11-1} \end{center}

## Consideraciones acerca de los métodos kriging {#consideraciones-kriging}

Los métodos kriging descritos anteriormente permiten obtener el mejor predictor lineal insesgado (BLUP, *best linear unbiased predictor*). 
Como es bien sabido, en el caso de normalidad el predictor óptimo (tomando como función de pérdidas el error cuadrático) es lineal y va a coincidir con los predictores kriging. 
Pero si el proceso no es normal no tiene porque serlo, lo que ha motivado el desarrollo de métodos kriging no lineales (ver e.g. Rivoirard, 1994) y del kriging trans-normal (ver Sección \@ref(kriging-trans-normal)).

En estos métodos se supone que el variograma (covariograma) es conocido, sin embargo en la práctica en realidad el variograma es estimado (kriging estimado).
Puede verse (Yakowitz y Szidarovszky, 1985) que, bajo condiciones muy generales, el predictor kriging con variograma estimado converge al valor correcto si la densidad de datos tiende a infinito, incluso cuando la estimación del variograma no es muy buena. 
Además, Stein (1988) probó que para una predicción asintóticamente (de relleno) eficiente lo que se necesita generalmente es capturar la conducta del variograma cerca del origen. 
Por tanto, en cuanto a las predicciones, el factor más importante es que la aproximación al variograma
verdadero cerca del origen no sea muy mala.

Al contrario que en el caso del predictor, la estimación del
variograma afecta directamente a la varianza kriging y en general no es un estimador consistente del error en media cuadrática del predictor con variograma estimado.
En general, por ejemplo si el proceso es normal, es de esperar que subestime la verdadera varianza de predicción y por tanto debería incrementarse para que tenga en cuenta el efecto de la estimación del variograma. 
Para más detalles sobre este problema, ver por ejemplo Cressie (1993, Sección 5.3), Christensen (1991, Sección 6.5), Stein (1999, Sección 6.8) o Chilès y Delfiner (2012, Sección 3.4.3).
En la Sección \@ref(validacion-cruzada) se sugiere una posible corrección de la varianza kriging a partir del método de validación cruzada.


### Kriging como interpolador {#kriging-interpolador}

Las ecuaciones kriging tienen en cuenta varios aspectos del problema de interpolación^[Para un tratamiento más detallado ver por ejemplo Chilès y Delfiner (2012), secciones 3.3.2 y 3.4.2.]:

* La configuración espacial de los datos, a través de las matrices $\boldsymbol{\Sigma}$ (o $\boldsymbol{\Gamma}$), donde el covariograma (o el variograma) actúa como una "distancia estadística" entre las observaciones y de forma que se tiene en cuenta la información redundante presente en los datos.
* La situación de la posición de predicción respecto a los datos, a través
de $\mathbf{c}$ (o $\boldsymbol{\gamma}$).
* La presencia de una función determinística de tendencia.

Adicionalmente también tienen en cuenta propiedades estadísticas del proceso $Z(\cdot)$, a través del variograma o el covariograma (que como se comentó en la Sección \@ref(procesos-estacionarios), entre otras cosas, determina las propiedades de continuidad del proceso). 
Esta es la principal diferencia con otros métodos de interpolación que no tienen en cuenta la estructura de segundo orden del proceso.

Una propiedad importante de los predictores kriging es que son interpoladores exactos (suponiendo que no hay error de medida^[En caso contrario interesaría predecir el proceso libre de ruido y habría que modificar ligeramente las ecuaciones kriging. Para más detalles, ver por ejemplo Cressie (1993, pp. 128-130) o Chilès y Delfiner (2012, Sección 3.7.1)]), en el sentido de que $p(\mathbf{Z},\mathbf{s}_{0})=Z(\mathbf{s}_{0})$ cuando $\mathbf{s}_{0}=\mathbf{s}_{i}$ (la solución de los sistemas es $\lambda_{i} =1$ y $\lambda_{j} =0$, $\forall j\neq i$), y naturalmente en ese caso la estimación de la varianza es 0. 
Además, por lo general no son continuos en las posiciones de los datos, para que lo sean el efecto nugget debe ser nulo.

Otra característica de la interpolación kriging (y que no aparece en otros métodos como los que asignan pesos inversamente proporcionales a la distancia) es el denominado *efecto pantalla*. 
En general se observa (ver comentarios en la siguiente sección) que la influencia de un valor es menor si está oculto detrás de otro valor (e.g. Journel y Huijbregts, 1978, p. 346). 
Esto produce, por ejemplo en el caso del KO (incluso con un variograma isotrópico), que puntos situados a la misma distancia de la posición de predicción puedan tener distintos pesos y que los datos cercanos no apantallados reciban los mayores pesos, reduciéndose considerablemente (llegando a ser negativos) los pesos de los datos que quedan ocultos^[En la literatura se muestran numerosos ejemplos sobre el comportamiento de los pesos kriging en distintos escenarios; una colección bastante completa se tiene en Wakernagel (1998, Capítulo 13).].

La aparición de pesos negativos (o mayores que 1) en el KO como consecuencia del efecto pantalla, puede provocar (incluso suponiendo media constante) que el predictor kriging no esté necesariamente comprendido entre el valor mínimo y máximo de los datos. 
Esto que en principio puede ser una propiedad muy interesante puede conducir a resultados extraños en ciertas ocasiones, como por ejemplo dar lugar a predicciones negativas en casos en los que la variable considerada es necesariamente positiva. 
Para solucionar estos problemas se han propuesto numerosas alternativas, entre ellas la inclusión de restricciones adicionales sobre los pesos de forma que sean positivos (e.g. Chilès y Delfiner, 2012, Sección 3.9.1) (lo cual puede dar lugar a un incremento considerable del MSPE de predicción) o sobre el predictor (ver p.e. Goovaerts, 1997, Sección 7.4.2). 
Otra alternativa que puede ser preferible es la transformación del proceso $Z(\cdot)$ a otra escala (de forma que se aproxime a la normalidad), realizar la predicción kriging del proceso transformado y volver a la escala original (pero asegurándose de que al hacer la transformación inversa el resultado tenga las propiedades de optimalidad deseadas); más detalles sobre este procedimiento se tienen en la Sección \@ref(kriging-trans-normal).

### Efecto del variograma (covariograma) en el kriging {#efecto-variog-kriging}

El variograma (o el covariograma) tiene un efecto determinante en la predicción espacial. 
Como ejemplo, a continuación se incluyen algunas observaciones acerca de la influencia en el kriging de las tres principales características de un variograma estacionario (normalmente tratadas como parámetros) definidas en la Sección \@ref(procesos-estacionarios).

**Rango**

Supongamos que la posición de predicción $\mathbf{s}_{0}$ está a una
distancia mayor que el rango de las posiciones de los datos $\left\{ \mathbf{s}_{1}, \ldots,\mathbf{s}_{n} \right\}$ (i.e. la posición de predicción está fuera de la zona de influencia de los datos), entonces $\mathbf{c}=\mathbf{0}$ en las ecuaciones kriging, obteniéndose que:
$$p_{KS} (\mathbf{Z},\mathbf{s}_{0})=\mu(\mathbf{s}_{0}),\ \ p_{KU} (\mathbf{Z},\mathbf{s}_{0})=\mathbf{x}_0^\top\hat{\boldsymbol{\beta}}_{gls},$$
por lo tanto la predicción kriging se reduce a la media^[Puede verse fácilmente que la ecuaciones del kriging universal con $\mathbf{c}=\mathbf{0}$, son las obtenidas en el denominado método kriging de estimación de la tendencia (e.g. Wackernagel, 1998, pp. 212-213; Chilès y Delfiner, 2012, Sección 3.4.5).] (estimada en el caso del KU).

**Nugget y umbral**

Resulta claro que las estimaciones obtenidas de la varianza de los predictores kriging dependen en gran medida de estos parámetros. 
Es importante destacar que la escala del variograma (o del covariograma) no influye en las predicciones obtenidas, solamente en la varianza kriging.
Si se multiplica el variograma (o el covariograma) por una constante, las ecuaciones de los predictores kriging quedan invariantes y consecuentemente los pesos kriging no cambian, aunque la varianza kriging resulta multiplicada por esa constante.
Para estudiar su influencia en la predicción resulta de utilidad la proporción del efecto nugget en el umbral total $c_{0} /\sigma^{2}$ (que como ya se comentó al final de la Sección \@ref(procesos-estacionarios), proporciona mucha información acerca del grado de dependencia espacial presente en los datos). 
Por ejemplo, en el caso en que toda la variabilidad es efecto nugget (i.e. el proceso $Z(\cdot)$ es ruido blanco) entonces $\boldsymbol{\Sigma}=\sigma^{2} \mathbf{I}_{n}$ y $\mathbf{c}=\mathbf{0}$ (suponiendo que $\mathbf{s}_{0}\neq \mathbf{s}_{i}, \forall i$), y los predictores kriging se reducen a la estimación OLS de la tendencia:
$$p_{KU} (\mathbf{Z},\mathbf{s}_{0}) = \mathbf{x}_0^\top(\mathbf{X }^\top\mathbf{X})^{-1} \mathbf{X}^\top\mathbf{Z} = \mathbf{x }_0^\top\hat{\boldsymbol{\beta}}_{ols}.$$
En el caso del KO se obtiene la media muestral:
$$p_{KO} (\mathbf{Z},\mathbf{s}_{0})=\bar{Z} =\dfrac{1}{n}
\sum\nolimits_{i=1}^{n}Z(\mathbf{s}_{i}),$$
predictor bien conocido que asigna igual peso a todos los datos (por tanto el efecto pantalla es nulo).
Además, teniendo en cuenta los resultados de la Sección \@ref(kriging-residual), como $\sigma_{KS}^{2} (\mathbf{s}_{0})=\sigma^{2}$ (caso más desfavorable), entonces:
$$\sigma_{KO}^{2} (\mathbf{s}_{0})=\sigma_{}^{2} +\dfrac{\sigma_{}^{2}
}{n},$$
es decir, la varianza del KO para el caso de procesos incorrelados es igual a la varianza del proceso más la varianza de la media muestral. 
En general (al menos en KS y KO), se puede ver que al aumentar el porcentaje de efecto nugget en el umbral total disminuye el efecto pantalla y aumenta la varianza kriging (ver e.g. Isaaks y Srivastava, 1989, pp. 305-306).
Hay que tener en cuenta que cuando la media no es constante (e.g. KU), puede ocurrir incluso lo contrario del efecto pantalla, y observaciones alejadas pueden tener una gran influencia en la estimación (como es bien conocido en la estimación de la tendencia).

Teniendo en cuenta los comentarios anteriores, podemos afirmar que todos los parámetros (características) del variograma influyen en el kriging (aunque quizás el rango es el que tiene un menor efecto, ya que pequeñas variaciones en este parámetro producen resultados casi idénticos). 
Estas observaciones no contradicen el resultado de que asintóticamente lo importante es capturar el comportamiento del variograma cerca del origen (Stein, 1988).
Es difícil determinar cuando los datos están suficientemente cerca como para tener sólo en cuenta el efecto nugget y la pendiente del variograma cerca del origen.

###  Elección del vecindario {#eleccion-vecindario}

Una práctica habitual en geoestadística, en lugar de considerar todas las observaciones disponibles, es incluir en las ecuaciones kriging únicamente los $n(\mathbf{s}_{0})$ datos más "próximos" a la posición de predicción $\mathbf{s}_{0}$ . 
Esto puede justificarse por varias razones:

* Utilizar todos los datos puede dar lugar a un sistema de difícil solución debido a problemas numéricos. Por ejemplo, entre otros, el tiempo de computación (aproximadamente proporcional a $n(\mathbf{s}_{0})^{3}$) aumenta drásticamente al aumentar el numero de datos.
* Las estimaciones del variograma son normalmente eficientes (o incluso el propio modelo geoestadístico válido) únicamente en pequeñas distancias.
* El uso de vecindarios locales permite la relajación de las hipótesis del modelo (como la estacionariedad intrínseca en el caso del KO) o su simplificación (por ejemplo, en el caso del KU se puede suponer que locamente la estructura de la tendencia es más simple o incluso constante y utilizar en su lugar KO local).
* En muchos casos los datos cercanos apantallan a los más alejados
reduciendo su influencia (aunque no siempre de forma significativa; ver
observaciones siguientes).

La selección "optima" de un vecindario local resulta no obstante un problema algo complejo. Por ejemplo, se acostumbra a pensar que el rango del variograma permite determinar por sí solo un criterio de vecindad, como incluir en las ecuaciones sólo los datos que estén dentro del rango de $\mathbf{s}_{0}$, sin embargo esto puede no ser adecuado en muchos casos (aunque en la práctica el valor de este parámetro puede ser de gran utilidad como referencia inicial). 
Teniendo en cuentas las observaciones realizadas en secciones anteriores, cuando aumenta la proporción de efecto nugget disminuye el efecto pantalla, el predictor kriging se reduce a la media y observaciones a más distancia que el rango de la posición de predicción contribuyen (a veces de forma significativa) a la estimación de la tendencia. 
Hay que tener en cuenta que los pesos kriging dependen de la configuración espacial de todas las observaciones y observaciones fuera del rango pueden tener influencia en la predicción a través de su correlación con observaciones dentro del rango (esto es conocido en la literatura como efecto *relay*, que podríamos traducir por efecto transmisión).

Se han propuesto algunos criterios para la selección de un vecindario óptimo (e.g. Cressie, 1993, pp. 176-177), que son de utilidad cuando los datos están regularmente espaciados y el vecindario se puede fijar de antemano. 
Por ejemplo, se pueden ir incluyendo observaciones en el vecindario hasta que no se produzca una disminución "significativa" en la estimación de la varianza kriging.

En la práctica, la densidad de datos y su configuración espacial en torno a las posiciones de predicción pueden ser muy irregulares.
Teniendo en cuenta esto se han desarrollado distintos algoritmos, algunos bastante sofisticados, para la selección de vecindarios (ver e.g. Isaaks y Srivastava, 1989, Capítulo 14; Deutsch y Journel, 1992, secciones II.4 y IV.6).
Para la selección de los datos típicamente se fija un radio máximo de búsqueda y únicamente se consideran los datos dentro de una circunferencia (esfera) centrada en la posición de predicción. 
En el caso de anisotropía (Sección 2.2.2), se considera una elipse (elipsoide) con el radio mayor orientado en la dirección de máxima variación. 
Además suele interesar disponer de observaciones en todas direcciones, por lo que se divide la zona de búsqueda en sectores angulares (por ejemplo cuadrantes en el caso bidimensional o octantes en el caso tridimensional) y se selecciona un número mínimo de datos en todos o en la mayoría de esos sectores (esto evita también que clusters de datos tengan una excesiva influencia sobre predicciones en su entorno). 
Si se sospecha de la presencia de una tendencia en los datos (KU), puede ser deseable la inclusión de observaciones más alejadas de la posición de predicción para poder estimarla de forma más eficiente.

Utilizando un algoritmo de búsqueda que tenga en cuenta todas o alguna de las consideraciones anteriores, típicamente se selecciona un número pequeño de datos como vecindario (e.g. entre 10 y 20 observaciones) para cada posición de predicción. 
Sin embargo esto puede causar que las superficies de predicción presenten discontinuidades (especialmente cuando los datos están regularmente espaciados y se utiliza búsqueda por octantes). 
Una aproximación distinta sería la selección un único vecindario más grande (e.g. de 20 a 40 observaciones) para pequeños conjuntos de posiciones de predicción, de esta forma en condiciones normales los vecindarios correspondientes a conjuntos de predicción próximos se solapan y es de esperar que no aparezcan discontinuidades. 
Además el incremento en tiempo de computación debido a la inclusión de un número mayor de observaciones se compensa por el hecho de que sólo es necesario factorizar una vez la matriz sistema kriging para obtener las predicciones en el conjunto considerado^[Por ejemplo, si se pretenden obtener predicciones en una rejilla bidimensional, el tiempo de computación considerando un vecindario distinto con 16 observaciones para cada nodo resulta similar a considerar un vecindario con 25 (o incluso más) observaciones para grupos de 4 nodos (dos por fila y columna).].

Otra forma de proceder que puede ser de interés en la práctica, es usar el semivariograma como distancia en lugar de la tradicional distancia euclidea; de esta forma los datos son seleccionados preferentemente en la dirección de máxima continuidad (y se evita tener que considerar elipsoides en el caso de anisotropía).
Adicionalmente, cuando el número de datos es grande y sus posiciones irregulares, es recomendable utilizar alguna técnica de búsqueda, como el denominado *kd-tree* (e.g. ver paquete [`FNN`](https://CRAN.R-project.org/package=FNN)), de forma que se puedan determinar eficientemente las observaciones más próximas a la posición de predicción $\mathbf{s}_{0}$ (en lugar de comprobar todas las posiciones).

Independientemente del algoritmo de búsqueda que se vaya a utilizar, puede ser recomendable realizar antes algunas pruebas utilizando por ejemplo la técnica de validación cruzada  descrita a continuación.


## Validación cruzada del modelo ajustado {#validacion-cruzada}

El método de validación cruzada es la técnica normalmente utilizada en geoestadística para diagnosticar si un modelo (de tendencia y variograma) describe adecuadamente la variabilidad espacial de los datos (ver e.g. Cressie, 1993, Sección 2.6.4).
Si se asume que la tendencia es constante, permitiría verificar si el modelo de variograma describe adecuadamente la dependencia espacial de los datos. 
Aunque también es utilizada para otros fines (ver e.g. Isaaks y Srivastava, 1989, Capítulo 15), entre ellos: comparar distintas hipótesis sobre el modelo geoestadístico (tipo de modelo, vecindarios, etc.), detectar observaciones atípicas o incluso para la estimación de los parámetros del variograma. 
La idea básica es eliminar una parte de los datos y utilizar el resto de los datos para predecir los datos eliminados, entonces el error de predicción puede deducirse del valor que se predice menos el observado; repitiendo esto sobre varios conjuntos de datos se tiene una idea sobre la variabilidad del error de predicción. 
En su versión más simple, validación cruzada dejando uno fuera (*Leave-one-out cross-validation*, LOOCV), para cada observación de la muestra se obtiene una predicción empleando el resto de observaciones (para más detalles, ver e.g. Fernández-Casal et al., 2021, [Sección 1.3.3](https://rubenfcasal.github.io/aprendizaje_estadistico/const-eval.html#cv)).
En el caso de datos geoestadísticos no sólo interesa analizar las predicciones, en general son también de interés las estimaciones del error cuadrático de predicción (varianza kriging).

Supongamos que $\hat{Z}_{-j}(\mathbf{s}_{j})$ es un predictor de $Z(\mathbf{s}_{j})$ obtenido, utilizando alguno de los métodos de predicción espacial, a partir de $\left\{ Z(\mathbf{s}_{i}):i\neq j\right\}$ y el variograma ajustado $2\gamma(\cdot ,\hat{\boldsymbol{\theta}})$ (calculado utilizando todos los datos), y que $\sigma_{-j}^2 (\mathbf{s}_{j})$ es el correspondiente error en media cuadrática de predicción. 
Hay varias formas de medir la aproximación de las predicciones a los verdaderos valores, por ejemplo:

* La media de los errores tipificados (*dimensionless mean error*)
$$\text{DME} =\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \hat{Z}_{-j}(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right) /\sigma_{-j}(\mathbf{s}_{j})$$ 
debería ser próxima a cero. Este no es un criterio muy adecuado (sobre todo en el caso del KO) ya que los predictores kriging son insesgados independientemente del modelo de variograma utilizado (ver e.g. Yakowitz y Szidarovski, 1985).

* El error cuadrático medio adimensional (*dimensionless mean squared error*):
$$\text{DMSE} =\sqrt{\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \left( \hat{Z}_{-j}(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right) /\sigma_{-j}(\mathbf{s}_{j})\right)^2  }$$ 
debería ser próximo a uno. 
El valor de este estadístico puede interpretarse como una medida de la concordancia entre las varianzas kriging y las varianzas observadas.
Teniendo en cuenta que si reescalamos el variograma multiplicándolo por una constante, las predicciones con el variograma reescalado son idénticas y las varianzas kriging serán las mismas multiplicadas por esa constante. 
Podemos pensar en "corregir" las varianzas kriging obtenidas con un modelo de variograma estimado de forma que el DMSE sea igual a 1, multiplicándolas por $\text{DMSE}^2$.

* El error cuadrático medio (*mean squared error*):
$$\text{MSE} =\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \hat{Z}_{-j}(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right)^2$$ debería ser pequeño.
El principal problema de este estadístico es que asigna igual peso a todos los datos y no tiene en cuenta las posiciones espaciales. 
Por lo general los errores son mayores en los puntos más alejados del resto de los datos (observaciones exteriores) y pueden tener un efecto dominante en la media global. 
Se podría pensar en calcular una media ponderada con pesos inversamente proporcionales a la varianza kriging o a alguna medida de la distancia de una posición al resto de los datos.

* Diversos criterios gráficos pueden ser también de interés como herramientas de diagnóstico, como un gráfico de tallo-hojas de los residuos tipificados o gráficos de normalidad.

Después de la validación cruzada del variograma, si esta resultó ser satisfactoria, se puede confiar en que la predicción basada en el modelo ajustado es aproximadamente óptima y que las estimaciones del error en media cuadrática de predicción son bastante buenas (i.e. el modelo ajustado no es muy incorrecto).

Uno de los principales problemas de esta técnica es el elevado coste computacional (Cressie, 1993, p. 104), sin embargo, se han desarrollado métodos(normalmente ignorados) que permiten realizar la validación cruzada de un modelo de variograma de forma rápida y sencilla (ver Fernández-Casal, 2003c, Sección 4.4).
Alternativamente se podría emplear validación cruzada en *k* grupos (*k-fold cross-validation*), considerando típicamente 10 o 5 grupos^[LOOCV sería un caso particular considerando un número de grupos igual al número de observaciones. La partición en k-fold CV se suele realizar al azar. Hay que tener en cuenta la aleatoriedad al emplear k-fold CV, algo que no ocurre con LOOCV.].

La validación cruzada en `gstat` está implementada en la función `krige.cv()`. 
La sintaxis de esta función es casi idéntica a la de la función `krige()` (Sección \@ref(kriging-gstat), salvo que incluye un argumento `nfold` en lugar de `newdata`:

```r
krige.cv(formula, locations, model, nfold = nrow(data), ...)
```
El resultado (un `data.frame` o un objeto del mismo tipo que `locations`), además de las predicciones y varianzas kriging de validación cruzada (en las posiciones de observación), contiene los componentes `observed` (valor observado),  `residual` (residuos),  `zscore` (residuos divididos por el error estándar kriging)  y `fold` (grupo de validación cruzada).

Como ejemplo continuaremos con los datos del acuífero Wolfcamp (en [s100](s100.html) se tiene un ejemplo adicional empleando KO).
Como ya se comentó, la función `krige.cv()` emplea LOOCV por defecto y puede requerir de mucho tiempo de computación (no implementa eficientemente esta técnica):


```r
system.time(cv <- krige.cv(formula = head ~ lon + lat, locations = aquifer_sf,
                           model = fit))
```

```
##    user  system elapsed 
##    0.46    0.00    0.47
```

```r
str(cv)
```

```
## Classes 'sf' and 'data.frame':	85 obs. of  7 variables:
##  $ var1.pred: num  15 23.5 22.9 24.6 17 ...
##  $ var1.var : num  3.08 2.85 2.32 2.81 2.05 ...
##  $ observed : num  14.6 25.5 21.6 24.6 17.6 ...
##  $ residual : num  -0.3357 1.9962 -1.3101 -0.0792 0.5478 ...
##  $ zscore   : num  -0.1914 1.1821 -0.8608 -0.0472 0.3829 ...
##  $ fold     : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ geometry :sfc_POINT of length 85; first list element:  'XY' num  42.8 127.6
##  - attr(*, "sf_column")= chr "geometry"
##  - attr(*, "agr")= Factor w/ 3 levels "constant","aggregate",..: NA NA NA NA NA NA
##   ..- attr(*, "names")= chr [1:6] "var1.pred" "var1.var" "observed" "residual" ...
```

Si el número de observaciones es grande puede ser preferible emplear k-fold CV (y como la partición en grupos es aleatoria se recomendaría fijar previamente la semilla de aleatorización):


```r
set.seed(1)
system.time(cv <- krige.cv(formula = head ~ lon + lat, locations = aquifer_sf,
                           model = fit, nfold = 10))
```

```
##    user  system elapsed 
##    0.06    0.00    0.06
```

Como ya se comentó, podemos considerar distintos estadísticos, por ejemplo los implementados en la siguiente función (los tres últimos tienen en cuenta la estimación de la varianza kriging):


```r
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
```

```
##           me         rmse          mae          mpe         mape    r.squared 
##  0.058039856  1.788446500  1.407874022 -0.615720059  7.852363328  0.913398424 
##          dme         dmse        rwmse 
##  0.001337332  1.118978878  1.665958815
```

Estas medidas podrían emplearse para seleccionar modelos (de tendencia y variograma), y también para ayudar a establecer los parámetros del vecindario para kriging local.

Para detectar datos atípicos, o problemas con el modelo, podemos generar distintos gráficos.
Por ejemplo, gráficos de dispersión de valores observados o residuos estándarizados frente a predicciones:


```r
old_par <- par(mfrow = c(1, 2))
plot(observed ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Observado")
abline(a = 0, b = 1, col = "blue")

plot(zscore ~ var1.pred, data = cv, xlab = "Predicción", ylab = "Residuo estandarizado")
abline(h = c(-3, -2, 0, 2, 3), lty = 3)
```



\begin{center}\includegraphics[width=1\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-16-1} \end{center}

```r
par(old_par)
```

Gráficos con la distribución espacial de los residuos:


```r
plot(cv["residual"], pch = 20, cex = 2, breaks = "quantile", nbreaks = 4)
```



\begin{center}\includegraphics[width=0.7\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-17-1} \end{center}

```r
plot(cv["zscore"], pch = 20, cex = 2)
```



\begin{center}\includegraphics[width=0.7\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-17-2} \end{center}

Además de los gráficos estándar para analizar la distribución de los residuos estándarizados o detectar atípicos:


```r
# Histograma
old_par <- par(mfrow = c(1, 3))
hist(cv$zscore, freq = FALSE)
lines(density(cv$zscore), col = "blue")
# Gráfico de normalidad
qqnorm(cv$zscore)
qqline(cv$zscore, col = "blue")
# Boxplot
car::Boxplot(cv$zscore, ylab = "Residuos estandarizados")
```



\begin{center}\includegraphics[width=1\linewidth]{04-kriging_files/figure-latex/unnamed-chunk-18-1} \end{center}

```
## [1] 78
```

```r
par(old_par)
```

<!-- 
--- 

*** AQUÍ TERMINA LA MATERIA EVALUABLE EN EL CURSO 21/22 DE AEDD ***

---
-->

## Otros métodos kriging

### Block kriging {#block-kriging}

Aunque en los métodos kriging descritos anteriormente se asumía que el soporte era puntual, serían igualmente válidos para el caso de distintos soportes. 
Simplemente habría que sustituir las semivarianzas (o covarianzas) puntuales por las del proceso agregado $Var\left( Z(B_1)-Z(B_2)\right)$ (ver Sección \@ref(procesos-agregados)).

La función `krige()` del paquete `gtsat` empleará este método de forma automática cuando la geometría del argumento `newdata` sean polígonos (incluyendo datos raster).


### Kriging trans-normal {#kriging-trans-normal}

Como se comentó en la Sección \@ref(consideraciones-kriging), en el caso de normalidad el predictor óptimo $E\left( \left. Z(\mathbf{s}_{0})\right| \mathbf{Z}\right)$ de $Z(\mathbf{s}_{0})$ es lineal y coincide con los predictores kriging.
Pero si el proceso no es normal este predictor puede ser altamente no lineal, en esos casos la transformación del proceso $Z(\cdot)$ a otra escala puede producir que se aproxime a la normalidad.
De esta forma se puede pensar en realizar la predicción lineal en la escala transformada (donde también puede ser más eficiente realizar el modelado) y posteriormente hacer la transformación inversa (pero asegurándose de que el resultado tenga las propiedades de optimalidad deseadas). 
En esta Sección simplemente se muestran algunos resultados sobre este método, para un tratamiento más detallado ver por ejemplo Cressie (1993, Sección 3.2.2) o Chilès y Delfiner (2012, Sección 3.4.10).

Una de las transformaciones más utilizadas en geoestadística es la transformación logarítmica, asumiendo que el proceso $Z(\cdot)$ sigue una distribución lognormal. 
Un proceso aleatorio lognormal es un proceso $\left\{ Z(\mathbf{s}):\mathbf{s}\in D\right\}$ (que toma valores positivos) tal que:
$$Y(\mathbf{s})=\log \left( Z(\mathbf{s})\right) ;\ \ \mathbf{s}\in D,$$
es un proceso normal.

El *kriging simple lognormal* (KSL) se basa en la suposición adicional de que el proceso $Y(\cdot)$ verifica las hipótesis del kriging simple (media y covariograma conocidos). 
En ese caso, utilizando el método del KS, a partir de $\mathbf{Y}=(Y(\mathbf{s}_{1}), \ldots,Y(\mathbf{s}_{n} ))^\top$ podemos obtener el predictor $p_{KS} (\mathbf{Y},\mathbf{s}_{0})$ de $Y(\mathbf{s}_{0})$ y la correspondiente varianza kriging $\sigma_{KS}^{2} (\mathbf{s}_{0})$. 
Si transformamos de nuevo este valor a la escala de $Z(\cdot)$, obtenemos $\exp (p_{KS} (\mathbf{Y},\mathbf{s}_{0}))$ que no es un predictor insesgado de $Z(\mathbf{s}_{0})$ (es un predictor insesgado en mediana). 
El predictor óptimo de $Z(\mathbf{s}_{0})$ resulta ser:
$$p_{KSL} (\mathbf{Z},\mathbf{s}_{0}) = \exp \left( p_{KS}(\mathbf{Y},\mathbf{s}_{0}) + \frac{1}{2} \sigma_{KS}^{2}(\mathbf{s}_{0}) \right),$$
y la correspondiente varianza kriging:
$$\sigma_{KSL}^{2} (\mathbf{s}_{0})=p_{KS} (\mathbf{Y},\mathbf{s}_{0}
)^{2} \left( \exp (\sigma_{KS}^{2} (\mathbf{s}_{0}))-1\right).$$

En el caso de media no conocida, i.e. suponiendo que el proceso $Y(\cdot)$ verifica las hipótesis del KU (kriging universal lognormal, KUL), se complica aún más el problema. 
No basta con sustituir la media teórica en por su predictor óptimo ya que se obtendría un predictor sesgado. 
Si se hace una corrección para obtener un predictor insesgado de $Z(\mathbf{s}_{0})$, el resultado sería:
$$p_{KUL} (\mathbf{Z},\mathbf{s}_{0}) = \exp \left( p_{KU}(\mathbf{Y},\mathbf{s}_{0}) + \frac{1}{2} \sigma_{KU}^{2}(\mathbf{s}_{0}) - \mathbf{m^\top }\mathbf{x}_0\right),$$
utilizando la notación de la Sección \@ref(kuniversal) (y suponiendo también que una de las funciones explicativas es idénticamente 1). 
Hay que destacar que el predictor no es un predictor óptimo en el sentido de que minimice el MSPE (este predictor minimiza $E\left( \log p(\mathbf{Z},\mathbf{s}_{0})-Y(\mathbf{s}_{0})\right)^2$, sujeto a las correspondientes restricciones de insesgadez y forma del predictor). 

La varianza kriging tiene una expresión considerablemente más complicada que en el caso de media conocida (ver Cressie, 1993, p. 136; para el caso de media constante).
Sin embargo, si el objetivo es la construcción de intervalos de confianza, se pueden transformar directamente de la escala $Y(\cdot)$.
Por ejemplo:
$$\left( \exp \left( p_{K} (\mathbf{Y},\mathbf{s}_{0}) - 1.96\sigma_{K}^{2}(\mathbf{s}_{0}) \right), \exp \left( p_{K} (\mathbf{Y},\mathbf{s}_{0}) + 1.96\sigma_{K}^{2} (\mathbf{s}_{0})\right) \right),$$
es un intervalo de confianza al 95% para $Z(\mathbf{s}_{0})$.

La aproximación anterior puede generalizarse para una transformación
cualquiera:
$$Z(\mathbf{s})=\phi \left( Y(\mathbf{s})\right) ;\;\;\mathbf{s}\in D,$$
siendo $Y(\cdot)$ un proceso normal y $\phi (\cdot)$ una función medible dos veces diferenciable. 
En general no se dispone de expresiones exactas como en el caso del kriging lognormal, aunque a partir de un predictor kriging $p_{K} (\mathbf{Y},\mathbf{s}_{0})$ de $Y(\mathbf{s}_{0})$ se pueden obtener un predictor aproximadamente insesgado de $Z(\mathbf{s}_{0})$ teniendo en cuenta que:
$$\begin{aligned}
\phi (Y(\mathbf{s}_{0})) & \simeq \phi (p_{K}(\mathbf{Y},\mathbf{s}_{0}))+(Y(\mathbf{s}_{0})-p_{K}(\mathbf{Y},\mathbf{s}_{0}))\phi^\prime (p_{K}(\mathbf{Y},\mathbf{s}_{0})) \\
 & +\frac{1}{2} (Y(\mathbf{s}_{0})-p_{K}(\mathbf{Y},\mathbf{s}_{0}))^{2} \phi^{\prime\prime} (p_{K}(\mathbf{Y},\mathbf{s}_{0})),
\end{aligned}$$
si el error kriging $p_{K} (\mathbf{Y},\mathbf{s}_{0})-Y(\mathbf{s}_{0})$ es pequeño. 
A partir de esto, si $\sigma_{K}^{2} (\mathbf{s}_{0})$ es la correspondiente varianza kriging, se obtiene el predictor (aproximadamente insesgado) del *kriging trans-normal* (KT):
$$p_{KT} (\mathbf{Z},\mathbf{s}_{0}) = \phi \left( p_{K}(\mathbf{Y},\mathbf{s}_{0})\right) + \frac{1}{2} \sigma_{K}^{2}(\mathbf{s}_{0}) \phi^{\prime\prime} \left( p_{K}(\mathbf{Y},\mathbf{s}_{0}) \right),$$
que en el caso del KS se aproxima al predictor óptimo $E\left( \left. Z(\mathbf{s}_{0})\right| \mathbf{Z}\right)$ de $Z(\mathbf{s}_{0})$. 
Como aproximación de la varianza kriging de este predictor se puede utilizar:
$$\sigma_{KT}^{2}(\mathbf{s}_{0}) = \sigma_{K}^{2}(\mathbf{s}_{0}) \phi^{\prime} (p_{K}(\mathbf{Y},\mathbf{s}_{0})).$$

<!-- 

### Kriging indicador

## Referencias 
-->

