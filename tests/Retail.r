##########################################
###  Script for Daily Retail Palantir Data
###########################################

## wipe
rm(list=ls())

library(devtools)

setwd("C:\\Users\\Tucker\\Documents\\GitHub\\sigex")
load_all(".")
 

######################
### Part I: load data
 
# automatic


#############################################################
### Part II: Metadata Specifications and Exploratory Analysis

start.date <- c(10,1,2012)
end.date <- day2date(dim(retail)[1]-1,start.date)
period <- 365

# calendar calculations
start.day <- date2day(start.date[1],start.date[2],start.date[3])
end.day <- date2day(end.date[1],end.date[2],end.date[3])
begin <- c(start.date[3],start.day) 
end <- c(end.date[3],end.day)

## create ts object and plot
dataALL.ts <- sigex.load(retail,begin,period,colnames(retail),TRUE)
 
#############################
## select span and transforms 

## all data with no transform
transform <- "none"
aggregate <- FALSE
subseries <- 1
begin.date <- start(dataALL.ts)
end.date <- end(dataALL.ts)
range <- NULL
data.ts <- sigex.prep(dataALL.ts,transform,aggregate,subseries,range,TRUE)

#######################
## spectral exploratory

## levels
par(mfrow=c(1,1))
for(i in subseries)
{
	sigex.specar(data.ts,FALSE,i,7)
}
dev.off()

## growth rates
par(mfrow=c(1,1))
for(i in subseries)
{
	sigex.specar(data.ts,TRUE,i,7)
}
dev.off()


HERE


###############################
### Part III: Model Declaration

N <- dim(data.ts)[2]
T <- dim(data.ts)[1]


################
## Default Model
 
## choose a model
# A: BW cycle and stabilized RW trend
cycle.class <- "bw"
cycle.order <- 1
cycle.bounds <- c(0,1,0,1)
trend.class <- "arma.stab"
trend.order <- c(0,0)
trend.bounds <- 0

# B: stabilized BW cycle and stabilized RW trend
cycle.class <- "bw.stab"
cycle.order <- 1
cycle.bounds <- c(0,1,0,1)
trend.class <- "arma.stab"
trend.order <- c(0,0)
trend.bounds <- 0
 
# C: BAL cycle and stabilized RW trend
cycle.class <- "bal"
cycle.order <- 1
cycle.bounds <- c(0,1,0,1)
trend.class <- "arma.stab"
trend.order <- c(0,0)
trend.bounds <- 0

# D: stabilized BAL cycle and stabilized RW trend
cycle.class <- "bal.stab"
cycle.order <- 1
cycle.bounds <- c(0,1,0,1)
trend.class <- "arma.stab"
trend.order <- c(0,0)
trend.bounds <- 0

## model construction
mdl <- NULL
# trend:
mdl <- sigex.add(mdl,seq(1,N),trend.class,trend.order,trend.bounds,c(1,-1))		
# cycle:
mdl <- sigex.add(mdl,seq(1,N),cycle.class,cycle.order,cycle.bounds,1)			
# irregular:
mdl <- sigex.add(mdl,seq(1,N),"arma",c(0,0),0,1)	
# regressors:
mdl <- sigex.meaninit(mdl,data.ts,0)				
 
## parameter initialization and checks
par.default <- sigex.default(mdl,data.ts)[[1]]
flag.default <- sigex.default(mdl,data.ts)[[2]]
psi.default <- sigex.par2psi(par.default,flag.default,mdl)
resid.init <- sigex.resid(psi.default,mdl,data.ts)
resid.init <- sigex.load(t(resid.init),start(data.ts),frequency(data.ts),colnames(data.ts),TRUE)
acf(resid.init,lag.max=40)


###########################
### Part IV: MLE Estimation

## setup, and fix parameters as desired
mdl.mle <- mdl
psi.mle <- psi.default
# psi.mle <- rnorm(length(psi.default))	# random initialization
flag.mle <- Im(psi.mle)
par.mle <- sigex.psi2par(psi.mle,mdl.mle,data.ts)

## run fitting
fit.mle <- sigex.mlefit(data.ts,par.mle,flag.mle,mdl.mle,"bfgs")

## manage output
psi.mle[flag.mle==1] <- fit.mle[[1]]$par 
psi.mle <- psi.mle + 1i*flag.mle
hess <- fit.mle[[1]]$hessian
par.mle <- fit.mle[[2]]

##  model checking 
resid.mle <- sigex.resid(psi.mle,mdl.mle,data.ts)
resid.mle <- sigex.load(t(resid.mle),start(data.ts),frequency(data.ts),colnames(data.ts),TRUE)
sigex.portmanteau(resid.mle,4*period,length(psi.mle))
sigex.gausscheck(resid.mle)
acf(resid.mle,lag.max=40)
      
## check on standard errors and condition numbers
print(eigen(hess)$values)
taus <- log(sigex.conditions(data.ts,psi.mle,mdl.mle))
print(taus)
tstats <- sigex.tstats(mdl.mle,psi.mle,hess)
stderrs <- sigex.psi2par(tstats,mdl,data.ts)
print(tstats)

## bundle  
analysis.mle <- sigex.bundle(data.ts,transform,mdl.mle,psi.mle)



##########################################
### Part V: Signal Extraction based on MLE

## load up the MLE fit for signal extraction
data.ts <- analysis.mle[[1]]
mdl <- analysis.mle[[3]]
psi <- analysis.mle[[4]]
param <- sigex.psi2par(psi,mdl,data.ts)

## get signal filters
signal.trend <- sigex.signal(data.ts,param,mdl,1)
signal.cycle <- sigex.signal(data.ts,param,mdl,2)
signal.irr <- sigex.signal(data.ts,param,mdl,3)
signal.noncyc <- sigex.signal(data.ts,param,mdl,c(1,3))
signal.hp <- sigex.signal(data.ts,param,mdl,c(2,3))
signal.lp <- sigex.signal(data.ts,param,mdl,c(1,2))

## get extractions 
extract.trend <- sigex.extract(data.ts,signal.trend,mdl,param)
extract.cycle <- sigex.extract(data.ts,signal.cycle,mdl,param)
extract.irr <- sigex.extract(data.ts,signal.irr,mdl,param)
extract.noncyc <- sigex.extract(data.ts,signal.noncyc,mdl,param)
extract.hp <- sigex.extract(data.ts,signal.hp,mdl,param)
extract.lp <- sigex.extract(data.ts,signal.lp,mdl,param)
  
## get fixed effects
reg.trend <- NULL
for(i in 1:N) {
reg.trend <- cbind(reg.trend,sigex.fixed(data.ts,mdl,i,param,"Trend")) }

## plotting
trendcol <- "tomato"
cyccol <- "navyblue"
fade <- 40
par(mfrow=c(2,1),mar=c(5,4,4,5)+.1)
for(i in 1:N)
{
	plot(data.ts[,i],xlab="Year",ylab="Trend",ylim=c(min(data.ts[,i])-2,max(data.ts[,i])),
		lwd=2,yaxt="n",xaxt="n")
	sigex.graph(extract.trend,reg.trend,begin.date,period,i,0,trendcol,fade)
	sigex.graph(extract.cycle,NULL,begin.date,period,i,10,cyccol,fade)
	axis(1,cex.axis=1)
	axis(2,cex.axis=1)
	axis(4,cex.axis=1,at=c(9.5,10,10.5,11,11.5),labels=c(9.5,10,10.5,11,11.5)-10)
	mtext("Cycle", side=4, line=3)
}
dev.off()

## transfer function analysis
grid <- 200
frf.trend <- sigex.getfrf(data.ts,param,mdl,1,TRUE,grid)
frf.cycle <- sigex.getfrf(data.ts,param,mdl,2,TRUE,grid)

## filter analysis
len <- 50
wk.trend <- sigex.wk(data.ts,param,mdl,1,TRUE,grid,len)
wk.cycle <- sigex.wk(data.ts,param,mdl,2,TRUE,grid,len)

