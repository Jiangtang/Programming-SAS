alpha <- 0.05
n <- 475
s <- 429
del1 <- 1-1/1.96
del2 <- 0.96

nb <- trunc(s/2) - max(0,s-n) + 1
dime <- nb
thet1 <- (1-del1)*4
thet2 <- (1+del2)*4

b <- rep(NA,nb)
prbl <- rep(NA,nb)
prbr <- rep(NA,nb)

INDIS6 <- 0

for (k in 1:nb)
   b[k] <- s-2*trunc(s/2) + 2*(k-1)

bhw <- s*(1-s/(2*n))

if (nb == 1)                                              
  { c1 <- b[1]
    c2 <- b[1]
    gam1 <- alpha
    gam2 <- alpha
  }                else
  { k <- 1
    while (b[k] <= bhw)
         k <- k+1
    k1 <- min(k+1,nb)

    k <- 1
    cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
    argexp1_u <- cl + (b[k]/2)*log(thet1)
    argexp2_u <- cl + (b[k]/2)*log(thet2)

    for (k in 2:nb)
       { cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
         argexp1_u <- max(argexp1_u, cl + (b[k]/2)*log(thet1))
         argexp2_u <- max(argexp2_u, cl + (b[k]/2)*log(thet2))
       }

    shiftl1 <- min(0, 700-argexp1_u)
    shiftl2 <- min(0, 700-argexp2_u)

    for (k in 1:nb)
       { cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
         prbl[k] <- exp(cl + (b[k]/2)*log(thet1) + shiftl1)
         prbr[k] <- exp(cl + (b[k]/2)*log(thet2) + shiftl2)
       }

    for (k in 2:nb)
       { prbl[k] <- prbl[k] + prbl[k-1]
         prbr[k] <- prbr[k] + prbr[k-1]
       }

    for (k in 1:nb)
       { prbl[k] <- prbl[k] / prbl[nb]
         prbr[k] <- prbr[k] / prbr[nb]
       }

    repeat                                    
       { k2 <- k1-1
         prblc1 <- prbl[max(k1-1,1)] * sign(k1-1)
         alpha1 <- 0
         prbrc1 <- prbr[max(k1-1,1)] * sign(k1-1)
         alpha2 <- 0
         while (max(alpha1,alpha2) <= alpha && k2 <= nb)
              { alpha1 <- prbl[min(k2,nb)] - prblc1
                alpha2 <- prbr[min(k2,nb)] - prbrc1
                k2 <- k2+1
              }
         k2 <- k2-2
         if (k2 < k1)
           { incl <- 1                           
             incr <- 1
           }                 else
           { k1 <- k1+1
             incl <- 0
             incr <- 1
           }

         repeat                                                    
            { alpha1 <- prbl[min(k2,nb)] - prbl[max(1,k1-1)]
              alpha2 <- prbr[min(k2,nb)] - prbr[max(1,k1-1)]
              delalph1 <- alpha-alpha1
              delalph2 <- alpha-alpha2
              exrandl1 <- prbl[k1-1] - prbl[max(k1-2,1)]*sign(k1-2)
              exrandl2 <- prbl[min(k2+1,nb)] - prbl[min(k2,nb)]
              exrandr1 <- prbr[k1-1] - prbr[max(k1-2,1)]*sign(k1-2)
              exrandr2 <- prbr[min(k2+1,nb)] - prbr[min(k2,nb)]
              det <- exrandl1*exrandr2 - exrandl2*exrandr1

              if (abs(det) >= 10**(-78) )
                { gam1 <- (exrandr2*delalph1 - exrandl2*delalph2) / det
                  gam2 <- (exrandl1*delalph2 - exrandr1*delalph1) / det
                }             else
                { gam1 <- -1
                  gam2 <- -1
                }
              if ( ( min(gam1,gam2)<0 || max(gam1,gam2)>= 1) && incl == 0 && incr == 1)
                { k1 <- k1-1
                  k2 <- k2-1                                   
                  incl <- 1
                  incr <- 0
                }                    else
              if ( ( min(gam1,gam2)<0 || max(gam1,gam2)>= 1) && incl == 1 && incr == 0)
                { k2 <- k2+1
                  incl <- 1                                    
                  incr <- 1
                }                    else
              if ( ( min(gam1,gam2)<0 || max(gam1,gam2)>= 1) && incl == 1 && incr == 1)
                { k1 <- k1-1
                  break                                        
                }                    else
                { c1 <- b[k1-1]
                  c2 <- b[k2+1]
                  INDIS6 <- 1
                  break
                }                             
            }                                                                 
         if (INDIS6 == 1)  break                              
       }                                                                          
    
  }

cat ("  N = ",n,"  S = ",s,"  ALPHA = ",alpha,"  DEL1 = ",del1,"  DEL2 = ",del2,
     "  GAM1 = ",gam1,"  GAM2 = ",gam2,"  C1 = ",c1,"  C2 = ",c2)
