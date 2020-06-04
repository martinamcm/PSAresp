library('MASS')
library('boot')
library('Hmisc')

meanprob=function(lm1,d)
{
  mean=lm1$coef[1]
  
  sigma=summary(lm1)$sigma
  
  prob=pnorm(d,mean,sigma)
  
  return(logit(mean(prob)))
  
}

deltamethod=function(lm1,d)
{
  prob=meanprob(lm1,d)
  templm1=lm1
  templm1$coef[1]=templm1$coef[1]+0.0001
  derivative=(meanprob(templm1,d)-prob)/0.0001
  
  
  var.meanprob=(summary(lm1)$coef[2]^2)*derivative^2
  return(inv.logit(c(prob,prob-1.96*sqrt(var.meanprob),prob+1.96*sqrt(var.meanprob))))
}




applyaugbin=function(data,dich,truncationpoint)
{
  #change scale to relative change from baseline (2 being 100% increase, 1 being 0% decrease, 0 representing 100% decrease)  
  
  y=(100-as.numeric(data))/100  
  d=(100-dich)/100
  trunc=(100-truncationpoint)/100
  
  #set values of y below truncationpoint to truncationpoint
  
  y=replace(y,which(y<trunc),trunc)
  
  #Get binary analysis:
  S=ifelse(y<d,1,0)
  
  bin<-binconf(x = sum(S),n = length(S))
  
  ##aug
  y=y+abs(min(y))+0.00001
  d=d+abs(min(y))+0.00001
  
  #transform using best fitting boxcox model:
  PSAdat=data.frame(y=y)
  lm.boxcox=lm(y~1,data=PSAdat,y=TRUE,qr=TRUE)
  lambda=boxcox(lm.boxcox)$x[which.max(boxcox(lm.boxcox)$y)]
  
  y=(y^lambda-1)/lambda
  d=(d^lambda-1)/lambda
  
  #augbin when no other covariates to adjust for:
  lm.augbin=lm(y~1)
  
  
  aug<-deltamethod(lm.augbin,d)
  
  return(c(aug,bin))
}

