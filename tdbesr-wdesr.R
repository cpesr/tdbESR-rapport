
missingdataplot <- ggplot(data=NULL,aes(x=1,y=1,label="Données manquantes")) + geom_text() + theme_void()


wdesr_dynsize <- function(df.g, ...) {
  
  nv <- nrow(df.g$vertices)
  
  if(nv < 8)        { node_size = c(12,25) ; label_size = c(2,3) }
  else if(nv < 20)  { node_size = c(10,20) ; label_size = c(2,3) }
  else if(nv < 100) { node_size = c(5,15) ; label_size = c(2,3) }
  else              { node_size = c(3,10) ; label_size = c(1,2) }
  
  return(wdesr_ggplot_graph(df.g,
                            node_size = node_size, label_size = label_size,
                            legend_position="none", arrow_gap = 0, ...) 
  )
}


plots.wd <- list()

wdesr_plots <- function(wdid) {
  if(is.na(wdid)) wdid <- "NA"
  
  if(!is.null(plots.wd[[wdid]])) return(plots.wd[[wdid]])
  
  plots <- list()
  
  plots$composition <- missingdataplot
  try({
    g.composition <- wdesr_get_graph(wdid,c('composante','associé'), depth=2) 
    plots$composition <- wdesr_dynsize(g.composition) 
  })
  
  
  plots$association <- missingdataplot
  try({
    g.association <- wdesr_get_graph(wdid,c('composante_de', 'associé_de', 'membre_de', 'affilié_à'), depth=2)
    plots$association <- wdesr_dynsize(g.association)
  })
  
  plots$filiation <- missingdataplot
  try({
    g.filiation <- wdesr_get_graph(wdid, c('prédécesseur', 'séparé_de'), depth=10)
    plots$filiation <- wdesr_dynsize(g.filiation, node_label="alias_date", margin_y=0.1)
  })
  
  try({
    
    g.all <- list(
      vertices = bind_rows(g.composition$vertices,g.association$vertices,g.filiation$vertices) %>% unique(),
      edges = bind_rows(g.composition$edges,g.association$edges,g.filiation$edges) %>% unique())
    
    plots$legend.wd <- cowplot::get_legend(
      wdesr_ggplot_graph(g.all) + 
        guides(fill=guide_legend(ncol=5, keyheight=rel(0.5), title.position = "left", title.vjust = 1,
                                 override.aes = list(size=4, color="white")),
               linetype=guide_legend(ncol=1, keyheight=rel(0.5), title.position = "left", title.vjust = 1),
               color=guide_legend(ncol=1, keyheight=rel(0.5), title.position = "left", title.vjust = 1)) +
        theme(legend.position = "bottom", 
              legend.direction = "vertical", 
              legend.box = "horizontal",
              legend.text = element_text(size=rel(0.7)))
    )
  })
  
  plots.wd[[wdid]] <<- plots
  return(plots)
}

