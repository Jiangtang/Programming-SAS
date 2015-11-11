alpha <- 0.05
m <- 50
n <- 50
del1 <- 0.40
del2 <- 0.40
sw <- 0.001
tolrd <- 0.000001
tol <- 0.0001
maxh <- 10

itmaxl <- ceiling((1-del2)/sw-1)
itmaxr <- ceiling((1-del1)/sw-1)
itmxl2pl <- itmaxl+2
itmxr2pl <- itmaxr+2

empt <- rep(NA,m+1)
kl <- rep(NA,m+1)
ku <- rep(NA,m+1)
klpr <- rep(NA,m+1)
kupr <- rep(NA,m+1)
p1rdl <- rep(NA,2)
p1rdr <- rep(NA,2)
p1l <- rep(NA,itmxl2pl)
p1r <- rep(NA,itmxr2pl)
indr <- matrix(rep(NA,((m+1)*(n+1))),nrow=m+1)

error <- "none"
WAR <- 0
indcs <- 0

p1rdl[1] <- del2+tolrd
p1rdl[2] <- 1-tolrd
p1rdr[1] <- tolrd
p1rdr[2] <- 1-del1-tolrd

u_al <- qnorm(alpha)

x <- 0
empt[x+1] <- 0
indr[x+1,0+1] <- 0
for (y in 1:(n-1))
   { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
     if (nc > 100) crit <- sqrt(nc)+u_al
     if (nc <= 100) crit <- sqrt(qchisq(alpha,1,nc))
     indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
     empt[x+1] <- empt[x+1] + indr[x+1,y+1]              
   }
indr[x+1,n+1] <- 0

for (x in 1:(m-1))
   { empt[x+1] <- 0
     for (y in 0:n)
        { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
          nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
          if (nc > 100) crit <- sqrt(nc)+u_al
          if (nc <= 100) crit <- sqrt(qchisq(alpha,1,nc))
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
     if (nc > 100) crit <- sqrt(nc)+u_al
     if (nc <= 100) crit <- sqrt(qchisq(alpha,1,nc))
     indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
     empt[x+1] <- empt[x+1] + indr[x+1,y+1]
   }
indr[x+1,n+1] <- 0

for (x in 0:m)
   { if (empt[x+1] == 0)
       { kl[x+1] <- n
         ku[x+1] <- 0
       }                   else
       { IND0 <- 0
         kl[x+1] <- 0
         y <- 0
         while (indr[x+1,y+1] == 0)  y <- y+1
         kl[x+1] <- y
         ku[x+1] <- kl[x+1] - 1
         for (y in kl[x+1]:n)
           {  
             if (indr[x+1,y+1] == 0) 
               { IND0 <- 1
                 break
               }
           }

         if (IND0 == 1)
        { ku[x+1] <- y-1
          for (y in (ku[x+1]+1):n)
            if (indr[x+1,y+1] == 1)
              { WAR <- 1
                cat("error1")
                break
              }
        }                               else
            ku[x+1] <- y
         if (WAR == 1) break                   
       }
    }

 
if (WAR == 0)                                 
  {
   size <- 0
   p1 <- del2
   while (p1 <= (1-sw))
        { p1 <- p1 + sw
          p2 <- -del2 + p1
          rej_ <- 0
          for (x in 0:m)
             { if (kl[x+1] > ku[x+1]) 
                   rej_x <- 0         else
                 { if (kl[x+1] > 0)
                       rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                       rej_x <- pbinom(ku[x+1],n,p2)
                 }
               problex <- pbinom(x,m,p1)
               if (x > 0)
                   probltx <- pbinom(x-1,m,p1)       else
                   probltx <- 0
               probx <- problex-probltx
               rej_ <- rej_ + rej_x*probx
             }
          size <- max(size,rej_)
        }

for (j in 1:2)
   { p1 <- p1rdl[j]
     p2 <- -del2+p1
     rej_ <- 0
     for (x in 0:m)
        { if (kl[x+1] > ku[x+1])
              rej_x <- 0          else
            { if (kl[x+1] > 0)
              rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else    
              rej_x <- pbinom(ku[x+1],n,p2)
            }
          problex <- pbinom(x,m,p1)
          if (x > 0) 
              probltx <- pbinom(x-1,m,p1)       else
              probltx <- 0
          probx <- problex-probltx
          rej_ <- rej_ + rej_x*probx
        }
      size <- max(size,rej_)
    }

p1 <- 1-del1
while (p1 >= sw)
     { p1 <- p1-sw
       p2 <- del1+p1
       rej_ <- 0
       for (x in 0:m)
          { if (kl[x+1] > ku[x+1])
             rej_x <- 0          else
            { if (kl[x+1] > 0)
              rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else    
              rej_x <- pbinom(ku[x+1],n,p2)
            }       
          problex <- pbinom(x,m,p1)
          if (x > 0) 
              probltx <- pbinom(x-1,m,p1)       else
              probltx <- 0
          probx <- problex-probltx
          rej_ <- rej_ + rej_x*probx
        }
      size <- max(size,rej_)
    }

for (j in 1:2)
   { p1 <- p1rdr[j]
     p2 <- del1+p1
     rej_ <- 0
     for (x in 0:m)
        { if (kl[x+1] > ku[x+1])
              rej_x <- 0          else
            { if (kl[x+1] > 0)
              rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else    
              rej_x <- pbinom(ku[x+1],n,p2)
            }
          problex <- pbinom(x,m,p1)
          if (x > 0) 
              probltx <- pbinom(x-1,m,p1)       else
              probltx <- 0
          probx <- problex-probltx
          rej_ <- rej_ + rej_x*probx
        }
      size <- max(size,rej_)
    }

if (size > alpha)
  {                                             
    alpha1 <- 0
    size1 <- 0
    alpha2 <- alpha
    nh <- 0

    repeat
   {                                             
    ABR <- 0
    CS1 <- 0
    CS2 <- 0
    alpha0 <- (alpha1+alpha2)/2
    nh <- nh+1

    for (x in 0:m)
       { klpr[x+1] <- kl[x+1]
         kupr[x+1] <- ku[x+1]
       }
    u_al0 <- qnorm(alpha0)
    inddis <- 0

    x <- 0
    empt[x+1] <- 0
    indr[x+1,0+1] <- 0
    for (y in 1:(n-1))
       { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
         nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
         if (nc > 100) crit <- sqrt(nc) + u_al0
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
              if (nc > 100) crit <- sqrt(nc) + u_al0
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
         if (nc > 100) crit <- sqrt(nc) + u_al0
         if (nc <= 100) crit <- sqrt(qchisq(alpha0,1,nc))
         indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
         empt[x+1] <- empt[x+1] + indr[x+1,y+1]  
       }
    indr[x+1,n+1] <- 0

    for (x in 0:m)
       { if (empt[x+1] == 0)
           { kl[x+1] <- n
             ku[x+1] <- 0
             inddis <- inddis + sign(abs(ku[x+1] - kupr[x+1]))
           }                                                       else
           { IND0 <- 0
             kl[x+1] <- 0
             y <- 0
             while (indr[x+1,y+1] == 0) y <- y+1
             kl[x+1] <- y
             inddis <- inddis + sign(abs(kl[x+1] - klpr[x+1]))
             ku[x+1] <- kl[x+1]-1
             for (y in kl[x+1]:n)
                 if (indr[x+1,y+1] == 0)
                   { IND0 <- 1
                     break 
                   }

             if (IND0 == 1) 
             { ku[x+1] <- y-1
               inddis <- inddis + sign(abs(ku[x+1] - kupr[x+1]))                 
               for (y in (ku[x+1]+1):n)
                   if (indr[x+1,y+1] == 1)
                      { WAR <- 1
                        cat("error2")
                        break
                      }
                  
              }                                else
                ku[x+1] <- y

              if (WAR == 1) break
            }

        }
     if (WAR == 1) break                                             

        if (nh == 5) inddis <- 4
 
        if (inddis == 0 && nh == maxh) 
          { ABR <- 1
            break    }
        if (inddis == 0 && indcs == 1) CS1 <- 1
        if (inddis == 0 && indcs == 2) CS2 <- 1

        if (ABR == 0 && CS1 == 0 && CS2 == 0)
          {                                                        
            size <- 0
            p1 <- del2
            while (p1 <= (1-sw))
                 { p1 <- p1 + sw
                   p2 <- -del2 + p1
                   rej_ <- 0
                   for (x in 0:m)
                      { if (kl[x+1] > ku[x+1]) 
                        rej_x <- 0         else
                        { if (kl[x+1] > 0)
                              rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                              rej_x <- pbinom(ku[x+1],n,p2)
                        }
                        problex <- pbinom(x,m,p1)
                        if (x > 0)
                            probltx <- pbinom(x-1,m,p1)       else
                            probltx <- 0
                        probx <- problex-probltx
                        rej_ <- rej_ + rej_x*probx
                      }
                      size <- max(size,rej_)
                  }

             for (j in 1:2)
                { p1 <- p1rdl[j]
                  p2 <- -del2 + p1
                  rej_ <- 0
                  for (x in 0:m)
                     { if (kl[x+1] > ku[x+1]) 
                       rej_x <- 0         else
                       { if (kl[x+1] > 0)
                             rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                             rej_x <- pbinom(ku[x+1],n,p2)
                       }
                       problex <- pbinom(x,m,p1)
                       if (x > 0)
                           probltx <- pbinom(x-1,m,p1)       else
                           probltx <- 0
                       probx <- problex-probltx
                       rej_ <- rej_ + rej_x*probx
                     }
                     size <- max(size,rej_)
                 }

            p1 <- 1-del1
            while (p1 >= sw)
                 { p1 <- p1-sw
                   p2 <- del1+p1
                   rej_ <- 0
                   for (x in 0:m)
                      { if (kl[x+1] > ku[x+1]) 
                        rej_x <- 0         else
                        { if (kl[x+1] > 0)
                              rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                              rej_x <- pbinom(ku[x+1],n,p2)
                        }
                        problex <- pbinom(x,m,p1)
                        if (x > 0)
                            probltx <- pbinom(x-1,m,p1)       else
                            probltx <- 0
                        probx <- problex-probltx
                        rej_ <- rej_ + rej_x*probx
                      }
                      size <- max(size,rej_)
                    }

             for (j in 1:2)
                { p1 <- p1rdr[j]
                  p2 <- del1+p1
                  rej_ <- 0                   
                  for (x in 0:m)
                     { if (kl[x+1] > ku[x+1]) 
                       rej_x <- 0         else
                       { if (kl[x+1] > 0)
                             rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                             rej_x <- pbinom(ku[x+1],n,p2)
                       }
                       problex <- pbinom(x,m,p1)
                       if (x > 0)
                           probltx <- pbinom(x-1,m,p1)       else
                           probltx <- 0
                       probx <- problex-probltx
                       rej_ <- rej_ + rej_x*probx
                     }
                     size <- max(size,rej_)
                  }

              if (size >= (alpha-tol) && size <= alpha)           
                { size0 <- size
                  break          }                                
              if (size > alpha && nh < maxh)                      
                 CS1 <- 1
                        
              if (size < (alpha-tol) && nh < maxh)                
                 CS2 <- 1
                             
              if (nh == maxh)                                     
                { ABR <- 1
                  break     }

          }                    
              if (CS1 == 1)
                { alpha2 <- alpha0
                  indcs <- 1
                }
              if (CS2 == 1)
                { alpha1 <- alpha0
                  size1 <- size
                  indcs <- 2
                }
        }                
    }                
 }             


if (WAR == 0)
  {                                                             
    if (ABR == 1) 
      { alpha0 <- alpha1
        size0 <- size1   }

    u_al0 <- qnorm(alpha0)                                     
    x <- 0
    empt[x+1] <- 0
    indr[x+1,y+1] <- 0
    for (y in 1:(n-1))
       { t <- abs(x/m - y/n - (del2-del1)/2) / sqrt((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
         nc <- ((del1+del2)/2)**2 / ((1/m)*(x/m)*(1-x/m) + (1/n)*(y/n)*(1-y/n))
         if (nc > 100) crit <- sqrt(nc)+u_al0
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
              if (nc > 100) crit <- sqrt(nc)+u_al0
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
         if (nc > 100) crit <- sqrt(nc)+u_al0
         if (nc <= 100) crit <- sqrt(qchisq(alpha0,1,nc))
         indr[x+1,y+1] <- trunc(0.5*(1+sign(crit-t)))
         empt[x+1] <- empt[x+1] + indr[x+1,y+1]              
       }
    indr[x+1,n+1] <- 0

    for (x in 0:m)
       { if (empt[x+1] == 0)
           { kl[x+1] <- n
             ku[x+1] <- 0
             inddis <- inddis + sign(abs(ku[x+1]-kupr[x+1]))        
           }                                                        else
           { IND0 <- 0
             kl[x+1] <- 0
             y <- 0
             while (indr[x+1,y+1] == 0)  y <- y+1
             kl[x+1] <- y
             ku[x+1] <- kl[x+1] - 1
             for (y in kl[x+1]:n)
                 if (indr[x+1,y+1] == 0)
                   { IND0 <- 1
                     break
                   }
             if (IND0 == 1)
             { ku[x+1] <- y-1
               for (y in (ku[x+1]+1):n)
                  if (indr[x+1,y+1] == 1)
                    { WAR <- 1
                      cat("error3")
                      break  }
             }                              else
               ku[x+1] <- y

           if (WAR == 1)      break
          }
       }
  }                                                            

if (WAR == 0)
  {                                                             
    p1l[1] <- del2 + tolrd
    for (j in 2:(itmaxl+1))
         p1l[j] <- del2 + sw*(j-1)
    p1l[itmxl2pl] <- 1-tolrd
    p1r[1] <- tolrd
    for (j in 2:(itmaxr+1))
         p1r[j] <- sw*(j-1)
    p1r[itmxr2pl] <- 1-del1-tolrd 

    size_ <- 0
    for (j in 1:itmxl2pl)
       { p1 <- p1l[j]
         p2 <- -del2+p1
         while (p2 > tolrd)
              { rej_ <- 0
                for (x in 0:m)
                   { if (kl[x+1] > ku[x+1]) 
                     rej_x <- 0         else
                     { if (kl[x+1] > 0)
                           rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                           rej_x <- pbinom(ku[x+1],n,p2)
                     }
                     problex <- pbinom(x,m,p1)
                     if (x > 0)
                         probltx <- pbinom(x-1,m,p1)       else
                         probltx <- 0
                     probx <- problex-probltx
                     rej_ <- rej_ + rej_x*probx
                   }
                size_ <- max(size_,rej_)
                p2 <- p2-sw                
              }
         p2 <- tolrd
         rej_ <- 0
         for (x in 0:m)
            { if (kl[x+1] > ku[x+1]) 
              rej_x <- 0         else
              { if (kl[x+1] > 0)
                    rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                    rej_x <- pbinom(ku[x+1],n,p2)
              }
              problex <- pbinom(x,m,p1)
              if (x > 0)
                  probltx <- pbinom(x-1,m,p1)       else
                  probltx <- 0
              probx <- problex-probltx
              rej_ <- rej_ + rej_x*probx
            }
         size_ <- max(size_,rej_)
       }

    for (j in 1:itmxr2pl)
       { p1 <- p1r[j]
         p2 <- del1 + p1
         while (p2 < 1-tolrd)
              { rej_ <- 0
                for (x in 0:m)
                   { if (kl[x+1] > ku[x+1]) 
                     rej_x <- 0         else
                     { if (kl[x+1] > 0)
                           rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                           rej_x <- pbinom(ku[x+1],n,p2)
                     }
                     problex <- pbinom(x,m,p1)
                     if (x > 0)
                         probltx <- pbinom(x-1,m,p1)       else
                         probltx <- 0
                     probx <- problex-probltx
                     rej_ <- rej_ + rej_x*probx
                   }
                size_ <- max(size_,rej_)
                p2 <- p2 + sw                
              }

         p2 <- 1-tolrd
         rej_ <- 0
         for (x in 0:m)
            { if (kl[x+1] > ku[x+1]) 
              rej_x <- 0         else
              { if (kl[x+1] > 0)
                    rej_x <- pbinom(ku[x+1],n,p2) - pbinom(kl[x+1]-1,n,p2)    else
                    rej_x <- pbinom(ku[x+1],n,p2)
              }
              problex <- pbinom(x,m,p1)
              if (x > 0)
                  probltx <- pbinom(x-1,m,p1)       else
                  probltx <- 0
              probx <- problex-probltx
              rej_ <- rej_ + rej_x*probx
            }
         size_ <- max(size_,rej_)
       }                

if (size_ > size0+tolrd) WAR <- 1 

  }                                                            

if (WAR == 1)
    error = "!!!!!"

cat(" ALPHA =",alpha,"  M =",m,"  N =",n,"  DEL1 =",del1,"  DEL2 =",del2,
    "  SW =",sw,"  TOLRD =",tolrd,"  TOL =",tol,"  MAXH =",maxh,"  NH =",nh,
    "  ALPHA0 =",alpha0,"  SIZE0 =",size0,"  ERROR =",error)                    

                                 
