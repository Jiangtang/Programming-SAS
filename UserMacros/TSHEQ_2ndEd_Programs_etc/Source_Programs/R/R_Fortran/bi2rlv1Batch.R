workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

m <- "345"               
n <- "231"               
rho1 <- ".6667"          
rho2 <- "1.5"            
alpha <- "0.05"          
p1 <- "0.0841"           
p2 <- "0.2294"             

###################################################

setwd(workdir)
out <- c(m,n,rho1,rho2,alpha,p1,p2)
write(out,file="rlv1_inp",ncolumns=1)
system("R CMD BATCH bi2rlv1.R bi2rlv1.log")
file.show("rlv1_inp")
file.show("rlv1_out")
file.remove("rlv1dummy.out")
