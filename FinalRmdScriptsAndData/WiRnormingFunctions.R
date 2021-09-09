TabulateOlderGroupMeans <- function(d){
  # get listeners > 11 y.o.
  dOlder <-  d %>%
    filter(age>=11) %>%
    droplevels()
  
  # break studies into SC vs the rest
  dOlder$g2 <- dplyr::recode(dOlder$study, RL = 'RL+GY+HR', GY = 'RL+GY+HR', HR = 'RL+GY+HR')
  dOlder <- relocate(dOlder, g2, study)
  
  print(ddply(dOlder, .(g2), summarise, mean=mean(SRT), min=min(SRT), max=max(SRT), n=length(SRT)))
  SRTadj <- mean(dOlder$SRT[dOlder$study!="SC"]) - mean(dOlder$SRT[dOlder$study=="SC"]) 
  noquote(paste('Aggregating RL+GY+HR into one group shows a mean difference of ', round(SRTadj,1), ' dB between this group of 3 and SC. ', sep=''))
}

AdjustSC <- function(d){
  # get listeners > 11 y.o.
  dOlder <-  d %>%
    filter(age>=11) %>%
    droplevels()
  # adjust mean of SC group to that of all the rest
  
  SRTadj <- mean(dOlder$SRT[dOlder$study!="SC"]) - mean(dOlder$SRT[dOlder$study=="SC"]) 
  # adjust SRTs from the SC study by the difference
  d$SRTx <- d$SRT + as.numeric(d$study=="SC")*SRTadj
  return(d)
}

require(minpack.lm)
FitBrokenStickLM <- function(d, sl1=-1.2, i1=3, b=10, zBoundary=3){
  # broken stick regression with upper slope=0
  TwoLinesFCT <- function(x, slope1, slope2, int1, brk) {
    (x<=brk)*(slope1 * x + int1) + (x>brk)*(slope2 * x + brk*(slope1-slope2)+int1) 
  }
  m <- nlsLM(SRTx ~ TwoLinesFCT(age, slope1, 0, int1, brk),
             start=list(slope1=sl1, int1=i1, brk=b),
             data=d,
             # control=list(maxiter = 150, minFactor = 1/4096),
             trace = FALSE)
  print(summary(m))
  d$fitASYMP <- fitted(m)
  sdRES <- sd(resid(m))
  print(noquote(paste("Standard deviation of the residuals=", round(sdRES,2))))
  d$Z <- resid(m)/sdRES
  p <- ggplot(d, aes(x=age, y=Z)) + geom_point() + geom_hline(yintercept = zBoundary) + geom_hline(yintercept = -zBoundary)
  print(p)
  print(noquote(paste("Maximum magnitude z score=", round(max(abs(d$Z)),4))))
  return(d)
}
FitBrokenStickLMsat <- function(d, sl1=-1.2, sl2=0.1, i1=3, b=10, zBoundary=3){
  # broken stick regression with upper slope=0
  TwoLinesFCT <- function(x, slope1, slope2, int1, brk) {
    (x<=brk)*(slope1 * x + int1) + (x>brk)*(slope2 * x + brk*(slope1-slope2)+int1) 
  }
  m <- nlsLM(SRTx ~ TwoLinesFCT(age, slope1, slope2, int1, brk),
             start=list(slope1=sl1, slope2=sl2, int1=i1, brk=b),
             data=d,
             # control=list(maxiter = 150, minFactor = 1/4096),
             trace = FALSE)
  print(summary(m))
  d$fitASYMP <- fitted(m)
  sdRES <- sd(resid(m))
  print(noquote(paste("Standard deviation of the residuals=", round(sdRES,2))))
  d$Z <- resid(m)/sdRES
  p <- ggplot(d, aes(x=age, y=Z)) + geom_point() + geom_hline(yintercept = zBoundary) + geom_hline(yintercept = -zBoundary)
  print(p)
  print(noquote(paste("Maximum magnitude z score=", round(max(abs(d$Z)),4))))
  return(d)
}

FitBrokenStick <- function(d, sl1=-1.2, i1=3, b=10){
  # broken stick regression with upper slope=0
  TwoLinesFCT <- function(x, slope1, slope2, int1, brk) {
    (x<=brk)*(slope1 * x + int1) + (x>brk)*(slope2 * x + brk*(slope1-slope2)+int1) 
  }
  m <- nls(SRTx ~ TwoLinesFCT(age, slope1, 0, int1, brk),
           start=list(slope1=sl1, int1=i1, brk=b),
           data=d,
           control=list(maxiter = 500, minFactor = 1/4096),
           trace = FALSE)
  print(summary(m))
  d$fitASYMP <- fitted(m)
  sdRES <- sd(resid(m))
  noquote(paste("Standard deviation of the residuals=", round(sdRES,2)))
  d$Z <- resid(m)/sdRES
  p <- ggplot(d, aes(x=age, y=Z)) + geom_point() + geom_hline(yintercept = 2.5) + geom_hline(yintercept = -2.5)
  print(p)
  return(d)
}

IdentifyAndFilter <- function(d, zBoundary=3){
  # sort(d$Z)
  # Who are these, and do their tracks look OK?
  print(noquote("Excluded listeners:"))
  print(d %>%
          select(listener, fileName, age, study, SRT, fitASYMP, Z) %>%
          filter(abs(Z)>=zBoundary) )
  
  # filter them out and return
  d <- d %>%
    filter(abs(Z)<zBoundary)
  return(d)
}
