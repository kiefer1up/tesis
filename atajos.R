#bibliography: biblio.bib
#toc: true
#fontsize: 11pt
#geometry: "left=4cm,right=2cm,top=2cm,bottom=2.5cm"
#metadata:
#  bibliography: biblio.bib

# ANAC
  anac.vnt= 7.199

# lay out
  area.nuevo=27*9
  area.viejo=19*22
  area.total.almacen=area.nuevo+area.viejo

# medida taller
  lado= 11+8+27
  base= 44
  yapa= (65-lado)*base/2
  area= lado*base+yapa

# medida taller viejo
  area.wh.old <- 1000
  area.medida<-c(area.viejo,area.nuevo,area.total.almacen)

# nombres
  area.nam <- c("Almacen A","Almacen B","Duarcon")
  julio <- "10 julio REVISAR"


df.area<- data.frame(area.nam,area.medida)
colnames(df.area)<- c('Sector','Area feet^2')

#area.tbl<- kable(df.area, caption = "Calculo de areas por sector")

#q.tipo.tbl<- kbl(query.n.compra, caption = "5 mayores numeros de recepcion, por provedor, desde Enero hasta Mayo 2021") %>% 
#  kable_paper(full_width = F) %>%
#  row_spec(0, bold = TRUE) %>% 
#  row_spec(1, background = '#C1FA95') %>%
#  row_spec(5, background = '#C1FA95') %>%
#  column_spec(1) %>%
#  column_spec(2) %>%
#  column_spec(3) %>%
#  kable_styling(latex_options = "HOLD_position")

# datos taller
  nam <- "Duarcon LTDA."
  yearsince <- 2005
  yearwh <- 2009
  dire <- "Lo Ovalle N 220, Quilicura"
  adm<- 1
  mec<- 4
  mecprac<- 1
  mec.ttl<- mec + mecprac
  trb.ttl<- mec.ttl + adm
# inventario
  cst.stock<- "**costo invent**"
  t.ob<- "proceso logístico del área almacén"
  l.osc<- "Oscar Barros"
## cap
  tesis.ant<- "antecedentes: situación actual mercado automóvil"
  vehiculo<- "wolkswagen 32321"
  k.mlm<- "mercado automotor de livianos y medianos"
  k.lm<- "livianos y medianos"
## formulas
