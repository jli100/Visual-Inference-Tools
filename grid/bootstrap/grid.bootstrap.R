##############################################################################
## Date     : 2011-05-09
## Author   : Vivian Li
## Type     : grid draw functions
## Usage    : bootstrap 1 animation layout and initialize only
##          : numerical data
##############################################################################


grid.bootstrap = function(...){
  grid.draw(bootstrapGrob(...))
}

bootstrapGrob = function(data, diffFun=median, vname=NULL, x.sim=NULL, main="MyData", digit=3,
                       name=NULL, gp=gpar(), vp=NULL, tab=list()){
  if(is.numeric(data))
    data = data.frame(x=data)
  else if(is.data.frame(data)){
    data = data.frame(x=data[,1])
  }
 
  names(data)=vname

  igt = gTree(data=data, diffFun=diffFun,digit=digit,
              children=makeBootstrapGrob(data,diffFun,x.sim, main, digit,tab),
              childrenvp=makeBootstrapViewports(data, diffFun,x.sim),
              name=name, gp=gp, vp=vp, tab=tab,
              cl="bootstrap")
  igt
}

makeBootstrapGrob = function(data, diffFun, x.sim, main, digit, tab){
  
  tabgb = datgb = ghostgb = rangb = distgb = NULL
  
  args  = list(data,tab,diffFun, gb="boxdotGrob", 
               gbfmt=initArgsBootstrapGhostBox(data[,1],diffFun), name="ghostBox")
  
  if(identical(diffFun, mean)){
    args$gb = "meanBarGrob"
    args$gbfmt = initArgsBootstrapGhostBar(data[,1],diffFun)
  }
  
  ## setting table grob at tablevp (col1)
  tabgb = do.call("tableGrob", initArgsBootstrapTable(data, main, digit))
  ## setting table grob at btablevp (col3)
  btabgb = do.call("tableGrob", initArgsBootstrapBootstrapTable(data, main, digit))
  
  ## setting boxdotsDiff grob at datavp (row1)
  datgb = do.call("boxdotGrob", initArgsBootstrapData(data[,1], diffFun))
  
   ## setting ghost boxeds at bstrapvp (row3)
  ghostgb = do.call("ghostGrob", args)
  
  ## setting boxdotsDiff grob at bstrapvp (row3)
  rangb = do.call("boxdotGrob", initArgsBootstrapRandom(data[,1], diffFun))
  
  ## setting stackpts grob at distvp (row5)
  distgb = do.call("stackptsGrob", initArgsBootstrapDist(data, diffFun, x.sim))
  gList(tabgb, btabgb, datgb, ghostgb, rangb, distgb)
}

makeBootstrapViewports = function(data,diffFun,x.sim){
  xat     = xatBootstrap(data,diffFun,x.sim)$xat1
  xrange  = range(xat)
  xat2    = xat
  #xat2    = xatBootstrap(data,diffFun,x.sim)$xat2
  xrange2 = range(xat2)
 
  nr = 6
  nc = 5
  # layout width
  # "null" is used to divide the remaining space proportionally
  widths  = unit(c(   0.3,  1,  0.3,      2,    1),
                 c("null","line","null", "line", "null"))
  heights = unit(c(      1,      2,     1,       2,      1,  0.2),
                  c("null", "line", "null", "line", "null","null"))
  
  mylay  = grid.layout(nrow=nr, ncol=nc, widths=widths, heights=heights)

  mar    = unit(c(2.5, 1, 1, 1), c("lines", "lines", "lines", "lines"))
  width  = unit(1, "npc") - mar[2] - mar[4]
  height = unit(1, "npc") - mar[1] - mar[3]
  
  tree = vpTree(viewport(layout=mylay, name="bootstrap",
                         x=mar[2], y=mar[1],
                         width=width, height=height, just=c(0, 0)),
                vpList(viewport(layout.pos.col=1, name="tablevp"),
                       viewport(layout.pos.col=3, name="btablevp"),
                       viewport(layout.pos.row=1, layout.pos.col=5,
                                xscale=xrange, name="datavp"),
                       viewport(layout.pos.row=3, layout.pos.col=5,
                                xscale=xrange, name="bstrapvp"),
                       viewport(layout.pos.row=5, layout.pos.col=5,
                                xscale=xrange2, name="bdistvp"),
                       viewport(layout.pos.row=6, layout.pos.col=5,
                                xscale=xrange2, name="extravp")
                      )
               )
  tree
}

drawDetails.bootstrap = function(x, recording){
  
  y     = x$data[,1]
  bxat  = xatBootstrap(x$data,x$diffFun, x$x.sim)
  
  xat   = bxat$xat1
  xat2  = bxat$xat1
  
  depth = downViewport(vpPath("bootstrap", "tablevp"))
  grid.roundrect(gp=gpar(fill=rgb(0, 0, 1, alpha=0.05)))

  if(length(y)>initArgsBootstrap()$maxRow){
    grid.text("more...", x=unit(1/6, "npc"), y=unit(2/170, "npc"),
              just="left", gp=gpar(cex=0.7))
  }
  upViewport(depth)
  
  depth = downViewport(vpPath("bootstrap","btablevp"))
  grid.roundrect(gp=gpar(fill=rgb(0, 0, 1, alpha=0.05)))
  upViewport(depth)
  
  depth = downViewport(vpPath("bootstrap","datavp"))
  
  grid.xaxis(at=xat)

  if(identical(x$diffFun, mean)){
    grid.meanBar(xat=unit(x$diffFun(y),"native"),yat=unit(0.5,"npc"),len=unit(0.3,"npc"),name="meanBar0")              
  }
 
  upViewport(depth)
  
  depth = downViewport(vpPath("bootstrap", "bstrapvp"))
  grid.xaxis(at=xat)
  
  upViewport(depth)
  
  depth = downViewport(vpPath("bootstrap", "bdistvp"))
  grid.xaxis(name="axis3",at=xat2)
  upViewport(depth)
}

editDetails.bootstrap = function(x, spec){
  x
}

validDetails.bootstrap = function(x){
  if(!is.numeric(x$data[,1]))
    stop("The numeric variable should be at column one!")   
  
  type = unlist(lapply(x$data, class))

  if(!any(c("numeric", "integer", "double")%in%type))
    stop("numeric/integer/double data not found")

  x
}

bstrapTest = function(nsim=1,ran=T,fly=F,type=1){
  sample.df=createRandom1Data()$data
  vname    = names(sample.df)[1]
  x        = sample.df[,1]

  grid.newpage()
  grid.bootstrap(x,vname=vname,main="Simulated Data",name="BootstrapMovie")
  m        = median(x)
  sim.bt  = bootstrapSimulation(x,nsim)
  
  sim.tab = sim.bt$tab
  sim.est= sim.bt$est

  grid.newpage()
  grid.bootstrap(x,x.sim=sim.est,vname=vname,main="Simulated Data",name="BootstrapMovie")
  if(ran){
    if(nsim<30){
      for(i in 1:nsim){
        index  = sim.tab[[i]]
        bootstrapUpdateBox(index,i)
        if(nsim==1 && fly){
         pointer=bootstrapGetPointerInfo(index)
         for(j in 1:length(x)){
           bootstrapShowPointer(pointer,index,j)
           if(length(which(index==j))>=2)
              Sys.sleep(1.2)
         }
         bootstrapRemovePointer()
        }
        bootstrapMoveBarFromBstrapvp(type=type)
        bootstrapUpdateDistShow(1:i)
        Sys.sleep(1)
        bootstrapRefresh()
      }
  #    bootstrapFinalise()
  #    bootstrapMoveArrowBarFromDatavp()
    }
    else{ 
      for(i in round(seq(1, nsim, length.out=10))[-1]){
        bootstrapUpdateDistShow(1:i)
      }
      #bootstrapMoveBarFromDatavp(type=type)
      #bootstrapShowCI(m)
    } 
  }
  else{
    for(i in 1:nsim){
      index = sim.tab[[i]]
      obj   = bootstrapInitMovingTxt(index) 
      for(i in 1:length(index)){
        bootstrapMoveTableFromTablevp(obj,index,i)
      }
    }
  }
}
