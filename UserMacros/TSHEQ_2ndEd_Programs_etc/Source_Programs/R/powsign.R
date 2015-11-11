alpha <- 0.06580
n <- 50
eps1 <- 0.847298
eps2 <- 0.847298
poa <- 0.26

p1 <- exp(-eps1) / (1+exp(-eps1))
p2 <- exp(eps2) / (1+exp(eps2))
pownonrd <- 0
pow <- alpha*poa**n

for (m in 1:n)                                        
   { INDIS7 <- 0
     INDIS6 <- 0
     k <- trunc(m/2)
     if (2*k < m || p2 != (1-p1)) bed1 <- "Gleich zu S00"  else
       { p1k <- pbinom(k,m,p1) - pbinom(k-1,m,p1)
         if (p1k >= alpha) INDIS7 <- 1 }
     if (INDIS7 == 0)                                 
       { pmi <- (p1+p2) / 2
         k1 <- max(trunc(m*p1),1)
         k2 <- max(trunc(m*pmi),k1-1)
         it <- 0
       repeat                                         
      { fbinp1c1 <- pbinom(k1-1,m,p1)
        alpha1 <- 0
        fbinp2c1 <- pbinom(k1-1,m,p2)
        alpha2 <- 0
        while (max(alpha1,alpha2) <= alpha)
        { alpha1 <- pbinom(k2,m,p1) - fbinp1c1
          alpha2 <- pbinom(k2,m,p2) - fbinp2c1
          k2 <- k2 + 1   }
        k2 <- k2 - 2
        if (k2 < k1)
          { incl <- 1
            incr <- 1 }  else
          { k1 <- k1 + 1
            incl <- 0
            incr <- 1 }
        repeat                                          
       { alpha1 <- pbinom(k2,m,p1) - pbinom(k1-1,m,p1)
         alpha2 <- pbinom(k2,m,p2) - pbinom(k1-1,m,p2)
         delalph1 <- alpha - alpha1
         delalph2 <- alpha - alpha2
         b11 <- pbinom(k1-1,m,p1) - pbinom(max(k1-2,0),m,p1) * sign(1+sign(k1-2))
         b12 <- pbinom(k2+1,m,p1) - pbinom(k2,m,p1)
         b21 <- pbinom(k1-1,m,p2) - pbinom(max(k1-2,0),m,p2) * sign(1+sign(k1-2))
         b22 <- pbinom(k2+1,m,p2) - pbinom(k2,m,p2)
         gam1 <- (b22*delalph1 - b12*delalph2) / (b11*b22 - b12*b21)
         gam2 <- (b11*delalph2 - b21*delalph1) / (b11*b22 - b12*b21)

         if ((min(gam1,gam2)<0 || max(gam1,gam2)>=1) && incl == 0 && incr == 1)       
           { k1 <- k1-1
             k2 <- k2-1
             incl <- 1
             incr <- 0 } else
         if ((min(gam1,gam2)<0 || max(gam1,gam2)>=1) && incl == 1 && incr == 0)       
           { k2 <- k2+1
             incl <- 1
             incr <- 1 } else
         if ((min(gam1,gam2)<0 || max(gam1,gam2)>=1) && incl == 1 && incr == 1)       
           { k1 <- k1+1
             break }     else
           { INDIS6 <- 1
             break }         }          

         if (INDIS6 == 1)
            break            }          

      c1 <- k1-1
      c2 <- k2+1
      fbiehc1 <- pbinom(c1,m,0.50)
      b01 <- fbiehc1 - pbinom(max(c1-1,0),m,0.5)*sign(1+sign(c1-1))
      fbiehk2 <- pbinom(k2,m,0.50)
      b02 <- pbinom(c2,m,0.50) - fbiehk2
      pownrdcm <- fbiehk2 - fbiehc1
      powcm <- gam1*b01 + pownrdcm + gam2*b02
      if (c1 == c2) powcm <- powcm/2                 }         

      if (INDIS7 == 1)                                        
        { c1 <- k
          c2 <- k
          gam1 <- alpha/p1k
          gam2 <- gam1
          pownrdcm <- 0
          proboofk <- pbinom(k,m,0.5) - pbinom(k-1,m,0.5)
          powcm <- gam1*proboofk  }

       probofm <- pbinom(n-m,n,poa) - pbinom(max(0,n-m-1),n,poa) * sign(1+sign(n-m-1))    
       pownonrd <- pownonrd + pownrdcm*probofm
       pow <- pow + powcm*probofm                  }             

cat(" ALPHA =",alpha,"   N =",n,"   EPS1 =",eps1,"   EPS2 =",eps2,"   POA =",poa,
    "   POWNONRD =",pownonrd,"   POW =",pow)       
     
