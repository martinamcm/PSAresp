library('MASS')
library('boot')
library('Hmisc')
library('car')

applyaugbin <- function(data, dich) {
  psadata         <- list(psa = -data, d = -dich)
  truncationpoint <- 0.01
  y               <- (100 - psadata$psa)/100
  d               <- (100 - psadata$d)/100
  # Set values of y below truncationpoint to truncationpoint
  y               <- replace(y, which(y < truncationpoint), truncationpoint)
  # Transform using best fitting boxcox model
  lm_boxcox       <- lm(y1 ~ 1, data.frame(y1 = y), y=TRUE,qr=TRUE)
  lambda          <- boxcox(lm_boxcox)$x[which.max(boxcox(lm_boxcox)$y)]
  y               <- (y^lambda - 1)/lambda
  d               <- (d^lambda - 1)/lambda
  # augbin when no other covariates to adjust for
  lm_augbin       <- lm(y ~ 1)
  # Get binary analysis
  S               <- ifelse(y < d, 1, 0)
  results         <- c(binconf(x = sum(S), n = length(S)),
                       deltamethod2(lm_augbin, d))
  results[4:6]    <- 1 - results[4:6]
  results[5:6]    <- results[6:5]
  return(results)
}

meanprob    <- function(lm1, d) {
  mean  <- lm1$coef[1]
  sigma <- summary(lm1)$sigma
  prob  <- 1 - pnorm(d,mean,sigma)
  return(logit(mean(prob)))
}

deltamethod <- function(lm1, d) {
  prob            <- meanprob2(lm1, d)
  templm1         <- lm1
  templm1$coef[1] <- templm1$coef[1] + 0.0001
  derivative      <- (meanprob2(templm1, d) - prob)/0.0001
  var.meanprob    <- (summary(lm1)$coef[2]^2)*derivative^2
  return(inv.logit(c(prob, prob - 1.96*sqrt(var.meanprob),
                     prob + 1.96*sqrt(var.meanprob))))
}
