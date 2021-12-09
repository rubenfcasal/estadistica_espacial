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
-->




***En preparación...***

En este capítulo se comentan brevemente los métodos más conocidos de predicción espacial denominados métodos kriging^[Podríamos definir los métodos kriging como algoritmos de predicción de mínimo error en media cuadrática que tienen en cuenta la estructura de segundo orden del proceso] (ver Sección \@ref(geoestadistica) para un resumen del origen de esta terminología), centrándonos únicamente en el caso de predicción lineal puntual univariante (el caso multivariante se trata en el Capítulo \@ref(multivar)). 
Una revisión más completa de estos métodos se tiene por ejemplo en Cressie (1993, Capítulo 3 y secciones 5.1, 5.4 y 5.9.1) o Chilès y Delfiner (1999, capítulos 3, 4 y 6).

## Introducción {#introduccion}

Si denotamos por $\mathbf{Z}=\left( Z(\mathbf{s}_{1}), \ldots, z(\mathbf{s}_{n} )\right)^\top$ valores observados del proceso, los distintos métodos kriging proporcionan un predictor $p(\mathbf{Z},\mathbf{s}_{0})$ de $Z(\mathbf{s}_{0})$ verificando que:

* es lineal:
  $$p(\mathbf{Z},\mathbf{s}_{0})=\sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i}) +\lambda_{0},$$
  
* es uniformemente insesgado, para cualquier $\mu(\cdot)$:
  $$E(p(\mathbf{Z},\mathbf{s}_{0}))=\mu(\mathbf{s}_{0}),$$
  
* y minimiza el error en media cuadrática de predicción (*mean squared prediction error*, MSPE)^[Como es bien sabido, en el caso de normalidad el predictor óptimo (tomando como función de pérdidas el error cuadrático) es lineal y va a coincidir con los predictores kriging. Pero si el proceso no es normal no tiene porque serlo, lo que ha motivado el desarrollo de métodos kriging no lineales (ver p.e. Rivoirard, 1994) y del kriging trans-normal (ver Sección 4.X).]:
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
  Se asume también que por lo menos existe el variograma y es conocido^[Siempre que una de las funciones explicativas sea idénticamente 1, p.e. $X_{0} (\cdot)\equiv 1$, en caso contrario las ecuaciones kriging sólo pueden expresarse en función del covariograma (Sección \@ref(ku-covariograma)).].

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
El predictor óptimo será de la forma y tal que minimiza el MSPE , que puede expresarse como:
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
Una condición suficiente para que esto ocurra es que el covariograma $C(\cdot ,\cdot)$ sea una función semidefinida positiva (hay que tener cuidado con la anisotropía zonal, ver Sección \@ref(anisotropia)) y las posiciones de los datos sean distintas.
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

Muchos de los algoritmos utilizados para la solución de los sistema kriging están diseñados y optimizados para covariogramas (e.g. Chilès y Delfiner, 1999, p. 170). 
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
Además, teniendo en cuenta que el error $\left( p_{KS} (\mathbf{Z},\mathbf{s}_{0})-Z(\mathbf{s}_{0})\right)$ tiene covarianza nula con cualquier combinación lineal de $\mathbf{Z}$ (ver p.e. Chilès y Delfiner, 1999, p. 161), esta relación también se extiende a la varianza kriging:
$$\sigma_{KU}^{2} (\mathbf{s}_{0})=\sigma_{KS}^{2} (\mathbf{s}_{0}
)+(\mathbf{x}_0-\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c})^\top \left(
\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{X}\right)^{-1}
(\mathbf{x}_0-\mathbf{X^\top }\boldsymbol{\Sigma}^{-1} \mathbf{c}),$$
donde el segundo termino cuantifica la precisión en la estimación de la media.
Estas expresiones son conocidas como la relación de aditividad entre el KS y el KU.

Los resultados anteriores permiten pensar en la predicción lineal con media desconocida como un proceso de dos etapas: en la primera estimar la media desconocida, y en la segunda realizar la predicción lineal óptima con media supuestamente conocida.
En el caso de una tendencia lineal obtenemos el predictor de KU, mientras que en el caso general se obtiene el denominado predictor del *kriging residual* (o *kriging con tendencia externa*).


## Consideraciones acerca de los métodos kriging {#consideraciones-kriging}

###  Kriging como interpolador {#kriging-interpolador}

### Efecto del variograma (covariograma) en el kriging {#efecto-variog-kriging}

## Validación cruzada del modelo ajustado {#validacion-cruzada}

El método de validación cruzada es la técnica normalmente utilizada en geoestadística para diagnosticar si un modelo (de tendencia y variograma) describe adecuadamente la variabilidad espacial de los datos (ver p.e. Cressie, 1993, Sección 2.6.4).
Si se asume que la tendencia es constante, permitiría verificar si el modelo de variograma describe adecuadamente la dependencia espacial de los datos. 
Aunque también es utilizada para otros fines (ver p.e. Isaaks y Srivastava, 1989, Capítulo 15), entre ellos: comparar distintas hipótesis sobre el modelo geoestadístico (tipo de modelo, vecindarios, etc.), detectar observaciones atípicas o incluso para la estimación de los parámetros del variograma. 
La idea básica es eliminar una parte de los datos y utilizar el resto de los datos para predecir los datos eliminados, entonces el error de predicción puede deducirse del valor que se predice menos el observado; repitiendo esto sobre varios conjuntos de datos se tiene una idea sobre la variabilidad del error de predicción. 
No sólo suele interesar estudiar las predicciones, en general son también de interés las estimaciones del error cuadrático de predicción (varianza  kriging).

Supongamos que $\hat{Z}_{-j}(\mathbf{s}_{j})$ es un predictor de $Z(\mathbf{s}_{j})$ obtenido, utilizando alguno de los métodos de predicción espacial, a partir de $\left\{ Z(\mathbf{s}_{i}):i\neq j\right\}$ y el variograma ajustado $2\gamma(\cdot ,\hat{\boldsymbol{\theta}})$ (calculado utilizando todos los datos), y que $\sigma_{-j}^2 (\mathbf{s}_{j})$ es el correspondiente error en media cuadrática de predicción. 
Hay varias formas de medir la aproximación de las predicciones a los verdaderos valores, por ejemplo:

* La media de los errores tipificados
$$\text{MET} =\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \hat{Z}_{-j}
(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right) /\sigma_{-j}(\mathbf{s}_{j}
)$$ debería ser próxima a cero. Este no es un criterio muy adecuado
(sobre todo en el caso del KO) ya que los predictores kriging son
insesgados independientemente del modelo de variograma utilizado (ver
p.e. Yakowitz y Szidarovski, 1985).

* El error cuadrático medio adimensional:
$$\text{ECMA} =\sqrt{\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \left( \hat{Z}
_{-j}(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right) /\sigma_{-j}
(\mathbf{s}_{j})\right)^2  }$$ debería ser próximo a uno. El valor
de este estadístico puede interpretarse como una medida de la
concordancia entre las varianzas kriging y las varianzas observadas.
Teniendo en cuenta que si reescalamos el variograma multiplicándolo por
una constante, las predicciones con el variograma reescalado son
idénticas y las varianzas kriging serán las mismas multiplicadas por esa
constante. Podemos pensar en "corregir" un modelo de variograma[^12] de
forma que ECMA sea igual a 1, multiplicándolo por $\text{ECMA}^2$.

* El error cuadrático medio:
$$\text{ECM} =\dfrac{1}{n} \sum\limits_{j=1}^{n}\left( \hat{Z}_{-j}
(\mathbf{s}_{j})-Z(\mathbf{s}_{j})\right)^2$$ debería ser pequeño.
El principal problema de este estadístico es que asigna igual peso a
todos los datos y no tiene en cuenta las posiciones espaciales. Por lo
general los errores son mayores en los puntos más alejados del resto de
los datos (observaciones exteriores) y pueden tener un efecto dominante
en la media global. Se podría pensar en calcular una media ponderada con
pesos inversamente proporcionales a la varianza kriging o a alguna
medida de la distancia de una posición al resto de los datos.

* Diversos criterios gráficos pueden ser también de interés como
herramientas de diagnóstico, como p.e. el diagrama tallo-hoja de los
residuos tipificados o gráficos de normalidad.

Después de la validación cruzada del variograma, si esta resultó ser
satisfactoria, se puede confiar en que la predicción basada en el modelo
ajustado $2\gamma(\cdot,\hat{\boldsymbol{\theta}})$ es aproximadamente óptima y que las
estimaciones del error en media cuadrática de predicción son bastante
buenas (i.e. el modelo ajustado no es muy incorrecto).

Uno de los principales problemas de esta técnica es el elevado coste
computacional (Cressie, 1993, p. 104), sin embargo, se han desarrollado métodos 
(normalmente ignorados) que permiten realizar la validación cruzada de un modelo
de variograma de forma rápida y sencilla (ver Fernández-Casal, 2003c, Sección 4.4).

## Otros métodos kriging

### Block kriging

### Kriging trans-normal

### Kriging indicador

<!-- 
## Referencias 
-->

