
library(kpiESR)
library(wikidataESR)
library(tidyverse)

path <- "plot"
logpath <- "log"

missingdataplot <- ggplot(data=NULL,aes(x=1,y=1,label="Données manquantes")) + geom_text() + theme_void()


small_style <- kpiesr_style(
  point_size = 12,
  line_size = 2,
  text_size = 3,
  primaire_plot.margin = ggplot2::unit(c(0.25,0,0,0), "cm"),
  bp_width = 1,
  bp_text_x = -0.21 )

big_style <- kpiesr_style(
  point_size = 17,
  line_size = 2,
  text_size = 4,
  primaire_plot.margin = ggplot2::unit(c(0.3,0,0,0), "cm"),
  bp_width = 0.9,
  bp_text_x = -0.21 )

strvar <- function(var) {
  s <- as.character(var)
  ifelse(str_length(s)>0,s,"N/A")
}

wdesr_load_cache()


# wdesr_load_and_plot("Q4027", c('prédécesseur', 'séparé_de'), depth=10, 
#                     node_label = "alias_date",
#                     legend_position="none",
#                     node_sizes = 40, arrow_gap = 0.17, margin_y = 0.2)



rentrée <- 2018

etabs <- subset(esr,Type %in% c("Université", "Grand établissement"), c(UAI,Libellé:url.legifrance) ) %>% unique %>% arrange(Type,Académie)
etabs <- subset(esr,Rentrée==2018, c(UAI,Libellé:url.legifrance) ) %>% unique %>% arrange(Type,Académie)
#etabs <- subset(esr,Type %in% c("Grand établissement"), c(UAI,Libellé:url.legifrance) ) %>% unique %>% arrange(desc(Type),Académie)
#etabs <- filter(etabs, UAI %in% c(uai.unistra,uai.uha))



for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  wdid <- substr(etab$url.wikidata,33,50)
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Libellé))

  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-composition.log"))
  try(
  p <- wdesr_load_and_plot(wdid, c('composante','associé'), depth=2,
                      legend_position="left", arrow_gap = 0)
  )
  warnings()
  sink(NULL)
  
  ggsave(
    paste0(path,"/",etab$UAI,"-composition.pdf"),
    plot = p,
    width= 10, height=5,
    device = cairo_pdf)
}

for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  wdid <- substr(etab$url.wikidata,33,50)
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Libellé))
  
  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-association.log"))
  try(  
  p <- wdesr_load_and_plot(wdid, c('composante_de', 'associé_de', 'membre_de'), depth=2, 
                      legend_position="none", margin_y = 0.1, arrow_gap = 0)
  )
  warnings()
  sink(NULL)
  
  ggsave(
    paste0(path,"/",etab$UAI,"-association.pdf"),
    plot = p,
    width= 7, height=5,
    device = cairo_pdf)
}

for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  wdid <- substr(etab$url.wikidata,33,50)
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Libellé))
  
  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-filiation.log"))
  try(  
  p <- wdesr_load_and_plot(wdid, c('prédécesseur', 'séparé_de'), depth=10, 
                      node_label = "alias_date",
                      legend_position="none",
                      node_sizes = 40, arrow_gap = 0, margin_y = 0.15)
  )
  warnings()
  sink(NULL)
  
  ggsave(
    paste0(path,"/",etab$UAI,"-filiation.pdf"),
    plot = p,
    width= 7, height=5,
    device = cairo_pdf)
}

wdesr_save_cache()





for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Libellé))
  
  p <- missingdataplot
  try(
    p <- kpiesr_plot_tdb(rentrée, etab$UAI, style.kpi.k=big_style, style.kpi=small_style)
  )
  ggsave(
    paste0(path,"/",etab$UAI,"-kpi.pdf"),
    plot = p,
    width= 9, height=13,
    device = cairo_pdf)
}

