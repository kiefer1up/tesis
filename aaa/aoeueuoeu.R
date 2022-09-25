library(readxl)
library(SixSigma)
library(dplyr)
library(ggplot2)

?rmarkdown::odt_document
?rmarkdown
?knit
?knitr::opts_chunk 

source('~/R/tesis/bbdd.R')

ggplot(data = fdf,mapping= aes(mnth,sales,group=yr,color=yr))+
  geom_line()+
  geom_point()+
  theme_linedraw()+
  #ggtitle("Ventas mensuales a publico del mercado de livianos y medianos") +
  geom_text(aes(label= sales),vjust = "inward", hjust = "inward",show.legend = FALSE,size = 3)+
  labs(x = "Mes", y = "Numero de ventas",
       title = "Ventas mensuales a publico del mercado de livianos y medianos",
       caption = "ANAC, Mercado Automotor Mayo 2021",colour="Año")+
  theme(text=element_text(size=11,  family="calibri"))
#knitr::include_graphics("/home/kiefer/Rplot01.png")

effect <- "Mayor tiempo despacho"
causes.gr <- c("Material",
               "Mano de Obra",
               "Metodo",
               "Maquina",
               "Medio",
               "Medicion")
causes <- vector(mode = "list", length = length(causes.gr))
causes[1] <- list(c("","Falta de repuesto","","Uso de alternativas"))
causes[2] <- list(c("","","Ausencia","","Incertidumbre stock"))
causes[3] <- list(c("","Deficiente picking*"))
causes[4] <- list(c("","Uso reactivo de vehiculo"))
causes[5] <- list(c("","","Ubicacion errada","","Area sin estandar","","Sobrestock"))
causes[6] <- list(c("","falta de indicadores"))
ss.ceDiag(effect, causes.gr, causes,,)
