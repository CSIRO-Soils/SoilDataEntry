plotLabResults <- function(df, att){
  
  xBound <-  max(df$vals)  + (max(df$vals) * 0.2)
  depth <- max(as.numeric(df$ld))
  par(oma=c(0,0,0,0)) 
  par(mar=c(5,5,3,2))
  plot( 0, type="n",  col.main = 'blue', cex.main=2,
        ylab='Soil Depth (m)',
        xlab='Value',
        yaxs = "i", xaxs = "i", xlim = c(0, xBound), ylim = rev(range(c(0,depth))),
        cex.lab = 2,
        main = paste0( att)
  )
    mid <-  df$ud + (df$ld - df$ud)/2
    vc <- df$vals
    n <- data.frame(x=vc, y=mid)
    lines(n, lwd=3, pch=19, col='darkgreen')
  
}


getSoilProfileDiagram <- function(sid, p){
  
  hue <- str_sub(p$col_hue_val_chrom, start = 1, end = nchar(p$col_hue_val_chrom) - 2)
  value <- str_sub(p$col_hue_val_chrom, start = nchar(hue)+1, end = nchar(hue)+1)
  chroma <- str_sub(p$col_hue_val_chrom, start = nchar(hue)+2, end = nchar(hue)+2)
  
  sp <-  data.frame(ud=as.integer(p$h_upper_depth*100), ld=as.integer(p$h_lower_depth*100), h_desig_master=p$h_desig_master, 
                    h_desig_num_pref=p$h_desig_num_pref, h_desig_subdiv=p$h_desig_subdiv, h_desig_suffix=p$h_desig_suffix, hue, value, chroma)
  
  depth = max(sp$ld)
  par(mar=c(0.1,3,6,2))
  
  lableft = 1.5
  profleft = 2.5
  profWidth = 2
  
  plot.new(); plot.window(xlim=c(1,10),ylim=rev(c(0,depth)) )
  # text(lableft+0.5, sp$ud[1], 'Depth (cm)')
  mtext('Depth (cm)', side=3, at=2)
  for (i in 1:nrow(sp)) {
    rec=sp[i,]
    if(rec$hue!=''){
      mnsl <- paste0(rec$hue, ' ', rec$value, '/', rec$chroma)
      col <- munsell::mnsl2hex(in_gamut(mnsl, fix = T))
    }else{
      col='white'
    }
    
    if(is.na(rec$h_desig_num_pref)){rec$h_desig_num_pref=''}
    if(is.na(rec$h_desig_master)){rec$h_desig_master=''}
    if(is.na(rec$h_desig_subdiv)){rec$h_desig_subdiv=''}
    if(is.na(rec$h_desig_suffix)){rec$h_desig_suffix=''}
    hnameAll <- paste0(rec$h_desig_num_pref, rec$h_desig_master, rec$h_desig_subdiv, rec$h_desig_suffix)
    
    rect(xleft = profleft, xright = profleft+profWidth, ybottom = rec$ld,   ytop = rec$ud, col=col)
    text(lableft, rec$ld, rec$ld, cex = 1, font=1)
    text(lableft, rec$ud, rec$ud, cex = 1, font=1)
    text(profleft + profWidth/2, rec$ud +  ((rec$ld-rec$ud)/2), hnameAll, cex = 1, font=2, col='gray')
    
  }
} 




saveSoilProfileDiagram <- function(sid, p, outpath){
  
  
  hue <- str_sub(p$col_hue_val_chrom, start = 1, end = nchar(p$col_hue_val_chrom) - 2)
  value <- str_sub(p$col_hue_val_chrom, start = nchar(hue)+1, end = nchar(hue)+1)
  chroma <- str_sub(p$col_hue_val_chrom, start = nchar(hue)+2, end = nchar(hue)+2)
  
  sp <-  data.frame(ud=as.integer(p$h_upper_depth*100), ld=as.integer(p$h_lower_depth*100), h_desig_master=p$h_desig_master, 
                    h_desig_num_pref=p$h_desig_num_pref, h_desig_subdiv=p$h_desig_subdiv, h_desig_suffix=p$h_desig_suffix, hue, value, chroma)
  
  depth = max(sp$ld)
  par(mar=c(0.3,1,1,0.1))
  
  lableft = 1.5
  profleft = 2.5
  profWidth = 2
  
  pngPath <- outpath
  print(pngPath)
  png(pngPath, units='in', width=5, height=15, res=300)
  
  
  plot.new(); plot.window(xlim=c(1,5),ylim=rev(c(0,depth)) )
  # text(lableft+0.5, sp$ud[1], 'Depth (cm)')
  mtext('Depth (cm)', side=3, at=2, cex=2.5)
  for (i in 1:nrow(sp)) {
    rec=sp[i,]
    if(rec$hue!=''){
      mnsl <- paste0(rec$hue, ' ', rec$value, '/', rec$chroma)
      col <- munsell::mnsl2hex(in_gamut(mnsl, fix = T))
    }else{
      col='white'
    }
    
    if(is.na(rec$h_desig_num_pref)){rec$h_desig_num_pref=''}
    if(is.na(rec$h_desig_master)){rec$h_desig_master=''}
    if(is.na(rec$h_desig_subdiv)){rec$h_desig_subdiv=''}
    if(is.na(rec$h_desig_suffix)){rec$h_desig_suffix=''}
    hnameAll <- paste0(rec$h_desig_num_pref, rec$h_desig_master, rec$h_desig_subdiv, rec$h_desig_suffix)
    
    rect(xleft = profleft, xright = profleft+profWidth, ybottom = rec$ld,   ytop = rec$ud, col=col)
    text(lableft, rec$ld, rec$ld, cex = 2.5, font=1)
    text(lableft, rec$ud, rec$ud, cex = 2.5, font=1)
    text(profleft + profWidth/2, rec$ud +  ((rec$ld-rec$ud)/2), hnameAll, cex = 2.5, font=2, col='gray')
    
  }
  
  dev.off()
} 



