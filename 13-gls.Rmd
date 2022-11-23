# Mínimos cuadrados generalizados en R {#gls}


<!-- 
---
title: "Mínimos cuadrados generalizados en R"
author: "Estadística Espacial"
date: "Análisis estadístico de datos con dependencia (GCED)"
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

Apéndice \@ref(gls)
bookdown::preview_chapter("13-gls.Rmd")
knitr::purl("13-gls.Rmd", documentation = 2)
knitr::spin("13-gls.R",knit = FALSE)
-->


## Motivación


Uno de los modelos más utilizados en estadística para el caso de datos no homogéneos es el conocido modelo clásico de regresión lineal: 
$$Y =\sum\limits_{j=0}^{p}X_{j}\beta_{j} +\varepsilon,$$
donde $\boldsymbol{\beta }=(\beta_{0}, \ldots,\beta_{p})^{\top}\in \mathbb{R}^{p+1}$ es un vector desconocido, $\left\{ X_{j}:j=0, \ldots,p\right\}$ un conjunto de variables explicativas (por comodidad asumiremos que $X_0=1$) y $\varepsilon$ un error aleatorio (independiente) de media cero con $Var(\varepsilon)=\sigma^{2}$.

Supongamos que el objetivo es la estimación eficiente de los parámetros de $\boldsymbol{\beta}$ (*variación de gran escala*), a partir de una muestra aleatoria simple (los datos observados) 
$$\left\{ \left( X_{1_i}, \ldots, X_{p_i}, Y_{i} \right)  : i = 1, \ldots, n \right\}.$$
Bajo las hipótesis anteriores:
$$\mathbf{Y} = \mathbf{X}\boldsymbol{\beta} + \boldsymbol{\varepsilon},$$ 
siendo $\mathbf{Y}=\left( Y_1, \ldots, Y_n \right)^{\top}$, $\mathbf{X}$ una matriz $n\times (p+1)$ con $\mathbf{X}_{ij} = X_{{j-1}_i}$ y $\boldsymbol{\varepsilon} = \left( \varepsilon_1, \ldots,\varepsilon_n \right)^{\top}$, con
$$Var\left( \mathbf{Y} \right) =Var\left( \boldsymbol{\varepsilon} \right) = \sigma^{2} \mathbf{I}_{n},$$
siendo $\mathbf{I}_{n}$ la matriz identidad $n\times n$.
En estas condiciones el estimador lineal insesgado de $\boldsymbol{\beta}$ más eficiente (el óptimo bajo normalidad) resulta ser el estimador de mínimos cuadrados ordinarios (OLS, *ordinary least squares*):
\begin{equation} 
  \hat{\boldsymbol{\beta}}_{ols}=(\mathbf{X}^{\top}\mathbf{X})^{-1}\mathbf{X}^{\top}\mathbf{Y},
  (\#eq:beta-ols-rlm)
\end{equation}
<!-- \@ref(eq:beta-ols-rlm) -->
que se obtiene al minimizar la correspondiente suma de cuadrados
$$\hat{\boldsymbol{\beta}}_{ols} = \arg \min_{\mathbf{\beta }}\left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right)^{\top }\left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right)$$
o al maximizar la verosimilitud asumiendo normalidad.
Además, puede verse fácilmente que 
$$Var(\hat{\boldsymbol{\beta}}_{ols})=\sigma^{2}(\mathbf{X}^{\top}\mathbf{X})^{-1}.$$

Sin embargo la suposición de que los errores son independientes e idénticamente distribuidos influye crucialmente en la inferencia. 
En el modelo anterior, en lugar de errores incorrelados, si suponemos que:
$$Var\left( \boldsymbol{\varepsilon} \right) =\boldsymbol{\Sigma},$$
obtenemos el modelo lineal de regresión generalizado y en este caso el estimador lineal óptimo de $\boldsymbol{\beta}$ es el estimador de mínimos cuadrados generalizados (GLS, *generalized least squares*; WLS, *weighted least squares*, como caso particular si es diagonal):
\begin{equation} 
  \hat{\boldsymbol{\beta}}_{gls} =(\mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1} \mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{Y}.
  (\#eq:beta-gls-rlm)
\end{equation}
<!-- \@ref(eq:beta-gls-rlm) -->

Podemos ver cómo se obtiene este estimador desde varios puntos de vista.
Uno de ellos es aplicar una transformación lineal a los datos de forma que sean incorrelados y tenga sentido aplicar el estimador OLS.
Para ello se emplea una factorización de la matriz de covarianzas (ver p.e. la [Sección 7.3](https://rubenfcasal.github.io/simbook/fact-cov.html) de Fernández-Casal y Cao, 2021), por ejemplo la factorización de Cholesky:
$$\Sigma=LL^\top,$$
donde $L$ es una matriz triangular inferior (fácilmente invertible), por lo que: 
$$Var\left( L^{-1}\mathbf{Y} \right) =Var\left( L^{-1}\boldsymbol{\varepsilon} \right) = L^{-1} \boldsymbol{\Sigma} L^{{-1}^\top} \\
= L^{-1} LL^\top L^{\top^{-1}} = \mathbf{I}_{n}.$$
Aplicando esta transformación al modelo anterior:
$$L^{-1}\mathbf{Y} = L^{-1}\mathbf{X}\boldsymbol{\beta} + L^{-1}\boldsymbol{\varepsilon}\\
\tilde{\mathbf{Y}} = \tilde{\mathbf{X}}\boldsymbol{\beta} + \tilde{\boldsymbol{\varepsilon}},$$
al minimizar la suma de cuadrados
$$\left( \tilde{\mathbf{Y}}-\tilde{\mathbf{X}}\mathbf{\beta }\right)^{\top }\left( \tilde{\mathbf{Y}}-\tilde{\mathbf{X}}\mathbf{\beta }\right) \\ 
= \left( L^{-1}\mathbf{Y}-L^{-1}\mathbf{X}\mathbf{\beta }\right)^{\top }\left( L^{-1}\mathbf{Y}-L^{-1}\mathbf{X}\mathbf{\beta }\right) \\
= \left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right)^{\top } L^{{-1}^\top}L^{-1}  \left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right) \\
= \left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right)^{\top } \boldsymbol{\Sigma}^{-1}\left( \mathbf{Y}-\mathbf{X}\mathbf{\beta }\right)$$
obtenemos el estimador lineal óptimo:
$$\hat{\boldsymbol{\beta}}_{gls}=(\tilde{\mathbf{X}}^{\top}\tilde{\mathbf{X}})^{-1}\tilde{\mathbf{X}}^{\top}\tilde{\mathbf{Y}} 
= (\mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1} \mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{Y}.$$

Si $\boldsymbol{\Sigma}=\sigma^{2} \mathbf{I}_{n}$, los estimadores \@ref(eq:beta-ols-rlm) y \@ref(eq:beta-gls-rlm) coinciden; pero en caso contrario las estimaciones basadas en el modelo anterior pueden llegar a ser altamente ineficientes. 
Puede verse fácilmente que en el caso general:
$$Var\left( \hat{\boldsymbol{\beta}}_{gls} \right)=(\mathbf{X}^{\top}\boldsymbol{\Sigma}^{-1} \mathbf{X})^{-1}, \\
Var\left( \hat{\boldsymbol{\beta}}_{ols} \right) =(\mathbf{X}^{\top}\mathbf{X})^{-1} (\mathbf{X}^{\top}\boldsymbol{\Sigma}\mathbf{X})(\mathbf{X}^{\top}\mathbf{X})^{-1},$$
resultando además que $Var( \hat{\boldsymbol{\beta}}_{ols}) - Var( \hat{\boldsymbol{\beta}}_{gls} )$ es una matriz semidefinida positiva (e.g. Searle, 1971, Sección 3.3). 

En la práctica la matriz de covarianzas suele ser desconocida y habría que estimarla.
Para más detalles, incluyendo el enfoque de máxima verosimilitud y su aplicación en la práctica para la regresión con series de tiempo, ver por ejemplo el apéndice [Time-Series Regression and Generalized Least Squares in R](https://socialsciences.mcmaster.ca/jfox/Books/Companion/appendices/Appendix-Timeseries-Regression.pdf) de [Fox (2019)](https://socialsciences.mcmaster.ca/jfox/Books/Companion/).


