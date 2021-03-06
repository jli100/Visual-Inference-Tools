##############################################################################
## Date     : 2011-02-28
## Author   : Danny Chang
## Type     : grid drawing object and functions
## Usage    : draw table
##############################################################################

grid.table = function(...){
  grid.draw(tableGrob(...))
}

tableGrob = function(data, varname, main, rc.layout=dim(data),
                     cex.data=1, cex.varname=1.5, cex.main=2,
                     col.data="black", col.varname="black", col.main="black",
                     height.varname=1.5, height.main=1.5,
                     name=NULL, gp=gpar(), vp=NULL, showTxt=TRUE){
  ## define table grob
  ##
  ## Args:
  ## rc.layout: row column layout
  ##
  ## Returns:
  ##  grob
  
  data = as.matrix(data)
  igt = gTree(data=data, varname=varname, main=main, rc.layout=rc.layout, 
              cex.data=cex.data, cex.varname=cex.varname, cex.main=cex.main,
              col.data=col.data, col.varname=col.varname, col.main=col.main,
              height.main=height.main, height.varname=height.varname,
              childrenvp=makeTableViewports(height.main,  height.varname),
              children=makeTableGrob(data, varname, main, rc.layout,
                                     cex.data, cex.varname, cex.main,
                                     col.data, col.varname, col.main, showTxt),
              gp=gp, name=name, vp=vp, cl="table")
  igt
}

makeTableGrob = function(data, varname, main, rc.layout,
                         cex.data, cex.varname, cex.main,
                         col.data, col.varname, col.main, showTxt){                         
  datagb = varnamegb = maingb = NULL
  if(class(col.data)=="data.frame")
    col.data = as.matrix(col.data)
  if(class(col.data)=="matrix")
    col.data = as.vector(t(col.data))  
  if(all(is.logical(showTxt)))
    idx = rep(showTxt, length.out=nrow(data))
  else
    idx = showTxt

  label.coord = function(nr, nc){
    ## unit: npc
    x = seq(0, 1, length.out=nc*2+1)[c(FALSE, TRUE)]
    y = seq(1, 0, length.out=nr*2+1)[c(FALSE, TRUE)]
    list(x=x, y=y)
  }
  
  if(!is.null(data)){
    coord = label.coord(rc.layout[1], rc.layout[2])
    xy = expand.grid(x=coord$x, y=coord$y)
    label = as.vector(t(as.matrix(data)))
    x = coord$x[as.vector(t(col(data)))]
    y = coord$y[as.vector(t(row(data)))]
    
    if(length(label[idx])>0){
      datagb = textGrob(label[idx], x=unit(x, "npc")[idx], y=unit(y, "npc")[idx],
                      name="dataTxt", gp=gpar(cex=cex.data, col=col.data),
                      vp=vpPath("tablelay", "datavp"))
    }
    else{
      datagb = textGrob(NULL, x=unit(x, "npc"), y=unit(y, "npc"),
                      name="dataTxt", gp=gpar(cex=cex.data, col=col.data),
                      vp=vpPath("tablelay", "datavp"))
    }
  }
  
  if(!is.null(varname)){
    nc = length(varname)
    coord = label.coord(1, rc.layout[2])
    x = unit(coord$x, "npc")[1:nc]
    y = unit(coord$y, "npc")
    varnamegb = textGrob(varname, x=x, y=y, gp=gpar(cex=cex.varname),
                         name="varnameTxt", vp=vpPath("tablelay", "varnamevp"))
  }
  
  if(!is.null(main)){
    maingb = textGrob(main, x=unit(0.5, "npc"), y=unit(0.5, "npc"),
                      name="mainTxt", gp=gpar(cex=cex.main),
                      vp=vpPath("tablelay", "mainvp"))
  }
  gList(maingb, varnamegb, datagb)
}

makeTableViewports = function(height.main,  height.varname){
  mylay = grid.layout(3, 1, heights=unit(c(height.main,  height.varname, 1),
                                         c("lines", "lines", "null")))
  vpTree(viewport(layout=mylay, name="tablelay"),
         vpList(viewport(layout.pos.row=1, name="mainvp"),
                viewport(layout.pos.row=2, name="varnamevp"),
                viewport(layout.pos.row=3, name="datavp")))
}

editDetails.table = function(x, spec){
  x = tableGrob(x$data, x$varname, x$main, x$rc.layout,
                x$cex.data, x$cex.varname, x$cex.main,
                x$col.data, x$col.varname, x$col.main,
                x$height.varname, x$height.main,
                x$name, x$gp, x$vp)
  x
}

validDetails.table = function(x){
  if(!(class(x$data)=="data.frame"||class(x$data)=="matrix"))
    stop("only support data.frame and matrix")  
  x
}

grid.table.example = function(){
  vp = viewport(width=unit(0.8, "npc"), height=unit(0.8, "npc"),
                xscale=c(-10, 10), yscale=c(-10, 10), name="parent")
  pushViewport(vp)
  grid.rect(name="box")
  grid.xaxis(name="xaxis")
  grid.yaxis(name="yaxis")
  x = data.frame(x=1:14, y=11:24)
  col.data = cbind("black", sample(c("red", "blue"), 14, replace=TRUE))
  print(col.data)
  grid.table(x, c("x", "y"), "MyTitle", c(15, 3),
             col.data=col.data, name="test")
}
# grid.table.example()
# grid.ls()
# current.viewport()