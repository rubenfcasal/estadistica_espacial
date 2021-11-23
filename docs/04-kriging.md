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
    pandoc_args: ["--number-offset", "0,0"]
    toc: yes 
    # mathjax: local            # copia local de MathJax, hay que establecer:
    # self_contained: false     # las dependencias se guardan en ficheros externos 
  bookdown::pdf_document2:
    keep_tex: yes
    toc: yes 
---

bookdown::preview_chapter("04-kriging.Rmd")
knitr::purl("04-kriging.Rmd", documentation = 2)
knitr::spin("04-kriging.R",knit = FALSE)
-->




***En preparación...***

En este capítulo se comentan brevemente los métodos más conocidos de predicción espacial denominados métodos kriging^[Podríamos definir los métodos kriging como algoritmos de predicción de mínimo error en media cuadrática que tienen en cuenta la estructura de segundo orden del proceso.] (ver Sección 1.2.1 para un resumen del origen de esta terminología), centrándonos únicamente en el caso de predicción lineal puntual univariante (el caso multivariante se trata en el Capítulo 5). 
Una revisión más completa de estos métodos se tiene por ejemplo en Cressie (1993, Capítulo 3 y secciones 5.1, 5.4 y 5.9.1) o Chilès y Delfiner (1999, capítulos 3, 4 y 6).

## Introducción {#introducción}

Si denotamos por $\mathbf{Z}=\left( Z(\mathbf{s}_{1} ), \ldots, z(\mathbf{s}_{n} )\right)^\top$ valores observados del proceso, los distintos métodos kriging proporcionan un predictor $p(\mathbf{Z},\mathbf{s}_{0} )$ de $Z(\mathbf{s}_{0} )$ verificando que:

* es lineal:
  $$p(\mathbf{Z},\mathbf{s}_{0} )=\sum\limits_{i=1}^{n}\lambda_{i} Z(\mathbf{s}_{i} ) +\lambda_{0},$$
  
* es uniformemente insesgado, para cualquier $\mu(\cdot)$:
  $$E(p(\mathbf{Z},\mathbf{s}_{0} ))=\mu(\mathbf{s}_{0} ),$$
  
* y minimiza el error en media cuadrática (e.m.c.) de predicción^[Como es bien sabido, en el caso de normalidad el predictor óptimo (tomando como función de pérdidas el error cuadrático) es lineal y va a coincidir con los predictores kriging. Pero si el proceso no es normal no tiene porque serlo, lo que ha motivado el desarrollo de métodos kriging no lineales (ver p.e. Rivoirard, 1994) y del kriging trans-normal (ver sección 4.X).]:
  $$E\left( \left( p(\mathbf{Z},\mathbf{s}_{0} )-Z(\mathbf{s}_{0} )\right)^{\text{2} } \right),$$

(al hablar de predicción óptima nos referiremos a que se verifican estas dos últimas condiciones).

Dependiendo de las suposiciones acerca de la función de tendencia $\mu(\cdot)$, se distingue principalmente entre tres métodos kriging:

1. *Kriging simple* (KS): se supone que la media es conocida (algunos autores suponen también que es constante o incluso cero). 
  Además se asume que el covariograma existe y es conocido.
  
2. *Kriging ordinario* (KO): se supone que la media es constante (i.e. $E(Z(\mathbf{s}))=\mu ,\forall \mathbf{s}\in D$) y desconocida. 
  Además se asume que por lo menos existe el variograma y es conocido.
  
3. *Kriging universal* (KU; también denominado kriging con modelo de tendencia): se supone que la media es desconocida y no constante, pero
que es una combinación lineal (desconocida) de $p+1$ funciones (o variables explicativas) conocidas $\left\{ x_{j} (\cdot):j=0, \ldots,p\right\}$:
  $$\mu(\mathbf{s})=\sum\limits_{j=0}^{p}x_{j} (\mathbf{s})\beta_{j}$$
  donde $?=(\beta_{0} , \ldots,\beta_{p} )^\top \in \mathbb{R}^{p+1}$ es un vector desconocido. 
  Se asume también que por lo menos existe el variograma y es conocido^[Siempre que una de las funciones explicativas sea idénticamente 1, p.e. $x_{0} (\cdot)\equiv 1$, en caso contrario las ecuaciones kriging sólo pueden expresarse en función del covariograma.].

Por simplicidad el kriging ordinario se tratará en este capítulo como un caso particular del kriging universal (aunque en la práctica se suele
pensar en el KO como un método distinto al KU, principalmente por ciertos inconvenientes que presenta este último; ver Sección 4.X.X).

## Kriging con media conocida: kriging simple {#ksimple}

## Kriging con media desconocida: kriging universal {#kuniversal}

## Consideraciones acerca de los métodos kriging {#consideraciones-kriging}

<!-- 
## Referencias 
-->
