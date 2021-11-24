
library(kpiESR)
library(wikidataESR)
library(tidyverse)
library(ggcpesrthemes)
library(cowplot)

source("tsbesr-plots.R")
source("tdbesr-wdesr.R")

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
            theme(plot.title = element_text(hjust=1),
                  panel.spacing = unit(2,"lines"), 
                  strip.text = element_text(size=rel(0.7), 
                                            margin=margin(c(2,0,2,0)))))


wdesr_load_cache()

rentrée <- 2019

etabs <- esr.etab %>% filter(Etablissement %in% c("Université de Strasbourg","Université de Lorraine","Université de Haute-Alsace"))
etabs <- esr.etab %>% filter(Etablissement == "Université Paris sciences et lettres")
etabs <- esr.etab



for (i in seq(1,nrow(etabs))) {
  etab <- etabs[i,]
  message("\nProcessing ",i,"/",nrow(etabs)," : ",strvar(etab$Etablissement))
  grp <- ifelse(etab$Groupe == "Université","Université","Ensemble")
  wdid <- substr(etab$url.wikidata,33,50)
  plots <- list()
  
  message("kpi")
  try(
    plots <- kpiesr_plot_all(rentrée, etab$UAI, grp, style.kpi.k=big_style, style.kpi=small_style)
  )
  
  message("wikidata")
  plots <- c(plots, wdesr_plots(wdid))
    
  message("combine")
  plot.kpi <- combine_plots_kpi(plots)
  ggsave(
    paste0(path,"/",etab$UAI,"-kpi.pdf"),
    plot = plot.kpi,
    width= 12, height=8,
    device = cairo_pdf)
  
  plot.series <- combine_plots_series(plots)
  ggsave(
    paste0(path,"/",etab$UAI,"-series.pdf"),
    plot = plot.series,
    width= 12, height=8,
    device = cairo_pdf)
  
}


wdesr_save_cache()

