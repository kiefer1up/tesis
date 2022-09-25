# librery----
library(RMySQL)
library(ggplot2)
library(kableExtra)
library(lubridate)
library(dplyr)
library(readxl)
library(SixSigma)
library(tidyverse)
library(flextable)
library(ganttrify)
library(data.table)
library(bookdown)
library(qcc)

## https://isci.cl/parque-de-autos-se-acelera-y-rozara-los-55-millones-de-unidades-este-ano/

##lapply(dbListConnections(MySQL()), dbDisconnect)

#database----
database<- dbConnect(MySQL(), user="root", host="127.0.0.1", password="pini", dbname="duarcon")

query<- dbGetQuery(database,statement ="SELECT s.id,st.name,t.name as tipo,sum(q) as total FROM stock s
inner join prod_st st on st.id=s.id
inner join prod_tp t on t.id=st.tp
group by id order by s.id;")

query.q.tipo<- dbGetQuery(database,statement = "SELECT t.name as tipo, sum(q) as total FROM stock s
inner join prod_st st on st.id=s.id
inner join prod_tp t on t.id=st.tp
group by tipo;")

query.n.compra<- dbGetQuery(database,statement = "SELECT p.name as proveedor,count(p.name) as n_compra, sum(pc.total) as 'monto_total $' FROM puch_cost pc
inner join prov p on p.id=pc.prov group by name order by n_compra desc limit 5;")

query.vnt<- dbGetQuery(database,statement = "SELECT prod_tp.name ,sum(q) as cantidad FROM duarcon.`vnt_tmp_` inner join prod_tp on vnt_tmp_.prd_tp = prod_tp.id WHERE name <> 'arriendo_vehiculo' group by prd_tp order by cantidad desc limit 10;")

query.tipo<-dbGetQuery(database,statement = "SELECT * FROM prod_tp;")

#preparacion datos
tip<- data.frame(query.tipo)

# df----
## df vnt----

df.vnt<-data.frame(query.vnt)

### ABC
query.vnt.abc<- dbGetQuery(database,statement = "SELECT prod_tp.id,prod_tp.name ,sum(q),sum(price),sum(q*price) as venta_total FROM duarcon.`vnt_tmp_` inner join prod_tp on vnt_tmp_.prd_tp = prod_tp.id where prod_tp.name <> 'arriendo_vehiculo' group by prod_tp.name order by venta_total desc;")

df.vnt.abc.or<-data.frame(query.vnt.abc)

ee<-df.vnt.abc.or[order(-df.vnt.abc.or$venta_total),]
ee

df.vnt.abc.or %>%
  mutate(acumulado= cumsum(venta_total))
### pareto
def<- c(df.vnt$cantidad)
names(def) <- c(df.vnt$name)

pare <- pareto.chart(def, xlab = "Categories",
          ylab="Frequency",
			    col=heat.colors(length(def)),
			    cumperc = seq(0, 100, by = 10),
			    ylab2 = "Cumulative Percentage",
			    main = "Pareto")

## df prod-----
df.prd<-data.frame(query)
### level to tipo
df.prd$tipo<- factor(df.prd$tipo,
                     levels = c(tip$name),
       #labels = c("Freno disco","Freno pastilla","Filtro aire","Filtro aceite","Filtro combustible","Filtro polen","Freno balata","Aceite","NN","Bomba de encendido")
)
sm.total.in<- sum(df.prd$total, na.rm = TRUE)
lng.ttl.prod <-length(df.prd$id)
#df.prd%>%filter(tipo =="Filtro aire" | tipo== "Filtro polen" | tipo== "Filtro combustible" | tipo=="Filtro aceite")%>% arrange(tipo)

res.prd<- df.prd %>% group_by(tipo)%>%
  summarise(N= round(sum(total, na.rm= TRUE),1),
            Min= round(min(total, na.rm = TRUE),1),
            Qu.1st= round (quantile(total, na.rm = TRUE, 0.25),1),
            Median= round(median(total, na.rm = TRUE),1),
            Mean= round(mean(total, na.rm = TRUE), 1),
            Qu.3st= round(quantile(total, na.rm = TRUE, 0.75),1),
            Max= round(max(total, na.rm = TRUE),1)
            )
res.prd.fd<- df.prd %>%
summarise(tipo=tipo,q = total) 

plt.rsmn.prd <- res.prd.fd %>%
  ggplot(aes(x= q, color = tipo , fill= tipo)) +
  geom_histogram(alpha = 0.9,
                 bins =  15) +
  theme(
    legend.position = "none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 15)
    ) +
  ylab("Frecuencia de cantidad de stock por producto")+
  xlab("stock")+
  #facet_wrap(~tipo)
  facet_wrap(~tipo, scales = "free")
## df tecnolagias tecnicas----
tec.nam<-c('ERP, Entreprise Resource Planning','WMS, Warehouse Management System','CRM, Customer Relationship Management','SCM, Supply Chain Management')
tec.obj<-c('Sistema de planificación de los recursos empresariales, por ejemplo: fabricación, ventas, compras, logística, contabilidad, gestión de proyectos, inventarios y control de almacén, pedidos, nóminas, etc.',
           'Se define como la herramienta informática más importante en la administración de almacenes, mediante la cobertura de múltiples actividades propias de los almacenes. Este sistema también dirige y optimiza el inventario basado en información de tiempo real.',
           'Estrategia empresarial para medir a sus clientes y establecer ponderaciones al evaluar el comportamiento individual de cada uno de ellos.',
           'administración y mando de todos los materiales, fondos e información relacionada en el proceso de la logística, desde la adquisición de materias primas a la entrega de productos acabados al usuario final.')
tec<-data.frame(tec.nam,tec.obj)
colnames(tec)<- c('Eje','Descripcion')
tec.tbl<- kbl(tec, caption = "Clasificacion de software") %>% 
  kable_paper(full_width = F) %>%
  row_spec(0, bold = TRUE) %>%
  column_spec(1, width = "8em") %>%
  column_spec(2,  width = "30em")


s5.nam<- c('Seiri Seleccionar','Seiton Organizar','Seiso Limpiar','Seiketsu Estandarizar','Shitsuke Seguimiento')
s5.pos<- c('1','2','3','4','5')
s5.def<- c('Es remover de nuestra area de trabajo todos los articulos que no son necesarios',
           'Es ordenar los articulos necesarios para nuestro trabajo, estableciendo un lugar espesifico para cada cosa',
           'Es basicamente eliminar la suciedad',
           'Es lograr que los procidimientos y actividades se ejecuton constantemente',
           "Es hacer un habito de las actividades de 5's para asgurar que se mantengan las areas de trabajo")
s5 <- data.frame(s5.pos,s5.nam,s5.def)
colnames(s5)<-c('Etapa','Nombre','Descripcion')

s5.tbl<- kbl(s5, caption = "The first 6 rows of the dataset, gapminder") %>% 
  kable_paper(full_width = F) %>%
  column_spec(1) %>%
  row_spec(0, bold = TRUE) %>% 
  column_spec(2,  width = "7em") %>%
  column_spec(3, width = "20em") %>%
  kable_styling(latex_options = "HOLD_position")
## df ventas----
sales=c(35322,29427,33355,35470,35328,33228,31285,38729,39263,37132,33518,34981,36543,27912,30199,32716,31204,28446,31474,33059,37925,28038,24272,31090,32104,25028,19056,8906,8681,8971,11464,19037,31897,36243,29486,27962,24984,24492,32511,27241,34130,35499,38226,37564,42627)
dt<-as.Date("2018-01-31") %m+% months(0:44)
mnth<-format(as.Date(dt),"%m")
mnth<-factor(c(mnth),labels = month.abb)
yr<-c(format(as.Date(dt),"%Y"))
df<-data.frame(dt,mnth,yr,sales)
fdf<-filter(df,yr %in% c(2019,2020,2021))
## df gantt----
#a <- c('Título','Dedicatoria','Agradecimientos','Índice de contenido','Índice de tablas y figuras','Resumen','Introducción','Objetivos','Objetivo general','Objetivos específicos','Marco teórico','Metodología','Resumen capitular','Desarrollo del trabajo','Conclusiones y/o recomendaciones','Bibliografía','Anexos')
wp <- c('tu','yo','yo','yo','yo','yo','yo','yo','yo')
activity <- c('Título','Introducción','Objetivos','Marco teórico','Metodología','Desarrollo del trabajo','Conclusión','Bibliografía','Anexos')
start_date <- c(1,1,1,2,2,2,3,3,3)
end_date <- c(3,2,2,3,3,3,3,3,3)
test_project<- data.frame(wp,activity,start_date,end_date)
#test_project
#grafico----
## grafico ventas vehiculos

ptl1<- ggplot(data = fdf,mapping= aes(mnth,sales,group=yr,color=yr))+
  geom_line()+
  geom_point()+
  theme_linedraw()+
  #ggtitle("Ventas mensuales a publico del mercado de livianos y medianos") +
  geom_text(aes(label= sales),vjust = "inward", hjust = "inward",show.legend = FALSE,size = 3)+
  labs(x = "Mes", y = "Numero de ventas",caption = "ANAC, Mercado Automotor Septiembre 2021",colour="Año")
  #theme(text=element_text(size=11,  family="calibri"))
#title = "Ventas mensuales a publico del mercado de livianos y medianos"

## Gantt
gantt1<- ganttrify(project = test_project,
          project_start_date = "2021-10",
          size_text_relative = 1.2, 
          mark_quarters = TRUE,
          hide_wp = TRUE,
          font_family = 'Roboto Condens')+
  ggplot2::labs(title = "Planificación proyecto de titulo")
                #subtitle = "I will definitely comply with the exact timing of each and all activities*",
                #caption = "* I mean, I'll do my best, but if there's a pandemic or something, it's not my fault really")
## grafico pescado
#effect <- "Mayor tiempo despacho"
#causes.gr <- c("Material","Mano de Obra","Metodo","Maquina","Medio","Medicion")
#causes <- vector(mode = "list", length = length(causes.gr))
#causes[1] <- list(c("","Falta de repuesto","","Uso de alternativas"))
#causes[2] <- list(c("","","Ausencia","","Incertidumbre stock"))
#causes[3] <- list(c("","Registro nulo"))
#causes[4] <- list(c("","Uso reactivo de vehiculo"))
#causes[5] <- list(c("","","Ubicacion errada","","Area sin estandar","","Sobrestock"))
#causes[6] <- list(c("","falta de indicadores"))
#plot2<- ss.ceDiag(effect, causes.gr, causes,"Problema tiempo despacho, area almacén","Diagrama causas-efecto")

#tables----

df.q.tipo<-data.frame(query.q.tipo)
pie.q.tipo<-ggplot(df.q.tipo,aes(x="",y=total, fill=tipo))+
  geom_bar(stat = "identity",color="white")+
  coord_polar(theta="y")


## tables docx

