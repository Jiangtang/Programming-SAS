alpha <- 0.05
tol <- 1.0e-10
itmax <- 100
n <- 80
eps <- 0.3

ny <- 2*n
err1 <- -alpha
c1 <- 1.0

while (err1 < 0)
 {  c1 <- c1 -0.05
    h <- alpha + pchisq(ny*c1/(1+eps),ny)
    c2 <- qchisq(h,ny) * (1+eps)/ny
    err1 <- pchisq(ny*(1+eps)*c2,ny) - pchisq(ny*(1+eps)*c1,ny) - alpha
  }

c1L <- c1
c1R <- c1 + 0.05
it <- 0

while (abs(err1) >= tol && it <= itmax)
 {  it <- it + 1
    c1 <- (c1L+c1R) / 2
    h <- alpha + pchisq(ny*c1/(1+eps),ny)
    c2 <- qchisq(h,ny) * (1+eps)/ny
    err1 <- pchisq(ny*(1+eps)*c2,ny) - pchisq(ny*(1+eps)*c1,ny) - alpha
    if (err1 <= 0) 
       c1R <- c1   else
                   c1L <- c1
  }

pow0 <- pchisq(ny*c2,ny) - pchisq(ny*c1,ny)
c1 <- n*c1
c2 <- n*c2

cat(" ALPHA =",alpha,"   TOL =",tol,"   ITMAX =",itmax,"   N =",n,"   EPS =",eps,
 "   IT =",it,"\n","C1 =",c1,"   C2 =",c2,"   ERR1 =",err1,"   POW0 =",pow0)
      
