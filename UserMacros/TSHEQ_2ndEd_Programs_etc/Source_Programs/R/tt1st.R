alpha <- 0.05
tol <- 1.0e-10
itmax <- 50
n <- 36
theta1 <- -0.4716
theta2 <- 0.3853

ny <- n-1
del1 <- theta1*sqrt(n)
del2 <- theta2*sqrt(n)
err1 <- -alpha
c1 <- (del1+del2)/2

err2 <- NA

S8 <- 0

while (err1 < 0)
     { c1 <- c1-0.5
       areac1_2 <- pt(c1,ny,del2)
       if (is.na(areac1_2)) 
         { S8 <- 1
           break }
       h <- alpha + areac1_2
       c2 <- qt(h,ny,del2)
       err1 <- pt(c2,ny,del1) - pt(c1,ny,del1) - alpha
     }

if (S8 == 0)
  { c1l <- c1
    c1r <- c1 + 0.5
    it <- 0
    while (abs(err1) >= tol && it <= itmax)
         { it <- it + 1
           c1 <- (c1l+c1r) / 2
           h <- alpha + pt(c1,ny,del2)
           c2 <- qt(h,ny,del2)
           err1 <- pt(c2,ny,del1) - pt(c1,ny,del1) - alpha
           if (err1 <= 0)
              c1r <- c1   else
              c1l <- c1
          }
    }

if (S8 == 1)
  { c2 <- qt(alpha,ny,del2)
    c1 <- qt(1-alpha,ny,del1)
    areac1_1 <- pt(c1,ny,del1)
    areac2_1 <- pt(c2,ny,del1)
    if (is.na(areac2_1)) areac2_1 <- 1
    err1 <- areac2_1 - areac1_1 - alpha
    areac1_2 <- pt(c1,ny,del2)
    areac2_2 <- pt(c2,ny,del2)
    if (is.na(areac1_2)) areac1_2 <- 0
    err2 <- areac2_2 - areac1_2 - alpha
  }

pow0 <- pt(c2,ny) - pt(c1,ny)

cat(" ALPHA =",alpha,"  N =",n,"  THETA1 =",theta1,"  THETA2 =",theta2,
    "  IT =",it,"  C1 =",c1,"  C2 =",c2,"  ERR1 =",err1,"  ERR2 =",err2,
    "  POW0 =",pow0)
