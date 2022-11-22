# INEbase > Fenómenos demográficos > Movimiento Natural de la Población
# Defunciones (Cifras anuales) > Por lugar de residencia y sexo.
# Total nacional y comunidades autónomas
# https://www.ine.es/jaxiT3/Tabla.htm?t=6546&L=0
# Descargar > Pc-Axis
# https://www.ine.es/jaxiT3/files/t/es/px/6546.px?nocab=1
# Con grupo de edad: https://www.ine.es/jaxiT3/files/t/es/px/6550.px?nocab=1

library("pxR") # install.packages("pxR")
px.file <- read.px("https://www.ine.es/jaxiT3/files/t/es/px/6546.px?nocab=1")
mortalidad <- as.data.frame(px.file)
names(mortalidad) <- tolower(names(mortalidad))
names(mortalidad)[3] <- "ccaa"
# library(stringr)
# txt <- levels(mortalidad$ccaa)
# dput(txt)
# stringr::str_extract(txt, "^[0-9]+") # ccaa.code
# stringr::str_split(txt, "(?<=^[0-9]{2}) ", simplify = TRUE) # ccaa.code ccaa.name

library(dplyr)
library(tidyr)
library(forcats)
mortalidad <- mortalidad %>%
  mutate(ccaa = fct_recode(ccaa,
                        "00 España" = "Total", "99 Extranjero" = "No residente")) %>%
  separate(ccaa, c("ccaa.code", "ccaa.name"), "(?<=^[0-9]{2}) ")
# str(mortalidad)
# Pendiente: convertir a factores/operar con niveles
save(mortalidad, file = "mortalidad.RData")

# -------------------------------------

library(sf)
library(mapSpain) # install.packages("mapSpain")

mort_sf <- mortalidad %>%
  filter(!ccaa.code %in% c("00", "99"), periodo %in% c("2019", "2020"), sexo == "Total") %>%
  select(-sexo, -ccaa.name) %>%
  pivot_wider(names_from = periodo, values_from = value, names_prefix = "mort.") %>%
  mutate(incremento = 100*(mort.2020 - mort.2019)/mort.2019)

# CUIDADO: el primer elemento de xxx_join debe ser un objeto sf
# para que lo procese el paquete sf

mort_sf <- esp_get_ccaa() %>%
  left_join(mort_sf, by = c("codauto" = "ccaa.code"))

save(mort_sf, file = "mort_sf.RData")

# -------------------------------------

# library(sf)
# library(mapSpain) # install.packages("mapSpain")
# load("mort_sf.RData")
# plot(mort_sf["incremento"])

library(ggplot2)
ggplot(mort_sf) +
  geom_sf(aes(fill = incremento),
    color = "grey70",
    lwd = .3
  ) +
  geom_sf(data = esp_get_can_box(), color = "grey70") +
  geom_sf_label(aes(label = paste0(round(incremento, 1), "%")),
    fill = "white", alpha = 0.5,
    size = 3,
    label.size = 0
  ) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10,
    labels = function(x) {
      sprintf("%1.1f%%", x)
    },
    guide = guide_legend(title = "Incremento")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))

