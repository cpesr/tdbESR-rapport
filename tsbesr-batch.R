
library(kpiESR)
library(wikidataESR)
library(tidyverse)
library(ggcpesrthemes)

path <- "plot"
dir.create(path)
logpath <- "log"
dir.create(logpath)

missingdataplot <- ggplot(data=NULL,aes(x=1,y=1,label="Données manquantes")) + geom_text() + theme_void()


small_style <- kpiesr_style(
  point_size = 12,
  line_size = 0.7,
  text_size = 3,
  primaire_margin = 1.25
  )

big_style <- kpiesr_style(
  point_size = 16,
  line_size = 1,
  text_size = 4)

strvar <- function(var) {
  s <- as.character(var)
  ifelse(str_length(s)>0,s,"N/A")
}


theme_set(ggcpesrthemes::theme_cpesr() + 
            theme(panel.spacing = unit(0.5,"lines"), 
                  strip.text = element_text(size=rel(0.7), 
                                            margin=margin(c(2,0,2,0)))))



rentrée <- 2019

etabs <- esr.etab %>% filter(Etablissement %in% c("Université de Strasbourg","Université de Lorraine","Université de Haute-Alsace"))
etabs <- esr.etab


for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Etablissement))
  
  grp <- ifelse(etab$Groupe == "Université","Université","Ensemble")
  
  p <- missingdataplot
  try(
    p <- kpiesr_plot_tdb(rentrée, etab$UAI, grp, style.kpi.k=big_style, style.kpi=small_style)
  )
  ggsave(
    paste0(path,"/",etab$UAI,"-kpi.pdf"),
    plot = p,
    width= 9, height=9,
    device = cairo_pdf)
}



# wdesr_load_and_plot("Q4027", c('prédécesseur', 'séparé_de'), depth=10, 
#                     node_label = "alias_date",
#                     legend_position="none",
#                     node_sizes = 40, arrow_gap = 0.17, margin_y = 0.2)

wdesr_load_cache()



for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  wdid <- substr(etab$url.wikidata,33,50)
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Etablissement))
  
  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-composition.log"))
  try(
    p <- wdesr_load_and_plot(wdid, c('composante','associé'), depth=2,
                             legend_position="right", arrow_gap = 0)
  )
  warnings()
  sink(NULL)
  
  ggsave(
    paste0(path,"/",etab$UAI,"-composition.pdf"),
    plot = p,
    width= 7, height=5,
    device = cairo_pdf)
}

for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  wdid <- substr(etab$url.wikidata,33,50)
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Etablissement))
  
  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-association.log"))
  try(  
    p <- wdesr_load_and_plot(wdid, c('composante_de', 'associé_de', 'membre_de', 'affilié_à'), depth=2, 
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
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Etablissement))
  
  p <- missingdataplot
  
  sink(paste0(logpath,"/",etab$UAI,"-filiation.log"))
  try(  
    p <- wdesr_load_and_plot(wdid, c('prédécesseur', 'séparé_de'), depth=10, 
                             node_label = "alias_date",
                             legend_position="none",
                             arrow_gap = 0, margin_y = 0.15)
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

