alpha0 <- 0.0228
m <- 50
n <- 50
del1 <- 0.20
del2 <- 0.20
p1 <- 0.50
p2 <- 0.50

kl <- rep(NA,m+1)
ku <- rep(NA,m+1)
empt <-rep(NA,m+1)
indr <- matrix(rep(NA,((m+1)*(n+1))),nrow=m+1)

error <- "none"
WAR <- 0

u_al <- qnorm(alpha0)

x <- 0

empt[x+1] <- 0
indr[x+1,0+1] <- 0
for (y in 1:(n-1))
   { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     if (nc > 100) crit <- sqrt(nc) + u_al
     if (nc <= 100) crit <- sqrt(qchisq(alpha0,1,nc))
     indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
     empt[x+1] <- empt[x+1] + indr[x+1,y+1]
    }
indr[x+1,n+1] <- 0
for (x in 1:(m-1))
   { empt[x+1] <- 0
     for (y in 0:n)
        { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
          nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
          if (nc > 100) crit <- sqrt(nc) + u_al
          if (nc <= 100) crit <- sqrt(qchisq(alpha0,1,nc))
          indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
          empt[x+1] <- empt[x+1] + indr[x+1,y+1] 
         }
     } 

x <- m

empt[x+1] <- 0
indr[x+1,0+1] <- 0
for (y in 1:(n-1))
   { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     if (nc > 100) crit <- sqrt(nc) + u_al
     if (nc <= 100) crit <- sqrt(qchisq(alpha0,1,nc))
     indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
     empt[x+1] <- empt[x+1] + indr[x+1,y+1]
    }
indr[x+1,n+1] <- 0

for (x in 0:m)
   {
    INDI0 <- 0
    if (empt[x+1] == 0)
      { kl[x+1] <- n
        ku[x+1] <- 0
      }                    else
      { kl[x+1] <- 0
        y <- 0
        while (indr[x+1,y+1] == 0)
            { y <- y + 1 }
        kl[x+1] <- y
        ku[x+1] <- kl[x+1] - 1
        for (y in kl[x+1]:n)
           { if (indr[x+1,y+1] == 0)
               { INDI0 <- 1
                 break
               }
           }

       if (INDI0 == 1)                                   
           ku[x+1] <- y-1    else
           ku[x+1] <- y                                 
       if (INDI0 == 1)
        { for (y in (ku[x+1]+1):n)
           { if (indr[x+1,y+1] == 1)
             { WAR <- 1
               cat("ERROR = !!!!!"," x = ",x," y = ",y)
               break 
             }
           }
        }  
      }
     if (WAR == 1)                         
       { error <- "!!!!!!"
         break
       }
    }

if (WAR == 0)                               
  { rej_ <- 0
    for (x in 0:m)
      {
        if (kl[x+1] <= ku[x+1])
          {
            if (kl[x+1] > 0)
               rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2) else              
               rej_x <- pbinom(ku[x+1],n,p2)
           } else
        rej_x <- 0
        problex <- pbinom(x,m,p1)
        if (x > 0)
           probltx <- pbinom(x-1,m,p1) else                                             
           probltx <- 0
        probx <- problex - probltx
        rej_ <- rej_ + rej_x * probx
      } 
    powex <- rej_
  }
        
cat(" ALPHA0 =",alpha0,"  M =",m,"  N =",n,"  DEL1 =",del1,"  DEL2 =",del2,
    "  P1 =",p1,"  P2 =",p2,"  POWEX =",powex,"  ERROR =",error)          

        
