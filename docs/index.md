--- 
title: "Estadística Espacial con R"
author: 
  - "Rubén Fernández Casal (MODES, CITIC, UDC; ruben.fcasal@udc.es)"
  - "Tomás Cotos Yáñez (SIDOR, UVIGO; cotos@uvigo.es)"
date: "2021-12-21"
site: bookdown::bookdown_site
output: bookdown::gitbook
documentclass: book
lang: es
bibliography: ["packages.bib", "estadistica_espacial.bib"]
# biblio-style: "apalike"
link-citations: yes
github-repo: rubenfcasal/estadistica_espacial
description: "Apuntes de Estadística Espacial (para las asignaturas: 'Análisis estadístico de datos con dependencia' del Grado en Ciencia e Ingeniería de Datos y 'Aprendizaje estadístico' del Máster InterUniversitario en Técnicas Estadísticas)."
---



# Prólogo {-}

La versión actual del libro ***se está desarrollando*** principalmente como apoyo a la docencia de la última parte de la asignatura de [Análisis estadístico de datos con dependencia](https://guiadocente.udc.es/guia_docent/index.php?centre=614&ensenyament=614G02&assignatura=614G02022&idioma=cast) del [Grado en Ciencia e Ingeniería de Datos](https://estudos.udc.es/es/study/start/614G02V01) de la [UDC](https://www.udc.es). 
El objetivo es que (futuras versiones del libro con contenidos adicionales) también resulte de utilidad para la docencia de la asignatura de [Estadística Espacial](http://eamo.usc.es/pub/mte/index.php?option=com_content&view=article&id=2202&idm=15&a%C3%B1o=2021) del [Máster interuniversitario en Técnicas Estadísticas](http://eio.usc.es/pub/mte)). 

La teoría en este libro está basada en gran parte en la tesis doctoral:

Fernández Casal, R. (2003). [*Geoestadística espacio-temporal: modelos flexibles de variogramas anisotrópicos no separables*](https://rubenfcasal.github.io/files/Geoestadistica_espacio-temporal.pdf). Tesis doctoral, Universidad de Santiago de Compostela. 

donde se puede encontrar información adicional.

Este libro ha sido escrito en [R-Markdown](http://rmarkdown.rstudio.com) empleando el paquete [`bookdown`](https://bookdown.org/yihui/bookdown/)  y está disponible en el repositorio Github: [rubenfcasal/estadistica_espacial](https://github.com/rubenfcasal/estadistica_espacial). 
Se puede acceder a la versión en línea a través del siguiente enlace:

<https://rubenfcasal.github.io/estadistica_espacial> (también <https://bit.ly/estadistica_espacial>).

donde puede descargarse en formato [pdf](https://rubenfcasal.github.io/estadistica_espacial/estadistica_espacial.pdf).

Para ejecutar los ejemplos mostrados en el libro sería necesario tener instalados los siguientes paquetes:
[`sf`](https://CRAN.R-project.org/package=sf), [`sp`](https://CRAN.R-project.org/package=sp), [`starts`](https://CRAN.R-project.org/package=starts), [`gstat`](https://CRAN.R-project.org/package=gstat), [`geoR`](https://CRAN.R-project.org/package=geoR), [`spacetime`](https://CRAN.R-project.org/package=spacetime), [`sm`](https://CRAN.R-project.org/package=sm), [`fields`](https://CRAN.R-project.org/package=fields), [`rgdal`](https://CRAN.R-project.org/package=rgdal), [`rgeos`](https://CRAN.R-project.org/package=rgeos), [`maps`](https://CRAN.R-project.org/package=maps), [`maptools`](https://CRAN.R-project.org/package=maptools), [`ggplot2`](https://CRAN.R-project.org/package=ggplot2), [`plot3D`](https://CRAN.R-project.org/package=plot3D), [`lattice`](https://CRAN.R-project.org/package=lattice), [`classInt`](https://CRAN.R-project.org/package=classInt), [`viridis`](https://CRAN.R-project.org/package=viridis), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`mapSpain`](https://CRAN.R-project.org/package=mapSpain), [`tmap`](https://CRAN.R-project.org/package=tmap), [`mapview`](https://CRAN.R-project.org/package=mapview), [`osmdata`](https://CRAN.R-project.org/package=osmdata), [`rnaturalearth`](https://CRAN.R-project.org/package=rnaturalearth), [`ncdf`](https://CRAN.R-project.org/package=ncdf), [`quadprog`](https://CRAN.R-project.org/package=quadprog), [`spam`](https://CRAN.R-project.org/package=spam), [`DEoptim`](https://CRAN.R-project.org/package=DEoptim).
<!-- 
raster, terra
"quadprog", "spam", "DEoptim"
Comprobar si es necesario añadir: 
remotes::install_github("r-spatial/mapview")
-->
Por ejemplo mediante los siguientes comandos:

```r
pkgs <- c("sf", "sp", "starts", "gstat", "geoR", "spacetime", "sm", "fields", 
          "rgdal", "rgeos", "maps", "maptools", "ggplot2", "plot3D", "lattice", 
          "classInt", "viridis", "dplyr", "mapSpain", "tmap", "mapview", 
          "osmdata", "rnaturalearth", "ncdf", "quadprog", "spam", "DEoptim" )

install.packages(setdiff(pkgs, installed.packages()[,"Package"]), dependencies = TRUE)
```

Si aparecen errores (normalmente debidos a incompatibilidades con versiones ya instaladas), probar a ejecutar en lugar de lo anterior:

```r
install.packages(pkgs, dependencies=TRUE) # Instala todos...
```

Además, para geoestadística no paramétrica se empleará el paquete [`npsp`](https://rubenfcasal.github.io/npsp) ***no disponible actualmente en CRAN*** (aunque esperamos que vuelva a estarlo pronto... incluyendo soporte para el paquete `sf`).
Se puede instalar la versión de desarrollo en GitHub, siguiendo las instrucciones de la [web](https://rubenfcasal.github.io/npsp/#installation):
``` r
# install.packages("devtools")
devtools::install_github("rubenfcasal/npsp")
```
Aunque al necesitar compilación los usuarios de Windows deben tener instalado previamente la versión adecuada de [Rtools](https://cran.r-project.org/bin/windows/Rtools/), y [Xcode](https://apps.apple.com/us/app/xcode/id497799835) los usuarios de OS X 
(para lo que se pueden seguir los pasos descritos [aquí](https://rubenfcasal.github.io/post/instalacion-de-r)).
Alternativamente, los usuarios de Windows (con una versión 4.X.X de R) pueden instalar este paquete ya compilado con el siguiente código:

```r
install.packages('https://github.com/rubenfcasal/npsp/releases/download/v0.7-8/npsp_0.7-8.zip', 
                 repos = NULL)
```


Para generar el libro (compilar) serán necesarios paquetes adicionales, 
para lo que se recomendaría consultar el libro de ["Escritura de libros con bookdown" ](https://rubenfcasal.github.io/bookdown_intro) en castellano.


\includegraphics[width=1.22in]{images/by-nc-nd-88x31} 

Este obra está bajo una licencia de [Creative Commons Reconocimiento-NoComercial-SinObraDerivada 4.0 Internacional](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.es_ES) 
(esperamos poder liberarlo bajo una licencia menos restrictiva más adelante...).


