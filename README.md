# Estadística Espacial con R

## R. Fernández-Casal (ruben.fcasal@udc.es), T.R. Cotos Yáñez (cotos@uvigo.es)

La versión actual del libro ***se está desarrollando*** principalmente como apoyo la docencia de la última parte de la asignatura de [Análisis estadístico de datos con dependencia](https://guiadocente.udc.es/guia_docent/index.php?centre=614&ensenyament=614G02&assignatura=614G02022&idioma=cast) del [Grado en Ciencia e Ingeniería de Datos](https://estudos.udc.es/es/study/start/614G02V01) de la [UDC](https://www.udc.es). 
El objetivo es que (futuras versiones del libro con contenidos adicionales) también resulte de utilidad para la docencia de la asignatura de [Estadística Espacial](http://eamo.usc.es/pub/mte/index.php?option=com_content&view=article&id=2202&idm=15&a%C3%B1o=2021) del [Máster interuniversitario en Técnicas Estadísticas](http://eio.usc.es/pub/mte)).  

El libro ha sido escrito en [R-Markdown](http://rmarkdown.rstudio.com) empleando el paquete [`bookdown`](https://bookdown.org/yihui/bookdown/) y está disponible en el repositorio Github: [rubenfcasal/simbook](https://github.com/rubenfcasal/estadistica_espacial). 
Se puede acceder a la versión en línea a través del siguiente enlace:

<https://rubenfcasal.github.io/estadistica_espacial/index.html>.

donde puede descargarse en formato [pdf](https://rubenfcasal.github.io/estadistica_espacial/estadistica_espacial.pdf).

Para instalar los paquetes necesarios para poder ejecutar los ejemplos mostrados en el libro se puede emplear el siguiente comando:
```{r eval=FALSE}
pkgs <- c("caret", "rattle", "gbm", "car", "leaps", "MASS", "RcmdrMisc", 
          "lmtest", "glmnet", "mgcv", "np", "NeuralNetTools", "pdp", "vivid",
          "plot3D", "AppliedPredictiveModeling", "ISLR")
# install.packages(pkgs, dependencies=TRUE)
install.packages(setdiff(pkgs, installed.packages()[,"Package"]), 
                 dependencies = TRUE)

# Si aparecen errores, debidos a incompatibilidades entre las versiones de los paquetes, 
# probar a ejecutar en lugar de lo anterior:
# install.packages(pkgs, dependencies = TRUE) # Instala todos...
```

Para generar el libro (compilar) serán necesarios paquetes adicionales, 
para lo que se recomendaría consultar el libro de ["Escritura de libros con bookdown" ](https://rubenfcasal.github.io/bookdown_intro) en castellano.


Este obra está bajo una licencia de [Creative Commons Reconocimiento-NoComercial-SinObraDerivada 4.0 Internacional ](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.es_ES) 
(esperamos poder liberarlo bajo una licencia menos restrictiva más adelante...).

![](https://licensebuttons.net/l/by-nc-nd/4.0/88x31.png)
