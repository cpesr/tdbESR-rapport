
library(kpiESR)
library(wikidataESR)
library(tidyverse)
library(ggcpesrthemes)
library(cowplot)

source("tdbesr-plots.R")
source("tdbesr-wdesr.R")

path <- "plot"
dir.create(path)
logpath <- "log"
dir.create(logpath)

missingdataplot <- ggplot(data=NULL,aes(x=1,y=1,label="Données manquantes")) + geom_text() + theme_void()


k_style <- kpiesr_style(
  point_size = 16,
  line_size = 1,
  text_size = 4)

o_style <- kpiesr_style(
  point_size = 12,
  line_size = 0.7,
  text_size = 3,
  primaire_margin = 1.25,
  strip_labeller = lfc_dont_labeller
  )

lfc_pc_labeller_custom <- function(labels) {
  return(
    stringr::str_replace(lfc_pc_labeller(labels),"\\(","\n (")
  )
}
onorm_style <- kpiesr_style(
  point_size = 12,
  line_size = 0.7,
  text_size = 3,
  primaire_margin = 1.25,
  strip_labeller = lfc_pc_labeller_custom,
  label_wrap = 12
)


strvar <- function(var) {
  s <- as.character(var)
  ifelse(str_length(s)>0,s,"N/A")
}

theme_set(ggcpesrthemes::theme_cpesr() + 
            theme(plot.title = element_text(hjust=1),
                  panel.spacing = unit(2,"lines"), 
                  plot.margin = margin(0,0,0,0),
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
    plots <- kpiesr_plot_all(rentrée, etab$UAI, grp, style.k=k_style, style.o=o_style, style.o.norm = onorm_style)
  )
  
  message("wikidata")
  plots <- c(plots, wdesr_plots(wdid))
    
  message("combine")
  plot.kpi <- combine_plots_kpi(plots)
  ggsave(
    paste0(path,"/",etab$UAI,"-kpi.pdf"),
    plot = plot.kpi,
    width= 12, height=9,
    device = cairo_pdf)
  
  plot.series <- combine_plots_series(plots)
  ggsave(
    paste0(path,"/",etab$UAI,"-series.pdf"),
    plot = plot.series,
    width= 12, height=9,
    device = cairo_pdf)
  
}


wdesr_save_cache()

